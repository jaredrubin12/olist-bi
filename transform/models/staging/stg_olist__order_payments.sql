-- One row per payment against an order (order_id + payment_sequential).

with source as (

    select * from {{ source('olist', 'order_payments') }}

),

renamed as (

    select
        -- ids
        cast(order_id as varchar)                  as order_id,
        cast(payment_sequential as integer)        as payment_sequential,

        -- attributes
        cast(payment_type as varchar)              as payment_type,
        cast(payment_installments as integer)      as payment_installments,

        -- amounts (BRL)
        cast(payment_value as decimal(18, 2))      as payment_value

    from source

)

select * from renamed
