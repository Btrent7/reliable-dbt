/*
Grain:
One voucher header.

Confirmed unique key:
voucher_number

Relationship:
One voucher header can be associated with multiple voucher-detail
records through voucher_number.
*/

select
    VCHNO as voucher_number,
    PONBR as po_number,
    RLSENO as release_number,
    PLT as warehouse,
    VNDID as vendor_id,
    VNDSFX as vendor_suffix,
    INVNO as invoice_number,
    INVDTE as invoice_date_key,
    VCHDTE as voucher_date_key,
    DTEPAID as paid_date_key,
    INVITMAMT as invoice_item_amount,
    INVFRTAMT as invoice_freight_amount,
    INVTAXAMT as invoice_tax_amount,
    INVDISAMT as invoice_discount_amount,
    CHKAMT as check_amount,
    ACCTPER as accounting_period

from {{ source('asi400', 'DPHVCH1') }}
