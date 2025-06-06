with source_data as (
    select *
    from {{ source('main', 'order_log_incentive_sessions_customer_app_sessions') }}
)

select *
from source_data

