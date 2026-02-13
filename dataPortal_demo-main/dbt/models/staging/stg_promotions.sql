with source as (
    select * from {{ ref('raw_promotions') }}
),

renamed as (
    select
        id as promotion_id,
        promotion_code,
        discount_pct,
        valid_from,
        valid_to,
        min_order_cents / 100.0 as min_order_amount
    from source
)

select * from renamed
