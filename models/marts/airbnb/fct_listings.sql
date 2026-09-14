with listings as (

    select * from {{ ref('stg_airbnb_nyc__listings') }}

),

room_types as (
    select * from {{ ref('dim_room_type') }}
),

neighbourhood_groups as (
    select * from {{ ref('dim_neighbourhood_group') }}
),

neighbourhoods as (
    select * from {{ ref('dim_neighbourhood') }}
),

final as (

    select
        l.listing_id,
        l.listing_name,
        l.host_id,
        ng.neighbourhood_group_id,
        n.neighbourhood_id,
        rt.room_type_id,
        l.latitude,
        l.longitude,
        l.price,
        l.minimum_nights,
        l.number_of_reviews,
        l.last_review_date,
        l.reviews_per_month,
        l.calculated_host_listings_count,
        l.availability_365

    from listings l
    left join room_types           rt on l.room_type = rt.room_type_name
    left join neighbourhood_groups ng on l.neighbourhood_group = ng.neighbourhood_group_name
    left join neighbourhoods       n  on l.neighbourhood = n.neighbourhood_name

)

select * from final
