{{
    config(
        materialized='incremental',
        unique_key='neighbourhood_group_name'
    )
}}

with distinct_groups as (

    select distinct neighbourhood_group
    from {{ ref('stg_airbnb_nyc__listings') }}

    {% if is_incremental() %}
    -- only look at boroughs that don't have an id assigned yet
    where neighbourhood_group not in (select neighbourhood_group_name from {{ this }})
    {% endif %}

),

next_id as (

    {% if is_incremental() %}
    select coalesce(max(neighbourhood_group_id), 0) as current_max_id
    from {{ this }}
    {% else %}
    select 0 as current_max_id
    {% endif %}

)

select
    next_id.current_max_id + row_number() over (order by distinct_groups.neighbourhood_group) as neighbourhood_group_id,
    distinct_groups.neighbourhood_group                                                        as neighbourhood_group_name

from distinct_groups
cross join next_id