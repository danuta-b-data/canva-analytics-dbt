with users as (
    select * from {{ ref('stg_users') }}
),

first_design as (
    select
        user_id,
        min(event_date)     as first_design_date
    from {{ ref('stg_events') }}
    where event_type = 'created_design'
    group by user_id
),

final as (
    select
        u.user_id,
        u.plan_type,
        u.country_code,
        u.created_at                                        as signup_date,
        f.first_design_date,
        datediff('day', u.created_at, f.first_design_date) as days_to_first_value,
        case
            when f.first_design_date is null        then 'never_activated'
            when datediff('day', u.created_at,
                f.first_design_date) = 0            then 'same_day'
            when datediff('day', u.created_at,
                f.first_design_date) <= 7           then 'within_1_week'
            when datediff('day', u.created_at,
                f.first_design_date) <= 30          then 'within_1_month'
            else 'after_1_month'
        end                                                 as activation_segment
    from users u
    left join first_design f on u.user_id = f.user_id
)

select * from final