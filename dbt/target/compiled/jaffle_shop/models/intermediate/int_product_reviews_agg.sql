-- Aggregated review metrics per product
with reviews as (
    select * from ANALYTICS.STAGING.stg_reviews
),

final as (
    select
        product_id,
        count(review_id) as review_count,
        avg(rating) as avg_rating,
        min(rating) as min_rating,
        max(rating) as max_rating,
        sum(case when rating >= 4 then 1 else 0 end) as positive_reviews,
        sum(case when rating <= 2 then 1 else 0 end) as negative_reviews
    from reviews
    group by product_id
)

select * from final