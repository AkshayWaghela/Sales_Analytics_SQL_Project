-- ============================================================
-- 07_business_case.sql
-- Portfolio business case
-- ============================================================

-- Business question 1:
-- What is the overall business performance?
SELECT
    SUM(revenue) AS revenue,
    SUM(profit) AS profit,
    SUM(profit)*100.0/NULLIF(SUM(revenue),0) AS margin_pct,
    COUNT(DISTINCT order_id) AS completed_orders,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(revenue)/NULLIF(COUNT(DISTINCT order_id),0) AS aov
FROM completed_order_details;

-- Business question 2:
-- Which categories drive revenue and profit?
SELECT
    category,
    SUM(revenue) AS revenue,
    SUM(profit) AS profit,
    SUM(profit)*100.0/NULLIF(SUM(revenue),0) AS margin_pct,
    RANK() OVER (ORDER BY SUM(revenue) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY SUM(profit) DESC) AS profit_rank
FROM completed_order_details
GROUP BY category
ORDER BY revenue DESC;

-- Business question 3:
-- Which products are the top revenue generators in each category?
WITH ranked AS (
    SELECT
        product_id,
        product_name,
        category,
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
ORDER BY category,rn;

-- Business question 4:
-- Which customers generate the most value?
SELECT
    customer_id,
    customer_name,
    total_orders,
    total_revenue,
    total_profit,
    average_order_value
FROM customer_order_summary
ORDER BY total_revenue DESC
LIMIT 20;

-- Business question 5:
-- Which customers are potentially at risk?
WITH customer_activity AS (
    SELECT
        customer_id,
        customer_name,
        MAX(last_order_date)::date AS last_order_date,
        total_orders,
        total_revenue,
        total_profit
    FROM customer_order_summary
    GROUP BY customer_id, customer_name, total_orders, total_revenue, total_profit
)
SELECT *,
       CURRENT_DATE-last_order_date AS days_since_last_order
FROM customer_activity
WHERE CURRENT_DATE-last_order_date > 90
ORDER BY total_revenue DESC;
