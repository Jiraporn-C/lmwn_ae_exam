with summary as (
select
    ot.driver_id,
    ot.delivery_zone,
    sum(ld.bonus_amount) as total_bonus,
    sum(delivery_target) as total_target,
    sum(actual_deliveries) as total_actual_deliveries,
    count(ot.order_id) as total_tasks,
    count(case when (ot.order_status  = 'completed') then 1 end) as completed_tasks, ---ต้องใส้เพิ่มไหมนะ and issue_type = 'delivery' and issue_sub_type != 'not_delivered'
    avg(extract(epoch from ot.pickup_datetime - ot.order_datetime) / 60.0) as avg_response_time_mins,
    avg(extract(epoch from ot.delivery_datetime - ot.pickup_datetime) / 60.0) as avg_delivery_time_mins,
    count(case when ot.is_late_delivery = true then 1 end) as late_deliveries,
    avg(st.csat_score) as avg_feedback_score,
    count(st.ticket_id) as total_feedbacks
from {{ ref('model_stg_order_transactions') }} ot
left join {{ ref('model_stg_support_tickets') }} st   on ot.order_id = st.order_id
left join {{ ref('model_stg_order_log_incentive_sessions_driver_incentive_logs') }} ld  on ot.driver_id = ld.driver_id
group by ot.driver_id,ot.delivery_zone
)

select * from summary