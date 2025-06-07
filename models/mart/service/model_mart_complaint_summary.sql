{{ config(materialized='table') }}

select
  issue_type,
  date_trunc('day',opened_datetime) as complaint_date,
  count(distinct ticket_id) as total_complaints,
  sum(compensation_amount) as total_compensation,
  avg(resolution_duration_mins) as avg_resolution_time,
  sum(is_resolved) as total_resolved,
from {{ ref('model_int_ticket_resolution_summary') }}
group by 1, 2