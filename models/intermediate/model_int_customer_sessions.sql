with base_sessions as (
    select
        session_id,
        customer_id,
        session_start,
        session_end,
        device_type
    from {{ ref('model_stg_order_log_incentive_sessions_customer_app_sessions') }}
),

interactions as (
    select
        'SESS'||right(session_id,6) as session_id,
        interaction_datetime,
        campaign_id,
        event_type,
        ad_cost
    from {{ ref('model_stg_campaign_interactions') }}
),

orders as (
    select
        order_id,
        customer_id,
        order_datetime,
        total_amount,
        order_status
    from {{ ref('model_stg_order_transactions') }}
)

select
    s.session_id,
    s.customer_id,
    s.session_start,
    s.session_end,
 --   s.platform,
    s.device_type,
    i.campaign_id,
    i.event_type,
    i.ad_cost,
    i.interaction_datetime,
    o.order_id,
    o.order_datetime,
    o.total_amount,
    o.order_status,
    -- คำนวณเวลาจาก session start → interaction / order
    datediff('minute', s.session_start, i.interaction_datetime) as time_to_click_min,
    datediff('minute', s.session_start, o.order_datetime) as time_to_order_min

from base_sessions s
left join interactions i
    on s.session_id = i.session_id
left join orders o
    on s.customer_id = o.customer_id
    and o.order_datetime between s.session_start and s.session_end
