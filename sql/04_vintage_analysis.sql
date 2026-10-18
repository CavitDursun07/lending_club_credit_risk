/*
04 - Vintage analysis (mature loans only)
Default and loss by loan age and grade
=======================================
*/
SELECT * FROM loans_mature LIMIT 5;


-- Q9. Vintage analysis: for 36-month loans only, how did default and loss rates change by issue year?
SELECT issue_year,
    COUNT(*)                                          AS loan_count,
    ROUND(AVG(int_rate), 2)                           AS avg_int_rate,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)    AS loss_rate_pct
FROM loans_mature
WHERE term_months = 36
GROUP BY issue_year;