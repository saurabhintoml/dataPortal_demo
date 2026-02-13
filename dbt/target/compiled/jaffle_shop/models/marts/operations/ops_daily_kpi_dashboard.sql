-- Daily KPI dashboard combining multiple metrics
with daily as (
    select * from ANALYTICS.STAGING.int_daily_orders
),

running as (
    select
        order_date,
        order_count,
        daily_revenue,
        avg_order_value,
        items_sold,
        unique_customers,
        completed_count,
        returned_count,
        sum(daily_revenue) over (order by order_date) as cumulative_revenue,
        sum(order_count) over (order by order_date) as cumulative_orders,
        avg(daily_revenue) over (
            order by order_date
            rows between 6 preceding and current row
        ) as revenue_7day_avg,
        avg(order_count) over (
            order by order_date
            rows between 6 preceding and current row
        ) as orders_7day_avg
    from daily
)

select * from running