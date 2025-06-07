{{ config(materialized='table') }}

select *
from {{ ref('model_mart_driver_incentive_impact') }}
--order by interaction_date asc