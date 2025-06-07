select
    delivery_zone,
    count(order_id) as total_requests,
    sum(is_completed) as completed_requests,
    round(avg(delivery_duration_mins), 2) as avg_delivery_time_mins,
    count(distinct driver_id) as unique_drivers
from {{ ref('model_int_order_delivery_summary') }}
group by delivery_zone