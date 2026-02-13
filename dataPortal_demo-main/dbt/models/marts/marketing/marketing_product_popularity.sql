-- Product popularity for marketing campaigns
with products as (
    select * from {{ ref('dim_products') }}
),

category_perf as (
    select * from {{ ref('int_category_performance') }}
),

cat_totals as (
    select
        product_category,
        sum(units_sold) as cat_total_units,
        sum(category_revenue) as cat_total_revenue
    from category_perf
    group by product_category
),

final as (
    select
        p.product_id,
        p.product_name,
        p.product_category,
        p.unit_price,
        p.avg_rating,
        p.rating_tier,
        p.review_count,
        p.total_units_sold,
        p.product_total_revenue,
        ct.cat_total_units as category_total_units,
        case when ct.cat_total_units > 0
            then p.total_units_sold * 1.0 / ct.cat_total_units * 100
            else 0
        end as pct_of_category_units,
        case
            when p.avg_rating >= 4 and p.total_units_sold > 5 then 'Star Product'
            when p.avg_rating >= 3.5 then 'Solid Performer'
            when p.total_units_sold > 5 then 'Volume Driver'
            else 'Niche'
        end as product_classification
    from products p
    left join cat_totals ct on p.product_category = ct.product_category
)

select * from final
