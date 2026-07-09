with events as (
    select * from {{ ref('stg_events') }}
),

users as (
    select * from {{ ref('stg_users') }}
),

activity as (
    select
        e.user_id,
        count(*)                                                    as total_events,
        count(case when e.event_type = 'created_design' then 1 end) as designs_created,
        count(case when e.event_type = 'exported_design' then 1 end) as designs_exported,
        count(case when e.event_type = 'invited_team_member' then 1 end) as team_invites,
        min(e.event_date)                                           as first_event_date,
        max(e.event_date)                                           as last_event_date
    from events e
    group by e.user_id
)

select
    u.user_id,
    u.plan_type,
    u.country_code,
    u.created_at,
    coalesce(a.total_events, 0)         as total_events,
    coalesce(a.designs_created, 0)      as designs_created,
    coalesce(a.designs_exported, 0)     as designs_exported,
    coalesce(a.team_invites, 0)         as team_invites,
    a.first_event_date,
    a.last_event_date
from users u
left join activity a on u.user_id = a.user_id