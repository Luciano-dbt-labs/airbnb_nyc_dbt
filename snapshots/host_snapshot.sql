{% snapshot host_snapshot %}

{{
    config(
        target_schema=target.schema,
        unique_key='host_id',
        strategy='check',
        check_cols=['host_name'],
        invalidate_hard_deletes=true,
    )
}}

-- the source is one row per listing, so the same host_id can appear more
-- than once with a different host_name (rare, but possible). we collapse
-- to a single row per host_id per snapshot invocation by keeping the most
-- frequent name, since dbt snapshot requires unique_key to be unique.
with host_name_counts as (

    select
        host_id,
        host_name,
        count(*) as name_occurrences
    from {{ ref('stg_airbnb_nyc__listings') }}
    group by host_id, host_name

)

select
    host_id,
    host_name

from host_name_counts
qualify row_number() over (
    partition by host_id
    order by name_occurrences desc
) = 1

{% endsnapshot %}