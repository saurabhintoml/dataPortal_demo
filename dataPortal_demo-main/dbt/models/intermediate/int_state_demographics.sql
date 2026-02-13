-- Customer count and order metrics by state
with addresses as (
    select * from {{ ref('int_customer_addresses') }}
),

segments as (
    select * from {{ ref('int_customer_segments') }}
),

history as (
    select * from {{ ref('int_customer_order_history') }}
),

final as (
    select
        a.state,
        a.city,
        count(distinct a.customer_id) as customer_count,
        sum(h.lifetime_orders) as total_orders,
        sum(h.lifetime_spend) as total_revenue,
        avg(h.lifetime_spend) as avg_customer_spend,
        sum(case when s.customer_segment = 'VIP' then 1 else 0 end) as vip_customers,
        sum(case when s.customer_segment = 'New' then 1 else 0 end) as new_customers
    from addresses a
    left join segments s on a.customer_id = s.customer_id
    left join history h on a.customer_id = h.customer_id
    group by a.state, a.city
)

select * from final
