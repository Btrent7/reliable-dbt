select
    purchase_transaction_key,
    po_number,
    release_number,
    po_line_number,
    warehouse

from {{ ref('fct_purchase_orders') }}

where warehouse = 'MFG'