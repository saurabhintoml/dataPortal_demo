-- Analyzes payment methods across orders
with payments as (
    select * from ANALYTICS.STAGING.stg_payments
),

orders as (
    select * from ANALYTICS.STAGING.stg_orders
),

final as (
    select
        p.payment_method,
        date_trunc('month', o.order_date) as order_month,
        count(distinct p.payment_id) as transaction_count,
        count(distinct p.order_id) as order_count,
        sum(p.amount) as total_amount,
        avg(p.amount) as avg_amount,
        min(p.amount) as min_amount,
        max(p.amount) as max_amount
    from payments p
    left join orders o on p.order_id = o.order_id
    group by p.payment_method, date_trunc('month', o.order_date)
)

select * from final