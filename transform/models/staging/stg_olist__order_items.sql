-- One row per item within an order (order_id + order_item_id).

with source as (

    select * from {{ source('olist', 'order_items') }}

),

renamed as (

    select
        -- ids
        cast(order_id as varchar)                  as order_id,
        cast(order_item_id as integer)             as order_item_id,
        cast(product_id as varchar)                as product_id,
        cast(seller_id as varchar)                 as seller_id,

        -- amounts (BRL); decimal avoids floating-point rounding in sums
        cast(price as decimal(18, 2))              as item_price,
        cast(freight_value as decimal(18, 2))      as freight_value,

        -- timestamps
        cast(shipping_limit_date as timestamp)     as shipping_deadline_at

    from source

)

select * from renamed
