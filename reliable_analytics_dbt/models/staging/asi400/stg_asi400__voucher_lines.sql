/*
Grain:
One voucher-detail record associated with a specific purchase-order line.

Candidate unique key:
voucher_number
+ voucher_line_number
+ copy_sequence_number
+ po_number
+ release_number
+ po_line_number
*/

select
    VCHNO as voucher_number,
    VCHLINNO as voucher_line_number,
    CPSEQNO as copy_sequence_number,
    PONBR as po_number,
    RLSENO as release_number,
    POLNNBR as po_line_number,
    ITMID as item_number,
    VNDSKU as vendor_item_number,
    ITMQTY as item_quantity,
    UOM as unit_of_measure,
    ITMUNTPRC as item_unit_price,
    ITMGRSAMT as item_gross_amount,
    FRTAMT as freight_amount,
    TAXAMT as tax_amount,
    DISCAMT as discount_amount,
    DTLNETAMT as detail_net_amount,
    ITMCHGTOI as item_charge_to_indicator,
    ITMCHGTOA as item_charge_to_account,
    STAT as status

from {{ source('asi400', 'DPHVCH3') }}