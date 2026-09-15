{{
    config(
        materialized='incremental',
        unique_key='listing_id'
    )
}}

-- transactional fact table: one row per listing, reflecting its current
-- known state. New listing_ids get inserted; existing ones get their
-- measures updated in place (price, reviews, availability, etc. always
-- reflect the latest load). No historical trail of prior attribute
-- values is kept here -- that's a deliberate trade-off for simplicity.
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

current_state as (

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

select
    c.*,

    {% if is_incremental() %}
    -- preserve the original insert timestamp for listings that already
    -- exist; only brand-new listing_ids get a fresh inserted_at
    coalesce(e.inserted_at, current_datetime('America/New_York')) as inserted_at,
    {% else %}
    current_datetime('America/New_York') as inserted_at,
    {% endif %}

    -- refreshed every run this row is touched (insert or update)
    current_datetime('America/New_York') as updated_at

from current_state c
{% if is_incremental() %}
left join {{ this }} e on c.listing_id = e.listing_id
{% endif %}
