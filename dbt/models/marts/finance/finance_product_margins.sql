-- Product-level margin analysis for finance
with profitability as (
    select * from {{ ref('int_product_profitability') }}
),

reviews as (
    select * from {{ ref('int_product_reviews_agg') }}
),

final as (
    select
        p.product_id,
        p.product_name,
        p.product_category,
        p.unit_price,
        p.supply_cost,
        p.unit_margin,
        p.margin_pct,
        p.total_units_sold,
        p.total_revenue,
        p.total_cost,
        p.gross_profit,
        r.avg_rating,
        r.review_count,
        case
            when p.margin_pct >= 50 then 'High Margin'
            when p.margin_pct >= 30 then 'Medium Margin'
            else 'Low Margin'
        end as margin_category
    from profitability p
    left join reviews r on p.product_id = r.product_id
)

select * from final
