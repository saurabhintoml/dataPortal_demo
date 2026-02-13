-- Payment method distribution analysis
with payments as (
    select * from ANALYTICS.STAGING.int_payment_method_analysis
),

totals as (
    select
        order_month,
        sum(total_amount) as month_total
    from payments
    group by order_month
),

final as (
    select
        p.payment_method,
        p.order_month,
        p.transaction_count,
        p.order_count,
        p.total_amount,
        p.avg_amount,
        case when t.month_total > 0
            then p.total_amount / t.month_total * 100
            else 0
        end as pct_of_monthly_revenue
    from payments p
    left join totals t on p.order_month = t.order_month
)

select * from final