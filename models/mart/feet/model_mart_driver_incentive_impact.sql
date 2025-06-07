{{ config(materialized='table') }}


select
    ods.driver_id,
    ods.incentive_program,
    ods.applied_date,
    ods.region_log,
    count(ods.log_id) as total_sessions,
    sum(ods.actual_deliveries) as total_deliveries,
    sum(ods.bonus_qualified_sessions) as total_bonus_qualified_sessions,
    round(sum(case when ods.bonus_qualified = true then ods.bonus_amount else 0 end),2) as total_bonus_earned,
    round(avg(ods.csat_score), 2) as avg_feedback_score,
    round(avg(ods.delivery_duration_mins), 2) as avg_delivery_time_mins,
    round(avg(ods.response_time_mins), 2) as avg_response_time_mins
from {{ ref('model_int_order_delivery_summary') }} ods
where ods.is_completed = 1 and ods.incentive_program is not null
group by
    ods.driver_id,
    ods.incentive_program,
    ods.applied_date,
    ods.region_log
