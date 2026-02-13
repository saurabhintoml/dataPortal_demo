-- Order fulfillment and status tracking
with orders as (
    select * from {{ ref('fct_orders') }}
),

final as (
    select
        order_date,
        status,
        count(order_id) as order_count,
        sum(total_payment_amount) as total_value,
        avg(total_quantity) as avg_items_per_order,
        sum(case when order_size_bucket = 'Large' then 1 else 0 end) as large_orders,
        sum(case when order_size_bucket = 'Medium' then 1 else 0 end) as medium_orders,
        sum(case when order_size_bucket = 'Small' then 1 else 0 end) as small_orders
    from orders
    group by order_date, status
)

select * from final
