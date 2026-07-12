with time_to_value as (
    select * from {{ ref('int_time_to_first_value') }}
)

select
    user_id,
    plan_type,
    country_code,
    signup_date,
    first_design_date,
    days_to_first_value,
    activation_segment
from time_to_value
order by signup_date