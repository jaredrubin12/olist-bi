-- One row per seller.

with source as (

    select * from {{ source('olist', 'sellers') }}

),

renamed as (

    select
        -- ids
        cast(seller_id as varchar)                  as seller_id,

        -- location
        cast(seller_zip_code_prefix as varchar)     as zip_code_prefix,
        cast(seller_city as varchar)                as city,
        upper(cast(seller_state as varchar))        as state

    from source

)

select * from renamed
