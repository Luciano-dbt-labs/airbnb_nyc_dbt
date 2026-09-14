with distinct_neighbourhoods as (

    select distinct
        neighbourhood,
        neighbourhood_group
    from {{ ref('stg_airbnb_nyc__listings') }}

),

with_group_id as (

    select
        n.neighbourhood,
        {{ dbt_utils.generate_surrogate_key(['n.neighbourhood_group']) }} as neighbourhood_group_id
    from distinct_neighbourhoods n

)

select
    {{ dbt_utils.generate_surrogate_key(['neighbourhood']) }} as neighbourhood_id,
    neighbourhood                                             as neighbourhood_name,
    neighbourhood_group_id

from with_group_id