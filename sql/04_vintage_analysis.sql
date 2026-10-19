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