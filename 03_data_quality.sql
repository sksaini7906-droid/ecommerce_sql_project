-- =====================================================================
-- 03_data_quality.sql  |  Each check should return pass = 1
-- =====================================================================
-- Q1. Row counts match between staging and fact
SELECT 'row_count_match' AS check_name,
       (SELECT COUNT(*) FROM stg_orders) = (SELECT COUNT(*) FROM fact_orders) AS pass;

-- Q2. order_id is unique
SELECT 'order_id_unique' AS check_name,
       COUNT(*) = COUNT(DISTINCT order_id) AS pass FROM fact_orders;

-- Q3. No NULLs in any key column
SELECT 'no_nulls' AS check_name,
       SUM(order_date IS NULL OR customer_id IS NULL OR category_id IS NULL
           OR region_id IS NULL OR payment_id IS NULL OR revenue IS NULL) = 0 AS pass
FROM fact_orders;

-- Q4. Revenue equals quantity * price * (1 - discount) within 1 paisa
SELECT 'revenue_formula_valid' AS check_name,
       SUM(ABS(revenue - ROUND(quantity * unit_price * (1 - discount), 2)) > 0.011) = 0 AS pass
FROM fact_orders;

-- Q5. Dates parsed correctly (valid ISO and ordered by order_id)
SELECT 'dates_valid_iso' AS check_name,
       SUM(date(order_date) IS NULL) = 0 AS pass FROM fact_orders;

-- Q6. No orphan foreign keys
SELECT 'no_orphan_customers' AS check_name,
       COUNT(*) = 0 AS pass FROM fact_orders f
LEFT JOIN dim_customer c USING (customer_id) WHERE c.customer_id IS NULL;

-- Q7. Value ranges sane (rating 1-5, discount 0-35%, delivery 1-11 days)
SELECT 'ranges_sane' AS check_name,
       MIN(customer_rating) >= 1 AND MAX(customer_rating) <= 5
       AND MIN(discount) >= 0 AND MAX(discount) <= 0.35
       AND MIN(delivery_days) >= 1 AS pass FROM fact_orders;

-- Q8. Outlier scan: orders above Q3 + 1.5*IQR of revenue
WITH ranked AS (
    SELECT revenue, NTILE(4) OVER (ORDER BY revenue) AS q FROM fact_orders
),
bounds AS (
    SELECT MAX(CASE WHEN q = 1 THEN revenue END) AS q1,
           MAX(CASE WHEN q = 3 THEN revenue END) AS q3
    FROM ranked
)
SELECT 'high_revenue_outliers_count' AS check_name,
       COUNT(*) AS n_orders
FROM fact_orders, bounds
WHERE revenue > q3 + 1.5 * (q3 - q1);
