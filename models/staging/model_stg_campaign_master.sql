with source_data as (
    select *
    from {{ source('main', 'campaign_master') }}
)

select *
from source_data

