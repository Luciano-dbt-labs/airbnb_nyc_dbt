{{
    config(
        materialized='table'
    )
}}

with bounds as (

    select
        date_sub(min(last_review_date), interval 1 year) as start_date,
        date_add(greatest(max(last_review_date), current_date('America/New_York')), interval 1 year) as end_date
    from {{ ref('stg_airbnb_nyc__listings') }}
    where last_review_date is not null

),

date_spine as (

    select date_value
    from bounds,
    unnest(generate_date_array(bounds.start_date, bounds.end_date)) as date_value

)

select
    date_value                                as date_day,
    extract(year from date_value)             as year_number,
    extract(quarter from date_value)          as quarter_number,
    extract(month from date_value)             as month_number,
    format_date('%B', date_value)              as month_name,
    format_date('%b', date_value)              as month_name_short,
    extract(day from date_value)               as day_of_month,
    extract(dayofweek from date_value)         as day_of_week_number,  -- 1=Sunday .. 7=Saturday
    format_date('%A', date_value)              as day_name,
    format_date('%a', date_value)              as day_name_short,
    extract(dayofyear from date_value)         as day_of_year,
    extract(isoweek from date_value)           as week_of_year,
    extract(dayofweek from date_value) in (1, 7) as is_weekend

from date_spine
