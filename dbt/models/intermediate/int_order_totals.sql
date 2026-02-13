-- Aggregates order-level totals from line items
with order_items as (
    select * from {{ ref('int_order_items_with_products') }}
),

final as (
    select
        order_id,
        count(distinct order_item_id) as total_items,
        sum(quantity) as total_quantity,
        sum(line_total) as items_subtotal,
        count(distinct product_category) as distinct_categories
    from order_items
    group by order_id
)

select * from final
