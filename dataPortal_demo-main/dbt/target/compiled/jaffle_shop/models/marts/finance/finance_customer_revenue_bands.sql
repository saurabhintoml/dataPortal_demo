-- Customer revenue band distribution for finance planning
with customers as (
    select * from ANALYTICS.STAGING.dim_customers
),

final as (
    select
        case
            when lifetime_spend >= 100 then '$100+'
            when lifetime_spend >= 75 then '$75-99'
            when lifetime_spend >= 50 then '$50-74'
            when lifetime_spend >= 25 then '$25-49'
            when lifetime_spend > 0 then '$1-24'
            else '$0'
        end as revenue_band,
        count(customer_id) as customer_count,
        sum(lifetime_spend) as band_total_revenue,
        avg(lifetime_spend) as avg_spend,
        avg(lifetime_orders) as avg_orders,
        min(first_order_date) as earliest_customer,
        max(last_order_date) as latest_activity
    from customers
    group by
        case
            when lifetime_spend >= 100 then '$100+'
            when lifetime_spend >= 75 then '$75-99'
            when lifetime_spend >= 50 then '$50-74'
            when lifetime_spend >= 25 then '$25-49'
            when lifetime_spend > 0 then '$1-24'
            else '$0'
        end
)

select * from final