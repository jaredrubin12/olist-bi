-- Coordinates by zip-code prefix. NOT one row per prefix: ~50 rows each (DQ-2).
-- Never join to this directly; use the per-prefix aggregate in the intermediate layer.

with source as (

    select * from {{ source('olist', 'geolocation') }}

),

renamed as (

    select
        cast(geolocation_zip_code_prefix as varchar)    as zip_code_prefix,
        cast(geolocation_lat as double)                 as latitude,
        cast(geolocation_lng as double)                 as longitude,
        cast(geolocation_city as varchar)               as city,
        upper(cast(geolocation_state as varchar))       as state

    from source

)

select * from renamed
