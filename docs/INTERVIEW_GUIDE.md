# Interview Guide

## 30-second project explanation

“I built an E-Commerce Sales & Customer Analytics project using PostgreSQL and Supabase to revisit and strengthen my SQL skills through a business-oriented use case. I modeled customers, products, orders and order items, created reusable analytical views, and wrote queries for sales, profitability, customer/product performance, RFM and cohort analysis. I also included data-quality checks. The focus was connecting SQL techniques to business questions and making the analysis reproducible.”

## Explain the data model

- `customers` to `orders`: one-to-many through `customer_id`
- `orders` to `order_items`: one-to-many through `order_id`
- `products` to `order_items`: one-to-many through `product_id`

`order_items` resolves the many-to-many relationship between orders and products.

## Why create `completed_order_details`?

“It provides a reusable item-level analytical layer that joins order, customer, item and product data. It standardizes revenue, cost and profit calculations, so downstream queries can focus on business questions instead of repeating joins.”

## Why use `COUNT(DISTINCT order_id)`?

“An order can contain multiple item lines. After joining orders to order items, a simple row count would count lines, not orders. Distinct order counting preserves the correct order-level KPI.”

## How would you calculate AOV correctly?

“First aggregate revenue to one row per order, then average those order totals. The item-level analytical view can repeat the order ID across multiple lines, so AOV should not be calculated by averaging line revenue or by dividing a line-level sum by a non-distinct order count.”

## What do RFM and cohort analysis add?

“RFM summarizes how recently a customer purchased, how frequently they purchased and how much monetary value they generated. Cohort analysis groups customers by a common starting period, such as first purchase month, and tracks activity over subsequent periods.”

## What data-quality checks matter?

- Referential integrity across customer, order, item and product IDs
- Allowed order-status values
- Nonnegative prices and costs
- Positive quantities
- Duplicate emails or suspicious duplicate order patterns
- Future-dated orders
- Null/missing fields and inconsistent date ranges

## What are the limitations?

“The dataset is synthetic, and the profit calculation is simplified. The core analysis includes completed orders only and doesn't model discounts, tax, shipping, refunds or inventory. Any business conclusion would need validation against real operational data.”

## Be ready to discuss

1. Why did you choose these tables and keys?
2. How do JOINs change row counts?
3. When would you use a CTE versus a view?
4. How do window functions help rank or compare performance?
5. How would you improve query performance on larger tables?
6. How would you validate revenue and profit definitions with stakeholders?
7. What additional data would you request before recommending business actions?
