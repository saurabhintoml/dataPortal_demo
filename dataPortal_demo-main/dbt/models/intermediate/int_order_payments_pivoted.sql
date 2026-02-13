-- Pivots payments by method for each order
{% set payment_methods = ['credit_card', 'coupon', 'bank_transfer', 'gift_card'] %}

with payments as (
    select * from {{ ref('stg_payments') }}
),

final as (
    select
        order_id,
        {% for method in payment_methods -%}
        sum(case when payment_method = '{{ method }}' then amount else 0 end) as {{ method }}_amount,
        {% endfor -%}
        sum(amount) as total_payment_amount,
        count(*) as payment_count
    from payments
    group by order_id
)

select * from final
