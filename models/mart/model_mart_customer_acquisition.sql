with new_customer_conversions as (
    -- 1. Identify New Customers who converted and had a completed order
    select
        ci.campaign_id,
        ci.customer_id,
        MIN(ot.order_datetime) as first_purchase_datetime,
        MAX(ci.ad_cost) as total_ad_cost_for_conversion 
    from
        {{ ref('model_stg_order_transactions') }} ci
    inner join
        {{ ref('model_stg_order_transactions') }} ot on ci.customer_id = ot.customer_id
    where
        ci.is_new_customer = TRUE
        and ci.event_type = 'conversion'
        and ot.order_status = 'completed'
    group by
        ci.campaign_id, ci.customer_id
),
customer_spending as (
    -- 2. Calculate spending behavior for these new customers
    select
        ncc.campaign_id,
        ncc.customer_id,
        SUM(ot.total_amount) as total_customer_spending,
        COUNT(ot.order_id) as total_orders,
        ROW_NUMBER() over (partition by ncc.customer_id order by ot.order_datetime asc) as order_rn
    from
        new_customer_conversions ncc
    inner join
        {{ ref('model_stg_order_transactions') }} ot on ncc.customer_id = ot.customer_id
    where
        ot.order_status = 'completed' -- Ensure all orders are completed
    group by
        ncc.campaign_id, ncc.customer_id, ot.order_id, ot.order_datetime 
),
aggregated_spending as (
    select
        campaign_id,
        customer_id,
        SUM(total_customer_spending) as total_spent,
        SUM(case when order_rn > 1 then 1 else 0 end) as num_repeat_orders,
        MAX(total_orders) as all_customer_orders_count 
    from
        customer_spending
    group by
        campaign_id, customer_id
),
order_log_sessions_customer_app as (
    select * from  {{ ref('model_stg_order_log_incentive_sessions_customer_app_sessions') }}
)

customer_activitytime as (
    -- 3. Calculate activity duration
    select
        ncc.campaign_id,
        ncc.customer_id,
        ncc.first_purchase_datetime,
        GREATEST(
            MAX(ot.order_datetime),
            (select MAX(session_start) from order_log_sessions_customer_app where customer_id = ncc.customer_id)
        ) AS last_activity_datetime
    from
        new_customer_conversions ncc
    join
        {{ ref('model_stg_order_transactions') }} ot on ncc.customer_id = ot.customer_id
    where
        ot.order_status = 'completed'
    group by
        ncc.campaign_id, ncc.customer_id, ncc.first_purchase_datetime
)
SELECT
    cm.campaign_name,
    cm.channel, 
    ci_base.platform, 
    COUNT(DISTINCT ncc.customer_id) as total_new_customer, -- (จากข้อ 1)
    COALESCE(AVG(asg.total_spent / asg.all_customer_orders_count), 0) as avg_purchase, -- (จากข้อ 2.1)
    SUM(asg.num_repeat_orders) as total_repeat_orders, -- (จากข้อ 2.2)    
    -- Avg. Days Active After First Purchase (จากข้อ 3)
    COALESCE(AVG(EXTRACT(EPOCH FROM (cat.last_activity_datetime - cat.first_purchase_datetime))) / (60*60*24), 0) AS "Avg. Days Active After First Purchase",

    -- Avg. Days to First Purchase (จากข้อ 4)
    COALESCE(AVG(EXTRACT(EPOCH FROM (ncc.first_purchase_datetime - ncc.first_interaction_datetime))) / (60*60*24), 0) AS "Avg. Days to First Purchase",

    -- Total Acquisition Cost (จากข้อ 5 - ใช้ ad_cost)
    SUM(ncc.total_ad_cost_for_conversion) AS "Total Acquisition Cost (THB)",
    -- Estimated CPA Per New Customer (จากข้อ 5 - ใช้ budget)
    CAST(MAX(cm.budget) AS DECIMAL) / NULLIF(COUNT(DISTINCT ncc.customer_id), 0) AS "Estimated CPA Per New Customer (THB)"

FROM
    new_customer_conversions ncc
LEFT JOIN -- Use LEFT JOIN to ensure all campaigns are included even if some metrics are null
    aggregated_spending asg ON ncc.campaign_id = asg.campaign_id AND ncc.customer_id = asg.customer_id
LEFT JOIN
    customer_activitytime cat ON ncc.campaign_id = cat.campaign_id AND ncc.customer_id = cat.customer_id
JOIN
    campaign_master cm ON ncc.campaign_id = cm.campaign_id
JOIN -- Joining back to campaign_interactions to get platform from the first interaction
    campaign_interactions ci_base ON ncc.customer_id = ci_base.customer_id AND ncc.first_interaction_datetime = ci_base.interaction_datetime
WHERE
    ci_base.is_new_customer = TRUE
    AND ci_base.event_type = 'conversion'
GROUP BY
    cm.campaign_name, cm.channel, ci_base.platform
ORDER BY
    "Total New Customers Converted & Completed Order" DESC;