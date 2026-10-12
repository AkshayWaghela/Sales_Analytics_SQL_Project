-- ============================================================
-- 04_analysis.sql
-- Core analysis queries
-- Run after 01_schema.sql, 02_sample_data.sql, 03_views.sql
-- ============================================================

-- 1. Customer overview
SELECT state, COUNT(*) AS customers
FROM customers
GROUP BY state
ORDER BY customers DESC;

-- 2. Product catalog
SELECT category, COUNT(*) AS products, AVG(price) AS avg_price
FROM products
GROUP BY category
ORDER BY products DESC;

-- 3. Revenue / profit by category
SELECT
    category,
    SUM(revenue) AS revenue,
    SUM(cost_amount) AS cost,
    SUM(profit) AS profit,
    SUM(profit) * 100.0 / NULLIF(SUM(revenue),0) AS margin_pct
FROM completed_order_details
GROUP BY category
ORDER BY revenue DESC;

-- 4. Top 10 customers
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS orders,
    SUM(revenue) AS revenue,
    SUM(profit) AS profit
FROM completed_order_details
GROUP BY customer_id, customer_name
ORDER BY revenue DESC
LIMIT 10;

-- 5. Customers above average revenue
WITH customer_revenue AS (
    SELECT customer_id, customer_name, SUM(revenue) AS revenue
    FROM completed_order_details
    GROUP BY customer_id, customer_name
)
SELECT *
FROM customer_revenue
WHERE revenue > (SELECT AVG(revenue) FROM customer_revenue)
ORDER BY revenue DESC;

-- 6. Monthly executive metrics + MoM growth
WITH monthly AS (
    SELECT
        DATE_TRUNC('month',order_date) AS month,
        SUM(revenue) AS revenue,
        SUM(profit) AS profit,
        COUNT(DISTINCT order_id) AS orders,
        COUNT(DISTINCT customer_id) AS customers
    FROM completed_order_details
    GROUP BY DATE_TRUNC('month',order_date)
),
x AS (
    SELECT *,
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
        LAG(profit) OVER (ORDER BY month) AS prev_profit,
        LAG(customers) OVER (ORDER BY month) AS prev_customers
    FROM monthly
)
SELECT
    month, revenue, profit, orders, customers,
    revenue / NULLIF(orders,0) AS aov,
    profit * 100.0 / NULLIF(revenue,0) AS margin_pct,
    (revenue-prev_revenue)*100.0/NULLIF(prev_revenue,0) AS revenue_growth_pct,
    (profit-prev_profit)*100.0/NULLIF(prev_profit,0) AS profit_growth_pct,
    (customers-prev_customers)*100.0/NULLIF(prev_customers,0) AS customer_growth_pct
FROM x
ORDER BY month;

-- 7. Top 3 products per category
WITH ranked AS (
    SELECT
        product_id, product_name, category,
        SUM(quantity) AS units,
        SUM(revenue) AS revenue,
        SUM(profit) AS profit,
        ROW_NUMBER() OVER (
            PARTITION BY category ORDER BY SUM(revenue) DESC
        ) AS rn
    FROM completed_order_details
    GROUP BY product_id, product_name, category
)
SELECT *
FROM ranked
WHERE rn <= 3
ORDER BY category, rn;

-- 8. RFM dataset
WITH rfm AS (
    SELECT
        customer_id,
        customer_name,
        CURRENT_DATE - MAX(order_date)::date AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(revenue) AS monetary
    FROM completed_order_details
    GROUP BY customer_id, customer_name
),
scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm
)
SELECT *,
    r_score + f_score + m_score AS rfm_score,
    CONCAT(r_score,f_score,m_score) AS rfm_code,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 3 THEN 'At Risk High Value'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost Customers'
        ELSE 'Other'
    END AS rfm_segment
FROM scored
ORDER BY rfm_score DESC, monetary DESC;

-- 9. Cohort retention
WITH first_purchase AS (
    SELECT customer_id, MIN(DATE_TRUNC('month',order_date)) AS cohort_month
    FROM completed_order_details
    GROUP BY customer_id
),
activity AS (
    SELECT DISTINCT customer_id, DATE_TRUNC('month',order_date) AS activity_month
    FROM completed_order_details
),
cohort AS (
    SELECT
        a.customer_id,
        f.cohort_month,
        a.activity_month,
        (
            EXTRACT(YEAR FROM a.activity_month)-EXTRACT(YEAR FROM f.cohort_month)
        )*12+
        (
            EXTRACT(MONTH FROM a.activity_month)-EXTRACT(MONTH FROM f.cohort_month)
        ) AS month_number
    FROM activity a
    JOIN first_purchase f ON a.customer_id=f.customer_id
),
size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM cohort GROUP BY cohort_month
),
active AS (
    SELECT cohort_month, month_number, COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort GROUP BY cohort_month, month_number
)
SELECT
    a.cohort_month,
    a.month_number,
    s.cohort_customers,
    a.active_customers,
    a.active_customers*100.0/NULLIF(s.cohort_customers,0) AS retention_pct
FROM active a
JOIN size s ON a.cohort_month=s.cohort_month
ORDER BY a.cohort_month,a.month_number;

-- 10. Executive KPI snapshot
SELECT
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT order_id) AS completed_orders,
    COUNT(DISTINCT product_id) AS products_sold,
    SUM(quantity) AS units_sold,
    SUM(revenue) AS total_revenue,
    SUM(cost_amount) AS total_cost,
    SUM(profit) AS total_profit,
    SUM(profit)*100.0/NULLIF(SUM(revenue),0) AS profit_margin_pct,
    SUM(revenue)/NULLIF(COUNT(DISTINCT order_id),0) AS average_order_value
FROM completed_order_details;
