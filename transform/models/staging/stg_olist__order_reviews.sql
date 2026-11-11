-- One row per review per order (review_id + order_id). review_id alone is
-- not unique: some reviews are linked to several orders (DQ-1).

with source as (

    select * from {{ source('olist', 'order_reviews') }}

),

renamed as (

    select
        -- ids
        cast(review_id as varchar)                     as review_id,
        cast(order_id as varchar)                      as order_id,

        -- attributes
        cast(review_score as integer)                  as review_score,
        cast(review_comment_title as varchar)          as review_title,
        cast(review_comment_message as varchar)        as review_message,

        -- timestamps
        cast(review_creation_date as timestamp)        as survey_sent_at,
        cast(review_answer_timestamp as timestamp)     as survey_answered_at

    from source

)

select * from renamed
