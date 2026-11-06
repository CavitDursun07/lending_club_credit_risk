# Lending Club Credit Risk Analysis

End-to-end credit risk analysis of **1.35M completed loans and 27.6M rejected applications** from Lending Club (2007–2018):
data cleaning in Python, a star schema in PostgreSQL, SQL analysis, a default prediction model and a Power BI dashboard.

**Tools:** Python (pandas, scikit-learn, matplotlib) · PostgreSQL · SQL (CTEs, window functions) · Power BI (DAX, what-if parameters)

---

## Business questions

1. How large and how risky is the loan portfolio, and how did risk change over time?
2. Which borrower and loan characteristics drive default?
3. How did approval rates change, and is there a link between approval and loan quality?
4. Would rejecting risky loans have increased profit?

---

## Key findings

**1. Using all completed loans overstates risk.** Most loans issued after 2015 had not finished when the data ends,
so only early payoffs and early defaults are included. On mature loans, the default rate is **14.87%** instead of 19.98%,
and the loss rate is **5.62%** instead of 10.26%.

![Selection bias](images/01_selection_bias.png)

**2. Lending Club's grade separates risk much better than any single variable:** default rate rises 6.8x from grade A to G,
compared with 2.9x across FICO bands and 1.8x across debt-to-income bands. Region barely matters.

![Risk segments](images/02_risk_segments.png)

**3. On 36-month loans, grades B–C give the best net return (8.81%).** Riskier grades lose more and earn less:
above B–C, the extra interest no longer covers the extra loss.

![Risk and return](images/03_risk_return.png)

**4. Growth came with looser standards.** In 2014–2015, average FICO stayed flat while interest rates fell and default rose.
After 2015, applications grew 3x and the approval rate fell from 15% (2013) to 5% (2018).

![Approval rate](images/04_approval_rate.png)

**5. A logistic regression model ranks risk well** (the riskiest 10% of loans default 9.8x more often than the safest 10%),
but it underestimated risk in 2015, especially for risky loans: the model should be recalibrated on recent data.

![Risk deciles](images/09_risk_deciles.png)

➡️ Full findings, 6 recommendations with impact and trade-offs, and limitations:
[docs/findings_and_recommendations.md](docs/findings_and_recommendations.md)

---

## Dashboard

Four pages, built on a star schema with shared date and state dimensions.

| Portfolio overview | Risk segments |
| --- | --- |
| ![Portfolio](images/10_dashboard_portfolio.png) | ![Risk segments](images/11_dashboard_risk.png) |

| Approvals and credit quality | Policy scenario (what-if) |
| --- | --- |
| ![Approvals](images/12_dashboard_approvals.png) | ![Policy scenario](images/13_dashboard_scenario.png) |

The **policy scenario** page lets the user choose a sub-grade cutoff and shows the amount not lent, losses avoided and
the change in profit. Rejecting grades E–G would avoid about $40M of losses but reduce profit by about $19M,
because these loans still earned more than they lost.

---

## Approach

```
Raw CSV (Kaggle)
  → Python: cleaning, target variable, outliers          notebooks/01, 02
  → PostgreSQL: star schema (3 facts, 2 dimensions)       sql/01*
  → SQL: portfolio, segments, vintages, approval rate,
         window functions, policy scenario                sql/02–07
  → Python: EDA and default model                         notebooks/03, 04
  → Power BI: views, DAX measures, 4-page dashboard       sql/08, dashboard/
```

**Methodological choices**
- **Mature cohorts** for all risk figures, to avoid selection bias from loans that had not finished.
- **Ratio of sums**, never average of ratios, for every rate (default, loss, approval, return).
- **Time-based split** for the model: trained on loans issued 2007–2014, tested on 2015.
- **No data leakage:** outcome columns (`total_pymnt`, `recoveries`, `net_loss`) are never used as model inputs;
  missing values are imputed from training data only.

**Data model:** `loans`, `rejected_applications` and `accepted_monthly` share `dim_date` and `dim_state`.
Column definitions and the ER diagram: [docs/data_dictionary.md](docs/data_dictionary.md)

---

## Project structure

```
lending-club-credit-risk/
├── data/
│   ├── raw/                  # Kaggle files (not in the repo)
│   └── processed/            # Cleaned parquet files (not in the repo)
├── notebooks/
│   ├── 01_data_cleaning.ipynb
│   ├── 02_rejected_cleaning.ipynb
│   ├── 03_eda.ipynb
│   └── 04_default_model.ipynb
├── sql/
│   ├── 01_schema.sql                  # loans table, loans_mature view
│   ├── 01b_schema_applications.sql    # rejected_applications, accepted_monthly
│   ├── 01c_dimensions.sql             # dim_date, dim_state
│   ├── 01d_data_checks.sql
│   ├── 02_portfolio_overview.sql
│   ├── 03_segment_analysis.sql
│   ├── 04_vintage_analysis.sql
│   ├── 05_approval_rate.sql
│   ├── 06_trends_and_rankings.sql
│   ├── 07_policy_scenario.sql
│   ├── 08_views.sql                   # Views for Power BI
│   └── 09_risk_scores.sql             # Model output table
├── dashboard/
│   └── credit_risk_dashboard.pbix
├── docs/
│   ├── data_dictionary.md
│   └── findings_and_recommendations.md
├── images/
└── requirements.txt
```

---

## How to reproduce

1. **Data:** download `accepted_2007_to_2018Q4.csv` and `rejected_2007_to_2018Q4.csv` from
   [Kaggle – Lending Club](https://www.kaggle.com/datasets/wordsforthewise/lending-club) into `data/raw/`.
2. **Python environment:**
   ```bash
   python -m venv venv
   venv\Scripts\activate          # Windows
   pip install -r requirements.txt
   ```
3. **Database:** create a PostgreSQL database `credit_risk` and a `.env` file in the project root:
   ```
   DATABASE_URL=postgresql+psycopg2://postgres:YOUR_PASSWORD@localhost:5432/credit_risk
   ```
4. **Schema:** run `sql/01_schema.sql`, `sql/01b_schema_applications.sql` and `sql/01c_dimensions.sql`.
5. **Load data:** run `notebooks/01_data_cleaning.ipynb` and `notebooks/02_rejected_cleaning.ipynb`,
   then check the data with `sql/01d_data_checks.sql`.
6. **Analysis:** run `sql/02`–`sql/07`, then `sql/08_views.sql` and `sql/09_risk_scores.sql` (table only).
7. **Model:** run `notebooks/03_eda.ipynb` and `notebooks/04_default_model.ipynb` (writes `loan_risk_scores`).
8. **Dashboard:** open `dashboard/credit_risk_dashboard.pbix` in Power BI Desktop and refresh.

---

## Limitations

The data contains only approved loans, recent loans are excluded from risk figures, and the profit measure ignores
funding costs and fees. Full list: [docs/findings_and_recommendations.md](docs/findings_and_recommendations.md#3-limitations)

---

**Author:** Cavit Konuralp Dursun · [LinkedIn](https://www.linkedin.com/in/cavitdursun07/)