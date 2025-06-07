{{ config(materialized='table') }}

select *
from {{ ref('model_mart_retargeting _performance') }}
order by campaign_id asc