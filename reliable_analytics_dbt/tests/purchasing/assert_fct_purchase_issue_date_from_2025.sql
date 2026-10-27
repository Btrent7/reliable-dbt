select
    purchase_transaction_key,
    po_number,
    release_number,
    po_line_number,
    date_issued

from {{ ref('fct_purchase_orders') }}

where date_issued < cast('2025-01-01' as date)