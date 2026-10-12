# Supabase Step-by-Step Setup Guide

## Step 1 — Create the Supabase project

1. Go to Supabase.
2. Sign in.
3. Select **New project**.
4. Give it a project name such as:
   `ecommerce-sales-customer-analytics`
5. Choose a strong database password.
6. Wait for the project to finish provisioning.

## Step 2 — Open SQL Editor

Inside the project:

**Dashboard → SQL Editor → New query**

You will run the project scripts here.

## Step 3 — Create the database schema

Open `01_schema.sql`.

Copy the entire file into the SQL Editor.

Click **Run**.

You should now have:

- `customers`
- `products`
- `orders`
- `order_items`

and the recommended indexes.

## Step 4 — Load the sample data

Open `02_sample_data.sql`.

Copy/paste it into a new SQL Editor query.

Click **Run**.

The generated dataset contains:

- 500 customers
- 30 products
- 2,000 orders
- approximately 5,000 order items

## Step 5 — Verify the data

Run:

```sql
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
```

Expected approximate result:

```text
customers    = 500
products     = 30
orders       = 2000
order_items  ≈ 5000
```

## Step 6 — Create the analytics layer

Run `03_views.sql`.

This creates:

- `completed_order_details`
- `customer_order_summary`
- `product_performance_summary`

These views are the reusable semantic layer for the project.

## Step 7 — Run data-quality checks

Run `05_data_quality.sql`.

Review:

- invalid foreign keys
- invalid products
- invalid orders
- negative prices
- negative costs
- invalid statuses
- duplicate emails
- future dates
- possible duplicate order patterns

A zero issue count is the expected result for the intentionally clean demo data.

## Step 8 — Run the analysis

Run `04_analysis.sql`.

This demonstrates:

- customer analysis
- category performance
- top customers
- MoM growth
- top products
- RFM
- cohorts
- retention
- executive KPIs

## Step 9 — Run dashboard queries

Run `06_dashboard_queries.sql`.

These queries are designed as BI-ready datasets.

Potential dashboards:

### Executive Dashboard
- Revenue
- Profit
- Margin
- Orders
- Customers
- AOV
- Monthly trend

### Customer Dashboard
- Customer revenue
- Orders
- Profit
- AOV
- RFM segment

### Product Dashboard
- Revenue
- Units
- Profit
- Margin
- Product rank

### Retention Dashboard
- Cohort month
- Month number
- Active customers
- Retention %

## Step 10 — Run the business case

Run `07_business_case.sql`.

This is the portfolio/interview layer.

It demonstrates that the project is not just SQL syntax practice: the queries answer realistic business questions.

## Step 11 — Inspect tables in Supabase

Open:

**Table Editor**

Select each table and inspect the records.

Also inspect the views if your Supabase UI exposes them under the database objects.

## Step 12 — Optional BI connection

Use the dashboard queries with:

- Tableau
- Power BI
- Looker Studio

The recommended dashboard structure is:

1. Executive Overview
2. Customer Analytics
3. Product & Category Performance
4. RFM / Retention

## Step 13 — GitHub structure

Recommended repository:

```text
ecommerce-sales-customer-analytics/
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_sample_data.sql
│   ├── 03_views.sql
│   ├── 04_analysis.sql
│   ├── 05_data_quality.sql
│   ├── 06_dashboard_queries.sql
│   └── 07_business_case.sql
│
├── dashboard/
│   └── README.md
│
├── screenshots/
│
└── README.md
```

## Important

Run scripts in order. Do not run the analysis before the views have been created.

If you need to rebuild the project from scratch, rerun `01_schema.sql`, then `02_sample_data.sql`, then the remaining files in order.
