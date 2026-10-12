-- ============================================================
-- 02_sample_data.sql
-- Deterministic demo dataset: 500 customers, 30 products,
-- 2,000 orders, and ~5,000 order_items.
-- ============================================================

-- ============================================
-- INSERT CUSTOMERS
-- ============================================

INSERT INTO customers
    (customer_name, email, city, state, signup_date)

SELECT
    'Customer ' || gs,
    'customer' || gs || '@example.com',

    (ARRAY[
        'Mumbai',
        'Pune',
        'Ahmedabad',
        'Vadodara',
        'Delhi',
        'Bengaluru',
        'Hyderabad',
        'Chennai',
        'Kolkata',
        'Jaipur'
    ])[1 + floor(random() * 10)::int],

    (ARRAY[
        'Maharashtra',
        'Maharashtra',
        'Gujarat',
        'Gujarat',
        'Delhi',
        'Karnataka',
        'Telangana',
        'Tamil Nadu',
        'West Bengal',
        'Rajasthan'
    ])[1 + floor(random() * 10)::int],

    DATE '2024-01-01'
        + floor(random() * 900)::int

FROM generate_series(1, 500) AS gs;


-- ============================================
-- INSERT PRODUCTS
-- ============================================

INSERT INTO products
    (product_name, category, price, cost)
VALUES

('Laptop Pro 14', 'Electronics', 74999, 58000),
('Laptop Air 13', 'Electronics', 62999, 49000),
('Gaming Laptop X', 'Electronics', 89999, 70000),
('Wireless Mouse', 'Electronics', 1499, 800),
('Mechanical Keyboard', 'Electronics', 3999, 2300),
('Bluetooth Headphones', 'Electronics', 2999, 1700),
('Smart Watch', 'Electronics', 5999, 3500),
('Power Bank 20000mAh', 'Electronics', 1999, 1100),

('Running Shoes', 'Fashion', 3499, 1900),
('Casual Sneakers', 'Fashion', 2999, 1600),
('Denim Jacket', 'Fashion', 2499, 1300),
('Cotton T-Shirt', 'Fashion', 799, 350),
('Formal Shirt', 'Fashion', 1499, 700),
('Backpack', 'Fashion', 1999, 1100),

('Coffee Maker', 'Home & Kitchen', 4999, 3000),
('Air Fryer', 'Home & Kitchen', 6999, 4200),
('Mixer Grinder', 'Home & Kitchen', 3499, 2200),
('Electric Kettle', 'Home & Kitchen', 1799, 950),
('Non-Stick Cookware Set', 'Home & Kitchen', 4499, 2700),
('Water Bottle', 'Home & Kitchen', 999, 450),

('Face Wash', 'Beauty', 499, 220),
('Moisturizer', 'Beauty', 699, 320),
('Sunscreen SPF 50', 'Beauty', 899, 400),
('Shampoo', 'Beauty', 599, 280),
('Perfume', 'Beauty', 2499, 1300),

('Notebook Set', 'Stationery', 499, 200),
('Pen Set', 'Stationery', 299, 120),
('Desk Organizer', 'Stationery', 799, 350),
('Calculator', 'Stationery', 599, 250),
('Study Lamp', 'Stationery', 1299, 700);


-- ============================================
-- INSERT ORDERS
-- ============================================

INSERT INTO orders
    (customer_id, order_date, order_status)

SELECT
    1 + floor(random() * 500)::int,

    DATE '2024-01-01'
        + floor(random() * 1000)::int,

    CASE
        WHEN random() < 0.75 THEN 'Completed'
        WHEN random() < 0.85 THEN 'Pending'
        WHEN random() < 0.93 THEN 'Cancelled'
        ELSE 'Returned'
    END

FROM generate_series(1, 2000);


-- ============================================
-- INSERT ORDER ITEMS
-- ============================================

INSERT INTO order_items
    (order_id, product_id, quantity)

SELECT
    o.order_id,
    1 + floor(random() * 30)::int,
    1 + floor(random() * 4)::int

FROM orders o
CROSS JOIN LATERAL generate_series(
    1,
    1 + floor(random() * 4)::int
);



