{{ config(materialized='table') }}

select
    ods.driver_id,
    dp.vehicle_type,
    dp.region,
    sum(ods.delivery_target) as total_target,
    sum(ods.actual_deliveries) as total_actual_deliveries,   
    round(avg(ods.response_time_mins), 2) as avg_response_time_mins,
    round(avg(ods.delivery_time_mins), 2) as avg_delivery_time_mins,
    sum(ods.late_deliveries) as late_deliveries,
    round(avg(ods.csat_score),2) as avg_feedback_score,
    count(ods.ticket_id) as total_feedbacks
from {{ ref('model_int_order_delivery_summary') }} ods
left join {{ ref('model_int_driver_profile_active') }} dp on ods.driver_id = dp.driver_id
where ods.driver_id is not null
group by  
    ods.driver_id,
    dp.vehicle_type,
    dp.region,
    ods.csat_score,
    ods.ticket_id

