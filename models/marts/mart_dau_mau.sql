with events as (
    select * from {{ ref('stg_events') }}
),

dau as (
    select
        event_date,
        count(distinct user_id) as daily_active_users
    from events
    group by event_date
),

mau as (
    select
        date_trunc('month', event_date)     as month,
        count(distinct user_id)             as monthly_active_users
    from events
    group by date_trunc('month', event_date)
),

final as (
    select
        d.event_date,
        d.daily_active_users,
        m.monthly_active_users,
        round(
            d.daily_active_users * 100.0 / m.monthly_active_users, 1
        )                                   as dau_mau_ratio
    from dau d
    left join mau m
        on date_trunc('month', d.event_date) = m.month
)

select * from final
order by event_date