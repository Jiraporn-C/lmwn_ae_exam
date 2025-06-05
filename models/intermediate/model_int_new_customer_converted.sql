with new_customers_converted as (
  select
    icc.campaign_id,
    date(icc.interaction_datetime) as date,
    icc.customer_id
    --count(icc.customer_id) as new_customers,
  from {{ ref('model_int_campaign_conversions') }} icc
  inner join {{ ref('model_stg_campaign_interactions') }} sci 
  on icc.customer_id = sci.customer_id
  where sci.is_new_customer = TRUE
  --group by icc.campaign_id, date(icc.interaction_datetime)
)

select * from new_customers_converted