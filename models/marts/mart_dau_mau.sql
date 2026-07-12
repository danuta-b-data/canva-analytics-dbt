with dau_mau as (
    select * from {{ ref('int_dau_mau') }}
)

select
    event_date,
    daily_active_users,
    monthly_active_users,
    dau_mau_ratio
from dau_mau
order by event_date