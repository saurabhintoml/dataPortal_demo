-- Category mix analysis for operations planning
with category_perf as (
    select * from ANALYTICS.STAGING.int_category_performance
),

monthly_totals as (
    select
        order_month,
        sum(category_revenue) as total_monthly_revenue,
        sum(units_sold) as total_monthly_units
    from category_perf
    group by order_month
),

final as (
    select
        cp.product_category,
        cp.order_month,
        cp.order_count,
        cp.units_sold,
        cp.category_revenue,
        cp.unique_customers,
        cp.avg_line_value,
        mt.total_monthly_revenue,
        case when mt.total_monthly_revenue > 0
            then cp.category_revenue / mt.total_monthly_revenue * 100
            else 0
        end as revenue_share_pct,
        case when mt.total_monthly_units > 0
            then cp.units_sold * 1.0 / mt.total_monthly_units * 100
            else 0
        end as volume_share_pct
    from category_perf cp
    left join monthly_totals mt on cp.order_month = mt.order_month
)

select * from final