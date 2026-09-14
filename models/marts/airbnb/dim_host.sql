with distinct_hosts as (

    select distinct
        host_id,
        host_name
    from {{ ref('stg_airbnb_nyc__listings') }}
    -- if the same host_id ever appeared with more than one host_name (shouldn't
    -- happen, but just in case) we keep the most frequent one
    qualify row_number() over (
        partition by host_id
        order by count(*) over (partition by host_id, host_name) desc
    ) = 1

)

select
    host_id,
    host_name

from distinct_hosts
