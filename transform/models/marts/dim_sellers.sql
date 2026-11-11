-- One row per seller, with coordinates for maps (null where unknown: DQ-4, DQ-8).

with sellers as (

    select * from {{ ref('stg_olist__sellers') }}

),

geo as (

    select * from {{ ref('int_geolocation__by_zip') }}

)

select
    sellers.seller_id,
    sellers.zip_code_prefix,
    sellers.city,
    sellers.state,
    geo.latitude,
    geo.longitude

from sellers
left join geo
    on sellers.zip_code_prefix = geo.zip_code_prefix
