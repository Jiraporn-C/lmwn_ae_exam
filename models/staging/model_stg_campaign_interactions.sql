with raw_camp_data as (
    select *
    from {{ source('main', 'campaign_interactions') }}
)

select *
from raw_camp_data
where platform = 'google'
