
select
  ticket_id,
  customer_id,
  driver_id,
  restaurant_id,
  issue_type,
  issue_sub_type,
  opened_datetime,
  resolved_datetime,
  extract(epoch from resolved_datetime - opened_datetime) / 60.0 as resolution_duration_mins,
  case when status = 'resolved' then 1 else 0 end as is_resolved,
  status,
  compensation_amount,
  csat_score
from {{ ref('model_stg_support_tickets') }}



 