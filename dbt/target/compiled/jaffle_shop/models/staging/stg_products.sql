with source as (
    select * from ANALYTICS.STAGING.raw_products
),

renamed as (
    select
        id as product_id,
        name as product_name,
        category as product_category,
        unit_price_cents / 100.0 as unit_price,
        created_at
    from source
)

select * from renamed