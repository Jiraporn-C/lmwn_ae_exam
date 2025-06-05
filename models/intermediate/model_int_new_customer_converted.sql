with new_customers_converted as (
  select
    icc.campaign_id,
    date(icc.interaction_datetime) as date,
    count(icc.customer_id) as new_customers,
  from {{ ref('model_int_campaign_conversions') }} icc
  inner join {{ ref('model_stg_customers_master') }} scm  
  on icc.customer_id = scm.customer_id
  where scm.customer_segment = 'new'
  group by icc.campaign_id, date(icc.interaction_datetime)
)

select * from new_customers_converted