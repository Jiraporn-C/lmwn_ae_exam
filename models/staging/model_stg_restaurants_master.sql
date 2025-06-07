with source_data as (
    select *
    from {{ source('main', 'restaurants_master') }}
)

select *
from source_data

