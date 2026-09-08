-- 01_schema.sql
-- PostgreSQL

DROP TABLE IF EXISTS experiments;
DROP TABLE IF EXISTS orders_legacy;
DROP TABLE IF EXISTS users_legacy;

CREATE TABLE users_legacy (
    user_id INT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    registration_date DATE NOT NULL,
    country TEXT,
    age INT
);

CREATE TABLE orders_legacy (
    order_id INT,
    user_id INT,
    order_date DATE,
    amount NUMERIC(12,2),
    status TEXT
);

CREATE TABLE experiments (
    user_id INT,
    group_name TEXT,
    converted INT
);

-- After creating the tables, load the CSV files.
-- In psql, for example:
-- \copy users_legacy FROM '/absolute/path/users_legacy.csv' WITH (FORMAT csv, HEADER true)
-- \copy orders_legacy FROM '/absolute/path/orders_legacy.csv' WITH (FORMAT csv, HEADER true)
-- \copy experiments FROM '/absolute/path/experiments.csv' WITH (FORMAT csv, HEADER true)
