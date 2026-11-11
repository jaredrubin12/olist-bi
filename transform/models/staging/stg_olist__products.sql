-- One row per product. Category stays in Portuguese here; the English name
-- and fallback for missing categories are applied in the intermediate layer (DQ-3).

with source as (

    select * from {{ source('olist', 'products') }}

),

renamed as (

    select
        -- ids
        cast(product_id as varchar)                     as product_id,

        -- attributes
        cast(product_category_name as varchar)          as category_name_pt,

        -- listing quality (source columns are misspelled "lenght")
        cast(product_name_lenght as integer)            as name_length,
        cast(product_description_lenght as integer)     as description_length,
        cast(product_photos_qty as integer)             as photo_count,

        -- physical dimensions
        cast(product_weight_g as integer)               as weight_g,
        cast(product_length_cm as integer)              as length_cm,
        cast(product_height_cm as integer)              as height_cm,
        cast(product_width_cm as integer)               as width_cm

    from source

)

select * from renamed
