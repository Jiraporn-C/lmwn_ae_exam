with source_data as (
    select *
    from {{ source('main', 'order_transactions') }}
)

select *
from source_data

