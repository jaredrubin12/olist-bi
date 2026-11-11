-- One row per real person (customer_unique_id), not per order (DQ-5).
-- Location is taken from the person's most recent order.
-- Order counts use the agreed countable-order definition (is_countable_order macro).

with customers as (

    select * from {{ ref('stg_olist__customers') }}

),

orders as (

    select * from {{ ref('stg_olist__orders') }}

),

geo as (

    select * from {{ ref('int_geolocation__by_zip') }}

),

customer_orders as (

    select
        customers.customer_unique_id,
        customers.zip_code_prefix,
        customers.city,
        customers.state,
        orders.purchased_at,
        {{ is_countable_order('orders.order_status') }} as is_countable

    from customers
    inner join orders
        on customers.customer_id = orders.customer_id

),

per_person as (

    select
        customer_unique_id,

        -- most recent known location
        arg_max(zip_code_prefix, purchased_at)              as zip_code_prefix,
        arg_max(city, purchased_at)                         as city,
        arg_max(state, purchased_at)                        as state,

        -- order history (countable orders only)
        min(purchased_at) filter (where is_countable)       as first_order_at,
        max(purchased_at) filter (where is_countable)       as last_order_at,
        count(*) filter (where is_countable)                as lifetime_orders

    from customer_orders
    group by customer_unique_id

)

select
    per_person.customer_unique_id,
    per_person.zip_code_prefix,
    per_person.city,
    per_person.state,
    geo.latitude,
    geo.longitude,
    per_person.first_order_at,
    per_person.last_order_at,
    per_person.lifetime_orders,
    per_person.lifetime_orders >= 2                         as is_repeat_customer

from per_person
left join geo
    on per_person.zip_code_prefix = geo.zip_code_prefix
