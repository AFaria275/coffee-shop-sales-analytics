-- =============================================================
-- Business analysis
-- Every result below was cross-checked against the Excel pivots
-- and ties out exactly.
-- =============================================================

-- -------------------------------------------------------------
-- 1. Headline KPIs
-- -------------------------------------------------------------
SELECT
    ROUND(SUM(revenue), 2)                                     AS total_revenue,
    ROUND(SUM(revenue) / COUNT(DISTINCT month_no), 2)          AS avg_monthly_revenue,
    COUNT(*)                                                   AS total_transactions,
    SUM(transaction_qty)                                       AS units_sold,
    ROUND(SUM(revenue) / COUNT(*), 2)                          AS avg_ticket,
    ROUND(SUM(revenue) / SUM(transaction_qty), 2)              AS avg_price_per_unit,
    ROUND(SUM(transaction_qty)::NUMERIC / COUNT(*), 3)         AS items_per_transaction
FROM v_transactions;
-- Cross-checked against PPT slide 4: 698,812 / 149,116 / 214,470 / 4.69 / 3.26 / 1.44

-- 1b. Total revenue growth, January vs June (PPT slide 2 & 4: "+103.8%")
WITH jan_jun AS (
    SELECT month_no, SUM(revenue) AS revenue
    FROM v_transactions
    WHERE month_no IN (1, 6)
    GROUP BY month_no
)
SELECT
    ROUND(
        (MAX(CASE WHEN month_no = 6 THEN revenue END)
         - MAX(CASE WHEN month_no = 1 THEN revenue END))
        * 100.0 / MAX(CASE WHEN month_no = 1 THEN revenue END), 1
    ) AS revenue_growth_jan_to_jun_pct
FROM jan_jun;

-- -------------------------------------------------------------
-- 2. Revenue by month x store
-- -------------------------------------------------------------
SELECT month_no, month_name, store_location, ROUND(SUM(revenue), 2) AS revenue
FROM v_transactions
GROUP BY month_no, month_name, store_location
ORDER BY month_no, store_location;

-- -------------------------------------------------------------
-- 3. Monthly trend: revenue, transactions, avg ticket and MoM growth
--    (window functions - this goes beyond what a static pivot can show)
-- -------------------------------------------------------------
WITH monthly AS (
    SELECT
        month_no,
        month_name,
        SUM(revenue)              AS revenue,
        COUNT(*)                  AS transactions,
        SUM(revenue) / COUNT(*)   AS avg_ticket
    FROM v_transactions
    GROUP BY month_no, month_name
)
SELECT
    month_no,
    month_name,
    ROUND(revenue, 2)      AS revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month_no))
        / LAG(revenue) OVER (ORDER BY month_no), 4
    ) AS revenue_mom,
    transactions,
    ROUND(avg_ticket, 2)   AS avg_ticket,
    ROUND(
        (avg_ticket - LAG(avg_ticket) OVER (ORDER BY month_no))
        / LAG(avg_ticket) OVER (ORDER BY month_no), 4
    ) AS avg_ticket_mom,
    ROUND(
        (transactions - LAG(transactions) OVER (ORDER BY month_no))::NUMERIC
        / LAG(transactions) OVER (ORDER BY month_no), 4
    ) AS transactions_mom
FROM monthly
ORDER BY month_no;
-- Cross-checked against Excel PVT!"Average ticket by month" (avg_ticket_mom,
-- transactions_mom) and PVT!"Revenue MoM by store" (confirms revenue MoM is
-- part of the workbook's own analysis, just split by store there).

-- -------------------------------------------------------------
-- 4. Top products by revenue, with cumulative share
--    (identifies how many SKUs drive 80% of revenue)
-- -------------------------------------------------------------
WITH prod AS (
    SELECT product_type, SUM(revenue) AS revenue
    FROM v_transactions
    GROUP BY product_type
),
total AS (SELECT SUM(revenue) AS grand_total FROM v_transactions)
SELECT
    product_type,
    ROUND(revenue, 2) AS revenue,
    ROUND(revenue * 100.0 / (SELECT grand_total FROM total), 2) AS pct_of_total,
    ROUND(
        SUM(revenue) OVER (ORDER BY revenue DESC) * 100.0
        / (SELECT grand_total FROM total), 2
    ) AS cumulative_pct
FROM prod
ORDER BY revenue DESC;

-- -------------------------------------------------------------
-- 5. Category growth: January vs June
-- -------------------------------------------------------------
WITH jan AS (
    SELECT product_category, SUM(revenue) AS revenue
    FROM v_transactions WHERE month_no = 1 GROUP BY product_category
),
jun AS (
    SELECT product_category, SUM(revenue) AS revenue
    FROM v_transactions WHERE month_no = 6 GROUP BY product_category
)
SELECT
    j.product_category,
    ROUND(j.revenue, 2) AS revenue_jan,
    ROUND(u.revenue, 2) AS revenue_jun,
    ROUND((u.revenue - j.revenue) * 100.0 / j.revenue, 1) AS pct_growth
FROM jan j
JOIN jun u ON j.product_category = u.product_category
ORDER BY pct_growth DESC;
-- INNER JOIN: a category with revenue in only one of the two months would
-- silently drop out. Fine here - all 10 categories in PVT!"Analysis by
-- product category" trade in both Jan and Jun - but worth an outer join
-- if the product-level version below (query 11) is ever extended to
-- categories/products that don't have full six-month history.

-- -------------------------------------------------------------
-- 6. Revenue by weekday x hour (heat map source data)
-- -------------------------------------------------------------
SELECT weekday_no, weekday_name, hour, ROUND(SUM(revenue), 2) AS revenue
FROM v_transactions
GROUP BY weekday_no, weekday_name, hour
ORDER BY weekday_no, hour;

-- -------------------------------------------------------------
-- 7. Store category mix - coffee beans as % of store revenue
--    (surfaces the Hell's Kitchen outlier: 7.9% vs ~4.5% elsewhere)
-- -------------------------------------------------------------
SELECT
    store_location,
    ROUND(
        SUM(CASE WHEN product_category = 'Coffee beans' THEN revenue ELSE 0 END)
        * 100.0 / SUM(revenue), 2
    ) AS pct_coffee_beans
FROM v_transactions
GROUP BY store_location
ORDER BY pct_coffee_beans DESC;

-- -------------------------------------------------------------
-- 8. Rank each store's top 3 products by revenue
--    (window function - no direct Excel equivalent without a helper column)
-- -------------------------------------------------------------
WITH store_prod AS (
    SELECT
        store_location,
        product_type,
        SUM(revenue) AS revenue,
        RANK() OVER (PARTITION BY store_location ORDER BY SUM(revenue) DESC) AS rnk
    FROM v_transactions
    GROUP BY store_location, product_type
)
SELECT store_location, rnk, product_type, ROUND(revenue, 2) AS revenue
FROM store_prod
WHERE rnk <= 3
ORDER BY store_location, rnk;
-- RANK() lets a tie at 3rd place show as two rows (and skips to rank 5);
-- switch to ROW_NUMBER() if the dashboard needs exactly 3 rows per store
-- no matter what. No ties occur in the current dataset, so both give the
-- same result today - this only matters if the data changes.

-- -------------------------------------------------------------
-- 9. Revenue and transactions by weekday, with % of total
--    (backs the deck's "day of week barely matters" finding -
--    every weekday sits within ~1pp of the 14.3% even share)
-- -------------------------------------------------------------
SELECT
    weekday_no,
    weekday_name,
    ROUND(SUM(revenue), 2)                                        AS revenue,
    COUNT(*)                                                      AS transactions,
    ROUND(SUM(revenue) / COUNT(*), 2)                             AS avg_ticket,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (), 4)    AS pct_of_revenue
FROM v_transactions
GROUP BY weekday_no, weekday_name
ORDER BY weekday_no;
-- Cross-checked against Excel PVT!"Analysis by weekday": Monday 101,677.28
-- (14.55%) through Saturday 96,894.48 (13.87%, the weakest day).

-- -------------------------------------------------------------
-- 10. Revenue by hour, all stores and weekdays combined
--     (the single-dimension cut behind "07:00-11:00 = 45.8% of revenue")
-- -------------------------------------------------------------
SELECT
    hour,
    ROUND(SUM(revenue), 2)                                      AS revenue,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (), 4)  AS pct_of_revenue
FROM v_transactions
GROUP BY hour
ORDER BY hour;
-- Cross-checked against Excel PVT!"Analysis by hour": hours 7-10 sum to
-- 320,069.26 = 45.81% of the 698,812.33 total, matching the deck exactly.

-- -------------------------------------------------------------
-- 11. Product-level growth, January vs June
--     (category growth in query 5 hides this - the deck and the
--     Excel README both flag it as a real limitation: "category
--     averages hide product-level divergence")
-- -------------------------------------------------------------
WITH jan AS (
    SELECT product_type, SUM(revenue) AS revenue
    FROM v_transactions WHERE month_no = 1 GROUP BY product_type
),
jun AS (
    SELECT product_type, SUM(revenue) AS revenue
    FROM v_transactions WHERE month_no = 6 GROUP BY product_type
)
SELECT
    j.product_type,
    ROUND(j.revenue, 2) AS revenue_jan,
    ROUND(u.revenue, 2) AS revenue_jun,
    ROUND((u.revenue - j.revenue) * 100.0 / j.revenue, 1) AS pct_growth
FROM jan j
JOIN jun u ON j.product_type = u.product_type
ORDER BY pct_growth DESC;
-- Cross-checked against Excel PVT!"Analysis by product": Chai tea +208.6%,
-- Gourmet Beans +125.2%, Espresso Beans +52.5%, Clothing +54.6% - the four
-- products the deck and README call out by name.

-- -------------------------------------------------------------
-- 12. Store summary: revenue, transactions, avg ticket, % of total
--     (explicit store-level roll-up - query 2 has the figures but
--     only broken out by month; this is the plain PVT!"Analysis by
--     store" equivalent)
-- -------------------------------------------------------------
SELECT
    store_location,
    ROUND(SUM(revenue), 2)                                      AS revenue,
    COUNT(*)                                                    AS transactions,
    ROUND(SUM(revenue) / COUNT(*), 2)                           AS avg_ticket,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (), 4)  AS pct_of_revenue
FROM v_transactions
GROUP BY store_location
ORDER BY revenue DESC;
-- Cross-checked against Excel PVT!"Analysis by store": Hell's Kitchen
-- 236,511.17 / 50,735 / 4.66 leads by a slim 3% margin over the other two.

-- -------------------------------------------------------------
-- 13. Revenue MoM by store
--     (query 3 has the MoM total; this splits it by store, matching
--     PVT!"Revenue MoM by store")
-- -------------------------------------------------------------
WITH monthly_store AS (
    SELECT month_no, month_name, store_location, SUM(revenue) AS revenue
    FROM v_transactions
    GROUP BY month_no, month_name, store_location
)
SELECT
    month_no,
    month_name,
    store_location,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (PARTITION BY store_location ORDER BY month_no))
        / LAG(revenue) OVER (PARTITION BY store_location ORDER BY month_no), 4
    ) AS revenue_mom
FROM monthly_store
ORDER BY store_location, month_no;
-- Cross-checked against Excel PVT!"Revenue MoM by store": Astoria Feb -8.1%,
-- Hell's Kitchen Feb -7.6%, Lower Manhattan Feb -4.6%.

-- -------------------------------------------------------------
-- 14. Items and items per transaction, by month
--     (query 1 has this as one aggregate figure; PVT!"Average ticket
--     by month" tracks it monthly)
-- -------------------------------------------------------------
SELECT
    month_no,
    month_name,
    SUM(transaction_qty)                                        AS items,
    COUNT(*)                                                     AS transactions,
    ROUND(SUM(transaction_qty)::NUMERIC / COUNT(*), 4)           AS items_per_transaction
FROM v_transactions
GROUP BY month_no, month_name
ORDER BY month_no;
-- Cross-checked against Excel PVT!"Average ticket by month": Jan 1.4364,
-- Jun 1.4410 items per transaction.

-- -------------------------------------------------------------
-- 15. Category summary: revenue, quantity, % of revenue, avg price/unit
--     (query 5 has category growth Jan->Jun; this is the "current state"
--     equivalent of query 12, one level up from store to category)
-- -------------------------------------------------------------
SELECT
    product_category,
    ROUND(SUM(revenue), 2)                                        AS revenue,
    SUM(transaction_qty)                                          AS quantity,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (), 4)    AS pct_of_revenue,
    ROUND(SUM(revenue) / SUM(transaction_qty), 2)                 AS avg_price_per_unit
FROM v_transactions
GROUP BY product_category
ORDER BY revenue DESC;
-- Cross-checked against Excel PVT!"Analysis by product category": Coffee
-- 38.6% of revenue at 3.02/unit, Branded the outlier at 17.53/unit.

-- -------------------------------------------------------------
-- 16. Growth by hour, January vs June
--     (query 10 has the current-state hourly split; this is its
--     Jan->Jun growth equivalent, matching PVT!"Growth by hour")
-- -------------------------------------------------------------
WITH jan AS (
    SELECT hour, SUM(revenue) AS revenue
    FROM v_transactions WHERE month_no = 1 GROUP BY hour
),
jun AS (
    SELECT hour, SUM(revenue) AS revenue
    FROM v_transactions WHERE month_no = 6 GROUP BY hour
)
SELECT
    j.hour,
    ROUND(j.revenue, 2) AS revenue_jan,
    ROUND(u.revenue, 2) AS revenue_jun,
    ROUND((u.revenue - j.revenue) * 100.0 / j.revenue, 1) AS pct_growth
FROM jan j
JOIN jun u ON j.hour = u.hour
ORDER BY j.hour;
-- Cross-checked against Excel PVT!"Growth by hour": the 20:00 hour grew
-- +153.8% (the fastest of any hour), 09:00 was the slowest at +90.0% -
-- every hour grew, just at different rates.

-- -------------------------------------------------------------
-- 17. Product category by store (full matrix)
--     (query 7 isolates coffee beans only; this is every category,
--     matching PVT!"Product category by store")
-- -------------------------------------------------------------
SELECT
    product_category,
    store_location,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(
        SUM(revenue) * 100.0
        / SUM(SUM(revenue)) OVER (PARTITION BY store_location), 4
    ) AS pct_of_store_revenue
FROM v_transactions
GROUP BY product_category, store_location
ORDER BY product_category, store_location;
-- Cross-checked against Excel PVT!"Product category by store": Branded
-- ranges from 0.8% (Hell's Kitchen) to 2.7% (Lower Manhattan) of each
-- store's revenue; Coffee beans has the widest spread of any category,
-- 4.4%-7.9% (the Hell's Kitchen outlier already flagged in query 7).
