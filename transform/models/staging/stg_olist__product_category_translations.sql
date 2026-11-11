-- Lookup from Portuguese to English product category names.

with source as (

    select * from {{ source('olist', 'product_category_name_translation') }}

),

renamed as (

    select
        cast(product_category_name as varchar)          as category_name_pt,
        cast(product_category_name_english as varchar)  as category_name_en

    from source

)

select * from renamed
