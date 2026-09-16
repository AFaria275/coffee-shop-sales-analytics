# Coffee Shop Sales — End-to-End Sales Analysis

A complete data analysis case study on a coffee shop chain with three locations in New York (Astoria, Hell's Kitchen, Lower Manhattan), covering roughly **149,000 transactions** between **January and June 2023**.

The goal was to replicate a real business analysis workflow — from raw data cleaning to actionable recommendations — using **Excel**, **SQL**, and **Power BI**.

---

## Process

1. **Data cleaning & preparation** — handled inconsistencies and structured the raw transactions table in Excel.
2. **Pivot tables & charts** — explored sales patterns in Excel (`Copy of Coffee Shop Sales.xlsx`).
3. **Business analysis** — drew initial insights from the Excel exploration.
4. **SQL replication** — rebuilt the analysis in PostgreSQL (`/sql`) to validate and scale the process.
5. **Power BI dashboard** — built a 4-page interactive dashboard (`/powerbi`): Overview, Products, Time Patterns, Stores.
6. **Executive summary** — synthesized findings into business recommendations (`/reports`).

## Key Findings

- Revenue grew steadily across the period, from **$82K** in January to **$166K** in June (**+102%**), with the strongest month-over-month increase in May (**+32%**).
- The **top 4 products** account for **44%** of total revenue, with Barista Espresso alone contributing **13%**.
- **10am** is the peak revenue hour, generating nearly twice the average hourly revenue.
- Weekday revenue is evenly distributed, with Monday and Friday slightly leading and Saturday recording the lowest volume.
- All three stores perform at a comparable level (**~$230–236K each**) and grow at a similar pace, with no location significantly outperforming the others.

Full recommendations are available in the [Executive Summary](reports/Executive_Summary_Coffee_Shop_Sales.docx).

## Dashboard preview

**Overview**
![Overview page](images/overview.png)

**Products**
![Products page](images/products.png)

**Time Patterns**
![Time Patterns page](images/time-patterns.png)

**Stores**
![Stores page](images/stores.png)

## Repository structure

```
├── Copy of Coffee Shop Sales.xlsx    # Excel exploration (pivot tables, charts)
├── Coffee Shop Sales.pptx            # Excel-stage presentation
├── sql/                              # PostgreSQL scripts (data validation & analysis)
├── powerbi/                          # Power BI dashboard (.pbix)
├── reports/                          # Executive summary (Word/PDF)
├── images/                           # Dashboard screenshots
└── README.md
```

## Tools

`Excel` · `PostgreSQL` · `Power BI` · `DAX`

## Author

**António Faria** — [LinkedIn](https://www.linkedin.com/in/antoniofaria5/) · [Portfolio site](https://afaria275.github.io)
