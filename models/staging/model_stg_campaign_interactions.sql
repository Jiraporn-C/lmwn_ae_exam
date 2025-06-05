with source_data as (
    select *
    from {{ source('main', 'campaign_interactions') }}
)

select *
from source_data

