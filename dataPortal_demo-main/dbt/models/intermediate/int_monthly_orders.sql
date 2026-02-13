-- Monthly aggregation of daily metrics
with daily as (
    select * from {{ ref('int_daily_orders') }}
),

final as (
    select
        date_trunc('month', order_date) as order_month,
        sum(order_count) as order_count,
        sum(daily_revenue) as monthly_revenue,
        avg(avg_order_value) as avg_order_value,
        sum(items_sold) as items_sold,
        sum(unique_customers) as customer_orders,
        sum(completed_count) as completed_count,
        sum(returned_count) as returned_count,
        sum(returned_count) * 1.0 / nullif(sum(order_count), 0) as return_rate
    from daily
    group by date_trunc('month', order_date)
)

select * from final
