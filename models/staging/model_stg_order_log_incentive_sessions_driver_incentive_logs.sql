with source_data as (
    select *
    from {{ source('main', 'order_log_incentive_sessions_driver_incentive_logs') }}
)

select *
from source_data

