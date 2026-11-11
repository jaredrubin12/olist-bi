-- One row per item within an order. Use for anything split by product,
-- category or seller. `revenue` applies the agreed definition.

with items as (

    select * from {{ ref('stg_olist__order_items') }}

),

orders as (

    select order_id, customer_id, order_status, purchased_at
    from {{ ref('stg_olist__orders') }}

),

customers as (

    select customer_id, customer_unique_id from {{ ref('stg_olist__customers') }}

)

select
    -- keys
    items.order_id,
    items.order_item_id,
    items.product_id,
    items.seller_id,
    customers.customer_unique_id,
    cast(orders.purchased_at as date)                           as purchase_date,

    -- status
    orders.order_status,
    {{ is_countable_order('orders.order_status') }}              as is_countable,

    -- amounts
    items.item_price,
    items.freight_value,
    case
        when {{ is_countable_order('orders.order_status') }} then items.item_price
        else 0
    end                                                         as revenue,

    -- timing
    items.shipping_deadline_at

from items
inner join orders
    on items.order_id = orders.order_id
inner join customers
    on orders.customer_id = customers.customer_id
