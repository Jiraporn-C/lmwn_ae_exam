{{ config(materialized='table') }}

select *
from {{ ref('model_mart_restaurant_quality_complaint') }}
order by restaurant_id asc