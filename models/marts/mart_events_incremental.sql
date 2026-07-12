{{
    config(
        materialized='incremental',
        unique_key='event_id'
    )
}}

with enriched as (
    select * from {{ ref('int_events_enriched') }}
)

select * from enriched

{% if is_incremental() %}
    where event_date > (select max(event_date) from {{ this }})
{% endif %}