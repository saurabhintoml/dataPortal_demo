-- Builds per-customer order aggregation
with orders as (
    select * from ANALYTICS.STAGING.int_orders_enriched
),

final as (
    select
        customer_id,
        count(order_id) as lifetime_orders,
        sum(case when is_completed then 1 else 0 end) as completed_orders,
        sum(case when is_returned then 1 else 0 end) as returned_orders,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        sum(total_payment_amount) as lifetime_spend,
        avg(total_payment_amount) as avg_order_value,
        sum(total_quantity) as lifetime_items_purchased,
        max(total_payment_amount) as largest_order_amount
    from orders
    group by customer_id
)

select * from final