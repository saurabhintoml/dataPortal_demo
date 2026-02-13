-- Product category performance metrics
with items as (
    select * from {{ ref('int_order_items_with_products') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

final as (
    select
        i.product_category,
        date_trunc('month', o.order_date) as order_month,
        count(distinct i.order_id) as order_count,
        sum(i.quantity) as units_sold,
        sum(i.line_total) as category_revenue,
        count(distinct o.customer_id) as unique_customers,
        avg(i.line_total) as avg_line_value
    from items i
    left join orders o on i.order_id = o.order_id
    group by i.product_category, date_trunc('month', o.order_date)
)

select * from final
