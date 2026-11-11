-- Total revenue must be identical whether summed from orders or from items.
-- If they differ, a join has dropped or duplicated rows. Returns a row on failure.

with order_revenue as (

    select sum(revenue) as total from {{ ref('fct_orders') }}

),

item_revenue as (

    select sum(revenue) as total from {{ ref('fct_order_items') }}

)

select
    order_revenue.total as order_revenue,
    item_revenue.total  as item_revenue

from order_revenue
cross join item_revenue
where order_revenue.total != item_revenue.total
