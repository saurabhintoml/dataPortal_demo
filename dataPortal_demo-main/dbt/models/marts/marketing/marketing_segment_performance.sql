-- Performance metrics by customer segment
with customers as (
    select * from {{ ref('dim_customers') }}
),

final as (
    select
        customer_segment,
        spend_tier,
        count(customer_id) as customer_count,
        avg(lifetime_orders) as avg_orders,
        avg(lifetime_spend) as avg_spend,
        sum(lifetime_spend) as total_revenue,
        avg(avg_order_value) as avg_aov,
        sum(case when has_returns then 1 else 0 end) as customers_with_returns,
        avg(return_rate) as avg_return_rate,
        avg(rfm_total_score) as avg_rfm_score
    from customers
    group by customer_segment, spend_tier
)

select * from final
