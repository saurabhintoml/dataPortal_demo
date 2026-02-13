
    
    

with all_values as (

    select
        product_category as value_field,
        count(*) as n_records

    from ANALYTICS.STAGING.stg_products
    group by product_category

)

select *
from all_values
where value_field not in (
    'Food','Beverage','Merchandise','Gift'
)


