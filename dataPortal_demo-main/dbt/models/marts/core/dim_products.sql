-- Core product dimension with reviews and profitability
with products as (
    select * from {{ ref('stg_products') }}
),

reviews as (
    select * from {{ ref('int_product_reviews_agg') }}
),

profitability as (
    select * from {{ ref('int_product_profitability') }}
),

final as (
    select
        p.product_id,
        p.product_name,
        p.product_category,
        p.unit_price,
        pr.supply_cost,
        pr.unit_margin,
        pr.margin_pct,
        r.review_count,
        r.avg_rating,
        r.positive_reviews,
        r.negative_reviews,
        case
            when r.avg_rating >= 4.5 then 'Excellent'
            when r.avg_rating >= 3.5 then 'Good'
            when r.avg_rating >= 2.5 then 'Average'
            else 'Poor'
        end as rating_tier,
        pr.total_units_sold,
        pr.total_revenue as product_total_revenue,
        pr.gross_profit as product_gross_profit,
        p.created_at
    from products p
    left join reviews r on p.product_id = r.product_id
    left join profitability pr on p.product_id = pr.product_id
)

select * from final
