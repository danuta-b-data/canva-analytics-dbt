with source as (
    select * from {{ ref('raw_events') }}
),

renamed as (
    select
        event_id::integer       as event_id,
        user_id::integer        as user_id,
        lower(event_type)       as event_type,
        created_at::date        as event_date,
        current_timestamp       as _loaded_at
    from source
)

select * from renamed