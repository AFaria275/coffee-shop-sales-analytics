# Coffee Shop Sales — SQL analysis

Second stage of the portfolio project (Excel → **SQL** → Power BI → site).
Same source data as the Excel workbook, re-implemented as a relational
model and a set of PostgreSQL queries, so every result can be
cross-checked one against the other.

## Files

| File | Purpose |
|---|---|
| `01_schema.sql` | Table definition for `transactions` (one row per transaction line) |
| `02_views.sql` | `v_transactions` view — derives revenue, month, weekday and hour on the fly instead of storing them |
| `03_data_quality.sql` | Same checks as the Excel workbook (duplicates, blanks, out-of-range dates/hours, revenue reconciliation) |
| `04_business_analysis.sql` | Headline KPIs (incl. units sold, avg price/unit, Jan→Jun growth), monthly trend with MoM growth on revenue/avg ticket/transactions, top products with cumulative share, category growth Jan→Jun, weekday×hour heat map source, coffee-beans store mix, top products per store, revenue by weekday, revenue by hour, product-level growth Jan→Jun, store summary, revenue MoM by store, items/items per transaction by month, category summary, growth by hour Jan→Jun, category × store matrix |

## Why this adds to the Excel version

Pivot tables in Excel are limited to what you can drag into rows/columns.
A few things here go further:

- **Month-over-month growth** on revenue, avg ticket and transactions,
  computed with `LAG()` instead of a helper column per row.
- **Cumulative revenue share** of top products (`SUM() OVER (ORDER BY ...)`),
  showing how many SKUs make up 80% of revenue.
- **Top 3 products per store**, ranked with `RANK() OVER (PARTITION BY ...)`
  — no clean Excel equivalent without extra helper columns.

## Validation

Every query was cross-checked against the actual Excel pivots (`PVT` sheet)
and the numbers quoted in the deck (`Coffee_Shop_Sales.pptx`) — all figures
tie out exactly: total revenue (698,812.33), units sold (214,470), avg
ticket (4.69) and avg price/unit (3.26), the +103.8% Jan→Jun revenue growth,
monthly revenue by store, MoM growth, top 10 products (79% of revenue), the
weekday split (13.9%–14.6% each day), the 07:00–11:00 block (45.8% of
revenue), category and product-level growth Jan vs June (incl. Chai tea
+208.6% and Gourmet Beans +125.2%, which category-level growth alone
hides), the Hell's Kitchen coffee-beans outlier (7.9% vs ~4.5% elsewhere),
and the per-store summary.

Note on `03_data_quality.sql`: checks 1-3 (duplicate IDs, blank dates,
blank store/product) can only ever pass, because the schema's PRIMARY KEY
and NOT NULL constraints already reject any row that would fail them —
they document what the schema guarantees, not evidence about the source
data. Checks 4-7 are the real data-quality tests.

## Coverage

All 14 blocks in the Excel `PVT` sheet now have a matching query — month×store,
store, hour, product, weekday, average ticket by month (incl. MoM), the
weekday×hour heat map, product category, category growth Jan→Jun, growth by
hour Jan→Jun, category×store, plus revenue MoM by store. Two things stay
SQL-only, since the pivot sheet has no equivalent: product-level growth
Jan→Jun (query 11 — category-level growth hides it, and both the deck and
the Excel README call that out as a real limitation) and top-3-products-per-
store (query 8, window functions with no clean pivot equivalent).

## Next step

Power BI dashboard (stage 3), built on top of this same data model.
