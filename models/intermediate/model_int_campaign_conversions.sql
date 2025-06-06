with interactions as (
  select distinct
    interaction_datetime,
    campaign_id,
    customer_id,
    order_id,
    revenue
  from {{ ref('model_stg_campaign_interactions') }}
  where event_type = 'conversion'
),
orders as (
  select * from {{ ref('model_stg_order_transactions') }}
),
joined as (
  select distinct
    i.interaction_datetime,
    i.campaign_id,
    i.customer_id,
    i.order_id,
    i.revenue,
    o.order_datetime,
    o.total_amount
  from interactions i
  left join orders o on i.order_id = o.order_id
  where o.order_status = 'completed'
          
)

select * from joined