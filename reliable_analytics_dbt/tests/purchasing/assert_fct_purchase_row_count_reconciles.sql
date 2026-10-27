with intermediate as (

    select
        count(*) as row_count
    from {{ ref('int_asi400__purchasing') }}

),

fact as (

    select
        count(*) as row_count
    from {{ ref('fct_purchase_orders') }}

)

select
    intermediate.row_count as intermediate_row_count,
    fact.row_count as fact_row_count

from intermediate
cross join fact

where intermediate.row_count <> fact.row_count