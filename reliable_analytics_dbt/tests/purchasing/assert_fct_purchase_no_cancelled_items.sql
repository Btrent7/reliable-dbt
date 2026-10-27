select
    purchase_transaction_key,
    po_number,
    release_number,
    po_line_number,
    voucher_number,
    voucher_line_number,
    item_number

from {{ ref('fct_purchase_orders') }}

where item_number like '%CANCELLED%'