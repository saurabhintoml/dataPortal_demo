-- Identifies repeat vs one-time customers
with history as (
    select * from ANALYTICS.STAGING.int_customer_order_history
),

final as (
    select
        customer_id,
        lifetime_orders,
        lifetime_spend,
        case
            when lifetime_orders > 1 then true
            else false
        end as is_repeat_customer,
        case
            when lifetime_orders >= 5 then 'Champion'
            when lifetime_orders >= 3 then 'Loyal'
            when lifetime_orders = 2 then 'Repeat'
            else 'One-time'
        end as loyalty_tier,
        completed_orders * 1.0 / nullif(lifetime_orders, 0) as completion_rate
    from history
)

select * from final