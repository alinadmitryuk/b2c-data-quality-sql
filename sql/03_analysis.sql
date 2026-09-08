-- 03_analysis.sql
-- Business analysis examples.

-- 1. Orders and revenue by country
SELECT
    u.country,
    COUNT(o.order_id) AS orders_count,
    COALESCE(SUM(o.amount), 0) AS revenue,
    ROUND(COALESCE(AVG(o.amount), 0), 2) AS avg_order_value
FROM users_legacy u
LEFT JOIN orders_legacy o
    ON u.user_id = o.user_id
GROUP BY u.country
ORDER BY revenue DESC;

-- 2. Top 10 users by revenue
SELECT
    u.user_id,
    u.name,
    COALESCE(SUM(o.amount), 0) AS total_revenue
FROM users_legacy u
LEFT JOIN orders_legacy o
    ON u.user_id = o.user_id
GROUP BY u.user_id, u.name
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Revenue by order status
SELECT
    status,
    COUNT(*) AS orders_count,
    COALESCE(SUM(amount), 0) AS revenue
FROM orders_legacy
GROUP BY status
ORDER BY revenue DESC;

-- 4. Monthly revenue
SELECT
    DATE_TRUNC('month', order_date)::date AS month,
    COUNT(*) AS orders_count,
    SUM(amount) AS revenue
FROM orders_legacy
WHERE amount IS NOT NULL
  AND amount >= 0
GROUP BY 1
ORDER BY 1;

-- 5. Users with at least 5 orders
SELECT
    user_id,
    COUNT(*) AS orders_count
FROM orders_legacy
GROUP BY user_id
HAVING COUNT(*) >= 5
ORDER BY orders_count DESC, user_id;

-- 6. Classify users by revenue contribution
WITH user_revenue AS (
    SELECT
        u.user_id,
        u.name,
        COALESCE(SUM(o.amount), 0) AS total_revenue
    FROM users_legacy u
    LEFT JOIN orders_legacy o
        ON u.user_id = o.user_id
    GROUP BY u.user_id, u.name
)
SELECT
    user_id,
    name,
    total_revenue,
    CASE
        WHEN total_revenue >= 50000 THEN 'high'
        WHEN total_revenue >= 20000 THEN 'medium'
        ELSE 'low'
    END AS revenue_segment
FROM user_revenue
ORDER BY total_revenue DESC;
