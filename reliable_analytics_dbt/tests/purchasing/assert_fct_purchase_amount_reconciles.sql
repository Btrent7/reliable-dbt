with intermediate as (

    select
        sum(
            cast(
                voucher_item_quantity * voucher_item_unit_price
                as decimal(38, 6)
            )
        ) as extended_amount

    from {{ ref('int_asi400__purchasing') }}

),

fact as (

    select
        sum(voucher_extended_amount) as extended_amount

    from {{ ref('fct_purchase_orders') }}

)

select
    intermediate.extended_amount as intermediate_extended_amount,
    fact.extended_amount as fact_extended_amount,
    intermediate.extended_amount - fact.extended_amount as difference

from intermediate
cross join fact

where intermediate.extended_amount <> fact.extended_amount