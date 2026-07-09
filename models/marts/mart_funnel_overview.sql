with funnel as (
    select * from {{ ref('int_user_funnel') }}
),

aggregated as (
    select
        '1_signed_up'           as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_signup = 1

    union all

    select
        '2_created_design'      as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_create_design = 1

    union all

    select
        '3_exported_design'     as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_export_design = 1

    union all

    select
        '4_invited_team'        as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_invite_team = 1

    union all

    select
        '5_upgraded'            as funnel_stage,
        count(*)                as user_count
    from funnel
    where did_upgrade = 1
),

with_conversion as (
    select
        funnel_stage,
        user_count,
        first_value(user_count) over (
            order by funnel_stage
        )                       as top_of_funnel,
        round(
            user_count * 100.0 / first_value(user_count) over (
                order by funnel_stage
            ), 1
        )                       as conversion_rate_pct
    from aggregated
)

select * from with_conversion
order by funnel_stage