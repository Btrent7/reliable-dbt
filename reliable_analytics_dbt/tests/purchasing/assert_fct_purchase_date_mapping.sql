select
    purchase_transaction_key,
    received_date_key,
    date_received,
    is_received_date_mapped,
    invoice_date_key,
    date_invoiced,
    is_invoice_date_mapped,
    voucher_date_key,
    date_vouchered,
    is_voucher_date_mapped,
    paid_date_key,
    date_paid,
    is_paid_date_mapped

from {{ ref('fct_purchase_orders') }}

where
       (is_received_date_mapped = 1 and date_received is null)

    or (is_received_date_mapped = 0 and date_received is not null)

    or (is_invoice_date_mapped = 1 and date_invoiced is null)

    or (is_invoice_date_mapped = 0 and date_invoiced is not null)

    or (is_voucher_date_mapped = 1 and date_vouchered is null)

    or (is_voucher_date_mapped = 0 and date_vouchered is not null)

    or (is_paid_date_mapped = 1 and date_paid is null)

    or (is_paid_date_mapped = 0 and date_paid is not null)