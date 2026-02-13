-- Segments customers by behavior
with history as (
    select * from {{ ref('int_customer_order_history') }}
),

final as (
    select
        customer_id,
        lifetime_orders,
        lifetime_spend,
        avg_order_value,
        case
            when lifetime_orders >= 4 and lifetime_spend >= 50 then 'VIP'
            when lifetime_orders >= 2 then 'Regular'
            when lifetime_orders = 1 then 'New'
            else 'Inactive'
        end as customer_segment,
        case
            when avg_order_value >= 30 then 'High'
            when avg_order_value >= 15 then 'Medium'
            else 'Low'
        end as spend_tier,
        case
            when returned_orders > 0 then true
            else false
        end as has_returns,
        returned_orders * 1.0 / nullif(lifetime_orders, 0) as return_rate
    from history
)

select * from final
