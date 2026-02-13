-- Daily order aggregation
with orders as (
    select * from ANALYTICS.STAGING.int_orders_enriched
),

final as (
    select
        order_date,
        count(order_id) as order_count,
        sum(total_payment_amount) as daily_revenue,
        avg(total_payment_amount) as avg_order_value,
        sum(total_quantity) as items_sold,
        count(distinct customer_id) as unique_customers,
        sum(case when is_completed then 1 else 0 end) as completed_count,
        sum(case when is_returned then 1 else 0 end) as returned_count
    from orders
    group by order_date
)

select * from final