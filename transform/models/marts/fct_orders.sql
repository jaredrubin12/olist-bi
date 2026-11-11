-- One row per order (all 99,441, including canceled). Use `revenue` and
-- `is_countable` for the agreed metrics; they already apply the definition.

with orders as (

    select * from {{ ref('stg_olist__orders') }}

),

customers as (

    select customer_id, customer_unique_id from {{ ref('stg_olist__customers') }}

),

items as (

    select * from {{ ref('int_orders__items_agg') }}

),

payments as (

    select * from {{ ref('int_orders__payments_agg') }}

),

reviews as (

    select * from {{ ref('int_orders__latest_review') }}

),

joined as (

    select
        -- keys
        orders.order_id,
        customers.customer_unique_id,
        cast(orders.purchased_at as date)                       as purchase_date,

        -- status
        orders.order_status,
        {{ is_countable_order('orders.order_status') }}          as is_countable,

        -- lifecycle
        orders.purchased_at,
        orders.approved_at,
        orders.delivered_to_carrier_at,
        orders.delivered_to_customer_at,
        orders.estimated_delivery_date,

        -- items (orders with no items get zeros, not nulls)
        coalesce(items.item_count, 0)                           as item_count,
        coalesce(items.product_count, 0)                        as product_count,
        coalesce(items.seller_count, 0)                         as seller_count,
        items.order_id is not null                              as has_items,
        coalesce(items.items_value, 0)                          as items_value,
        coalesce(items.freight_value, 0)                        as freight_value,

        -- payments
        payments.payment_total,
        payments.primary_payment_type,
        payments.max_installments,

        -- review
        reviews.order_id is not null                            as has_review,
        reviews.review_score,
        coalesce(reviews.review_count, 0)                       as review_count

    from orders
    inner join customers
        on orders.customer_id = customers.customer_id
    left join items
        on orders.order_id = items.order_id
    left join payments
        on orders.order_id = payments.order_id
    left join reviews
        on orders.order_id = reviews.order_id

),

final as (

    select
        *,

        -- agreed Revenue: item prices on countable orders, excluding freight
        case when is_countable then items_value else 0 end      as revenue,
        items_value + freight_value                             as order_value,
        payment_total - (items_value + freight_value)           as payment_vs_order_diff,

        -- delivery
        delivered_to_customer_at is not null                    as is_delivered,
        date_diff('day', purchased_at, delivered_to_customer_at) as days_to_deliver,
        date_diff('day', estimated_delivery_date,
                  cast(delivered_to_customer_at as date))       as days_late,   -- negative = early
        case
            when delivered_to_customer_at is null then null
            else cast(delivered_to_customer_at as date) <= estimated_delivery_date
        end                                                     as is_on_time

    from joined

)

select * from final
