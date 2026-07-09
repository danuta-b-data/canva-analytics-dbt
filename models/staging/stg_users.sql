with source as (
    select * from {{ ref('raw_users') }}
),

renamed as (
    select
        user_id::integer        as user_id,
        lower(email)            as email,
        lower(plan)             as plan_type,
        created_at::date        as created_at,
        upper(country)          as country_code,
        current_timestamp       as _loaded_at
    from source
)

select * from renamed