-- Summary of each product across all orders
with order_items as (
    select * from ANALYTICS.STAGING.int_order_items_with_products
),

orders as (
    select * from ANALYTICS.STAGING.stg_orders
),

final as (
    select
        oi.product_id,
        oi.product_name,
        oi.product_category,
        count(distinct oi.order_id) as times_ordered,
        sum(oi.quantity) as total_units_sold,
        sum(oi.line_total) as total_revenue,
        avg(oi.line_total) as avg_line_total,
        count(distinct o.customer_id) as unique_customers
    from order_items oi
    left join orders o on oi.order_id = o.order_id
    group by oi.product_id, oi.product_name, oi.product_category
)

select * from final