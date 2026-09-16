# Coffee Shop Sales — New York

Portfolio project in Data / Business Analytics: six months of
transaction-level sales data from a three-store coffee shop chain,
analysed end to end — from raw data to a published case study.

## Objective

Analyse commercial performance across three New York stores and turn
~149,000 individual transactions into a set of findings and
recommendations a manager could act on.

## Data source

Public **"Coffee Shop Sales"** dataset ([Maven Analytics](https://www.mavenanalytics.io/)).
Raw transaction-level extract, one row per transaction line,
January–June 2023, stores: Astoria, Hell's Kitchen, Lower Manhattan.

## Pipeline

The same dataset is worked through four stages, each building on the
last, so every number can be traced back to the raw data no matter
which stage you're looking at.

| Stage | Status | What it covers |
|---|---|---|
| 1. Excel | ✅ Done | Source table → pivot layer → one-page dashboard. Every figure is a formula, no typed numbers. |
| 2. SQL | ✅ Done | Same data re-implemented as a relational model in PostgreSQL — schema, a derived view, data-quality checks, and business-analysis queries, cross-checked against the Excel pivots. |
| 3. Power BI | ✅ Done | 4-page interactive dashboard (Overview, Products, Time Patterns, Stores). |
| 4. Executive summary | ✅ Done | Findings synthesized into business recommendations. |
| 5. Case study site | 🔜 In progress | Write-up presenting the project end to end on my [portfolio site](https://afaria275.github.io). |

## Repository structure

```
Copy of Coffee Shop Sales.xlsx   Source table, pivots, dashboard
Coffee Shop Sales.pptx           Excel-stage presentation
sql/                             Schema, view, data-quality checks, business-analysis queries
powerbi/                         Power BI dashboard (.pbix)
reports/                         Executive summary (Word/PDF)
```

## Headline findings

- **Revenue nearly doubled in six months** — from $82K in January to
  $166K in June (**+102%**), on $698.8K total across ~149,000
  transactions, with the strongest month-over-month increase in May
  (+32%).
- **Product concentration** — the top 4 products account for **44%**
  of total revenue, with Barista Espresso alone contributing 13%.
- **The morning is the business** — 10am is the peak revenue hour,
  generating nearly twice the average hourly revenue.
- **Weekdays are evenly balanced** — Monday and Friday slightly lead,
  Saturday records the lowest volume.
- **Three stores, comparable performance** — revenue is within 3%
  across all three stores (~$230–236K each), growing at a similar
  pace, with no location significantly outperforming the others.

Full recommendations are available in the [Executive Summary](reports/Executive_Summary_Coffee_Shop_Sales.docx).

## Skills demonstrated

Excel (pivot tables, dashboard design) · PostgreSQL (schema design,
views, CTEs, window functions) · Power BI (DAX measures, interactive
dashboarding) · data quality validation · business analysis and
written recommendations.

## Limitations

No customer identifier (no repeat-purchase analysis), no cost/margin
data (revenue-only, not profitability), and six months of data isn't
enough to fully separate seasonality from underlying growth.

## Author

**António Faria** — [LinkedIn](https://www.linkedin.com/in/antoniofaria5/) · [Portfolio site](https://afaria275.github.io)
