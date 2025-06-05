{{ config(materialized='table') }}

select *
from {{ ref('model_mart_campaign_performance') }}
order by date asc