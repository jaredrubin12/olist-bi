-- One review per order: the most recently answered (547 orders have more than one).
-- review_id breaks ties so the result is deterministic.

with reviews as (

    select * from {{ ref('stg_olist__order_reviews') }}

),

ranked as (

    select
        *,
        count(*) over (partition by order_id)   as review_count,
        row_number() over (
            partition by order_id
            order by survey_answered_at desc, review_id
        )                                       as recency_rank

    from reviews

)

select
    order_id,
    review_id,
    review_score,
    review_title,
    review_message,
    survey_sent_at,
    survey_answered_at,
    review_count

from ranked
where recency_rank = 1
