{{ config(materialized='view') }}

select
    ITEM_ID,
    ITEM_NUMBER,
    LEGAL_ENTITY,
    SITE_ID,
    WAREHOUSE_ID,
    PHYSICAL_INVENT,
    AVAIL_PHYSICAL,
    STANDARD_COST
from {{ source('pbi', 'PBI_INVENTORY') }}