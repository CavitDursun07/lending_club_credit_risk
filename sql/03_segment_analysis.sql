-- Q4. Does Lending Club's grade separate risk well? (mature loans)
SELECT
    grade,
    COUNT(*)                                       AS loan_count,
    ROUND(AVG(int_rate), 2)                        AS avg_int_rate_pct,
    ROUND(AVG(is_default) * 100, 2)                AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans_mature
GROUP BY grade
ORDER BY grade;

-- Finding: Grade separates risk well: default rate rises at every step from A (5.50%) to G (37.43%),
-- and loss rate from 1.92% to 14.23%.
-- Most of the portfolio is in grades A-C (80.5% of loans); grades E-G are only 6.6%.
-- Interest rates increase with grade and stay above the loss rate in every grade,
-- and the gap grows from 5.31 points (A) to 10.07 points (G), so riskier grades are priced with a larger buffer.
-- Note: grade G has only 2,060 loans, so its rates are less precise (about +/-2 points).

-- Q5. Which loan purposes are the riskiest? (mature loans, purposes with at least 1,000 loans)
SELECT purpose,
    COUNT(*)                                  AS loan_count,
    ROUND(AVG(loan_amnt),2)                   AS avg_loan_amnt,
    ROUND(AVG(is_default)*100,2)              AS default_rate_pct,
    ROUND(SUM(net_loss)/SUM(loan_amnt)*100,2) AS loss_rate_pct
FROM loans_mature
GROUP BY purpose
HAVING COUNT(*) >= 1000
ORDER BY default_rate_pct DESC;
-- Finding: small_business is the riskiest purpose: default rate 24.77% (1.7x the portfolio average of 14.87%)
-- and loss rate 11.80%.
-- The portfolio is dominated by debt_consolidation (57.2% of loans) and credit_card (23.6%).
-- credit_card has a below-average default rate (12.26%) and the lowest loss rate (4.33%).
-- However, debt_consolidation causes about 63% of mature net losses because of its volume,
-- while small_business causes only about 3%.
-- Note: purposes with fewer than 1,000 loans are excluded (938 loans, 0.14% of mature loans).

-- Q6. How does risk change with FICO score? (mature loans)
SELECT 
    CASE
        WHEN fico_avg < 660 THEN '< 660'
        WHEN fico_avg < 680 THEN '660-679'
        WHEN fico_avg < 700 THEN '680-699'
        WHEN fico_avg < 720 THEN '700-719'
        WHEN fico_avg < 740 THEN '720-739'
        ELSE '740+'
    END AS fico_band,
    COUNT(*)                                  AS loan_count,
    ROUND(AVG(int_rate),2)                    AS avg_int_rate_pct,
    ROUND(AVG(is_default)*100,2)              AS default_rate_pct,
    ROUND(SUM(net_loss)/SUM(loan_amnt)*100,2) AS loss_rate_pct
FROM loans_mature
GROUP BY fico_band
ORDER BY MIN(fico_avg);
-- Finding: Default rate falls steadily as FICO rises, by about 3 points per 20-point band:
-- from 19.11% (660-679) to 6.69% (740+), 2.9x lower. Loss rate falls from 7.41% to 2.90%.
-- 62% of mature loans are below 700, so the portfolio is concentrated in mid-range scores.
-- FICO separates risk less strongly than grade (2.9x vs 6.8x between best and worst),
-- because grade combines FICO with other information such as DTI, credit history and term.
-- Note: the < 660 band has only 489 loans (below Lending Club's minimum score, likely
-- policy exceptions), so it is excluded from the comparison.

-- Q7. How does risk change with debt-to-income ratio (DTI)? (mature loans)
SELECT
    CASE
        WHEN dti IS NULL THEN 'Missing'
        WHEN dti < 10 THEN '< 10'
        WHEN dti < 20 THEN '10-19'
        WHEN dti < 30 THEN '20-29'
        ELSE '30+'
    END                                            AS dti_band,
    COUNT(*)                                       AS loan_count,
    ROUND(AVG(is_default) * 100, 2)                AS default_rate_pct,
    ROUND(SUM(net_loss) / SUM(loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans_mature
GROUP BY dti_band
ORDER BY MIN(dti);

-- Finding: Default rate rises steadily with DTI: from 11.55% (< 10) to 20.61% (30+), 1.8x higher.
-- Loss rate rises from 4.50% to 7.76% (1.7x).
-- The increase is steeper above DTI 20 (+3.7 points from 10-19 to 20-29) than below it (+2.1 points).
-- Most loans have a DTI of 10-19 (43.2%); 37.3% have a DTI of 20 or more.
-- DTI separates risk less strongly than FICO (2.9x) and grade (6.8x), so on its own it is a
-- weaker risk signal, but it adds information that FICO does not capture (current debt burden).
-- Note: only 5 mature loans have a missing DTI, too few to interpret.

-- Q8. Which states have the highest default rate? (mature loans, states with at least 5,000 loans, top 10)
SELECT
    l.addr_state,
    s.state_name,
    s.region,
    COUNT(*)                                           AS loan_count,
    ROUND(AVG(l.is_default) * 100, 2)                  AS default_rate_pct,
    ROUND(SUM(l.net_loss) / SUM(l.loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans_mature AS l
JOIN dim_state AS s ON l.addr_state = s.state_code
GROUP BY l.addr_state, s.state_name, s.region
HAVING COUNT(*) >= 5000
ORDER BY default_rate_pct DESC
LIMIT 10;
-- Q8. Which states have the highest default rate? (mature loans, states with at least 5,000 loans, top 10)
SELECT
    l.addr_state,
    s.state_name,
    s.region,
    COUNT(*)                                           AS loan_count,
    ROUND(AVG(l.is_default) * 100, 2)                  AS default_rate_pct,
    ROUND(SUM(l.net_loss) / SUM(l.loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans_mature AS l
JOIN dim_state AS s ON l.addr_state = s.state_code
GROUP BY l.addr_state, s.state_name, s.region
HAVING COUNT(*) >= 5000
ORDER BY default_rate_pct DESC
LIMIT 10;

-- Finding: Nevada has the highest default rate (18.08%), 3.2 points above the portfolio average of 14.87%.
-- 5 of the top 10 states are in the South (Oklahoma, Alabama, Tennessee, Louisiana, Florida).
-- Two of the largest markets are also in the top 10: New York (57,783 loans, 16.16%) and
-- Florida (47,487 loans, 16.42%), so their higher risk affects a large part of the portfolio.
-- The differences between states are small: the top 10 range from 15.63% to 18.08%, at most
-- 1.2x the average, much less than the gaps by grade (6.8x), FICO (2.9x) or DTI (1.8x).
-- State differences may partly reflect a different borrower mix (grade, FICO) rather than
-- location itself. Q8b checks the pattern by region.

-- Q8b. How does risk differ by US region? (mature loans)
-- Q8b. How does risk differ by US region? (mature loans)
SELECT
    s.region,
    COUNT(*)                                           AS loan_count,
    ROUND(AVG(l.is_default) * 100, 2)                  AS default_rate_pct,
    ROUND(SUM(l.net_loss) / SUM(l.loan_amnt) * 100, 2) AS loss_rate_pct
FROM loans_mature AS l
JOIN dim_state AS s ON l.addr_state = s.state_code
GROUP BY s.region
ORDER BY default_rate_pct DESC;
-- Finding: Region has almost no effect on risk. Default rates range only from 14.50% (Midwest)
-- to 15.16% (South), a gap of 0.66 points, and loss rates are nearly identical (5.37%-5.68%).
-- The South is the largest region (34.9% of mature loans) and the riskiest, but only slightly.
-- The state-level differences in Q8 average out within regions, so location is a weak risk
-- signal compared with grade, FICO and DTI. Region is not useful for credit decisions on its own.