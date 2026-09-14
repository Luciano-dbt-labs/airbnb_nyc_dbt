{{
    config(
        materialized='incremental',
        unique_key='neighbourhood_name'
    )
}}

with distinct_neighbourhoods as (

    select distinct
        neighbourhood,
        neighbourhood_group
    from {{ ref('stg_airbnb_nyc__listings') }}

    {% if is_incremental() %}
    -- only look at neighbourhoods that don't have an id assigned yet
    where neighbourhood not in (select neighbourhood_name from {{ this }})
    {% endif %}

),

neighbourhood_groups as (

    select * from {{ ref('dim_neighbourhood_group') }}

),

next_id as (

    {% if is_incremental() %}
    select coalesce(max(neighbourhood_id), 0) as current_max_id
    from {{ this }}
    {% else %}
    select 0 as current_max_id
    {% endif %}

)

select
    next_id.current_max_id + row_number() over (order by n.neighbourhood) as neighbourhood_id,
    n.neighbourhood                                                        as neighbourhood_name,
    ng.neighbourhood_group_id

from distinct_neighbourhoods n
left join neighbourhood_groups ng
    on n.neighbourhood_group = ng.neighbourhood_group_name
cross join next_id