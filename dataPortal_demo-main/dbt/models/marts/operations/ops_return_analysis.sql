-- Detailed return analysis
with orders as (
    select * from {{ ref('fct_orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

returned as (
    select
        o.order_id,
        o.customer_id,
        o.customer_name,
        o.order_date,
        o.status,
        o.total_payment_amount,
        o.total_items,
        c.customer_segment,
        c.lifetime_orders,
        c.lifetime_spend
    from orders o
    left join customers c on o.customer_id = c.customer_id
    where o.is_returned = true
),

final as (
    select
        date_trunc('month', order_date) as return_month,
        count(order_id) as return_count,
        sum(total_payment_amount) as returned_value,
        avg(total_payment_amount) as avg_return_value,
        count(distinct customer_id) as customers_returning,
        sum(case when customer_segment = 'VIP' then 1 else 0 end) as vip_returns,
        sum(case when lifetime_orders = 1 then 1 else 0 end) as first_order_returns
    from returned
    group by date_trunc('month', order_date)
)

select * from final
