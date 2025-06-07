{{ config(materialized='table') }}


with order_data as (
  select driver_id, count(order_id) as total_orders
  from {{ ref('model_stg_order_transactions') }}
  where order_status = 'completed'
  group by driver_id
)

select
  rs.driver_id,
  rs.issue_sub_type,
  count(rs.ticket_id) as total_complaints,
  o.total_orders,
  round(avg(rs.resolution_duration_mins), 2) as avg_resolution_time,
  round(avg(case when rs.status = 'resolved' then rs.csat_score end), 2) as avg_csat_score,
  round(count(rs.ticket_id) * 1.0 / nullif(o.total_orders, 0), 2) as complaint_to_order_ratio,
  pf.driver_rating 
from {{ ref('model_int_ticket_resolution_summary') }} rs
left join order_data o on rs.driver_id = o.driver_id
left join {{ ref('model_int_driver_profile_active') }} pf on rs.driver_id = pf.driver_id
where rs.issue_type = 'rider'
group by rs.driver_id, rs.issue_sub_type, o.total_orders, pf.driver_rating


