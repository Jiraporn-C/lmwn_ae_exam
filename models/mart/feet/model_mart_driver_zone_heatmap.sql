{{ config(materialized='table') }}

with failed_requests_unavailable_driver as (
    select  
        delivery_zone,
        count(*) as total_cancel_or_failed_requests
    from {{ ref('model_stg_order_transactions') }} ot
    left join {{ ref('model_stg_drivers_master') }} dm 
      on ot.driver_id = dm.driver_id
    where ot.order_status in ('cancelled', 'failed')
      and (ot.driver_id is null or dm.active_status = 'inactive')
    group by delivery_zone
),

aggregates as (
    select
        ods.delivery_zone,
        count(ods.order_id) as total_requests,
        sum(ods.is_completed) as completed_requests,
        round(avg(ods.delivery_duration_mins), 2) as avg_delivery_time_mins,
        dsd.available_drivers,
        coalesce(rud.total_cancel_or_failed_requests, 0) as failed_requests
    from {{ ref('model_int_order_delivery_summary') }} ods
    left join (
        select region as delivery_zone, count(driver_id) as available_drivers
        from {{ ref('model_int_driver_profile_active') }}
        group by region
    ) dsd on ods.delivery_zone = dsd.delivery_zone
    left join failed_requests_unavailable_driver rud  
      on ods.delivery_zone = rud.delivery_zone
    group by 
        ods.delivery_zone,
        dsd.available_drivers,
        rud.total_cancel_or_failed_requests
)

select 
    delivery_zone,
    total_requests,
    completed_requests,
    failed_requests,
    avg_delivery_time_mins,
    available_drivers,
    case 
        when total_requests > 0 
        then round((completed_requests::numeric / total_requests) * 100, 2) 
        else 0 
    end as completion_rate,
    case 
        when available_drivers > 0 
        then round((total_requests::numeric / available_drivers) * 100, 2) 
        else 0 
    end as demand_supply_rate
from aggregates
