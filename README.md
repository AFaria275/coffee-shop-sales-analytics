# Coffee Shop Sales — New York

Portfolio project in Data / Business Analytics: six months of
transaction-level sales data from a three-store coffee shop chain,
analysed end to end — from raw data to a published case study.

## Objective

Analyse commercial performance across three New York stores and turn
149,116 individual transactions into a set of findings and
recommendations a manager could act on.

## Data source

Public **"Coffee Shop Sales"** dataset ([Maven Analytics](https://www.mavenanalytics.io/)).
Raw transaction-level extract, no sampling — one row per transaction
line, January–June 2023, stores: Astoria, Hell's Kitchen, Lower
Manhattan.

## Pipeline

The same dataset is worked through four stages, each building on the
last, so every number can be traced back to the raw data no matter
which stage you're looking at.

| Stage | Status | What it covers |
|---|---|---|
| 1. Excel | ✅ Done | Source table → pivot layer → one-page dashboard. Every figure is a formula, no typed numbers. |
| 2. SQL | ✅ Done | Same data re-implemented as a relational model in PostgreSQL — schema, a derived view, data-quality checks, and 17 business-analysis queries, cross-checked against the Excel pivots. |
| 3. Power BI | 🔜 Next | Interactive dashboard on top of the same data model. |
| 4. Case study site | 🔜 Planned | Write-up presenting the project end to end. |

## Repository structure

```
Copy of Coffee Shop Sales.xlsx   Source table, pivots, one-page dashboard
Coffee Shop Sales.pptx           Executive summary and recommendations
sql/                             Schema, view, data-quality checks,
                                  business-analysis queries
                                  (see sql/README.md for the technical
                                  detail of this stage)
```

## Headline findings

- **Revenue doubled in six months** — from $81,678 in January to
  $166,486 in June (+103.8%), on $698,812 total across 149,116
  transactions.
- **Growth is volume, not price** — transactions grew 104% while the
  average ticket barely moved ($4.72 → $4.71). No pricing or upsell
  effect shows up yet.
- **The morning is the business** — 07:00–11:00 carries 45.8% of
  revenue, in all three stores, every day of the week.
- **Three stores, three different baskets** — revenue is within 3%
  across all three stores, but Hell's Kitchen sells coffee beans at
  nearly twice the rate of the other two (7.9% vs ~4.5% of revenue).
- **Category averages hide product-level swings** — e.g. Chai tea
  (+209%) and Gourmet Beans (+125%) grew far faster than their
  categories, a divergence only visible at product level.

## Skills demonstrated

Excel (pivot tables, `GETPIVOTDATA`, `XLOOKUP`, dashboard design) ·
PostgreSQL (schema design, views, CTEs, window functions —
`LAG`, `RANK`, `SUM() OVER`) · data quality validation · business
analysis and written recommendations.

## Limitations

No customer identifier (no repeat-purchase analysis), no cost/margin
data (revenue-only, not profitability), and six months of data isn't
enough to separate seasonality from underlying growth. See
`deck/Coffee_Shop_Sales.pptx` for the full list and what would resolve
each one.
