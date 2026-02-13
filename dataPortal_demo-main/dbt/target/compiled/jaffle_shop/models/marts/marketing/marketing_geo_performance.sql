-- Geographic performance for marketing targeting
with demographics as (
    select * from ANALYTICS.STAGING.int_state_demographics
),

final as (
    select
        state,
        city,
        customer_count,
        total_orders,
        total_revenue,
        avg_customer_spend,
        vip_customers,
        new_customers,
        case when customer_count > 0
            then vip_customers * 1.0 / customer_count * 100
            else 0
        end as vip_pct,
        case when customer_count > 0
            then total_revenue / customer_count
            else 0
        end as revenue_per_customer
    from demographics
)

select * from final