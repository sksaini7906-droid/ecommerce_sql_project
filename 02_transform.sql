-- =====================================================================
-- 02_transform.sql  |  Star schema built from stg_orders
-- =====================================================================

-- ---------- Dimensions ----------
CREATE TABLE dim_category (
    category_id   INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);
CREATE TABLE dim_region (
    region_id   INTEGER PRIMARY KEY,
    region_name TEXT NOT NULL UNIQUE
);
CREATE TABLE dim_payment (
    payment_id   INTEGER PRIMARY KEY,
    payment_name TEXT NOT NULL UNIQUE
);
CREATE TABLE dim_customer (
    customer_id      INTEGER PRIMARY KEY,
    first_order_date TEXT NOT NULL,
    last_order_date  TEXT NOT NULL
);

INSERT INTO dim_category (category_name) SELECT DISTINCT product_category FROM stg_orders ORDER BY 1;
INSERT INTO dim_region   (region_name)   SELECT DISTINCT region           FROM stg_orders ORDER BY 1;
INSERT INTO dim_payment  (payment_name)  SELECT DISTINCT payment_method   FROM stg_orders ORDER BY 1;

-- Cleaned staging view: converts M/D/YYYY text into ISO YYYY-MM-DD
CREATE TEMP VIEW stg_clean AS
SELECT s.*,
       printf('%04d-%02d-%02d',
              CAST(substr(order_date, length(order_date) - 3) AS INTEGER),
              CAST(substr(order_date, 1, instr(order_date, '/') - 1) AS INTEGER),
              CAST(substr(order_date, instr(order_date, '/') + 1,
                   instr(substr(order_date, instr(order_date, '/') + 1), '/') - 1) AS INTEGER)
       ) AS iso_date
FROM stg_orders s;

INSERT INTO dim_customer (customer_id, first_order_date, last_order_date)
SELECT customer_id, MIN(iso_date), MAX(iso_date)
FROM stg_clean
GROUP BY customer_id;

-- ---------- Fact table ----------
CREATE TABLE fact_orders (
    order_id        INTEGER PRIMARY KEY,
    order_date      TEXT    NOT NULL,                       -- ISO YYYY-MM-DD
    order_year      INTEGER NOT NULL,
    order_month     INTEGER NOT NULL CHECK (order_month BETWEEN 1 AND 12),
    customer_id     INTEGER NOT NULL,
    category_id     INTEGER NOT NULL,
    region_id       INTEGER NOT NULL,
    payment_id      INTEGER NOT NULL,
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    unit_price      REAL    NOT NULL CHECK (unit_price > 0),
    discount        REAL    NOT NULL CHECK (discount BETWEEN 0 AND 1),
    delivery_days   INTEGER NOT NULL CHECK (delivery_days >= 0),
    customer_rating REAL    NOT NULL CHECK (customer_rating BETWEEN 1 AND 5),
    gross_amount    REAL    NOT NULL,                       -- quantity * unit_price
    revenue         REAL    NOT NULL,                       -- net of discount
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (region_id)   REFERENCES dim_region(region_id),
    FOREIGN KEY (payment_id)  REFERENCES dim_payment(payment_id)
);

INSERT INTO fact_orders
SELECT i.order_id,
       i.iso_date,
       CAST(substr(i.iso_date, 1, 4) AS INTEGER),
       CAST(substr(i.iso_date, 6, 2) AS INTEGER),
       i.customer_id,
       c.category_id,
       r.region_id,
       p.payment_id,
       i.quantity,
       i.unit_price,
       i.discount,
       i.delivery_days,
       i.customer_rating,
       ROUND(i.quantity * i.unit_price, 2),
       i.revenue
FROM stg_clean i
JOIN dim_category c ON c.category_name = i.product_category
JOIN dim_region   r ON r.region_name   = i.region
JOIN dim_payment  p ON p.payment_name  = i.payment_method;

-- ---------- Indexes ----------
CREATE INDEX idx_fact_date     ON fact_orders(order_date);
CREATE INDEX idx_fact_customer ON fact_orders(customer_id);
CREATE INDEX idx_fact_category ON fact_orders(category_id);
CREATE INDEX idx_fact_region   ON fact_orders(region_id);

-- ---------- Views ----------
CREATE VIEW vw_orders_enriched AS
SELECT f.order_id, f.order_date, f.order_year, f.order_month,
       printf('%04d-%02d', f.order_year, f.order_month) AS year_month,
       f.customer_id,
       c.category_name AS category,
       r.region_name   AS region,
       p.payment_name  AS payment_method,
       f.quantity, f.unit_price, f.discount,
       f.gross_amount, f.revenue,
       ROUND(f.gross_amount - f.revenue, 2) AS discount_amount,
       f.delivery_days, f.customer_rating
FROM fact_orders f
JOIN dim_category c ON c.category_id = f.category_id
JOIN dim_region   r ON r.region_id   = f.region_id
JOIN dim_payment  p ON p.payment_id  = f.payment_id;

CREATE VIEW vw_customer_summary AS
SELECT customer_id,
       COUNT(*)                       AS orders,
       ROUND(SUM(revenue), 2)         AS total_revenue,
       ROUND(AVG(revenue), 2)         AS avg_order_value,
       ROUND(AVG(customer_rating), 2) AS avg_rating,
       MIN(order_date)                AS first_order,
       MAX(order_date)                AS last_order
FROM fact_orders
GROUP BY customer_id;
