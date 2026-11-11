-- One row per product, with a readable category that is never null (DQ-3):
-- English name, else Portuguese name, else 'unknown'.

with products as (

    select * from {{ ref('stg_olist__products') }}

),

translations as (

    select * from {{ ref('stg_olist__product_category_translations') }}

)

select
    products.product_id,
    coalesce(
        translations.category_name_en,
        products.category_name_pt,
        'unknown'
    )                                       as category,
    products.category_name_pt,
    products.name_length,
    products.description_length,
    products.photo_count,
    products.weight_g,
    products.length_cm,
    products.height_cm,
    products.width_cm

from products
left join translations
    on products.category_name_pt = translations.category_name_pt
