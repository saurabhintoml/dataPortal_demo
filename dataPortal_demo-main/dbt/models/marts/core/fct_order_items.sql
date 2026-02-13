-- Fact table at the line-item grain
with items as (
    select * from {{ ref('int_order_items_with_products') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

supply as (
    select * from {{ ref('stg_supply_costs') }}
),

final as (
    select
        i.order_item_id,
        i.order_id,
        o.customer_id,
        o.order_date,
        o.status as order_status,
        i.product_id,
        i.product_name,
        i.product_category,
        i.quantity,
        i.unit_price,
        i.line_total,
        s.supply_cost,
        i.quantity * s.supply_cost as line_cost,
        i.line_total - (i.quantity * s.supply_cost) as line_profit
    from items i
    left join orders o on i.order_id = o.order_id
    left join supply s on i.product_id = s.product_id
)

select * from final
