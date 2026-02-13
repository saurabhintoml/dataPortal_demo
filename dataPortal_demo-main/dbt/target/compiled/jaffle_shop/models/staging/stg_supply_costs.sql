with source as (
    select * from ANALYTICS.STAGING.raw_supply_costs
),

renamed as (
    select
        id as supply_cost_id,
        product_id,
        cost_cents / 100.0 as supply_cost,
        effective_from,
        effective_to
    from source
)

select * from renamed