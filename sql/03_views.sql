-- ============================================================
-- 03_views.sql
-- Reusable semantic layer
-- ============================================================

CREATE OR REPLACE VIEW completed_order_details AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    p.price,
    p.cost,
    oi.quantity * p.price AS revenue,
    oi.quantity * p.cost AS cost_amount,
    oi.quantity * (p.price - p.cost) AS profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';

CREATE OR REPLACE VIEW customer_order_summary AS
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,
    SUM(revenue) AS total_revenue,
    SUM(cost_amount) AS total_cost,
    SUM(profit) AS total_profit,
    SUM(revenue) / NULLIF(COUNT(DISTINCT order_id),0) AS average_order_value,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM completed_order_details
GROUP BY customer_id, customer_name;

CREATE OR REPLACE VIEW product_performance_summary AS
SELECT
    product_id,
    product_name,
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units_sold,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(revenue) AS total_revenue,
    SUM(cost_amount) AS total_cost,
    SUM(profit) AS total_profit,
    SUM(profit) * 100.0 / NULLIF(SUM(revenue),0) AS profit_margin_pct,
    SUM(revenue) / NULLIF(SUM(quantity),0) AS average_selling_price
FROM completed_order_details
GROUP BY product_id, product_name, category;
