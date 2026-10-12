-- ============================================================
-- 05_data_quality.sql
-- Data validation / quality checks
-- ============================================================

SELECT 'Invalid customer references' AS check_name,
       COUNT(*) AS issue_count
FROM orders o
LEFT JOIN customers c ON o.customer_id=c.customer_id
WHERE c.customer_id IS NULL

UNION ALL
SELECT 'Invalid order references', COUNT(*)
FROM order_items oi
LEFT JOIN orders o ON oi.order_id=o.order_id
WHERE o.order_id IS NULL

UNION ALL
SELECT 'Invalid product references', COUNT(*)
FROM order_items oi
LEFT JOIN products p ON oi.product_id=p.product_id
WHERE p.product_id IS NULL

UNION ALL
SELECT 'Negative prices', COUNT(*)
FROM products WHERE price < 0

UNION ALL
SELECT 'Negative costs', COUNT(*)
FROM products WHERE cost < 0

UNION ALL
SELECT 'Invalid statuses', COUNT(*)
FROM orders
WHERE order_status NOT IN ('Completed','Pending','Cancelled','Returned')

UNION ALL
SELECT 'Duplicate customer emails', COUNT(*)
FROM (
    SELECT email FROM customers GROUP BY email HAVING COUNT(*) > 1
) d

UNION ALL
SELECT 'Future-dated orders', COUNT(*)
FROM orders WHERE order_date > CURRENT_DATE;

-- Order status funnel
SELECT
    order_status,
    COUNT(*) AS orders,
    COUNT(*)*100.0/NULLIF(SUM(COUNT(*)) OVER (),0) AS pct
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- Potential duplicate order patterns (investigate; not automatically duplicates)
SELECT
    customer_id,
    order_date,
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY customer_id, order_date, order_status
HAVING COUNT(*) > 1
ORDER BY order_count DESC;
