{{ config(materialized='table') }}

select *
from {{ ref('model_mart_driver_related_complaints') }}
order by driver_id asc