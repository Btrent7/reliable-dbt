# Reliable Analytics DBT
A dbt analytics-engineering project that transforms legacy AS400 purchasing data into tested, documented, business-ready analytical models.

The project demonstrates a layered dbt architecture using SQL Server, including source definitions, staging models, intermediate transformations, a purchasing fact table, surrogate keys, automated data-quality tests, financial reconciliation, and Git-based development.

## Technology Used
- dbt Core
- dbt-sqlserver
- SQL Server
- SQL
- Jinja
- dbt-utils
- Git/GitHub
- VS Code

## Source Systems
- AS400
- Dynamics 365 F&O

## Data Platform
- SQL Server

## Project Structure
reliable_analytics_dbt/
|
|-- models/
|   |
|   |-- staging/
|   |   |-- _sources.yml
|   |   |
|   |   `-- asi400/
|   |       |-- purchasing.yml
|   |       |-- stg_asi400__dates.sql
|   |       |-- stg_asi400__items.sql
|   |       |-- stg_asi400__po_headers.sql
|   |       |-- stg_asi400__po_lines.sql
|   |       |-- stg_asi400__voucher_headers.sql
|   |       `-- stg_asi400__voucher_lines.sql
|   |
|   |-- intermediate/
|   |   `-- purchasing/
|   |       |-- purchasing.yml
|   |       `-- int_asi400__purchasing.sql
|   |
|   `-- marts/
|       `-- purchasing/
|           |-- purchasing.yml
|           `-- fct_purchase_orders.sql
|
|-- tests/
|   `-- purchasing/
|       |-- assert_fct_purchase_amount_reconciles.sql
|       |-- assert_fct_purchase_date_mapping.sql
|       |-- assert_fct_purchase_grain.sql
|       |-- assert_fct_purchase_issue_date_from_2025.sql
|       |-- assert_fct_purchase_key_reconciles.sql
|       |-- assert_fct_purchase_no_cancelled_items.sql
|       |-- assert_fct_purchase_no_mfg_warehouse.sql
|       |-- assert_fct_purchase_row_count_reconciles.sql
|       `-- assert_fct_purchase_transactions_reconcile.sql
|
|-- macros/
|-- seeds/
|-- dbt_project.yml
|-- packages.yml
|-- package-lock.yml
`-- README.md

## Business Purpose
Provides curated, business-ready purchasing data for Power BI and ad hoc reporting, with validated transaction grain, automated data-quality testing, and financial reconciliation.

## Business Outcome
During migration of the legacy purchasing query into dbt, source-grain analysis identified row multiplication caused by incomplete join predicates.

The legacy query returned duplicated rows but only 50,000 distinct transactions at the validated transaction grain, resulting in multiple additional row occurrences and a maximum multiplication factor of 22.

The redesigned dbt model uses grain-aware relationships between purchase orders, PO lines, voucher details, and voucher headers.

The resulting purchasing fact table currently contains:

- 50,504 validated transactions
- 0 duplicate purchase transaction keys
- 22 passing automated data tests
- $120M in reconciled voucher extended amount