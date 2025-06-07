{{ config(materialized='table') }}

select
    ods.driver_id,
    dp.vehicle_type,
    dp.region,
    count(ods.order_id) as total_order,
    sum(ods.is_completed) as completed_order,
    round(avg(ods.response_time_mins), 2) as avg_response_time_mins,
    round(avg(ods.delivery_time_mins), 2) as avg_delivery_time_mins,
    sum(ods.late_deliveries) as late_deliveries,
    ods.issue_sub_type as feedback

from {{ ref('model_int_order_delivery_summary') }} ods
inner join {{ ref('model_int_driver_profile_active') }} dp on ods.driver_id = dp.driver_id
group by  
    ods.driver_id,
    dp.vehicle_type,
    dp.region,
    ods.issue_sub_type

