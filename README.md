# E-commerce Sales Analytics: SQL Project

An end-to-end SQL analysis of 5,000 e-commerce orders (989 customers, 4 categories, 4 regions, 3 payment methods). Built in SQLite, runs with one command, and every number below comes from a query in `sql/`.

## Project structure

```
ecommerce_sql_project/
├── data/ecommerce_sales_analytics_5000.csv   raw data
├── sql/
│   ├── 01_schema.sql            drop/create staging table
│   ├── 02_transform.sql         star schema, date cleaning, indexes, views
│   ├── 03_data_quality.sql      8 validation checks
│   └── 04_business_analysis.sql 16 business queries
├── results/                     CSV output of every query + summary.md
├── build_db.py                  builds ecommerce.db and runs all SQL
└── ecommerce.db                 ready-to-open SQLite database
```

**Run it:** `python build_db.py` (Python 3 only, no packages needed). Open `ecommerce.db` in DB Browser for SQLite, DBeaver, or VS Code SQLite extension.

## Data model (star schema)

```
dim_category ─┐
dim_region  ──┼──< fact_orders >── dim_customer
dim_payment ──┘
```

`fact_orders` holds one row per order (quantity, unit price, discount, gross amount, revenue, delivery days, rating). Constraints: primary/foreign keys and CHECK rules on quantity, discount, rating. Views `vw_orders_enriched` and `vw_customer_summary` keep the analysis queries short.

## Data preparation and quality

- Raw dates are text in `M/D/YYYY`; they are converted to ISO `YYYY-MM-DD` in SQL using `substr`/`instr`.
- All 8 checks in `03_data_quality.sql` pass: row counts match, `order_id` unique, no NULLs, no orphan keys, valid dates, sane ranges, and `revenue = quantity × unit_price × (1 − discount)` on every row.
- 67 high-revenue orders are statistical outliers (above Q3 + 1.5×IQR); they are legitimate large orders, so they were kept.
- **Caveat:** the data has exactly one order per day from 2022-01-01 to 2035-09-09, which means it is synthetic and includes future dates. Year-over-year figures are therefore illustrative, and the partial year 2035 is flagged and excluded from growth calculations.

## SQL skills demonstrated

Joins, aggregation, `CASE`, CTEs, views, indexes, constraints, window functions (`RANK`, `ROW_NUMBER`, `NTILE`, `LAG`, running totals, moving average, `SUM() OVER ()` for shares), conditional aggregation (pivot), date/string handling, and RFM customer segmentation.

## Key findings

| Area | Finding |
|---|---|
| Overall | 5.11M revenue from 5,000 orders; average order value 1,022; 18.1% of gross sales given away as discounts |
| Category | Electronics leads with 35.8% of revenue, then Clothing 30.0%, Home 19.2%, Beauty 15.0%. Electronics is #1 in all four regions |
| Region | West is highest (1.35M), East lowest (1.24M); the gap is only about 9%, so regions are fairly balanced |
| Payment | Card 45% of orders, COD 35%, Wallet 19%. Card has the highest average order value (1,042) |
| Discounts | Orders with 0-9% discount average 1,175; those with 30-35% average 854. Deeper discounts did **not** increase quantity (about 4 units in every band) or ratings, so they reduce revenue without a visible volume gain |
| Delivery vs rating | Ratings are about 2.9-3.0 whatever the delivery time, so delivery speed shows no relationship with ratings in this data |
| Customers | Top 20% of customers (197) generate 37% of revenue, a much flatter spread than a classic 80/20. Only 39 customers bought once |
| RFM | "Champions" are 269 customers and 41.8% of revenue. 43 high-value customers are "at risk" (no recent orders), worth a win-back campaign |
| Trend | Yearly revenue is flat at roughly 350-410K with no consistent growth. May is the strongest month on average |

## Suggested recommendations

1. Review discount policy: the 30-35% band cuts average order value by about 27% versus the lowest band with no gain in units.
2. Target the 43 at-risk high-value customers with a win-back offer.
3. Lead marketing with Electronics, which is the top category in every region.
4. Investigate why average rating is only about 3/5 across every segment, since neither delivery time nor discount explains it.

## Resume bullets

- Designed a star-schema SQLite database from 5,000 e-commerce orders and wrote 16 analytical queries using CTEs and window functions.
- Built automated data-quality checks (8 validations) and an RFM segmentation identifying a customer group worth 42% of revenue.
- Found that deeper discounts reduced average order value by about 27% without increasing units sold.
