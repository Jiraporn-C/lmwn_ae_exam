with source_data as (
    select *
    from {{ source('main', 'support_tickets') }}
)

select *
from source_data

