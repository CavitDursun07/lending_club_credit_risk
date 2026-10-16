/* 
02 - Portfolio overview
Overall size, default rate and loss, by year and term
=====================================================
*/

-- Q1. What does the whole portfolio look like?
SELECT      
    COUNT(*)                                          AS loan_count,
    ROUND(SUM(loan_amnt) / 1e9, 2)                    AS total_amount_bn,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / 1e9, 2)                     AS total_net_loss_bn,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)    AS loss_rate_pct
FROM loans; 

-- Q2. How did lending volume and default rate change by issue year?
SELECT issue_year,
    COUNT(*)                                          AS loan_count,
    ROUND(SUM(loan_amnt) / 1e6, 1)                    AS total_amount_mn,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)    AS loss_rate_pct
FROM loans
GROUP BY issue_year
ORDER BY issue_year;

-- Q3. Are 60-month loans riskier than 36-month loans, and is the extra risk priced into the interest rate?
SELECT term_months,
    COUNT(*)                                          AS loan_count,
    ROUND(AVG(int_rate), 2)                           AS avg_int_rate,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM (loan_amnt) * 100, 2)    AS loss_rate_pct
    
FROM loans
GROUP BY term_months;  