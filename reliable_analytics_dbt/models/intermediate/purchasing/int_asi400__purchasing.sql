/*
Purpose:
Build an analysis-ready intermediate purchasing dataset from
legacy AS400 purchase orders, voucher transactions, item data,
and enterprise date mappings.

Grain:
One qualifying voucher-detail transaction associated with one
qualifying AS400 purchase-order line.

Expected unique key:
voucher_number
+ voucher_line_number
+ copy_sequence_number
+ po_number
+ release_number
+ po_line_number

Purchasing scope:
- RSLE items
- received purchase-order lines
- warehouse <> 'MFG'
- cancelled PO-line and voucher-line item records excluded
- purchase orders issued in calendar year 2025 or later

Relationship rules:
- PO lines join to PO headers using PO number + release number
- Voucher lines join to PO lines using PO number + release number
  + PO line number + item number
- Voucher headers join to voucher lines using voucher number
- Issue dates must map through the existing date dimension because
  issue year defines the reporting scope
- Receipt, invoice, voucher, and paid dates are mapped when available
- Unmapped secondary date keys are preserved for reconciliation

No DISTINCT-based deduplication is applied.
*/

with po_lines as (

    select
        po_number,
        release_number,
        po_line_number,
        item_number,
        vendor_id,
        vendor_suffix,
        warehouse,
        issued_date_key,
        received_date_key,
        unit_price,
        authorized_quantity,
        received_quantity,
        vouched_quantity,
        cancelled_quantity,
        unit_of_measure,
        status

    from {{ ref('stg_asi400__po_lines') }}

),

po_headers as (

    select
        po_number,
        release_number,
        po_type,
        po_status_code,
        buyer_id

    from {{ ref('stg_asi400__po_headers') }}

),

voucher_lines as (

    select
        voucher_number,
        voucher_line_number,
        copy_sequence_number,
        po_number,
        release_number,
        po_line_number,
        item_number,
        vendor_item_number,
        item_quantity,
        unit_of_measure,
        item_unit_price,
        item_gross_amount,
        freight_amount,
        tax_amount,
        discount_amount,
        detail_net_amount,
        item_charge_to_indicator,
        item_charge_to_account,
        status

    from {{ ref('stg_asi400__voucher_lines') }}

),

voucher_headers as (

    select
        voucher_number,
        invoice_number,
        invoice_date_key,
        voucher_date_key,
        paid_date_key,
        invoice_item_amount,
        invoice_freight_amount,
        invoice_tax_amount,
        invoice_discount_amount,
        check_amount,
        accounting_period

    from {{ ref('stg_asi400__voucher_headers') }}

),

items as (

    select
        item_number,
        item_description,
        item_status,
        product_group,
        buyer_id,
        commodity_code,
        vendor_id,
        item_type,
        item_class_code,
        product_category

    from {{ ref('stg_asi400__items') }}

),

dates as (

    select
        legacy_date_key,
        calendar_date,
        calendar_year,
        calendar_month,
        calendar_day,
        calendar_day_of_year,
        fiscal_year,
        fiscal_period,
        fiscal_week

    from {{ ref('stg_asi400__dates') }}

),

qualifying_po_lines as (

    select
        po.po_number,
        po.release_number,
        po.po_line_number,
        po.item_number,

        item.item_description,
        item.item_class_code,
        item.product_group,
        item.product_category,
        item.commodity_code,

        po.vendor_id,
        po.vendor_suffix,
        po.warehouse,

        po.issued_date_key,
        po.received_date_key,

        po.unit_price,
        po.authorized_quantity,
        po.received_quantity,
        po.vouched_quantity,
        po.cancelled_quantity,
        po.unit_of_measure,

        po.status as po_line_status

    from po_lines as po

    inner join items as item
        on po.item_number = item.item_number

    where item.item_class_code = 'RSLE'
      and po.received_date_key > 0
      and po.warehouse <> 'MFG'
      and po.item_number not like '%CANCELLED%'

),

purchase_order_detail as (

    select
        po.po_number,
        po.release_number,
        po.po_line_number,
        po.item_number,

        po.item_description,
        po.item_class_code,
        po.product_group,
        po.product_category,
        po.commodity_code,

        po.vendor_id,
        po.vendor_suffix,
        po.warehouse,

        header.po_type,
        header.po_status_code,
        header.buyer_id,

        po.issued_date_key,
        po.received_date_key,

        po.unit_price,
        po.authorized_quantity,
        po.received_quantity,
        po.vouched_quantity,
        po.cancelled_quantity,
        po.unit_of_measure,

        po.po_line_status

    from qualifying_po_lines as po

    inner join po_headers as header
        on po.po_number = header.po_number
        and po.release_number = header.release_number

),

purchasing_with_vouchers as (

    select
        po.po_number,
        po.release_number,
        po.po_line_number,
        po.item_number,

        po.item_description,
        po.item_class_code,
        po.product_group,
        po.product_category,
        po.commodity_code,

        po.vendor_id,
        po.vendor_suffix,
        po.warehouse,

        po.po_type,
        po.po_status_code,
        po.buyer_id,

        po.issued_date_key,
        po.received_date_key,

        po.unit_price,
        po.authorized_quantity,
        po.received_quantity,
        po.vouched_quantity,
        po.cancelled_quantity,
        po.unit_of_measure,

        po.po_line_status,

        voucher.voucher_number,
        voucher.voucher_line_number,
        voucher.copy_sequence_number,

        voucher.vendor_item_number,
        voucher.item_quantity as voucher_item_quantity,
        voucher.unit_of_measure as voucher_unit_of_measure,
        voucher.item_unit_price as voucher_item_unit_price,

        voucher.item_gross_amount,
        voucher.freight_amount,
        voucher.tax_amount,
        voucher.discount_amount,
        voucher.detail_net_amount,

        voucher.item_charge_to_indicator,
        voucher.item_charge_to_account,
        voucher.status as voucher_line_status

    from purchase_order_detail as po

    inner join voucher_lines as voucher
        on po.po_number = voucher.po_number
        and po.release_number = voucher.release_number
        and po.po_line_number = voucher.po_line_number
        and po.item_number = voucher.item_number

    where voucher.item_number not like '%CANCELLED%'

),

purchasing_with_voucher_headers as (

    select
        purchase.*,

        voucher_header.invoice_number,
        voucher_header.invoice_date_key,
        voucher_header.voucher_date_key,
        voucher_header.paid_date_key,

        voucher_header.invoice_item_amount,
        voucher_header.invoice_freight_amount,
        voucher_header.invoice_tax_amount,
        voucher_header.invoice_discount_amount,
        voucher_header.check_amount,
        voucher_header.accounting_period

    from purchasing_with_vouchers as purchase

    inner join voucher_headers as voucher_header
        on purchase.voucher_number = voucher_header.voucher_number

),

final as (

    select
        purchase.po_number,
        purchase.release_number,
        purchase.po_line_number,
        purchase.item_number,

        purchase.item_description,
        purchase.item_class_code,
        purchase.product_group,
        purchase.product_category,
        purchase.commodity_code,

        purchase.vendor_id,
        purchase.vendor_suffix,
        purchase.warehouse,

        purchase.po_type,
        purchase.po_status_code,
        purchase.buyer_id,

        purchase.issued_date_key,
        issued.calendar_date as date_issued,

        purchase.received_date_key,
        received.calendar_date as date_received,

        purchase.invoice_date_key,
        invoiced.calendar_date as date_invoiced,

        purchase.voucher_date_key,
        vouchered.calendar_date as date_vouchered,

        purchase.paid_date_key,
        paid.calendar_date as date_paid,

        case
            when received.legacy_date_key is not null then 1
            else 0
        end as is_received_date_mapped,

        case
            when invoiced.legacy_date_key is not null then 1
            else 0
        end as is_invoice_date_mapped,

        case
            when vouchered.legacy_date_key is not null then 1
            else 0
        end as is_voucher_date_mapped,

        case
            when paid.legacy_date_key is not null then 1
            else 0
        end as is_paid_date_mapped,

        purchase.unit_price,
        purchase.authorized_quantity,
        purchase.received_quantity,
        purchase.vouched_quantity,
        purchase.cancelled_quantity,
        purchase.unit_of_measure,

        purchase.voucher_number,
        purchase.voucher_line_number,
        purchase.copy_sequence_number,
        purchase.vendor_item_number,

        purchase.voucher_item_quantity,
        purchase.voucher_unit_of_measure,
        purchase.voucher_item_unit_price,

        purchase.item_gross_amount,
        purchase.freight_amount,
        purchase.tax_amount,
        purchase.discount_amount,
        purchase.detail_net_amount,

        purchase.invoice_number,
        purchase.invoice_item_amount,
        purchase.invoice_freight_amount,
        purchase.invoice_tax_amount,
        purchase.invoice_discount_amount,
        purchase.check_amount,
        purchase.accounting_period,

        purchase.item_charge_to_indicator,
        purchase.item_charge_to_account,

        purchase.po_line_status,
        purchase.voucher_line_status

    from purchasing_with_voucher_headers as purchase

    /*
    Issue-date mapping remains an inner join because the mapped
    calendar year defines inclusion in this model.
    */
    inner join dates as issued
        on purchase.issued_date_key = issued.legacy_date_key

    /*
    Secondary date mappings are optional enrichments. A source
    transaction is retained when one of these date keys does not
    have a matching DimDate record.
    */
    left join dates as received
        on purchase.received_date_key = received.legacy_date_key

    left join dates as invoiced
        on purchase.invoice_date_key = invoiced.legacy_date_key

    left join dates as vouchered
        on purchase.voucher_date_key = vouchered.legacy_date_key

    left join dates as paid
        on purchase.paid_date_key = paid.legacy_date_key

    where issued.calendar_year >= 2025

)

select
    po_number,
    release_number,
    po_line_number,
    item_number,

    item_description,
    item_class_code,
    product_group,
    product_category,
    commodity_code,

    vendor_id,
    vendor_suffix,
    warehouse,

    po_type,
    po_status_code,
    buyer_id,

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

    unit_price,
    authorized_quantity,
    received_quantity,
    vouched_quantity,
    cancelled_quantity,
    unit_of_measure,

    voucher_number,
    voucher_line_number,
    copy_sequence_number,
    vendor_item_number,

    voucher_item_quantity,
    voucher_unit_of_measure,
    voucher_item_unit_price,

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
    item_charge_to_account,

    po_line_status,
    voucher_line_status

from final