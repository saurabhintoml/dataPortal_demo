with source as (
    select * from ANALYTICS.STAGING.raw_reviews
),

renamed as (
    select
        id as review_id,
        product_id,
        customer_id,
        order_id,
        rating,
        review_text,
        created_at as reviewed_at
    from source
)

select * from renamed