-- Customer cohort analysis by first order month
with customers as (
    select * from ANALYTICS.STAGING.dim_customers
),

orders as (
    select * from ANALYTICS.STAGING.fct_orders
),

cohort_base as (
    select
        c.customer_id,
        date_trunc('month', c.first_order_date) as cohort_month,
        o.order_date,
        o.total_payment_amount,
        -- months since first order
        datediff('month', c.first_order_date, o.order_date) as months_since_first
    from customers c
    inner join orders o on c.customer_id = o.customer_id
),

final as (
    select
        cohort_month,
        months_since_first as period_number,
        count(distinct customer_id) as active_customers,
        count(*) as order_count,
        sum(total_payment_amount) as cohort_revenue,
        avg(total_payment_amount) as avg_order_value
    from cohort_base
    group by cohort_month, months_since_first
)

select * from final