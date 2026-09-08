-- =============================================================
-- Data quality checks
-- Mirrors the checks in the Excel workbook (Transactions!E4:I14) -
-- every check should return 0 rows / 'OK'.
-- =============================================================

-- -------------------------------------------------------------
-- A. Schema conformance
-- transaction_id is PRIMARY KEY and transaction_date/store_id/
-- product_id are NOT NULL in 01_schema.sql, so checks 1-3 can only
-- ever return 0 - the table physically rejects a row that would
-- fail them. Kept for parity with the Excel checklist and as
-- documentation of what the schema already guarantees; they are
-- not evidence of clean *source* data the way 4-7 are. To actually
-- test the raw extract, run these against a staging table loaded
-- without the PK/NOT NULL constraints, before the constrained load.
-- -------------------------------------------------------------

-- 1. Duplicate transaction_id
SELECT COUNT(*) AS duplicate_transaction_ids
FROM (
    SELECT transaction_id, COUNT(*)
    FROM transactions
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
) d;

-- 2. Blank / null dates
SELECT COUNT(*) AS blank_dates FROM transactions WHERE transaction_date IS NULL;

-- 3. Blank store or product id
SELECT COUNT(*) AS blank_ids
FROM transactions
WHERE store_id IS NULL OR product_id IS NULL;

-- -------------------------------------------------------------
-- B. Real data quality checks
-- Nothing in the schema protects against these - a genuine test
-- of the source extract.
-- -------------------------------------------------------------

-- 4. Quantity or unit price not positive
SELECT COUNT(*) AS non_positive_values
FROM transactions
WHERE transaction_qty <= 0 OR unit_price <= 0;

-- 5. Dates outside the expected period (2023-01-01 to 2023-06-30)
SELECT COUNT(*) AS dates_out_of_range
FROM transactions
WHERE transaction_date NOT BETWEEN '2023-01-01' AND '2023-06-30';

-- 6. Trading hours outside 6 a.m. - 8 p.m.
SELECT COUNT(*) AS hours_out_of_range
FROM v_transactions
WHERE hour NOT BETWEEN 6 AND 20;

-- 7. Reconciliation: total revenue should equal 698,812.33
-- (README.md, Excel PVT!Grand Total and PPT slide 4 all agree on this figure)
SELECT ROUND(SUM(revenue), 2) AS total_revenue,
       COUNT(*)               AS total_transactions
FROM v_transactions;
