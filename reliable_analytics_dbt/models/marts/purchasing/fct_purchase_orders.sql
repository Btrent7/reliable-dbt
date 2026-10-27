/*
Purpose:
Provide a business-ready purchasing fact table for downstream
finance, BI, and analytical reporting.

Grain:
One qualifying AS400 voucher-detail transaction associated with
one purchase-order line.

Natural/composite key:
voucher_number
+ voucher_line_number
+ copy_sequence_number
+ po_number
+ release_number
+ po_line_number

The purchase_transaction_key surrogate key is generated from
the validated natural key using dbt_utils.

Source:
int_asi400__purchasing

Financial measures:
- voucher_extended_amount = voucher item quantity * voucher item unit price
- item_gross_amount = source voucher-line gross amount
- detail_net_amount = source voucher-line net/detail amount

The different monetary fields are intentionally preserved rather
than treated as interchangeable financial measures.

Legacy date keys and mapping indicators are retained for
reconciliation and data-quality monitoring.
*/

with purchasing as (

    select
        *
    from {{ ref('int_asi400__purchasing') }}

),

final as (

    select

        {{ dbt_utils.generate_surrogate_key([
            'voucher_number',
            'voucher_line_number',
            'copy_sequence_number',
            'po_number',
            'release_number',
            'po_line_number'
        ]) }} as purchase_transaction_key,

        po_number,
        release_number,
        po_line_number,

        voucher_number,
        voucher_line_number,
        copy_sequence_number,

        item_number,
        item_description,
        item_class_code,
        product_group,
        product_category,
        commodity_code,

        vendor_id,
        vendor_suffix,
        vendor_item_number,

        warehouse,
        buyer_id,

        po_type,
        po_status_code,
        po_line_status,
        voucher_line_status,

        issued_date_key,
        date_issued,

        received_date_key,
        date_received,

        invoice_date_key,
        date_invoiced,

        voucher_date_key,
        date_vouchered,

        paid_date_key,
        date_paid,

        is_received_date_mapped,
        is_invoice_date_mapped,
        is_voucher_date_mapped,
        is_paid_date_mapped,

        unit_of_measure,
        unit_price,

        authorized_quantity,
        received_quantity,
        vouched_quantity,
        cancelled_quantity,

        voucher_unit_of_measure,
        voucher_item_quantity,
        voucher_item_unit_price,

        cast(
            voucher_item_quantity * voucher_item_unit_price
            as decimal(38, 6)
        ) as voucher_extended_amount,

        item_gross_amount,
        freight_amount,
        tax_amount,
        discount_amount,
        detail_net_amount,

        invoice_number,
        invoice_item_amount,
        invoice_freight_amount,
        invoice_tax_amount,
        invoice_discount_amount,
        check_amount,
        accounting_period,

        item_charge_to_indicator,
        item_charge_to_account

    from purchasing

)

select *
from final