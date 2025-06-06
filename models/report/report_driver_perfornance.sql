{{ config(materialized='table') }}

select *
from {{ ref('model_mart_driver_performance') }}
order by driver_id asc