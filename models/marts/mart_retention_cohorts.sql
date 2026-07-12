with cohorts as (
    select * from {{ ref('int_retention_cohorts') }}
)

select
    cohort_month,
    months_since_signup,
    retained_users,
    total_users,
    retention_rate_pct
from cohorts
where months_since_signup between 0 and 6
order by cohort_month, months_since_signup