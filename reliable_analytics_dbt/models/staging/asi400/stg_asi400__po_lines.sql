/*
Source grain:
One physical record from DPMORDM3. The raw source can contain
multiple lifecycle records for the same logical purchase-order line.

Analytical grain after applying the purchasing business scope:
One qualifying received purchase-order line.

Confirmed analytical key:
po_number
+ release_number
+ po_line_number

The analytical grain applies after limiting the data to:
- RSLE items
- received_date_key > 0
- warehouse <> 'MFG'
- item_number not like '%CANCELLED%'

These business filters are applied downstream, not in staging.
*/

select
    PONBR as po_number,
    RLSENO as release_number,
    POLNNBR as po_line_number,
    ITMID as item_number,
    VNDID as vendor_id,
    VNDSFX as vendor_suffix,
    PLT as warehouse,
    ISSDTE as issued_date_key,
    LSTRECPDTE as received_date_key,
    UNITPRICE as unit_price,
    QTYAUT as authorized_quantity,
    QTYRCV as received_quantity,
    QTYVCH as vouched_quantity,
    QTYCNL as cancelled_quantity,
    UOM as unit_of_measure,
    STAT as status

from {{ source('asi400', 'DPMORDM3') }}