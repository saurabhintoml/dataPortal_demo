-- Calculates margin per product
with product_orders as (
    select * from ANALYTICS.STAGING.int_product_order_summary
),

supply_costs as (
    select * from ANALYTICS.STAGING.stg_supply_costs
),

products as (
    select * from ANALYTICS.STAGING.stg_products
),

final as (
    select
        po.product_id,
        po.product_name,
        po.product_category,
        p.unit_price,
        sc.supply_cost,
        p.unit_price - sc.supply_cost as unit_margin,
        case when p.unit_price > 0
            then (p.unit_price - sc.supply_cost) / p.unit_price * 100
            else 0
        end as margin_pct,
        po.total_units_sold,
        po.total_revenue,
        po.total_units_sold * sc.supply_cost as total_cost,
        po.total_revenue - (po.total_units_sold * sc.supply_cost) as gross_profit
    from product_orders po
    left join supply_costs sc on po.product_id = sc.product_id
    left join products p on po.product_id = p.product_id
)

select * from final