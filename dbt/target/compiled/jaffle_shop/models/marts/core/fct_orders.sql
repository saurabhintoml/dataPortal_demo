-- Core fact table for orders with all enrichments
with orders as (
    select * from ANALYTICS.STAGING.int_orders_enriched
),

customers as (
    select * from ANALYTICS.STAGING.stg_customers
),

final as (
    select
        o.order_id,
        o.customer_id,
        c.first_name || ' ' || c.last_name as customer_name,
        o.order_date,
        o.status,
        o.is_completed,
        o.is_returned,
        o.total_items,
        o.total_quantity,
        o.items_subtotal,
        o.distinct_categories,
        o.credit_card_amount,
        o.coupon_amount,
        o.bank_transfer_amount,
        o.gift_card_amount,
        o.total_payment_amount,
        o.payment_count,
        case
            when o.total_payment_amount >= 50 then 'Large'
            when o.total_payment_amount >= 20 then 'Medium'
            else 'Small'
        end as order_size_bucket
    from orders o
    left join customers c on o.customer_id = c.customer_id
)

select * from final