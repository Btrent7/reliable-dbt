{{ config(materialized='table') }}

select

    ITEM_ID,

    ITEM_NUMBER,

    SITE_ID,

    WAREHOUSE_ID,

    PHYSICAL_INVENT,

    STANDARD_COST,

    PHYSICAL_INVENT * STANDARD_COST
        as INVENTORY_VALUE

from {{ ref('stg_inventory') }}