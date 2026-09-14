with distinct_groups as (

    select distinct neighbourhood_group
    from {{ ref('stg_airbnb_nyc__listings') }}

)

select
    {{ dbt_utils.generate_surrogate_key(['neighbourhood_group']) }} as neighbourhood_group_id,
    neighbourhood_group                                             as neighbourhood_group_name

from distinct_groups
