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

-- Q19. Risk and return by grade group (36-month mature loans)
WITH by_group AS (
    SELECT
        CASE
            WHEN grade = 'A'          THEN 'A'
            WHEN grade IN ('B', 'C')  THEN 'B-C'
            WHEN grade = 'D'          THEN 'D'
            ELSE 'E-G'
        END                           AS grade_group,
        COUNT(*)                      AS loan_count,
        SUM(loan_amnt)                AS total_amount,
        SUM(is_default)               AS default_count,
        SUM(net_loss)                 AS total_net_loss,
        SUM(total_pymnt - loan_amnt)  AS net_return
    FROM loans_mature
    WHERE term_months = 36
    GROUP BY grade_group
)
SELECT
    grade_group,
    loan_count,
    ROUND(total_amount * 100.0 / SUM(total_amount) OVER (), 2)  AS amount_share_pct,
    ROUND(default_count * 100.0 / loan_count, 2)                 AS default_rate_pct,
    ROUND(total_net_loss * 100.0 / total_amount, 2)              AS loss_rate_pct,
    ROUND(net_return * 100.0 / total_amount, 2)                  AS return_rate_pct,
    ROUND(total_amount / 1e6, 2)                                 AS total_amount_mn,
    ROUND(net_return / 1e6, 2)                                   AS net_return_mn
FROM by_group
ORDER BY grade_group;

-- Q19. Risk and return by grade group (36-month mature loans)
-- (query above)

-- Finding: Grades B-C are the core of the 36-month portfolio (58.69% of the amount) and give the best
-- return (8.81%), better than A (7.18%) and better than D (8.03%) and E-G (6.03%).
-- Risk rises steadily from A to E-G (default 5.48% to 29.54%, loss 1.91% to 12.64%), but return does not:
-- above B-C, the extra interest no longer covers the extra loss.
-- Scenario: if the $313.97M lent to E-G had earned the B-C return rate, profit would have been
-- about $8.7M higher (+1.4% of total net return), with a loss rate of about 5% instead of 12.64%.
-- The gain is modest in money but large in risk: the same capital would earn more with less than half the loss rate.
-- Limits: this assumes Lending Club could find more B-C borrowers of the same quality, and the return ignores
-- funding costs, fees and the time value of money.