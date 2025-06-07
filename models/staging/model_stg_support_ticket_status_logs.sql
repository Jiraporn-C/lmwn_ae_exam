with source_data as (
    select *
    from {{ source('main', 'support_ticket_status_logs') }}
)

select *
from source_data

