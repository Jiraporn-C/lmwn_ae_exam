{{ config(materialized='table') }}

with impression as (
  select
    campaign_id,
    date(interaction_datetime) as date,
    count(*) as impressions
  from {{ ref('model_stg_campaign_interactions') }}
  where event_type = 'impression'
  group by campaign_id, date(interaction_datetime)
),
click as (
  select
    campaign_id,
    date(interaction_datetime) as date,
    count(*) as clicks
  from {{ ref('model_stg_campaign_interactions') }}
  where event_type = 'click'
  group by campaign_id, date(interaction_datetime)
),
conversions as (
  select
    campaign_id,
    date(interaction_datetime) as date,
    count(order_id) as conversions,
    sum(total_amount) as total_revenue
  from {{ ref('model_int_campaign_conversions') }}
  group by campaign_id, date(interaction_datetime)
),
costs as (
  select 
    campaign_id, 
    date(interaction_datetime) as date,
    sum(ad_cost) as total_cost
  from {{ ref('model_stg_campaign_interactions') }}
  group by campaign_id, date(interaction_datetime)
),
campaign_name as (
  select 
    campaign_id, 
    campaign_name
  from {{ ref('model_stg_campaign_master') }}
),
new_customers_converted as (
  select
    icc.campaign_id,
    date(icc.interaction_datetime) as date,
    count(icc.customer_id) as new_customers,
  from {{ ref('model_int_campaign_conversions') }} icc
  inner join {{ ref('model_stg_customers_master') }} scm  
  on icc.customer_id = scm.customer_id
  where scm.customer_segment = 'new'
  group by icc.campaign_id, date(icc.interaction_datetime)
),
final as (
  select
    cn.campaign_name,
    i.date,
    i.impressions,
    cl.clicks,
    cv.conversions,
    cv.total_revenue,
    co.total_cost,
    co.total_cost / ncc.new_customers as cac,
    ROUND((cv.total_revenue/co.total_cost)*100,2) as roas_percentage
  from impression i
  left join click cl on i.campaign_id = cl.campaign_id and i.date = cl.date
  left join conversions cv on i.campaign_id = cv.campaign_id and i.date = cv.date
  left join costs co on i.campaign_id = co.campaign_id and i.date = co.date
  left join campaign_name cn on i.campaign_id = cn.campaign_id
  left join new_customers_converted ncc on i.campaign_id = ncc.campaign_id and i.date = ncc.date
)
select * from final