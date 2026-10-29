-- =====================================================================
-- 04_business_analysis.sql  |  Each query is tagged "-- Q<n>: title"
-- Skills shown: aggregation, CASE, CTEs, window functions, subqueries
-- =====================================================================

-- Q1: Executive KPI summary
SELECT COUNT(*)                        AS total_orders,
       COUNT(DISTINCT customer_id)     AS unique_customers,
       ROUND(SUM(revenue), 2)          AS total_revenue,
       ROUND(AVG(revenue), 2)          AS avg_order_value,
       SUM(quantity)                   AS units_sold,
       ROUND(100.0 * SUM(discount_amount) / SUM(gross_amount), 2) AS discount_pct_of_gross,
       ROUND(AVG(customer_rating), 2)  AS avg_rating,
       ROUND(AVG(delivery_days), 2)    AS avg_delivery_days
FROM vw_orders_enriched;

-- Q2: Revenue by category with share of total
SELECT category,
       COUNT(*)                                            AS orders,
       ROUND(SUM(revenue), 2)                              AS revenue,
       ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 2) AS revenue_share_pct,
       ROUND(AVG(revenue), 2)                              AS avg_order_value,
       ROUND(AVG(customer_rating), 2)                      AS avg_rating
FROM vw_orders_enriched
GROUP BY category
ORDER BY revenue DESC;

-- Q3: Regional performance
SELECT region,
       COUNT(*)                   AS orders,
       ROUND(SUM(revenue), 2)     AS revenue,
       ROUND(AVG(revenue), 2)     AS avg_order_value,
       ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
       ROUND(AVG(customer_rating), 2) AS avg_rating,
       RANK() OVER (ORDER BY SUM(revenue) DESC) AS revenue_rank
FROM vw_orders_enriched
GROUP BY region
ORDER BY revenue_rank;

-- Q4: Payment method mix
SELECT payment_method,
       COUNT(*)                                     AS orders,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS order_share_pct,
       ROUND(SUM(revenue), 2)                       AS revenue,
       ROUND(AVG(revenue), 2)                       AS avg_order_value,
       ROUND(AVG(customer_rating), 2)               AS avg_rating
FROM vw_orders_enriched
GROUP BY payment_method
ORDER BY revenue DESC;

-- Q5: Yearly revenue with YoY growth (LAG); partial years are flagged, not compared
WITH yearly AS (
    SELECT order_year,
           COUNT(*)                AS orders,
           COUNT(DISTINCT order_date) AS days_with_orders,
           ROUND(SUM(revenue), 2)  AS revenue
    FROM vw_orders_enriched
    GROUP BY order_year
)
SELECT order_year, orders, revenue,
       CASE WHEN days_with_orders < 365 AND order_year % 4 <> 0 THEN 'partial year'
            WHEN days_with_orders < 366 AND order_year % 4 = 0  THEN 'partial year'
            ELSE 'full year' END AS coverage,
       CASE WHEN days_with_orders < 365 THEN NULL
            ELSE ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY order_year))
                       / LAG(revenue) OVER (ORDER BY order_year), 2) END AS yoy_growth_pct
FROM yearly
ORDER BY order_year;

-- Q6: Monthly revenue with 3-month moving average (first 12 months shown)
WITH monthly AS (
    SELECT year_month, ROUND(SUM(revenue), 2) AS revenue
    FROM vw_orders_enriched
    GROUP BY year_month
)
SELECT year_month, revenue,
       ROUND(AVG(revenue) OVER (ORDER BY year_month
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m,
       ROUND(SUM(revenue) OVER (ORDER BY year_month), 2)    AS cumulative_revenue
FROM monthly
ORDER BY year_month
LIMIT 12;

-- Q7: Seasonality - average revenue per calendar month across all years
SELECT order_month,
       ROUND(SUM(revenue) / COUNT(DISTINCT order_year), 2) AS avg_revenue_per_year,
       ROUND(AVG(revenue), 2)                              AS avg_order_value
FROM vw_orders_enriched
GROUP BY order_month
ORDER BY order_month;

-- Q8: Discount band impact on order value and rating
SELECT CASE WHEN discount < 0.10 THEN '1) 0-9%'
            WHEN discount < 0.20 THEN '2) 10-19%'
            WHEN discount < 0.30 THEN '3) 20-29%'
            ELSE                      '4) 30-35%' END AS discount_band,
       COUNT(*)                        AS orders,
       ROUND(AVG(quantity), 2)         AS avg_quantity,
       ROUND(AVG(revenue), 2)          AS avg_order_value,
       ROUND(SUM(discount_amount), 2)  AS total_discount_given,
       ROUND(AVG(customer_rating), 2)  AS avg_rating
FROM vw_orders_enriched
GROUP BY discount_band
ORDER BY discount_band;

-- Q9: Delivery speed vs customer rating
SELECT CASE WHEN delivery_days <= 3 THEN '1) 1-3 days (fast)'
            WHEN delivery_days <= 7 THEN '2) 4-7 days (standard)'
            ELSE                         '3) 8-11 days (slow)' END AS delivery_band,
       COUNT(*)                       AS orders,
       ROUND(AVG(customer_rating), 2) AS avg_rating,
       ROUND(100.0 * SUM(customer_rating <= 2) / COUNT(*), 2) AS pct_low_rating
FROM vw_orders_enriched
GROUP BY delivery_band
ORDER BY delivery_band;

-- Q10: Top 10 customers by revenue (with rank and share)
SELECT RANK() OVER (ORDER BY total_revenue DESC) AS rnk,
       customer_id, orders, total_revenue, avg_order_value, avg_rating,
       ROUND(100.0 * total_revenue / SUM(total_revenue) OVER (), 3) AS pct_of_total
FROM vw_customer_summary
ORDER BY total_revenue DESC
LIMIT 10;

-- Q11: Best-selling category in each region (RANK within partition)
WITH cr AS (
    SELECT region, category, ROUND(SUM(revenue), 2) AS revenue,
           RANK() OVER (PARTITION BY region ORDER BY SUM(revenue) DESC) AS rnk
    FROM vw_orders_enriched
    GROUP BY region, category
)
SELECT region, category, revenue FROM cr WHERE rnk = 1 ORDER BY region;

-- Q12: Category x region revenue matrix (conditional aggregation / pivot)
SELECT category,
       ROUND(SUM(CASE WHEN region = 'North' THEN revenue END), 0) AS north,
       ROUND(SUM(CASE WHEN region = 'South' THEN revenue END), 0) AS south,
       ROUND(SUM(CASE WHEN region = 'East'  THEN revenue END), 0) AS east,
       ROUND(SUM(CASE WHEN region = 'West'  THEN revenue END), 0) AS west
FROM vw_orders_enriched
GROUP BY category
ORDER BY category;

-- Q13: Customer loyalty - repeat vs one-time vs frequent buyers
SELECT CASE WHEN orders = 1 THEN '1 order'
            WHEN orders <= 3 THEN '2-3 orders'
            WHEN orders <= 6 THEN '4-6 orders'
            ELSE '7+ orders' END AS frequency_band,
       COUNT(*)                      AS customers,
       ROUND(SUM(total_revenue), 2)  AS revenue,
       ROUND(AVG(total_revenue), 2)  AS avg_revenue_per_customer
FROM vw_customer_summary
GROUP BY frequency_band
ORDER BY MIN(orders);

-- Q14: Pareto - what share of revenue comes from the top 20% of customers?
WITH ranked AS (
    SELECT customer_id, total_revenue,
           ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS rn,
           COUNT(*) OVER ()                                AS n
    FROM vw_customer_summary
)
SELECT COUNT(*)                                  AS top_customers,
       ROUND(SUM(total_revenue), 2)              AS revenue,
       ROUND(100.0 * SUM(total_revenue) /
             (SELECT SUM(total_revenue) FROM vw_customer_summary), 2) AS pct_of_revenue
FROM ranked
WHERE rn <= 0.2 * n;

-- Q15: RFM segmentation (Recency, Frequency, Monetary) using NTILE
WITH snapshot AS (SELECT MAX(order_date) AS snap FROM fact_orders),
rfm_raw AS (
    SELECT c.customer_id,
           CAST(julianday(s.snap) - julianday(c.last_order) AS INTEGER) AS recency_days,
           c.orders       AS frequency,
           c.total_revenue AS monetary
    FROM vw_customer_summary c, snapshot s
),
scored AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY recency_days DESC) AS r,   -- 4 = most recent
           NTILE(4) OVER (ORDER BY frequency)         AS f,
           NTILE(4) OVER (ORDER BY monetary)          AS m
    FROM rfm_raw
),
segmented AS (
    SELECT *,
           CASE WHEN r >= 3 AND f >= 3 AND m >= 3 THEN 'Champions'
                WHEN f >= 3 AND m >= 3             THEN 'Loyal high-value'
                WHEN r >= 3                        THEN 'Recent / promising'
                WHEN r <= 2 AND m >= 3             THEN 'At risk (high value)'
                ELSE                                    'Needs attention' END AS segment
    FROM scored
)
SELECT segment,
       COUNT(*)                     AS customers,
       ROUND(AVG(recency_days), 0)  AS avg_recency_days,
       ROUND(AVG(frequency), 2)     AS avg_orders,
       ROUND(SUM(monetary), 2)      AS revenue,
       ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 2) AS revenue_share_pct
FROM segmented
GROUP BY segment
ORDER BY revenue DESC;

-- Q16: Highest-revenue day in each year (ROW_NUMBER per partition)
WITH daily AS (
    SELECT order_year, order_date, revenue,
           ROW_NUMBER() OVER (PARTITION BY order_year ORDER BY revenue DESC) AS rn
    FROM fact_orders
)
SELECT order_year, order_date, revenue FROM daily WHERE rn = 1 ORDER BY order_year;
