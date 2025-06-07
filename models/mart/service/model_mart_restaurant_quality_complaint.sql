{{ config(materialized='table') }}

with order_data as (
  select restaurant_id, count(order_id) as total_orders
  from {{ ref('model_stg_order_transactions') }}
  where order_status = 'completed'
  group by restaurant_id
),

complaint_customers as (
  select
    st.customer_id,
    min(st.resolved_datetime) as first_complaint_resolved_at
  from {{ ref('model_stg_support_tickets') }} st
  where st.resolved_datetime is not null
  group by st.customer_id
),

returned_customers as (
  select
    cc.customer_id,
    count(distinct ot.order_id) as total_orders_after_complaint
  from complaint_customers cc
  join {{ ref('model_stg_order_transactions') }} ot
    on cc.customer_id = ot.customer_id
   and ot.order_datetime > cc.first_complaint_resolved_at
   and ot.order_status = 'completed'
  group by cc.customer_id
)

select
  rs.restaurant_id,
  rs.issue_sub_type,
  count(rs.ticket_id) as total_complaints,
  round(avg(rs.resolution_duration_mins), 2) as avg_resolution_time,
  sum(rs.compensation_amount) as total_compensation,
  o.total_orders,
  round(count(rs.ticket_id) * 1.0 / nullif(o.total_orders, 0), 2) as complaint_to_order_ratio,
  sum(coalesce(rc.total_orders_after_complaint, 0)) as total_orders_after_complaint
from {{ ref('model_int_ticket_resolution_summary') }} rs
left join order_data o on rs.restaurant_id = o.restaurant_id
left join returned_customers rc on rs.customer_id = rc.customer_id  
where rs.issue_type = 'food'
group by
  rs.restaurant_id,
  rs.issue_sub_type,
  o.total_orders
