with events as (
    select * from {{ ref('stg_events') }}
),

funnel as (
    select
        user_id,
        max(case when event_type = 'signed_up'
            then 1 else 0 end)              as did_signup,
        max(case when event_type = 'created_design'
            then 1 else 0 end)              as did_create_design,
        max(case when event_type = 'exported_design'
            then 1 else 0 end)              as did_export_design,
        max(case when event_type = 'invited_team_member'
            then 1 else 0 end)              as did_invite_team,
        max(case when event_type = 'upgraded_plan'
            then 1 else 0 end)              as did_upgrade
    from events
    group by user_id
),

with_stage as (
    select
        user_id,
        did_signup,
        did_create_design,
        did_export_design,
        did_invite_team,
        did_upgrade,
        case
            when did_upgrade = 1        then '5_upgraded'
            when did_invite_team = 1    then '4_invited_team'
            when did_export_design = 1  then '3_exported'
            when did_create_design = 1  then '2_created_design'
            when did_signup = 1         then '1_signed_up'
            else '0_no_activity'
        end                             as funnel_stage
    from funnel
)

select * from with_stage