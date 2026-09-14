with distinct_room_types as (

    select distinct room_type
    from {{ ref('stg_airbnb_nyc__listings') }}

)

select
    {{ dbt_utils.generate_surrogate_key(['room_type']) }} as room_type_id,
    room_type                                             as room_type_name

from distinct_room_types