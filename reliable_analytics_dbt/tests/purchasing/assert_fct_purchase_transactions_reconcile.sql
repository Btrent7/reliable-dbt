with intermediate as (

    select
        voucher_number,
        voucher_line_number,
        copy_sequence_number,
        po_number,
        release_number,
        po_line_number

    from {{ ref('int_asi400__purchasing') }}

),

fact as (

    select
        voucher_number,
        voucher_line_number,
        copy_sequence_number,
        po_number,
        release_number,
        po_line_number

    from {{ ref('fct_purchase_orders') }}

),

missing_from_fact as (

    select
        intermediate.*

    from intermediate

    left join fact
        on intermediate.voucher_number = fact.voucher_number
        and intermediate.voucher_line_number = fact.voucher_line_number
        and intermediate.copy_sequence_number = fact.copy_sequence_number
        and intermediate.po_number = fact.po_number
        and intermediate.release_number = fact.release_number
        and intermediate.po_line_number = fact.po_line_number

    where fact.voucher_number is null

),

unexpected_in_fact as (

    select
        fact.*

    from fact

    left join intermediate
        on fact.voucher_number = intermediate.voucher_number
        and fact.voucher_line_number = intermediate.voucher_line_number
        and fact.copy_sequence_number = intermediate.copy_sequence_number
        and fact.po_number = intermediate.po_number
        and fact.release_number = intermediate.release_number
        and fact.po_line_number = intermediate.po_line_number

    where intermediate.voucher_number is null

)

select
    'missing_from_fact' as reconciliation_error,
    *
from missing_from_fact

union all

select
    'unexpected_in_fact' as reconciliation_error,
    *
from unexpected_in_fact