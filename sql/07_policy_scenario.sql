-- Q18. Did each sub-grade make or lose money overall? (mature loans)
WITH by_sub_grade AS (
    SELECT
        sub_grade,
        COUNT(*)                      AS loan_count,
        SUM(loan_amnt)                AS total_amount,
        SUM(total_pymnt - loan_amnt)  AS net_return
    FROM loans_mature
    GROUP BY sub_grade
)
SELECT
    sub_grade,
    loan_count,
    ROUND(net_return * 100.0 / total_amount, 2)                     AS return_rate_pct,
    ROUND(net_return / 1e6, 2)                                      AS net_return_mn,
    ROUND(SUM(net_return) OVER (ORDER BY sub_grade DESC) / 1e6, 2)  AS cum_net_return_mn
FROM by_sub_grade
ORDER BY sub_grade DESC;

-- Finding (Q18): All 35 sub-grades had a positive net return; the mature portfolio returned $830.63M
-- on $8.84B lent (about 9.4% over the life of the loans). Riskier sub-grades appear more profitable
-- (E-G: 10.85%-19.70% vs A: 6.41%-7.78%), but this mixes 36- and 60-month loans, and 60-month loans
-- earn interest for 5 years instead of 3. Q18b removes this effect.

-- Q18b. Same as Q18, 36-month loans only (removes the effect of longer interest periods)
WITH by_sub_grade AS (
    SELECT
        sub_grade,
        COUNT(*)                      AS loan_count,
        SUM(loan_amnt)                AS total_amount,
        SUM(total_pymnt - loan_amnt)  AS net_return
    FROM loans_mature
    WHERE term_months = 36
    GROUP BY sub_grade
)
SELECT
    sub_grade,
    loan_count,
    ROUND(net_return * 100.0 / total_amount, 2)                     AS return_rate_pct,
    ROUND(net_return / 1e6, 2)                                      AS net_return_mn,
    ROUND(SUM(net_return) OVER (ORDER BY sub_grade DESC) / 1e6, 2)  AS cum_net_return_mn
FROM by_sub_grade
ORDER BY sub_grade DESC;

-- Finding (Q18b): On 36-month loans only, the picture reverses. Return rate peaks in grades B-C
-- (8.06%-9.66%) and falls for riskier grades: D 7.42%-8.61%, E 5.51%-6.91%, F-G -0.69% to 7.06%
-- (F5 is the only sub-grade with a negative return).
-- The high returns of risky sub-grades in Q18 came mostly from the longer interest period of 60-month loans,
-- not from better pricing.
-- Every 36-month sub-grade except F5 still made money, so rejecting them would not raise total profit
-- in this simple measure. But B-C earns more per dollar than E-G: if lending capital is limited,
-- moving money from E-G to B-C would increase the return.
-- Note: this return ignores funding costs, fees and the time value of money; after funding costs,
-- the F-G sub-grades (mostly 1%-6% over 3 years) are likely unprofitable.
-- Note: G sub-grades have only 76-241 36-month loans, so their returns are imprecise.

