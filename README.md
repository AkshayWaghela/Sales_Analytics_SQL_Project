# E-Commerce Sales & Customer Analytics

An end-to-end SQL analytics portfolio project using **PostgreSQL, Supabase, and a reproducible sample dataset**. The project demonstrates how relational transactional data can be modeled, validated, transformed into reusable analytical views, and used to answer business questions.

## Project objective

Build a practical analytics workflow that moves from relational database design to SQL-based business analysis. The emphasis is on **SQL fundamentals applied in context**, not on presenting a dashboard as the deliverable.

## Technology

- **Database:** PostgreSQL (hosted on Supabase)
- **Query language:** SQL
- **Analysis:** sales, product, customer, profitability, RFM, cohort/retention
- **Data quality:** integrity checks, duplicate-pattern checks, status and date validation

## Data model

The project uses four related tables:

- `customers` — customer profile and signup information
- `products` — product category, price and cost
- `orders` — order date, customer reference and order status
- `order_items` — products and quantities associated with orders

Relationships:

```text
customers (1) ── (*) orders (1) ── (*) order_items (*) ── (1) products
```

## Main analytical layer

`completed_order_details` joins completed orders to customer and product information and calculates:

- `revenue = quantity × price`
- `cost_amount = quantity × cost`
- `profit = revenue − cost_amount`

Additional reusable views summarize customer and product performance. The SQL files include analysis queries, quality checks, dashboard-ready result sets, and business-case questions. Dashboard configuration is intentionally not required to use or review this repository.

## Project contents

- `sql/01_schema.sql` — table definitions, constraints and indexes
- `sql/02_sample_data.sql` — sample data inserts
- `sql/03_views.sql` — reusable analytical views
- `sql/04_analysis.sql` — core business analysis
- `sql/05_data_quality.sql` — validation and data-quality checks
- `sql/06_dashboard_queries.sql` — KPI/reporting queries (SQL only; no dashboard setup required)
- `sql/07_business_case.sql` — business questions and analytical queries
- `docs/DATA_DICTIONARY.md` — table/field definitions and metric logic
- `docs/ANALYSIS_AND_LIMITATIONS.md` — analytical approach, metric interpretation and caveats
- `docs/INTERVIEW_GUIDE.md` — project explanation and likely interview questions
- `docs/PORTFOLIO_COPY.md` — ready-to-adapt resume, LinkedIn and portfolio descriptions
- `SUPABASE_STEP_BY_STEP.md` — setup notes

## Reproducibility

Run the SQL files in this order in a **test project/database**, because the schema script drops existing project tables/views before recreating them:

1. `01_schema.sql`
2. `02_sample_data.sql`
3. `03_views.sql`
4. `04_analysis.sql`
5. `05_data_quality.sql`
6. `06_dashboard_queries.sql`
7. `07_business_case.sql`

The sample data is synthetic and intended for portfolio demonstration. It should not be presented as real company data.

## Example questions this project supports

- Which categories contribute the most revenue and profit?
- Which products and customers rank highest by revenue?
- How do revenue and profit change month over month?
- Which customers fall into different RFM segments?
- How can data integrity and potential duplicate patterns be checked?
- What are the limitations of analyzing only completed orders?

## Skills demonstrated

Relational modeling · PostgreSQL · SQL joins · CTEs · window functions · aggregations · reusable views · KPI definitions · RFM analysis · cohort analysis · data validation · business interpretation

## Metric and interpretation notes

The core view is restricted to `Completed` orders. Therefore, metrics derived from `completed_order_details` describe completed-order activity only, not the full order funnel. For cancellation/pending/return rates, query `orders` directly. Revenue is calculated at the order-item line level using listed product price and quantity; discounts, shipping, tax, refunds and inventory changes are not modeled in this synthetic dataset.

## Portfolio summary

This project demonstrates the end-to-end use of SQL to structure transactional data, validate it, build reusable analytical datasets, and investigate business performance. It is designed to be discussed in interviews through both technical decisions and business questions.
