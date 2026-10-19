SELECT *
FROM loans
LIMIT 10;
-- Q1. What does the loan portfolio look like overall? 
SELECT 
    COUNT(*)                                  AS loan_count,
    ROUND(SUM(loan_amnt)/1e9,2)               AS total_amnt_bn,
    ROUND(AVG(loan_amnt),2)                   AS avg_loan_amnt,
    ROUND(AVG(int_rate),2)                    AS avg_int_rate_pct,
    ROUND(AVG(is_default)*100,2)              AS default_rate_pct,
    ROUND(SUM(net_loss)/1e9,2)                AS total_net_loss_bn,
    ROUND(SUM(net_loss)/SUM(loan_amnt)*100,2) AS loss_rate_pct
FROM loans;
-- Finding: The portfolio contains 1,347,698 completed loans totaling $19.42B
-- (average loan $14.4K, average interest rate 13.24%).
-- About 1 in 5 loans defaulted (19.98%), but only 10.26% of the lent amount was lost,
-- because defaulted borrowers had already repaid part of their loan before defaulting.
-- Note: these figures include immature 2016-2018 loans, so risk is overstated (see Q1b).

-- Q2. How did loan volume and risk change by issue year?
SELECT d.year,
    COUNT(*)                                  AS loan_count,
    ROUND(SUM(l.loan_amnt)/1e6,2)               AS total_amnt_mn,
    ROUND(AVG(l.int_rate),2)                    AS avg_int_rate_pct,
    ROUND(AVG(l.is_default)*100,2)              AS default_rate_pct,
    ROUND(SUM(l.net_loss)/SUM(l.loan_amnt)*100,2) AS loss_rate_pct
FROM loans AS l
JOIN dim_date AS d ON l.issue_date = d.month_date
GROUP BY d.year;
-- Finding: Volume peaked in 2015 ($5,498.58M, 375,544 loans).
-- 2009-2013: default rate stayed between 13.69% and 16.20%, loss rate between 5.81% and 7.24%.
-- 2014-2017: default rate rose to 23.28% and loss rate to 16.54%. This is mostly selection bias:
-- most loans issued in these years were still open when the data ends, so only early payoffs
-- and early defaults are included. The drop in volume after 2015 has the same cause.
-- 2007-2008: very few loans (599 and 2,393), so the high default rates are not reliable.
-- Q2b repeats this on loans_mature to remove the selection bias.

-- Q3. How do 36-month and 60-month loans differ in interest rate and risk?
SELECT
    term_months,
    COUNT(*)                                       AS loan_count,
    ROUND(AVG(loan_amnt), 2)                       AS avg_loan_amnt,
    ROUND(AVG(int_rate), 2)                        AS avg_int_rate_pct,
    ROUND(AVG(is_default) * 100, 2)                AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans
GROUP BY term_months
ORDER BY term_months;
-- Finding: 60-month loans are about 24% of all loans (324,739 of 1,347,698), but they are
-- 1.6x larger on average ($20.3K vs $12.5K) and much riskier: the default rate is 2x higher
-- (32.46% vs 16.02%) and the loss rate is 2.2x higher (15.95% vs 7.34%).
-- The interest rate is only 4.65 points higher (16.77% vs 12.12%), while the loss rate is
-- 8.61 points higher, so the extra interest does not cover the extra loss.
-- As a result, 60-month loans are ~34% of the lent amount but cause ~53% of all net losses.
-- Note: 60-month loans are affected more by selection bias (they take longer to mature),
-- so the gap may be overstated. Q3b checks this on loans_mature.


-- Q1b. What does the mature loan portfolio look like overall? 
SELECT 
    COUNT(*)                                  AS loan_count,
    ROUND(SUM(loan_amnt)/1e9,2)               AS total_amnt_bn,
    ROUND(AVG(loan_amnt),2)                   AS avg_loan_amnt,
    ROUND(AVG(int_rate),2)                    AS avg_int_rate_pct,
    ROUND(AVG(is_default)*100,2)              AS default_rate_pct,
    ROUND(SUM(net_loss)/1e6,2)                AS total_net_loss_mn,
    ROUND(SUM(net_loss)/SUM(loan_amnt)*100,2) AS loss_rate_pct
FROM loans_mature;
-- Finding: The mature portfolio contains 676,296 loans (about half of all loans) totaling $8.84B.
-- Compared with Q1, the default rate drops from 19.98% to 14.87% (about 1 in 7 loans)
-- and the loss rate almost halves, from 10.26% to 5.62% ($497.16M net loss).
-- Q1 overstated portfolio risk because it included immature 2016-2018 loans.
-- From here on, trend and segment analysis uses loans_mature.


-- Q2b. How did mature loan volume and risk change by issue year?
SELECT d.year,
    COUNT(*)                                  AS loan_count,
    ROUND(SUM(l.loan_amnt)/1e6,2)               AS total_amnt_mn,
    ROUND(AVG(l.int_rate),2)                    AS avg_int_rate_pct,
    ROUND(AVG(l.is_default)*100,2)              AS default_rate_pct,
    ROUND(SUM(l.net_loss)/SUM(l.loan_amnt)*100,2) AS loss_rate_pct
FROM loans_mature AS l
JOIN dim_date AS d ON l.issue_date = d.month_date
GROUP BY d.year;

-- Finding: 2009-2013 are identical to Q2, because all loans from these years had matured.
-- In 2014-2015 the default rate drops from 18.45% to 13.73% and from 20.18% to 14.89%:
-- the increase seen in Q2 was selection bias, not a real decline in loan quality.
-- On mature loans, the default rate was stable between 13.69% and 16.20% from 2009 to 2015,
-- and the loss rate reached its lowest level in 2014 (4.73%).
-- Note: 2014-2015 include only 36-month loans (60-month loans had not matured yet),
-- which also explains part of the lower interest rate (11.28% in 2015 vs 14.53% in 2013).

-- Q3b. How do 36-month and 60-month mature loans differ in interest rate and risk?
SELECT
    term_months,
    COUNT(*)                                       AS loan_count,
    ROUND(AVG(loan_amnt), 2)                       AS avg_loan_amnt,
    ROUND(AVG(int_rate), 2)                        AS avg_int_rate_pct,
    ROUND(AVG(is_default) * 100, 2)                AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans_mature
GROUP BY term_months
ORDER BY term_months;

-- Finding: On mature loans, 60-month loans are only 8% of loans (55,280 of 676,296),
-- because most of them had not matured yet. They are still clearly riskier:
-- default rate 25.22% vs 13.95% (1.8x) and loss rate 9.30% vs 5.10% (1.8x).
-- The gap is smaller than in Q3 (2.0x and 2.2x), so selection bias had inflated it.
-- The interest premium is 5.33 points (17.35% vs 12.02%), larger than the 4.20-point
-- loss gap, so on mature loans the extra interest roughly covers the extra loss.
-- 60-month loans are ~12% of the mature lent amount but ~20% of mature net losses.