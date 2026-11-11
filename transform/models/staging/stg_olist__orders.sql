-- One row per order. Light cleanup only: clear names, explicit types.
-- Explicit casts mean the model doesn't depend on CSV type auto-detection.

with source as (

    select * from {{ source('olist', 'orders') }}

),

renamed as (

    select
        -- ids
        cast(order_id as varchar)                          as order_id,
        cast(customer_id as varchar)                       as customer_id,

        -- attributes
        cast(order_status as varchar)                      as order_status,

        -- lifecycle timestamps, in the order they happen
        cast(order_purchase_timestamp as timestamp)        as purchased_at,
        cast(order_approved_at as timestamp)               as approved_at,
        cast(order_delivered_carrier_date as timestamp)    as delivered_to_carrier_at,
        cast(order_delivered_customer_date as timestamp)   as delivered_to_customer_at,

        -- always midnight in the source, so it's really a date
        cast(order_estimated_delivery_date as date)        as estimated_delivery_date

    from source

)

select * from renamed
