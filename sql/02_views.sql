-- =============================================================
-- Derived view: adds revenue, month, weekday and hour on the fly.
-- Equivalent to the helper columns in the Excel "Transactions" sheet,
-- but here nothing is stored - it's always recalculated from source.
-- =============================================================

CREATE OR REPLACE VIEW v_transactions AS
SELECT
    transaction_id,
    transaction_date,
    transaction_time,
    transaction_qty,
    store_id,
    store_location,
    product_id,
    unit_price,
    ROUND(unit_price * transaction_qty, 2)      AS revenue,
    product_category,
    product_type,
    product_detail,
    EXTRACT(MONTH FROM transaction_date)::INT    AS month_no,
    TO_CHAR(transaction_date, 'FMMonth')         AS month_name,
    EXTRACT(HOUR FROM transaction_time)::INT     AS hour,
    -- ISODOW: 1 = Monday ... 7 = Sunday, matches WEEKDAY(date,2) in Excel
    EXTRACT(ISODOW FROM transaction_date)::INT   AS weekday_no,
    TO_CHAR(transaction_date, 'FMDay')           AS weekday_name
FROM transactions;
