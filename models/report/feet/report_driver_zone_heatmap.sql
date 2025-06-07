{{ config(materialized='table') }}

select *
from {{ ref('model_mart_driver_zone_heatmap') }}
order by delivery_zone asc