
    
    

select
    promotion_id as unique_field,
    count(*) as n_records

from ANALYTICS.STAGING.stg_promotions
where promotion_id is not null
group by promotion_id
having count(*) > 1


