{{ config(materialized='table') }}

with new_customer_orders as (
    select
        customer_id,
        campaign_id,
        campaign_name,
        channel,
        platform,
        min(date(order_datetime)) as acquisition_date,
        min(order_datetime) as first_purchase_datetime,
        count(order_id) as total_orders,
        sum(total_amount) as total_revenue,
        round(avg(total_amount), 2) as avg_order_value,
        sum(ad_cost) as total_ad_cost
    from {{ ref('model_int_campaign_customer_orders') }}
    where is_new_customer = true and order_status = 'completed'
    group by customer_id, campaign_id, campaign_name, channel, platform
),

first_interaction as (
    select
        customer_id,
        campaign_id,
        campaign_name,
        channel,
        platform,
        min(interaction_datetime) as first_interaction_datetime
    from {{ ref('model_int_campaign_customer_orders') }}
    where is_new_customer = true
    group by customer_id, campaign_id, campaign_name, channel, platform
),

order_log_sessions_customer_app as (
    select * 
    from {{ ref('model_stg_order_log_incentive_sessions_customer_app_sessions') }}
),

customer_activitytime as (
    select
        nco.campaign_id,
        nco.customer_id,
        nco.campaign_name,
        nco.channel,
        nco.platform,
        nco.first_purchase_datetime,
        greatest(
            max(ot.order_datetime),
            (select max(session_start) 
             from order_log_sessions_customer_app 
             where customer_id = nco.customer_id)
        ) as last_activity_datetime
    from new_customer_orders nco
    join {{ ref('model_stg_order_transactions') }} ot 
      on nco.customer_id = ot.customer_id
    where ot.order_status = 'completed'
    group by nco.campaign_id, nco.campaign_name, nco.customer_id, nco.first_purchase_datetime, nco.channel, nco.platform
)

select
    nco.acquisition_date,
    nco.campaign_id,
    nco.campaign_name,
    count(*) as new_customers,
    round(avg(nco.avg_order_value), 2) as avg_purchase_value,
    MAX(nco.total_orders) - 1 as repeat_orders,

    round(
    avg(extract(epoch from (ca.last_activity_datetime - nco.first_purchase_datetime)) / (60*60*24)) 
     ,2)  as avg_days_active_after_purchase,

    round(avg(
        case 
            when nco.first_purchase_datetime >= fi.first_interaction_datetime then
                extract(epoch from (nco.first_purchase_datetime - fi.first_interaction_datetime)) / (60*60*24)
            else null
        end
    ),2) as avg_days_to_first_purchase,

    round(sum(nco.total_revenue),2) as revenue,
    round(sum(nco.total_ad_cost) / nullif(count(*), 0), 2) as cac,
    round(sum(nco.total_revenue) / nullif(sum(nco.total_ad_cost), 0), 2) as roas,
    nco.channel,
    nco.platform
from new_customer_orders as nco
inner join first_interaction fi
  on nco.campaign_id = fi.campaign_id and nco.customer_id = fi.customer_id
left join customer_activitytime ca
  on nco.campaign_id = ca.campaign_id and nco.customer_id = ca.customer_id
group by 
    nco.acquisition_date, 
    nco.campaign_id, 
    nco.campaign_name, 
    nco.channel, 
    nco.platform
