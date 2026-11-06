# Findings, Recommendations and Limitations

Lending Club loans 2007–2018. Unless stated otherwise, risk figures use **mature loans**
(36-month loans issued before 2016, 60-month loans issued before 2013), because most later loans
had not finished when the data ends.

---

## 1. Key findings

| # | Finding | Evidence |
| --- | --- | --- |
| 1 | Using all completed loans overstates risk: default 19.98% vs 14.87% on mature loans, loss 10.26% vs 5.62% | Q1, Q1b, Q2b |
| 2 | Lending Club's grade separates risk much better than any single variable: 6.8x between A and G, vs 2.9x for FICO and 1.8x for DTI. Region barely matters (14.50%–15.16%) | Q4, Q6, Q7, Q8b |
| 3 | Losses are driven by volume, not by the riskiest niche: debt consolidation causes 62.69% of losses; small business is the riskiest purpose (24.77% default) but causes only 3.02% | Q5, Q14 |
| 4 | Growth came with looser standards: in 2014–2015 average FICO stayed flat, interest rates fell from 13.02% to 10.96% and default rose from 12.87% to about 15%. The gap between interest rate and loss rate shrank from 9.1 to 5.7 points | Q9b, Q16 |
| 5 | On 36-month loans, grades B–C give the best net return (8.81%). Riskier grades lose more and earn less: D 8.03%, E–G 6.03% | Q18b, Q19 |
| 6 | The approval rate fell from 15.05% (2013) to 4.96% (2018) because applications grew 3x, not because fewer loans were made | Q11, Q13 |
| 7 | The South has the lowest approval rate (6.65%) but a default rate close to other regions: stricter screening there offset a riskier applicant pool | Q8b, Q12b |
| 8 | A default model ranks risk well (riskiest 10% default 9.8x more than the safest 10%), but underestimated risk in 2015, especially for risky loans | 04_default_model |

---

## 2. Recommendations

### R1. Report risk on mature cohorts, with early warning indicators for recent loans
- **Finding:** All-loan figures overstate default by about 5 points (Finding 1).
- **Recommendation:** Use mature cohorts for portfolio KPIs and pricing decisions. For recent cohorts, track early
  indicators such as the default rate within the first 12 months, compared with older cohorts at the same age.
- **Impact:** Decisions are based on comparable figures; risk is neither overstated (all loans) nor known too late (mature only).
- **Trade-off:** Mature figures arrive 3–5 years late. Early indicators need loan-level payment history, which this dataset does not include.

### R2. Shift lending towards grades B–C and reprice or limit E–G
- **Finding:** On 36-month loans, E–G return 6.03% with a 12.64% loss rate; B–C return 8.81% with 5.12% (Finding 5).
- **Recommendation:** Cap the share of E–G loans, or raise their interest rates until their return matches the portfolio average.
  Use the freed capital for B–C borrowers.
- **Impact:** Lending the $314M given to E–G at the B–C return would add about $8.7M profit (+1.4% of total net return)
  and cut the loss rate on that capital from 12.64% to about 5%.
- **Trade-off:** Assumes more B–C borrowers of the same quality are available. Rejecting E–G outright, without
  redeploying the money, would **reduce** profit by about $19M, because E–G loans still earned more than they lost
  (Power BI policy scenario).

### R3. Add guardrails to growth: link interest rate cuts to observed performance
- **Finding:** In 3 of the 4 years after 2011, fast growth came with rising default; in 2014–2015 rates were cut while
  risk rose (Finding 4).
- **Recommendation:** Monitor the spread between interest rate and loss rate for each new cohort. Cut rates only when
  early performance of recent cohorts supports it.
- **Impact:** Avoids the pattern of 2014–2015, when the margin shrank from 9.1 to 5.7 points.
- **Trade-off:** Slower growth and possibly lost market share to competitors offering lower rates.

### R4. Focus loss reduction on debt consolidation loans
- **Finding:** Debt consolidation is 60.15% of the amount and 62.69% of losses (Finding 3).
- **Recommendation:** Put loss reduction efforts (tighter DTI and loan-to-income limits, extra verification) on this
  segment first, rather than on small niches like small business loans.
- **Impact:** Even a small improvement here affects most of the portfolio's losses.
- **Trade-off:** Stricter rules for the largest segment directly reduce volume.

### R5. Use additional signals in screening, and recalibrate the risk model every year
- **Finding:** Recent credit inquiries, loan-to-income and missing employment length predict default beyond
  FICO and income; combining them with the grade improved the model (AUC 0.679 to 0.688). The model underestimated
  2015 risk by up to 3.8 points in the riskiest deciles (Finding 8).
- **Recommendation:** Add these variables to screening rules, and recalibrate the model on the most recent mature cohorts every year.
- **Impact:** Better ranking of applicants and probabilities that stay close to actual default rates.
- **Trade-off:** The ranking gain is small. Every new variable needs a fairness and regulatory review before use in credit decisions.

### R6. Keep one national policy, but review Nevada
- **Finding:** Regions differ very little in default rate once screening is taken into account (Finding 7).
  Nevada combines a high approval rate (8.92%) with the highest default rate (18.08%).
- **Recommendation:** No region-specific pricing is needed. Review the approval criteria for Nevada.
- **Impact:** Avoids the complexity of regional pricing while fixing the clearest outlier.
- **Trade-off:** State differences may partly reflect a different borrower mix rather than location itself.

---

## 3. Limitations

1. **Selection bias from approval:** the data contains only approved loans. Rejected applicants' outcomes are unknown,
   so the model and the findings apply to borrowers who passed Lending Club's screening.
2. **Immature loans:** most loans issued after 2015 had not finished. Mature cohorts fix this, but they exclude the most recent
   years and all 60-month loans issued after 2013.
3. **Data period:** 2007–2018. The findings may not hold under different economic conditions or after later policy changes.
4. **Simple profit measure:** net return = total payments − loan amount. It ignores funding costs, fees and the time value of
   money, so small positive returns (for example in grades F–G) may be losses in practice.
5. **Rejected application data:** the rejected file may not include every application; `risk_score` changes scale in 2013 and is
   mostly missing after 2014, and employment length looks like a form default (76% "< 1 year"). It is used only for counts.
6. **Correlation, not causation:** findings such as "rates fell while default rose" describe what happened at the same time;
   this data cannot prove the cause.
7. **Model scope:** the model uses Lending Club's own sub-grade, so it partly learns Lending Club's assessment. It was built and
   tested on 36-month loans only.