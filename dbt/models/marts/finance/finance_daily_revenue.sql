-- Daily revenue breakdown by payment method
with daily as (
    select * from {{ ref('int_daily_orders') }}
),

payments as (
    select * from {{ ref('int_payment_method_analysis') }}
),

final as (
    select
        d.order_date,
        d.order_count,
        d.daily_revenue,
        d.avg_order_value,
        d.items_sold,
        d.unique_customers,
        d.completed_count,
        d.returned_count,
        d.daily_revenue - coalesce(lag(d.daily_revenue) over (order by d.order_date), 0) as revenue_change
    from daily d
)

select * from final
