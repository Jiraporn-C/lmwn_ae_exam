{{ config(materialized='table') }}

select *
from {{ ref('model_mart_retargeting_performance') }}
order by campaign_id asc