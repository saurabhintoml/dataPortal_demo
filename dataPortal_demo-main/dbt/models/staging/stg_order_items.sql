with source as (
    select * from {{ ref('raw_order_items') }}
),

renamed as (
    select
        id as order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price_cents / 100.0 as unit_price,
        quantity * (unit_price_cents / 100.0) as line_total
    from source
)

select * from renamed
