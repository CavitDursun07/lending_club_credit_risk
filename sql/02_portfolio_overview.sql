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
-- Finding: 1,347,698 completed loans ($19.42B). Default rate 19.98%, net loss $1.99B, loss rate 10.26%.
-- Note: includes immature recent loans (selection bias) - see Q1b for mature loans only.

-- Q2. How did lending volume and default rate change by issue year?
SELECT issue_year,
    COUNT(*)                                          AS loan_count,
    ROUND(SUM(loan_amnt) / 1e6, 1)                    AS total_amount_mn,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)    AS loss_rate_pct
FROM loans
GROUP BY issue_year
ORDER BY issue_year;
-- Finding: Volume grew from $5M (2007) to $5.5B (2015). Default rate was lowest in 2009-2013 (14-16%).
-- 2016-2018 figures are biased: most of those loans were still open when the data ends,
-- so the completed ones are mainly early payoffs and early defaults. Not comparable with earlier years.

-- Q3. Are 60-month loans riskier than 36-month loans, and is the extra risk priced into the interest rate?
SELECT term_months,
    COUNT(*)                                          AS loan_count,
    ROUND(AVG(int_rate), 2)                           AS avg_int_rate,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM (loan_amnt) * 100, 2)   AS loss_rate_pct
    
FROM loans
GROUP BY term_months; 
-- Finding: 60-month loans default twice as often as 36-month loans (32.5% vs 16.0%)
-- and lose twice as much (15.9% vs 7.3%), while their interest rate is only 1.4x higher (16.8% vs 12.1%).

-- Q1b. What does the portfolio look like when only mature loans are included?
SELECT      
    COUNT(*)                                          AS loan_count,
    ROUND(SUM(loan_amnt) / 1e9, 2)                    AS total_amount_bn,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / 1e9, 2)                     AS total_net_loss_bn,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)    AS loss_rate_pct
FROM loans_mature; 
-- Finding: 676,296 mature loans ($8.84B). Default rate 14.87%, loss rate 5.62%.
-- Using all loans would overstate the default rate by ~5 points and the loss rate by ~4.6 points.

-- Q2b. How did default rate change by issue year (mature loans only)?
SELECT issue_year,
    COUNT(*)                                          AS loan_count,
    ROUND(SUM(loan_amnt) / 1e6, 1)                    AS total_amount_mn,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)    AS loss_rate_pct
FROM loans_mature
GROUP BY issue_year
ORDER BY issue_year;
-- Finding: 2007-2013 match Q2 exactly, because all loans from those years are mature.
-- 2014-2015 show lower default rates (13.7% and 14.9%) because only 36-month loans are mature in those years.
-- Year-over-year comparison must keep the term constant (see vintage analysis).

-- Q3b. Are 60-month loans still riskier than 36-month loans when only mature loans are included?

SELECT term_months,
    COUNT(*)                                          AS loan_count,
    ROUND(AVG(int_rate), 2)                           AS avg_int_rate,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM (loan_amnt) * 100, 2)   AS loss_rate_pct
    
FROM loans_mature   
GROUP BY term_months; 
-- Finding: The term effect holds for mature loans: 60-month loans default 1.8x more often (25.2% vs 14.0%)
-- and lose 1.8x more (9.3% vs 5.1%), while the interest rate is only 1.4x higher (17.4% vs 12.0%).
-- 60-month loans may be underpriced for their risk. Mature 60-month loans come only from 2010-2013 (55K loans).