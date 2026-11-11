-- Payment-level data rolled up to one row per order.
-- primary_payment_type is the method that paid the largest share of the order.

with payments as (

    select * from {{ ref('stg_olist__order_payments') }}

),

aggregated as (

    select
        order_id,
        sum(payment_value)                          as payment_total,
        count(*)                                    as payment_count,
        arg_max(payment_type, payment_value)        as primary_payment_type,
        max(payment_installments)                   as max_installments

    from payments
    group by order_id

)

select * from aggregated
