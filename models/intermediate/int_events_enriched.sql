with events as (
    select * from {{ ref('stg_events') }}
),

users as (
    select
        user_id,
        plan_type,
        country_code
    from {{ ref('stg_users') }}
),

final as (
    select
        e.event_id,
        e.user_id,
        e.event_type,
        e.event_date,
        u.plan_type,
        u.country_code
    from events e
    left join users u on e.user_id = u.user_id

    {% if is_incremental() %}
        where e.event_date > (select max(event_date) from {{ this }})
    {% endif %}
)

select * from final