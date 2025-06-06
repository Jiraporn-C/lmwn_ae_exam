{{ config(materialized='table') }}

select
    dts.driver_id,
    dm.vehicle_type,
    dts.delivery_zone,
    dts.total_target,
    dts.total_actual_deliveries,
    dts.total_tasks,
    dts.completed_tasks,
    round(dts.avg_response_time_mins, 2) as avg_response_time_mins,
    round(dts.avg_delivery_time_mins, 2) as avg_delivery_time_mins,
    dts.late_deliveries,
    dts.avg_feedback_score,
    dts.total_feedbacks
from {{ ref('model_int_driver_task_summary') }} dts
left join {{ ref('model_stg_drivers_master') }} dm on dts.driver_id = dm.driver_id

