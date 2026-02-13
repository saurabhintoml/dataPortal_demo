-- RFM (Recency, Frequency, Monetary) scoring
with history as (
    select * from {{ ref('int_customer_order_history') }}
),

rfm_calc as (
    select
        customer_id,
        last_order_date,
        lifetime_orders as frequency,
        lifetime_spend as monetary,
        -- Recency: days since last order (relative to max order date)
        datediff('day', last_order_date, (select max(last_order_date) from history)) as recency_days
    from history
),

final as (
    select
        customer_id,
        recency_days,
        frequency,
        monetary,
        case
            when recency_days <= 30 then 5
            when recency_days <= 60 then 4
            when recency_days <= 90 then 3
            when recency_days <= 120 then 2
            else 1
        end as recency_score,
        case
            when frequency >= 5 then 5
            when frequency >= 4 then 4
            when frequency >= 3 then 3
            when frequency >= 2 then 2
            else 1
        end as frequency_score,
        case
            when monetary >= 100 then 5
            when monetary >= 75 then 4
            when monetary >= 50 then 3
            when monetary >= 25 then 2
            else 1
        end as monetary_score
    from rfm_calc
)

select * from final
