-- Payment channel attribution analysis for marketing
with orders as (
    select * from ANALYTICS.STAGING.fct_orders
),

customers as (
    select * from ANALYTICS.STAGING.dim_customers
),

final as (
    select
        c.customer_segment,
        c.spend_tier,
        case
            when o.credit_card_amount > 0 and o.coupon_amount > 0 then 'Mixed (CC+Coupon)'
            when o.credit_card_amount > 0 then 'Credit Card Only'
            when o.coupon_amount > 0 then 'Coupon Only'
            when o.bank_transfer_amount > 0 then 'Bank Transfer'
            when o.gift_card_amount > 0 then 'Gift Card'
            else 'Unknown'
        end as primary_payment_channel,
        count(distinct o.order_id) as order_count,
        sum(o.total_payment_amount) as total_revenue,
        avg(o.total_payment_amount) as avg_order_value,
        count(distinct o.customer_id) as unique_customers
    from orders o
    left join customers c on o.customer_id = c.customer_id
    group by
        c.customer_segment,
        c.spend_tier,
        case
            when o.credit_card_amount > 0 and o.coupon_amount > 0 then 'Mixed (CC+Coupon)'
            when o.credit_card_amount > 0 then 'Credit Card Only'
            when o.coupon_amount > 0 then 'Coupon Only'
            when o.bank_transfer_amount > 0 then 'Bank Transfer'
            when o.gift_card_amount > 0 then 'Gift Card'
            else 'Unknown'
        end
)

select * from final