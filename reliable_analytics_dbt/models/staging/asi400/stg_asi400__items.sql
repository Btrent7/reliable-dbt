select
    ITMID as item_number,
    ITMDESC as item_description,
    ITMST as item_status,
    PRDGRP as product_group,
    UOM as unit_of_measure,
    BYRID as buyer_id,
    COMMCD as commodity_code,
    VNDID as vendor_id,
    COPITMTYP as item_type,
    COPCLSCD as item_class_code,
    CURRCST as current_cost,
    FRZSTDCST as frozen_standard_cost,
    CURRSTDCST as current_standard_cost,
    PRDCTG as product_category

from {{ source('asi400', 'DCSCIM') }}