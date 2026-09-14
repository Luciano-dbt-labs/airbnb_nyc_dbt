with source as (

    select * from {{ source('airbnb_nyc', 'raw_airbnb_listings') }}

),

cleaned as (

    select
        id                                          as listing_id,
        nullif(trim(name), '')                      as listing_name,
        host_id,
        nullif(trim(host_name), '')                 as host_name,
        trim(neighbourhood_group)                   as neighbourhood_group,
        trim(neighbourhood)                         as neighbourhood,
        latitude,
        longitude,
        trim(room_type)                             as room_type,
        price,
        minimum_nights,
        number_of_reviews,
        -- the csv stores the date as M/D/YYYY; SAFE. prevents an unexpected
        -- format from breaking the whole model, returns null instead
        safe.parse_date('%m/%d/%Y', last_review)    as last_review_date,
        -- no reviews means no reviews_per_month: 0 instead of null
        coalesce(reviews_per_month, 0)               as reviews_per_month,
        calculated_host_listings_count,
        availability_365

    from source

)

select *
from cleaned
-- price = 0 is not a real rental (11 rows in the original dataset):
-- we exclude it here so no downstream mart model has to filter it again
where price > 0
