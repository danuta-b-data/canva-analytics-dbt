with funnel as (
    select * from {{ ref('int_user_funnel') }}
),

aggregated as (
    select
        'Signed Up'             as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_signup = 1

    union all

    select
        'Created Design'        as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_create_design = 1

    union all

    select
        'Exported Design'       as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_export_design = 1

    union all

    select
        'Invited Team Member'   as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_invite_team = 1

    union all

    select
        'Upgraded Plan'         as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_upgrade = 1
),

with_conversion as (
    select
        funnel_stage,
        user_count,
        first_value(user_count) over (
            order by user_count desc
        )                       as top_of_funnel,
        round(
            user_count * 100.0 / first_value(user_count) over (
                order by user_count desc
            ), 1
        )                       as conversion_rate_pct
    from aggregated
)

select * from with_conversion
order by user_count desc