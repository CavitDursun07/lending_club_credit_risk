/*
03 - Segment analysis (mature loans only)
Default and loss by grade, purpose and FICO band
=====================================================
*/
SELECT * FROM loans_mature LIMIT 5;

-- Q4. Does Lending Club's grade separate risk well? How do interest rate, default rate and loss rate change from A to G?
SELECT grade,
    COUNT(*)                                          AS loan_count,
    ROUND(AVG(int_rate), 2)                           AS avg_int_rate,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)   AS loss_rate_pct
FROM loans_mature
GROUP BY grade;
-- Finding: Grade ranks risk consistently. Default rate rises at every step from A (5.5%) to G (37.4%),
-- a 6.8x increase, while the interest rate rises only 3.4x (7.2% -> 24.3%). 81% of loans are grade A-C.


-- Q5. Which loan purposes are the riskiest? Top purposes by default rate (purposes with at least 1,000 loans).
SELECT purpose,
    COUNT(*)                                          AS loan_count,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)   AS loss_rate_pct    
FROM loans_mature
GROUP BY purpose
HAVING COUNT(*) >= 1000
ORDER BY default_rate_pct DESC;
-- Finding: small_business is the riskiest purpose, with a default rate of 24.8% (1.7x the portfolio average of 14.9%)
-- and a loss rate of 11.8% (2.1x the average of 5.6%).
-- debt_consolidation (57%) and credit_card (24%) make up 81% of all loans.
-- Loans to refinance credit card debt are less risky than average (loss rate 4.3% vs 5.6%).

-- Q6. How does risk change with credit score? Default and loss rate by FICO band.
SELECT 
    CASE 
        WHEN fico_avg < 660 THEN 'Below 660'
        WHEN fico_avg < 700 THEN '660-699'
        WHEN fico_avg < 740 THEN '700-739'
        ELSE '740+'
    END AS fico_band,
    COUNT(*)                                          AS loan_count,
    ROUND(AVG(int_rate), 2)                           AS avg_int_rate,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)   AS loss_rate_pct
FROM loans_mature
GROUP BY fico_band
ORDER BY MIN(fico_avg);
-- Finding: Default and loss rates rise steadily as the FICO score falls: from 6.7% (740+) to 17.7% (660-699),
-- a 2.6x increase, while the interest rate rises only 1.6x (8.5% -> 13.7%).
-- The "Below 660" band has only 489 loans, so its rates (30.9% default, 16.8% loss) are unreliable.
-- Loans are unevenly distributed: 62% are in the 660-699 band, 28% in 700-739 and 10% in 740+.

-- Q7. Do borrowers with a higher debt-to-income ratio default more often?
SELECT
    CASE 
        WHEN dti IS NULL THEN 'Unknown'
        WHEN dti < 10 THEN 'Below 10%'
        WHEN dti < 20 THEN '10-19%'
        WHEN dti < 30 THEN '20-29%'
        ELSE '30%+'
    END AS dti_band,
    COUNT(*)                                          AS loan_count,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)   AS loss_rate_pct
FROM loans_mature
GROUP BY dti_band
ORDER BY MIN(dti);
-- Finding: Default and loss rates rise steadily with DTI: default rate from 11.6% (below 10%) to 20.6% (30%+),
-- a 1.8x increase, and loss rate from 4.5% to 7.8%. DTI separates risk less strongly than grade (6.8x) or FICO (2.6x).
-- The "Unknown" band has only 5 loans and is not interpreted.


-- Q8. Which states have the highest default rates? Top 10 states (with at least 5,000 loans).
SELECT addr_state,
    COUNT(*)                                          AS loan_count,
    ROUND(AVG(is_default) * 100, 2)                   AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2)   AS loss_rate_pct
FROM loans_mature
GROUP BY addr_state
HAVING COUNT(*) >= 5000
ORDER BY default_rate_pct DESC
LIMIT 10;
-- Finding: Geography is a weak risk factor. The riskiest state, NV, has a default rate of 18.1%,
-- only 1.2x the portfolio average of 14.9% (compared to 6.8x between grades A and G).
-- Among the top 10 states, default rates fall within a narrow range (15.6% to 18.1%).
-- FL and NY are only slightly above average (16.4% and 16.2%), but with 105K loans combined
-- they contribute a large share of total losses. Differences may partly reflect each state's grade mix.