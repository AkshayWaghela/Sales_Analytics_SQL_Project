-- ============================================================
-- 06_dashboard_queries.sql
-- Dashboard-ready datasets
-- ============================================================

-- Executive monthly dashboard
WITH monthly AS (
    SELECT
        DATE_TRUNC('month',order_date) AS month,
        SUM(revenue) AS total_revenue,
        SUM(profit) AS total_profit,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS unique_customers
    FROM completed_order_details
    GROUP BY DATE_TRUNC('month',order_date)
)
SELECT
    month,
    total_revenue,
    total_profit,
    total_profit*100.0/NULLIF(total_revenue,0) AS profit_margin_pct,
    total_orders,
    unique_customers,
    total_revenue/NULLIF(total_orders,0) AS average_order_value
FROM monthly
ORDER BY month;

-- Category dashboard
SELECT
    category,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_id) AS customers,
    SUM(quantity) AS units,
    SUM(revenue) AS revenue,
    SUM(profit) AS profit,
    SUM(profit)*100.0/NULLIF(SUM(revenue),0) AS margin_pct
FROM completed_order_details
GROUP BY category
ORDER BY revenue DESC;

-- Product dashboard
SELECT *
FROM product_performance_summary
ORDER BY total_revenue DESC;

-- Customer dashboard
SELECT *
FROM customer_order_summary
ORDER BY total_revenue DESC;
