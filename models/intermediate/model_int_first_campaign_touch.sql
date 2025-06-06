with first_interaction as (
  select
    customer_id,
    campaign_id,
    min(interaction_datetime) as first_interaction_time
  from {{ ref('model_stg_campaign_interactions') }}
  where event_type in ('click', 'impression') and is_new_customer = TRUE
  group by customer_id, campaign_id
)

select * from first_interaction