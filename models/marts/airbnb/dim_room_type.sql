{{
    config(
        materialized='incremental',
        unique_key='room_type_name'
    )
}}

with distinct_room_types as (

    select distinct room_type
    from {{ ref('stg_airbnb_nyc__listings') }}

    {% if is_incremental() %}
    -- only look at room types that don't have an id assigned yet
    where room_type not in (select room_type_name from {{ this }})
    {% endif %}

),

next_id as (

    {% if is_incremental() %}
    select coalesce(max(room_type_id), 0) as current_max_id
    from {{ this }}
    {% else %}
    select 0 as current_max_id
    {% endif %}

)

select
    next_id.current_max_id + row_number() over (order by distinct_room_types.room_type) as room_type_id,
    distinct_room_types.room_type                                                        as room_type_name

from distinct_room_types
cross join next_id