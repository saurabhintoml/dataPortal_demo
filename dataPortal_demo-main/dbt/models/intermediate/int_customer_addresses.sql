-- Gets primary shipping address per customer
with addresses as (
    select * from {{ ref('stg_addresses') }}
),

final as (
    select
        customer_id,
        city,
        state,
        zip_code,
        address_type
    from addresses
    where is_primary = true and address_type = 'shipping'
)

select * from final
