{{ config(materialized='table') }}

with base as (
    select
        campaign_id,
        campaign_name,
        customer_id,
        event_type,
        interaction_datetime,
        ad_cost,
        order_id,
        order_status,
        revenue
    from {{ ref('model_int_campaign_customer_orders') }}
),

aggregated as (
    select
        campaign_id,
        campaign_name,
        date(interaction_datetime) as interaction_date,
        count(case when event_type = 'impression' then customer_id end) as impression,
        count(case when event_type = 'click' then customer_id end) as click,
        count(case when (event_type = 'conversion' and order_id is not null and order_status = 'completed') then customer_id end) as converted_customers,
        count(distinct(case when (order_id is not null and order_status = 'completed') then order_id end)) as total_orders,
        round(sum(ad_cost),2) as total_ad_cost,
        round(sum(revenue),2) as total_revenue,
        round(  case 
                    when sum(ad_cost) > 0 then sum(revenue) / sum(ad_cost)
                    else 0
                end,
            2)as roas,   
        round(  case 
                    when count(distinct (case when order_id is not null then customer_id END)) > 0
                        then sum(ad_cost) / count(distinct (case when order_id is not null then customer_id END))
                    else 0
                end
            ,2)as cpa
    from base
    group by campaign_id,campaign_name,interaction_date
)

select * from aggregated
