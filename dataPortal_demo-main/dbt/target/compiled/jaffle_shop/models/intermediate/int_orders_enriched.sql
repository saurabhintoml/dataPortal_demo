-- Combines orders with payment and item details
with orders as (
    select * from ANALYTICS.STAGING.stg_orders
),

order_totals as (
    select * from ANALYTICS.STAGING.int_order_totals
),

order_payments as (
    select * from ANALYTICS.STAGING.int_order_payments_pivoted
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        ot.total_items,
        ot.total_quantity,
        ot.items_subtotal,
        ot.distinct_categories,
        op.credit_card_amount,
        op.coupon_amount,
        op.bank_transfer_amount,
        op.gift_card_amount,
        op.total_payment_amount,
        op.payment_count,
        case
            when o.status = 'completed' then true
            else false
        end as is_completed,
        case
            when o.status in ('returned', 'return_pending') then true
            else false
        end as is_returned
    from orders o
    left join order_totals ot on o.order_id = ot.order_id
    left join order_payments op on o.order_id = op.order_id
)

select * from final