select
    voucher_number,
    voucher_line_number,
    copy_sequence_number,
    po_number,
    release_number,
    po_line_number,
    count(*) as row_count

from {{ ref('fct_purchase_orders') }}

group by
    voucher_number,
    voucher_line_number,
    copy_sequence_number,
    po_number,
    release_number,
    po_line_number

having count(*) > 1