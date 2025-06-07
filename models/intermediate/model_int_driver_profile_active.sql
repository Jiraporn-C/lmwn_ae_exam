select
    driver_id,
    vehicle_type,
    region,
    active_status,
    driver_rating,
    bonus_tier
from {{ ref('model_stg_drivers_master') }}
where active_status = 'active'
