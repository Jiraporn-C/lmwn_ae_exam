with source_data as (
    select *
    from {{ source('main', 'customers_master') }}
)

select *
from source_data

