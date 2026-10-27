select
    purchase_transaction_key,

    {{ dbt_utils.generate_surrogate_key([
        'voucher_number',
        'voucher_line_number',
        'copy_sequence_number',
        'po_number',
        'release_number',
        'po_line_number'
    ]) }} as expected_purchase_transaction_key,

    voucher_number,
    voucher_line_number,
    copy_sequence_number,
    po_number,
    release_number,
    po_line_number

from {{ ref('fct_purchase_orders') }}

where purchase_transaction_key <>
    {{ dbt_utils.generate_surrogate_key([
        'voucher_number',
        'voucher_line_number',
        'copy_sequence_number',
        'po_number',
        'release_number',
        'po_line_number'
    ]) }}