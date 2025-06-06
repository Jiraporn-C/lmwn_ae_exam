{{ config(materialized='table') }}

with retargeted_customers as (
    
    select
        customer_id,
        campaign_id,
        min(interaction_datetime) as first_retarget_datetime,
        sum(ad_cost) as total_ad_cost
    from {{ ref('model_int_campaign_customer_orders') }}
    where is_new_customer = false
    group by campaign_id, customer_id
),

returned_customers as (
   
    select
        rc.customer_id,
        rc.campaign_id,
        min(ot.order_datetime) as return_order_time,
        count(distinct ot.order_id) as orders_after_retarget,
        sum(ot.total_amount) as revenue_after_retarget
    from retargeted_customers rc
    join {{ ref('model_stg_order_transactions') }} ot
      on rc.customer_id = ot.customer_id
     and ot.order_datetime > rc.first_retarget_datetime
     and ot.order_status = 'completed'
    group by rc.customer_id, rc.campaign_id
),

original_orders as (
    
    select
        rc.customer_id,
        rc.campaign_id,
        max(ot.order_datetime) as original_order_time
    from retargeted_customers rc
    join {{ ref('model_stg_order_transactions') }} ot
      on rc.customer_id = ot.customer_id
     and ot.order_datetime < rc.first_retarget_datetime
     and ot.order_status = 'completed'
    group by rc.customer_id, rc.campaign_id
),

retention_customers as (
 
    select
        rc.customer_id,
        rc.campaign_id,
        count(distinct ot.order_id) as orders_created_after_return
    from retargeted_customers rc
    join returned_customers r
      on rc.customer_id = r.customer_id and rc.campaign_id = r.campaign_id
    join {{ ref('model_stg_order_transactions') }} ot
      on rc.customer_id = ot.customer_id
     and ot.order_datetime > r.return_order_time
    group by rc.customer_id, rc.campaign_id
),

campaign_info as (
   
    select
        campaign_id,
        campaign_type,
        targeting_strategy
    from {{ ref('model_stg_campaign_master') }}
)

select
    rc.campaign_id,
    ci.campaign_type,
    ci.targeting_strategy,
    count(distinct rc.customer_id) as targeted_customers,
    count(distinct r.customer_id) as returned_customers,
    round(1.0 * count(distinct r.customer_id) / count(distinct rc.customer_id), 2) as return_rate,
    round(sum(r.revenue_after_retarget), 2) as total_revenue_post_retarget,
    round(avg(datediff('day', o.original_order_time, r.return_order_time)), 1) as avg_days_between_orders,
    round(sum(coalesce(rt.orders_created_after_return, 0)), 0) as orders_created_after_return,
    round(sum(rc.total_ad_cost), 2) as total_ad_cost

from retargeted_customers rc
left join returned_customers r
  on rc.customer_id = r.customer_id and rc.campaign_id = r.campaign_id
left join original_orders o 
  on rc.customer_id = o.customer_id and rc.campaign_id = o.campaign_id
left join retention_customers rt
  on rc.customer_id = rt.customer_id and rc.campaign_id = rt.campaign_id
left join campaign_info ci
  on rc.campaign_id = ci.campaign_id
group by
    rc.campaign_id,
    ci.campaign_type,
    ci.targeting_strategy
