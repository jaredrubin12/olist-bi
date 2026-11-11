-- One row per zip-code prefix (DQ-2: source has ~50 rows per prefix).
-- Points outside Brazil's bounding box are excluded before averaging (DQ-8).

with geolocation as (

    select * from {{ ref('stg_olist__geolocation') }}

),

in_brazil as (

    select *
    from geolocation
    where latitude  between -34.0 and 5.3
      and longitude between -74.0 and -34.7

),

by_zip as (

    select
        zip_code_prefix,
        avg(latitude)       as latitude,
        avg(longitude)      as longitude,
        mode(state)         as state,
        count(*)            as source_point_count

    from in_brazil
    group by zip_code_prefix

)

select * from by_zip
