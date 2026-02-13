-- Customer LTV calculations
with customers as (
    select * from ANALYTICS.STAGING.dim_customers
),

orders as (
    select * from ANALYTICS.STAGING.fct_orders
),

order_gaps as (
    select
        customer_id,
        order_date,
        lag(order_date) over (partition by customer_id order by order_date) as prev_order_date,
        datediff('day', lag(order_date) over (partition by customer_id order by order_date), order_date) as days_between_orders
    from orders
),

avg_gaps as (
    select
        customer_id,
        avg(days_between_orders) as avg_days_between_orders,
        count(*) as repeat_purchases
    from order_gaps
    where days_between_orders is not null
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.full_name,
        c.customer_segment,
        c.spend_tier,
        c.state,
        c.lifetime_orders,
        c.lifetime_spend,
        c.avg_order_value,
        c.rfm_total_score,
        ag.avg_days_between_orders,
        ag.repeat_purchases,
        case
            when ag.avg_days_between_orders > 0 then 365.0 / ag.avg_days_between_orders
            else 1
        end as estimated_annual_orders,
        c.avg_order_value * case
            when ag.avg_days_between_orders > 0 then 365.0 / ag.avg_days_between_orders
            else 1
        end as estimated_annual_value
    from customers c
    left join avg_gaps ag on c.customer_id = ag.customer_id
)

select * from final