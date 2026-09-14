with host_name_counts as (

    select
        host_id,
        host_name,
        count(*) as name_occurrences
    from {{ ref('stg_airbnb_nyc__listings') }}
    group by host_id, host_name

)

-- if the same host_id ever appeared with more than one host_name (shouldn't
-- happen, but just in case) we keep the name that occurs most often
select
    host_id,
    host_name

from host_name_counts
qualify row_number() over (
    partition by host_id
    order by name_occurrences desc
) = 1