{{ config(materialized='table') }}

select *
from {{ ref('model_mart_customer_acquisition') }}
order by acquisition_date asc