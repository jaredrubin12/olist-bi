-- Item-level data rolled up to one row per order.
-- Orders with no items (775) are absent here; fct_orders fills them with zeros.

with order_items as (

    select * from {{ ref('stg_olist__order_items') }}

),

aggregated as (

    select
        order_id,
        count(*)                        as item_count,
        count(distinct product_id)      as product_count,
        count(distinct seller_id)       as seller_count,
        sum(item_price)                 as items_value,
        sum(freight_value)              as freight_value

    from order_items
    group by order_id

)

select * from aggregated
