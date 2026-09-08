-- 05_ab_test.sql
-- Goal: compare conversion between control and test groups.

-- 1. Basic group-level metrics
SELECT
    group_name,
    COUNT(*) AS users,
    SUM(converted) AS conversions,
    ROUND(AVG(converted::numeric), 4) AS conversion_rate
FROM experiments
GROUP BY group_name
ORDER BY group_name;

-- 2. Control vs test conversion rate side by side
WITH rates AS (
    SELECT
        group_name,
        AVG(converted::numeric) AS conversion_rate
    FROM experiments
    GROUP BY group_name
)
SELECT
    MAX(CASE WHEN group_name = 'control' THEN conversion_rate END) AS control_rate,
    MAX(CASE WHEN group_name = 'test' THEN conversion_rate END) AS test_rate,
    MAX(CASE WHEN group_name = 'test' THEN conversion_rate END)
      - MAX(CASE WHEN group_name = 'control' THEN conversion_rate END) AS absolute_uplift
FROM rates;

-- 3. Relative uplift (%), not a significance test
WITH rates AS (
    SELECT
        group_name,
        AVG(converted::numeric) AS conversion_rate
    FROM experiments
    GROUP BY group_name
)
SELECT
    (
        MAX(CASE WHEN group_name = 'test' THEN conversion_rate END)
        / NULLIF(MAX(CASE WHEN group_name = 'control' THEN conversion_rate END), 0)
        - 1
    ) * 100 AS relative_uplift_pct
FROM rates;

-- 4. Data-quality check for experiment assignments
SELECT
    COUNT(*) FILTER (WHERE group_name IS NULL) AS null_groups,
    COUNT(*) FILTER (WHERE group_name NOT IN ('control', 'test')) AS invalid_groups,
    COUNT(*) FILTER (WHERE converted IS NULL) AS null_conversions,
    COUNT(*) FILTER (WHERE converted NOT IN (0, 1)) AS invalid_conversions
FROM experiments;
