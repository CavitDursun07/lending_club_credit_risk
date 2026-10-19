-- Q9. How did 36-month loans perform by issue year (vintage)? (mature loans)
SELECT
    d.year,
    COUNT(*)                                           AS loan_count,
    ROUND(AVG(l.int_rate), 2)                          AS avg_int_rate_pct,
    ROUND(AVG(l.fico_avg), 0)                          AS avg_fico,
    ROUND(AVG(l.is_default) * 100, 2)                  AS default_rate_pct,
    ROUND(SUM(l.net_loss) / SUM(l.loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans_mature AS l
JOIN dim_date AS d ON l.issue_date = d.month_date
WHERE l.term_months = 36
GROUP BY d.year
ORDER BY d.year;

-- Finding: The best vintages were 2010-2011: default rate about 10.6%-10.9% and loss rate 3.96%-4.77%,
-- with the highest borrower quality (average FICO 716-718).
-- From 2012, average FICO fell to about 695-703 and default rates rose from 12.33% (2013) to 14.89% (2015).
-- At the same time the average interest rate fell from 13.37% to 11.28% while volume grew 2.8x
-- (100,422 to 283,024 loans): Lending Club grew by lending to weaker borrowers at lower prices,
-- and the gap between interest rate and loss rate shrank from 9.1 points (2013) to 5.7 points (2015).
-- 2007-2008 show very high risk (26.38% and 20.73%) but are small and affected by the financial crisis.
-- Compared with Q2b, 2010-2013 look better here because 60-month loans are excluded.

-- Q9b. How did 36-month loans perform by issue quarter? (mature loans, quarters with at least 1,000 loans)
SELECT
    d.year_quarter,
    COUNT(*)                                           AS loan_count,
    ROUND(AVG(l.int_rate), 2)                          AS avg_int_rate_pct,
    ROUND(AVG(l.fico_avg), 0)                          AS avg_fico,
    ROUND(AVG(l.is_default) * 100, 2)                  AS default_rate_pct,
    ROUND(SUM(l.net_loss) / SUM(l.loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans_mature AS l
JOIN dim_date AS d ON l.issue_date = d.month_date
WHERE l.term_months = 36
GROUP BY d.year_quarter
HAVING COUNT(*) >= 1000
ORDER BY d.year_quarter;
-- Q9b. How did 36-month loans perform by issue quarter? (mature loans, quarters with at least 1,000 loans)
SELECT
    d.year_quarter,
    COUNT(*)                                           AS loan_count,
    ROUND(AVG(l.int_rate), 2)                          AS avg_int_rate_pct,
    ROUND(AVG(l.fico_avg), 0)                          AS avg_fico,
    ROUND(AVG(l.is_default) * 100, 2)                  AS default_rate_pct,
    ROUND(SUM(l.net_loss) / SUM(l.loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans_mature AS l
JOIN dim_date AS d ON l.issue_date = d.month_date
WHERE l.term_months = 36
GROUP BY d.year_quarter
HAVING COUNT(*) >= 1000
ORDER BY d.year_quarter;

-- Finding: The quarterly view shows two different periods of rising risk that the yearly view mixed together.
-- 1) Late 2011 - 2012: average FICO fell from 720 (2011Q1) to 702 (2012Q3) and the default rate rose
--    from 9.09% to about 14.2%. Risk rose because borrower quality fell. The best quarter was 2011Q1
--    (default 9.09%, loss 3.25%).
-- 2) 2014 - 2015: average FICO stayed flat (693-697), but the interest rate fell from 13.02% to 10.96%
--    while the default rate rose from 12.87% to about 15%. Quarterly volume grew 2.6x (34,074 to 88,667).
--    The gap between interest rate and loss rate shrank from 9.06 points (2013Q4) to 5.27 points (2015Q4),
--    so loans became cheaper without becoming safer.
-- In between, 2012Q4-2013Q4 improved (default 12.84% to 11.91%) at the highest interest rates (13.1-13.7%):
-- the yearly view hid this improvement.
-- Note: 2008Q1 is the only 2008 quarter above 1,000 loans; volume dropped sharply after it.