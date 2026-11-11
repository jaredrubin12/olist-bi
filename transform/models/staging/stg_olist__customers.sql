-- One row per customer_id. customer_id is per order; customer_unique_id is
-- the actual person (DQ-5).

with source as (

    select * from {{ source('olist', 'customers') }}

),

renamed as (

    select
        -- ids
        cast(customer_id as varchar)                as customer_id,
        cast(customer_unique_id as varchar)         as customer_unique_id,

        -- location
        cast(customer_zip_code_prefix as varchar)   as zip_code_prefix,
        cast(customer_city as varchar)              as city,
        upper(cast(customer_state as varchar))      as state

    from source

)

select * from renamed
