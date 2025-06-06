with source_data as (
    select *
    from {{ source('main', 'drivers_master') }}
)

select *
from source_data

