-- =============================================================
-- Coffee Shop Sales | New York | Jan-Jun 2023
-- Schema
-- =============================================================
-- Source: transaction-level extract, one row per transaction line
-- (matches the "Transactions" sheet of the Excel workbook, tblTransactions)

DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    transaction_id      INTEGER PRIMARY KEY,
    transaction_date    DATE         NOT NULL,
    transaction_time    TIME         NOT NULL,
    transaction_qty     SMALLINT     NOT NULL,
    store_id            SMALLINT     NOT NULL,
    store_location      VARCHAR(30)  NOT NULL,
    product_id          SMALLINT     NOT NULL,
    unit_price          NUMERIC(6,2) NOT NULL,
    product_category    VARCHAR(30)  NOT NULL,
    product_type        VARCHAR(40)  NOT NULL,
    product_detail       VARCHAR(60)  NOT NULL
);

-- Revenue, month, weekday and hour are derived rather than stored,
-- so the model can't drift out of sync with the source columns.
-- (In the Excel version these were helper columns; in SQL they
-- become computed expressions or a view - see 02_views.sql)

CREATE INDEX idx_transactions_date  ON transactions (transaction_date);
CREATE INDEX idx_transactions_store ON transactions (store_location);
CREATE INDEX idx_transactions_type  ON transactions (product_type);
