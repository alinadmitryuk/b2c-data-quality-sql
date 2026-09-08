-- 04_migration.sql
-- Goal: simulate migration from a legacy orders table to a new structure
-- and validate that data was not lost or changed unexpectedly.

DROP TABLE IF EXISTS orders_new;

CREATE TABLE orders_new AS
SELECT
    order_id,
    user_id,
    order_date,
    amount,
    status
FROM orders_legacy;

-- 1. Row-count comparison
SELECT
    (SELECT COUNT(*) FROM orders_legacy) AS legacy_rows,
    (SELECT COUNT(*) FROM orders_new) AS new_rows,
    (SELECT COUNT(*) FROM orders_legacy)
      - (SELECT COUNT(*) FROM orders_new) AS row_diff;

-- 2. Revenue comparison
SELECT
    (SELECT COALESCE(SUM(amount), 0) FROM orders_legacy) AS legacy_revenue,
    (SELECT COALESCE(SUM(amount), 0) FROM orders_new) AS new_revenue,
    (SELECT COALESCE(SUM(amount), 0) FROM orders_legacy)
      - (SELECT COALESCE(SUM(amount), 0) FROM orders_new) AS revenue_diff;

-- 3. Orders present in legacy but missing in new
SELECT l.*
FROM orders_legacy l
LEFT JOIN orders_new n
    ON l.order_id = n.order_id
WHERE n.order_id IS NULL;

-- 4. Orders present in new but missing in legacy
SELECT n.*
FROM orders_new n
LEFT JOIN orders_legacy l
    ON n.order_id = l.order_id
WHERE l.order_id IS NULL;

-- 5. Duplicate IDs after migration
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders_new
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 6. Field-level consistency check
SELECT COUNT(*) AS changed_rows
FROM orders_legacy l
JOIN orders_new n
    ON l.order_id = n.order_id
WHERE l.user_id IS DISTINCT FROM n.user_id
   OR l.order_date IS DISTINCT FROM n.order_date
   OR l.amount IS DISTINCT FROM n.amount
   OR l.status IS DISTINCT FROM n.status;
