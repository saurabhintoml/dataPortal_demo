-- Promotion analysis (theoretical - maps promo validity to order periods)
with promotions as (
    select * from ANALYTICS.STAGING.stg_promotions
),

orders as (
    select * from ANALYTICS.STAGING.fct_orders
),

promo_orders as (
    select
        p.promotion_id,
        p.promotion_code,
        p.discount_pct,
        p.min_order_amount,
        p.valid_from,
        p.valid_to,
        count(distinct o.order_id) as orders_during_promo,
        sum(o.total_payment_amount) as revenue_during_promo,
        avg(o.total_payment_amount) as avg_order_during_promo,
        sum(o.coupon_amount) as coupon_usage_amount
    from promotions p
    left join orders o
        on o.order_date between p.valid_from and p.valid_to
        and o.total_payment_amount >= p.min_order_amount
    group by
        p.promotion_id, p.promotion_code, p.discount_pct,
        p.min_order_amount, p.valid_from, p.valid_to
)

select * from promo_orders