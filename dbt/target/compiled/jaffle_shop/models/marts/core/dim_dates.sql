-- Date dimension derived from order dates
with order_dates as (
    select distinct order_date
    from ANALYTICS.STAGING.stg_orders
),

final as (
    select
        order_date as date_day,
        extract(year from order_date) as year_number,
        extract(month from order_date) as month_number,
        to_char(order_date, 'MMMM') as month_name,
        extract(week from order_date) as week_number,
        dayofweek(order_date) as day_of_week,
        dayname(order_date) as day_name,
        case when dayofweek(order_date) in (0, 6) then true else false end as is_weekend,
        date_trunc('month', order_date) as first_day_of_month,
        extract(quarter from order_date) as quarter_number
    from order_dates
)

select * from final