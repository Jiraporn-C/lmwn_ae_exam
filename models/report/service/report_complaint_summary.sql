{{ config(materialized='table') }}

select *
from {{ ref('model_mart_complaint_summary') }}
order by complaint_date asc