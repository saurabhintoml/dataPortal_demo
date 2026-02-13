-- Product inventory velocity and demand signals
with items as (
    select * from {{ ref('fct_order_items') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

monthly_demand as (
    select
        i.product_id,
        date_trunc('month', i.order_date) as order_month,
        sum(i.quantity) as units_sold,
        sum(i.line_total) as revenue,
        count(distinct i.order_id) as order_count
    from items i
    group by i.product_id, date_trunc('month', i.order_date)
),

final as (
    select
        md.product_id,
        p.product_name,
        p.product_category,
        md.order_month,
        md.units_sold,
        md.revenue,
        md.order_count,
        p.avg_rating,
        p.margin_pct,
        case
            when md.units_sold >= 10 then 'Fast Moving'
            when md.units_sold >= 5 then 'Medium Moving'
            else 'Slow Moving'
        end as velocity_tier
    from monthly_demand md
    left join products p on md.product_id = p.product_id
)

select * from final
