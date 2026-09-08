-- 02_data_quality.sql
-- Goal: identify common data-quality problems in the legacy B2C data.

-- 1. Total users
SELECT COUNT(*) AS users_count
FROM users_legacy;

-- 2. Missing emails
SELECT COUNT(*) AS missing_email_count
FROM users_legacy
WHERE email IS NULL;

-- 3. Duplicate emails
SELECT
    email,
    COUNT(*) AS email_count
FROM users_legacy
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY email_count DESC, email;

-- 4. Invalid ages
SELECT *
FROM users_legacy
WHERE age < 0 OR age > 120;

-- 5. Missing countries
SELECT COUNT(*) AS missing_country_count
FROM users_legacy
WHERE country IS NULL;

-- 6. Negative or missing order amount
SELECT *
FROM orders_legacy
WHERE amount < 0 OR amount IS NULL;

-- 7. Orphan orders: user_id does not exist in users_legacy
SELECT o.*
FROM orders_legacy o
LEFT JOIN users_legacy u
    ON o.user_id = u.user_id
WHERE u.user_id IS NULL;

-- 8. Missing order status
SELECT COUNT(*) AS missing_status_count
FROM orders_legacy
WHERE status IS NULL;

-- 9. Duplicate order IDs
SELECT
    order_id,
    COUNT(*) AS order_id_count
FROM orders_legacy
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY order_id_count DESC, order_id;

-- 10. One compact quality summary
SELECT
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE amount IS NULL) AS null_amounts,
    COUNT(*) FILTER (WHERE amount < 0) AS negative_amounts,
    COUNT(*) FILTER (WHERE status IS NULL) AS null_statuses
FROM orders_legacy;
