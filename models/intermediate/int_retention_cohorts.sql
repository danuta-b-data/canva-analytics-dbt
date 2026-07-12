with users as (
    select * from {{ ref('stg_users') }}
),

events as (
    select * from {{ ref('stg_events') }}
),

user_months as (
    select distinct
        user_id,
        date_trunc('month', event_date) as activity_month
    from events
    where event_type != 'signed_up'
),

cohort_size as (
    select
        date_trunc('month', created_at)     as cohort_month,
        count(distinct user_id)             as total_users
    from users
    group by date_trunc('month', created_at)
),

cohorts as (
    select
        date_trunc('month', u.created_at)   as cohort_month,
        a.activity_month,
        u.user_id,
        datediff(
            'month',
            date_trunc('month', u.created_at),
            a.activity_month
        )                                   as months_since_signup
    from users u
    left join user_months a on u.user_id = a.user_id
),

retention as (
    select
        cohort_month,
        months_since_signup,
        count(distinct user_id)             as retained_users
    from cohorts
    where months_since_signup is not null
      and months_since_signup >= 0
    group by cohort_month, months_since_signup
)

select
    r.cohort_month,
    r.months_since_signup,
    r.retained_users,
    cs.total_users,
    round(
        r.retained_users * 100.0 / cs.total_users, 1
    )                                       as retention_rate_pct
from retention r
left join cohort_size cs on r.cohort_month = cs.cohort_month
order by r.cohort_month, r.months_since_signup