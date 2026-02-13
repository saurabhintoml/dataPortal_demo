-- Core customer dimension with all attributes
with customers as (
    select * from {{ ref('stg_customers') }}
),

segments as (
    select * from {{ ref('int_customer_segments') }}
),

rfm as (
    select * from {{ ref('int_customer_rfm') }}
),

addresses as (
    select * from {{ ref('int_customer_addresses') }}
),

history as (
    select * from {{ ref('int_customer_order_history') }}
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.first_name || ' ' || c.last_name as full_name,
        a.city,
        a.state,
        a.zip_code,
        s.customer_segment,
        s.spend_tier,
        s.has_returns,
        s.return_rate,
        r.recency_score,
        r.frequency_score,
        r.monetary_score,
        r.recency_score + r.frequency_score + r.monetary_score as rfm_total_score,
        h.lifetime_orders,
        h.completed_orders,
        h.returned_orders,
        h.first_order_date,
        h.last_order_date,
        h.lifetime_spend,
        h.avg_order_value,
        h.lifetime_items_purchased
    from customers c
    left join segments s on c.customer_id = s.customer_id
    left join rfm r on c.customer_id = r.customer_id
    left join addresses a on c.customer_id = a.customer_id
    left join history h on c.customer_id = h.customer_id
)

select * from final
