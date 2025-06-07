with summary as (
    select
        ot.order_id,
        ot.driver_id,
        ot.delivery_zone,
        ot.order_datetime,
        ot.pickup_datetime,
        ot.delivery_datetime,
        ot.is_late_delivery,
        case when ot.order_status = 'completed' then 1 else 0 end as is_completed,
        case when ot.order_status != 'completed' then 1 else 0 end as is_failed,
        extract(epoch from ot.pickup_datetime - ot.order_datetime) / 60.0 as response_time_mins,
        extract(epoch from ot.delivery_datetime - ot.pickup_datetime) / 60.0 as delivery_time_mins,
        extract(epoch from ot.delivery_datetime - ot.order_datetime) / 60.0 as delivery_duration_mins,
        case when ot.is_late_delivery = true then 1 else 0 end as late_deliveries,
        st.csat_score,
        st.ticket_id,
        st.issue_sub_type,
        ld.bonus_amount,
        ld.delivery_target,
        ld.actual_deliveries,
        ld.incentive_program,
        ld.applied_date,
        ld.bonus_qualified,
        case when ld.bonus_qualified = true then 1 else 0 end as bonus_qualified_sessions,
        ld.region as region_log,
        ld.log_id

    from {{ ref('model_stg_order_transactions') }} ot
    left join {{ ref('model_stg_support_tickets') }} st
        on ot.order_id = st.order_id

    left join {{ ref('model_stg_order_log_incentive_sessions_driver_incentive_logs') }} ld
        on ot.driver_id = ld.driver_id
)

select * from summary
