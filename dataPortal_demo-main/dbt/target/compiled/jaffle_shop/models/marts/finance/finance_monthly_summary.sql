-- Monthly P&L style summary
with monthly as (
    select * from ANALYTICS.STAGING.int_monthly_orders
),

line_items as (
    select
        date_trunc('month', order_date) as order_month,
        sum(line_profit) as total_profit,
        sum(line_cost) as total_cogs
    from ANALYTICS.STAGING.fct_order_items
    group by date_trunc('month', order_date)
),

final as (
    select
        m.order_month,
        m.order_count,
        m.monthly_revenue as gross_revenue,
        li.total_cogs,
        li.total_profit as gross_profit,
        case when m.monthly_revenue > 0
            then li.total_profit / m.monthly_revenue * 100
            else 0
        end as gross_margin_pct,
        m.avg_order_value,
        m.items_sold,
        m.completed_count,
        m.returned_count,
        m.return_rate
    from monthly m
    left join line_items li on m.order_month = li.order_month
)

select * from final