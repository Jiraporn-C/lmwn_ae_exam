{{ config(materialized='table') }}

select *
from {{ ref('model_mart_campaign_performance') }}
order by interaction_date asc