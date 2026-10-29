-- =====================================================================
-- 01_schema.sql  |  E-commerce Sales Analytics (SQLite)
-- Drops old objects and creates the raw staging table.
-- =====================================================================
PRAGMA foreign_keys = ON;

DROP VIEW  IF EXISTS vw_orders_enriched;
DROP VIEW  IF EXISTS vw_customer_summary;
DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_category;
DROP TABLE IF EXISTS dim_region;
DROP TABLE IF EXISTS dim_payment;
DROP TABLE IF EXISTS stg_orders;

-- Staging: raw CSV exactly as loaded (rows inserted by build_db.py)
CREATE TABLE stg_orders (
    order_id         INTEGER,
    order_date       TEXT,      -- raw format M/D/YYYY
    customer_id      INTEGER,
    product_category TEXT,
    region           TEXT,
    quantity         INTEGER,
    unit_price       REAL,
    discount         REAL,
    payment_method   TEXT,
    delivery_days    INTEGER,
    customer_rating  REAL,
    revenue          REAL
);
