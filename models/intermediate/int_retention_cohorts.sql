with users as (
    select * from {{ ref('stg_users') }}
),

events as (
    select * from {{ ref('stg_events') }}
),

user_activity as (
    select
        user_id,
        event_date,
        date_trunc('month', event_date) as activity_month
    from events
    where event_type != 'signed_up'
),

cohorts as (
    select
        u.user_id,
        date_trunc('month', u.created_at)   as cohort_month,
        a.activity_month,
        datediff(
            'month',
            date_trunc('month', u.created_at),
            a.activity_month
        )                                   as months_since_signup
    from users u
    left join user_activity a on u.user_id = a.user_id
),

cohort_size as (
    select
        cohort_month,
        count(distinct user_id) as total_users
    from cohorts
    group by cohort_month
),

retention as (
    select
        c.cohort_month,
        c.months_since_signup,
        count(distinct c.user_id)   as retained_users
    from cohorts c
    where c.months_since_signup is not null
    group by c.cohort_month, c.months_since_signup
)

select
    r.cohort_month,
    r.months_since_signup,
    r.retained_users,
    cs.total_users,
    round(
        r.retained_users * 100.0 / cs.total_users, 1
    )                               as retention_rate_pct
from retention r
left join cohort_size cs on r.cohort_month = cs.cohort_month
where r.months_since_signup >= 0
order by r.cohort_month, r.months_since_signup