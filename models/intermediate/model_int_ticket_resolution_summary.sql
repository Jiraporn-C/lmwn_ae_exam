
select
  ticket_id,
  issue_type,
  opened_datetime,
  resolved_datetime,
  extract(epoch from resolved_datetime - opened_datetime) / 60.0 as resolution_duration_mins,
  case when status = 'resolved' then 1 else 0 end as is_resolved,
  status,
  compensation_amount,
from {{ ref('model_stg_support_tickets') }}



 