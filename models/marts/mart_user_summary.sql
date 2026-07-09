with activity as (
    select * from {{ ref('int_user_activity') }}
),

funnel as (
    select * from {{ ref('int_user_funnel') }}
),

final as (
    select
        a.user_id,
        a.plan_type,
        a.country_code,
        a.created_at                                        as signup_date,
        a.total_events,
        a.designs_created,
        a.designs_exported,
        a.team_invites,
        a.first_event_date,
        a.last_event_date,
        f.funnel_stage,
        f.did_upgrade,
        datediff('day', a.created_at, a.last_event_date)   as days_active,
        {{ classify_engagement('a.total_events') }}        as engagement_tier
    from activity a
    left join funnel f on a.user_id = f.user_id
)

select * from final