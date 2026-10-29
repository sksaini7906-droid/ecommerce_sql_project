### Q1. Row counts match between staging and fact

| check_name | pass |
|---|---|
| row_count_match | 1 |

### Q2. order_id is unique

| check_name | pass |
|---|---|
| order_id_unique | 1 |

### Q3. No NULLs in any key column

| check_name | pass |
|---|---|
| no_nulls | 1 |

### Q4. Revenue equals quantity * price * (1 - discount) within 1 paisa

| check_name | pass |
|---|---|
| revenue_formula_valid | 1 |

### Q5. Dates parsed correctly (valid ISO and ordered by order_id)

| check_name | pass |
|---|---|
| dates_valid_iso | 1 |

### Q6. No orphan foreign keys

| check_name | pass |
|---|---|
| no_orphan_customers | 1 |

### Q7. Value ranges sane (rating 1-5, discount 0-35%, delivery 1-11 days)

| check_name | pass |
|---|---|
| ranges_sane | 1 |

### Q8. Outlier scan: orders above Q3 + 1.5*IQR of revenue

| check_name | n_orders |
|---|---|
| high_revenue_outliers_count | 67 |

### Q1: Executive KPI summary

| total_orders | unique_customers | total_revenue | avg_order_value | units_sold | discount_pct_of_gross | avg_rating | avg_delivery_days |
|---|---|---|---|---|---|---|---|
| 5000 | 989 | 5109775.74 | 1021.96 | 20224 | 18.11 | 2.97 | 6.12 |

### Q2: Revenue by category with share of total

| category | orders | revenue | revenue_share_pct | avg_order_value | avg_rating |
|---|---|---|---|---|---|
| Electronics | 1777 | 1829899.22 | 35.81 | 1029.77 | 2.95 |
| Clothing | 1531 | 1531931.72 | 29.98 | 1000.61 | 3.01 |
| Home | 969 | 982083.92 | 19.22 | 1013.5 | 2.94 |
| Beauty | 723 | 765860.88 | 14.99 | 1059.28 | 3.01 |

### Q3: Regional performance

| region | orders | revenue | avg_order_value | avg_delivery_days | avg_rating | revenue_rank |
|---|---|---|---|---|---|---|
| West | 1289 | 1345582.16 | 1043.9 | 6.08 | 2.96 | 1 |
| North | 1276 | 1281508.45 | 1004.32 | 6.12 | 2.99 | 2 |
| South | 1208 | 1246640.9 | 1031.99 | 6.17 | 2.97 | 3 |
| East | 1227 | 1236044.23 | 1007.37 | 6.1 | 2.97 | 4 |

### Q4: Payment method mix

| payment_method | orders | order_share_pct | revenue | avg_order_value | avg_rating |
|---|---|---|---|---|---|
| Card | 2270 | 45.4 | 2366248.2 | 1042.4 | 3.02 |
| COD | 1774 | 35.48 | 1788408.44 | 1008.12 | 2.94 |
| Wallet | 956 | 19.12 | 955119.1 | 999.08 | 2.93 |

### Q5: Yearly revenue with YoY growth (LAG); partial years are flagged, not compared

| order_year | orders | revenue | coverage | yoy_growth_pct |
|---|---|---|---|---|
| 2022 | 365 | 371824.3 | full year |  |
| 2023 | 365 | 365915.79 | full year | -1.59 |
| 2024 | 366 | 363209.13 | full year | -0.74 |
| 2025 | 365 | 349802.33 | full year | -3.69 |
| 2026 | 365 | 386369.69 | full year | 10.45 |
| 2027 | 365 | 386151.91 | full year | -0.06 |
| 2028 | 366 | 376844.8 | full year | -2.41 |
| 2029 | 365 | 359239.24 | full year | -4.67 |
| 2030 | 365 | 387884.46 | full year | 7.97 |
| 2031 | 365 | 365250.83 | full year | -5.84 |
| 2032 | 366 | 386584.63 | full year | 5.84 |
| 2033 | 365 | 408725.72 | full year | 5.73 |
| 2034 | 365 | 363239.55 | full year | -11.13 |
| 2035 | 252 | 238733.36 | partial year |  |

### Q6: Monthly revenue with 3-month moving average (first 12 months shown)

| year_month | revenue | moving_avg_3m | cumulative_revenue |
|---|---|---|---|
| 2022-01 | 35624.89 | 35624.89 | 35624.89 |
| 2022-02 | 29908.89 | 32766.89 | 65533.78 |
| 2022-03 | 30309.28 | 31947.69 | 95843.06 |
| 2022-04 | 30781.96 | 30333.38 | 126625.02 |
| 2022-05 | 41629.24 | 34240.16 | 168254.26 |
| 2022-06 | 29847.33 | 34086.18 | 198101.59 |
| 2022-07 | 28686.24 | 33387.6 | 226787.83 |
| 2022-08 | 29186.45 | 29240.01 | 255974.28 |
| 2022-09 | 28791.07 | 28887.92 | 284765.35 |
| 2022-10 | 29265.55 | 29081.02 | 314030.9 |
| 2022-11 | 32329.49 | 30128.7 | 346360.39 |
| 2022-12 | 25463.91 | 29019.65 | 371824.3 |

### Q7: Seasonality - average revenue per calendar month across all years

| order_month | avg_revenue_per_year | avg_order_value |
|---|---|---|
| 1 | 30455.35 | 982.43 |
| 2 | 29563.59 | 1047.82 |
| 3 | 30360.75 | 979.38 |
| 4 | 28479.65 | 949.32 |
| 5 | 34269.47 | 1105.47 |
| 6 | 31638.68 | 1054.62 |
| 7 | 31469.34 | 1015.14 |
| 8 | 32919.63 | 1061.92 |
| 9 | 28740.58 | 1008.44 |
| 10 | 31374.86 | 1012.09 |
| 11 | 31589.07 | 1052.97 |
| 12 | 30822.01 | 994.26 |

### Q8: Discount band impact on order value and rating

| discount_band | orders | avg_quantity | avg_order_value | total_discount_given | avg_rating |
|---|---|---|---|---|---|
| 1) 0-9% | 1260 | 4.05 | 1175.15 | 71242.43 | 2.96 |
| 2) 10-19% | 1413 | 4.02 | 1052.65 | 253084.03 | 2.95 |
| 3) 20-29% | 1476 | 4.11 | 958.78 | 459298.55 | 2.98 |
| 4) 30-35% | 851 | 3.98 | 853.74 | 346621.21 | 3.01 |

### Q9: Delivery speed vs customer rating

| delivery_band | orders | avg_rating | pct_low_rating |
|---|---|---|---|
| 1) 1-3 days (fast) | 1274 | 2.95 | 27.63 |
| 2) 4-7 days (standard) | 1843 | 3.03 | 25.34 |
| 3) 8-11 days (slow) | 1883 | 2.94 | 27.88 |

### Q10: Top 10 customers by revenue (with rank and share)

| rnk | customer_id | orders | total_revenue | avg_order_value | avg_rating | pct_of_total |
|---|---|---|---|---|---|---|
| 1 | 1663 | 14 | 17680.69 | 1262.91 | 2.75 | 0.346 |
| 2 | 1955 | 10 | 16265.15 | 1626.51 | 3.49 | 0.318 |
| 3 | 1675 | 11 | 15036.46 | 1366.95 | 2.98 | 0.294 |
| 4 | 1276 | 11 | 15023.71 | 1365.79 | 3.04 | 0.294 |
| 5 | 1647 | 11 | 14894.97 | 1354.09 | 3.03 | 0.291 |
| 6 | 1804 | 10 | 14330.98 | 1433.1 | 3.04 | 0.28 |
| 7 | 1193 | 7 | 14151.65 | 2021.66 | 3.27 | 0.277 |
| 8 | 1836 | 9 | 14110.78 | 1567.86 | 3.31 | 0.276 |
| 9 | 1957 | 12 | 13956.95 | 1163.08 | 3.18 | 0.273 |
| 10 | 1735 | 8 | 13146.25 | 1643.28 | 3.29 | 0.257 |

### Q11: Best-selling category in each region (RANK within partition)

| region | category | revenue |
|---|---|---|
| East | Electronics | 411803.35 |
| North | Electronics | 472450.93 |
| South | Electronics | 487055.68 |
| West | Electronics | 458589.26 |

### Q12: Category x region revenue matrix (conditional aggregation / pivot)

| category | north | south | east | west |
|---|---|---|---|---|
| Beauty | 186213.0 | 191074.0 | 174909.0 | 213664.0 |
| Clothing | 364659.0 | 348363.0 | 402583.0 | 416327.0 |
| Electronics | 472451.0 | 487056.0 | 411803.0 | 458589.0 |
| Home | 258185.0 | 220148.0 | 246749.0 | 257002.0 |

### Q13: Customer loyalty - repeat vs one-time vs frequent buyers

| frequency_band | customers | revenue | avg_revenue_per_customer |
|---|---|---|---|
| 1 order | 39 | 36803.19 | 943.67 |
| 2-3 orders | 240 | 639214.47 | 2663.39 |
| 4-6 orders | 465 | 2391508.44 | 5143.03 |
| 7+ orders | 245 | 2042249.64 | 8335.71 |

### Q14: Pareto - what share of revenue comes from the top 20% of customers?

| top_customers | revenue | pct_of_revenue |
|---|---|---|
| 197 | 1903458.57 | 37.25 |

### Q15: RFM segmentation (Recency, Frequency, Monetary) using NTILE

| segment | customers | avg_recency_days | avg_orders | revenue | revenue_share_pct |
|---|---|---|---|---|---|
| Champions | 269 | 291.0 | 7.26 | 2134634.33 | 41.78 |
| Loyal high-value | 153 | 1313.0 | 6.64 | 1150661.6 | 22.52 |
| Needs attention | 299 | 1858.0 | 3.27 | 790408.16 | 15.47 |
| Recent / promising | 225 | 322.0 | 3.98 | 780113.92 | 15.27 |
| At risk (high value) | 43 | 1747.0 | 3.67 | 253957.73 | 4.97 |

### Q16: Highest-revenue day in each year (ROW_NUMBER per partition)

| order_year | order_date | revenue |
|---|---|---|
| 2022 | 2022-06-07 | 3917.54 |
| 2023 | 2023-10-24 | 3868.11 |
| 2024 | 2024-03-20 | 4119.33 |
| 2025 | 2025-12-13 | 3451.15 |
| 2026 | 2026-06-03 | 3797.86 |
| 2027 | 2027-05-15 | 3408.27 |
| 2028 | 2028-01-24 | 4055.29 |
| 2029 | 2029-05-08 | 3616.33 |
| 2030 | 2030-06-29 | 4005.93 |
| 2031 | 2031-03-04 | 3898.48 |
| 2032 | 2032-02-04 | 3928.63 |
| 2033 | 2033-10-15 | 3807.92 |
| 2034 | 2034-04-26 | 3678.38 |
| 2035 | 2035-05-16 | 4083.17 |
