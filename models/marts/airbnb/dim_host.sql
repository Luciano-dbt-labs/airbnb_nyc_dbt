{{
    config(
        materialized='incremental',
        unique_key='host_id'
    )
}}

-- same append-only, Type 1 pattern as the other reference dimensions:
-- new hosts get inserted, existing ones are never revisited or updated.
-- (no business measure depends on tracking host_name history, so the
-- SCD2 snapshot approach was dropped in favor of this simpler pattern.)
with host_name_counts as (

    select
        host_id,
        host_name,
        count(*) as name_occurrences
    from {{ ref('stg_airbnb_nyc__listings') }}

    {% if is_incremental() %}
    where host_id not in (select host_id from {{ this }})
    {% endif %}

    group by host_id, host_name

),

distinct_hosts as (

    select
        host_id,
        host_name

    from host_name_counts
    qualify row_number() over (
        partition by host_id
        order by name_occurrences desc
    ) = 1

)

select
    host_id,
    host_name,
    current_datetime('America/New_York') as inserted_at,
    current_datetime('America/New_York') as updated_at

from distinct_hosts
