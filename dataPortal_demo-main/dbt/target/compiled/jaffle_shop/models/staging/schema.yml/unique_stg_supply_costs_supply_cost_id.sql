
    
    

select
    supply_cost_id as unique_field,
    count(*) as n_records

from ANALYTICS.STAGING.stg_supply_costs
where supply_cost_id is not null
group by supply_cost_id
having count(*) > 1


