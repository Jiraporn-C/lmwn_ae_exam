with interaction_base as (
    select
        i.interaction_id,
        i.customer_id,
        i.campaign_id,
        i.interaction_datetime,
        i.event_type,
        i.platform,
        i.device_type,
        i.ad_cost,
        i.order_id,
        i.session_id,
        i.is_new_customer,
        i.revenue,
        c.campaign_name,
        c.channel,
        c.cost_model,
        c.start_date as campaign_start,
        c.end_date as campaign_end,
        c.targeting_strategy

    from {{ ref('model_stg_campaign_interactions') }} i
    left join {{ ref('model_stg_campaign_master') }} c
        on i.campaign_id = c.campaign_id
),

enriched_with_orders as (
    select
        ib.*,
        o.order_datetime,
        o.total_amount,
        o.payment_method,
        o.order_status
    from interaction_base ib
    left join {{ ref('model_stg_order_transactions') }} o
        on ib.order_id = o.order_id
),

final as (
    select
        e.*,
        cust.signup_date,
        cust.customer_segment,
        cust.referral_source
    from enriched_with_orders e
    left join {{ ref('model_stg_customers_master') }} cust
        on e.customer_id = cust.customer_id
)

select * from final
