with source as (
    select * from {{ ref('raw_addresses') }}
),

renamed as (
    select
        id as address_id,
        customer_id,
        address_type,
        city,
        state,
        zip_code,
        case when is_primary = 1 then true else false end as is_primary
    from source
)

select * from renamed
