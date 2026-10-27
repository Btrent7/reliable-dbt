/*
Source grain:
One physical record from DPMORDM0. The raw source may contain
multiple lifecycle records associated with the same PO and release.

Analytical grain after restricting the model to PO/release
combinations containing qualifying purchasing lines:
One purchase-order header per PO and release.

Confirmed analytical key:
po_number
+ release_number

The qualifying purchasing scope is applied downstream and includes:
- RSLE items
- received_date_key > 0
- warehouse <> 'MFG'
- item_number not like '%CANCELLED%'

No source records are deduplicated in this staging model.
*/

select
    COMP as company,
    PURGRP as purchasing_group,
    PONBR as po_number,
    RLSENO as release_number,
    POTYP as po_type,
    POSTATCD as po_status_code,
    VNDID as vendor_id,
    VNDSFX as vendor_suffix,
    ISSDTE as issued_date_key,
    CRTDTE as created_date_key,
    LSTACTDTE as last_activity_date_key,
    POCLODTE as closed_date_key,
    BYRID as buyer_id,
    ORGPURAMT as original_purchase_amount,
    CURPURAMT as current_purchase_amount,
    CURINVAMT as current_invoice_amount,
    TOTPRCVAR as total_price_variance,
    PRCVARPCT as price_variance_percent,
    STAT as status

from {{ source('asi400', 'DPMORDM0') }}