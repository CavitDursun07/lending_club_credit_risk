-- Q14. What share of loans, lent amount and net loss does each purpose have? (mature loans)
WITH by_purpose AS (
    SELECT
        purpose,
        COUNT(*)       AS loan_count,
        SUM(loan_amnt) AS total_amount,
        SUM(net_loss)  AS total_net_loss
    FROM loans_mature
    GROUP BY purpose
)
SELECT
    purpose,
    loan_count,
    ROUND(loan_count     * 100.0 / SUM(loan_count)     OVER (), 2) AS loan_share_pct,
    ROUND(total_amount   * 100.0 / SUM(total_amount)   OVER (), 2) AS amount_share_pct,
    ROUND(total_net_loss * 100.0 / SUM(total_net_loss) OVER (), 2) AS loss_share_pct,
    ROUND(total_net_loss * 100.0 / total_amount, 2)                 AS loss_rate_pct
FROM by_purpose
ORDER BY loss_share_pct DESC;
-- Finding: debt_consolidation and credit_card together hold 85.04% of the lent amount
-- and cause 81.86% of net losses.
-- debt_consolidation causes 62.69% of losses with 60.15% of the amount, slightly more than its weight,
-- while credit_card causes only 19.17% of losses with 24.89% of the amount: it is the safest large segment.
-- small_business causes 2.1x more loss than its weight (3.02% of losses vs 1.44% of the amount),
-- the most disproportionate large purpose, but its total impact is small.
-- Any policy to reduce losses must focus on debt_consolidation because of its size,
-- not on the riskiest small purposes.

-- Q15. What are the 3 riskiest states in each region? (mature loans, states with at least 5,000 loans)
WITH by_state AS (
    SELECT
        l.addr_state,
        s.state_name,
        s.region,
        COUNT(*)                          AS loan_count,
        ROUND(AVG(l.is_default) * 100, 2) AS default_rate_pct
    FROM loans_mature AS l
    JOIN dim_state AS s ON l.addr_state = s.state_code
    GROUP BY l.addr_state, s.state_name, s.region
    HAVING COUNT(*) >= 5000
),
ranked AS (
    SELECT
        *,
        RANK() OVER (ORDER BY default_rate_pct DESC)                     AS overall_rank,
        RANK() OVER (PARTITION BY region ORDER BY default_rate_pct DESC) AS region_rank
    FROM by_state
)
SELECT
    region,
    region_rank,
    state_name,
    loan_count,
    default_rate_pct,
    overall_rank
FROM ranked
WHERE region_rank <= 3
ORDER BY region, region_rank;
-- Finding: Within each region, the riskiest states are Nevada (West, 18.08%), Oklahoma (South, 17.57%),
-- Missouri (Midwest, 16.22%) and New York (Northeast, 16.16%).
-- The South has the deepest risk: its top 3 states are ranked 2nd, 3rd and 4th overall,
-- while the 3rd riskiest state in the Northeast (Pennsylvania) is only 18th.
-- Nevada is an outlier in the West: 3 points above the next state (Arizona, 15.04%).
-- California, the largest state (103,888 loans), is close to the portfolio average (15.01% vs 14.87%).

-- Q16. How did volume and default rate change from the previous year? (36-month mature loans)
WITH yearly AS (
    SELECT
        d.year,
        COUNT(*)                          AS loan_count,
        ROUND(AVG(l.is_default) * 100, 2) AS default_rate_pct
    FROM loans_mature AS l
    JOIN dim_date AS d ON l.issue_date = d.month_date
    WHERE l.term_months = 36
    GROUP BY d.year
)
SELECT
    year,
    loan_count,
    LAG(loan_count) OVER w                                    AS prev_loan_count,
    ROUND(
        (loan_count - LAG(loan_count) OVER w) * 100.0
        / LAG(loan_count) OVER w,
        2
    )                                                         AS loan_growth_pct,
    default_rate_pct,
    LAG(default_rate_pct) OVER w                              AS prev_default_rate_pct,
    default_rate_pct - LAG(default_rate_pct) OVER w           AS default_change_pts
FROM yearly
WINDOW w AS (ORDER BY year)
ORDER BY year;
-- Finding: Volume grew every year, by 54% to 300%, but growth and risk moved together only after 2011.
-- 2008-2011: volume grew while default fell (from 26.38% to 10.63%), as lending recovered after the crisis.
-- 2012 was the fastest growth year after the crisis (+208%) and had the largest default increase (+2.95 pts).
-- 2014 and 2015 repeated the pattern: +62% and +74% volume with +1.40 and +1.16 pts default.
-- 2013 was the only exception: +131% volume with a lower default rate (-1.25 pts),
-- when interest rates were at their highest (Q9b).
-- In 3 of the 4 years after 2011, fast growth came with rising risk.

-- Q17. Cumulative share of lent amount and net loss, from the riskiest sub-grade (mature loans)
WITH by_sub_grade AS (
    SELECT
        sub_grade,
        COUNT(*)       AS loan_count,
        SUM(loan_amnt) AS total_amount,
        SUM(net_loss)  AS total_net_loss
    FROM loans_mature
    GROUP BY sub_grade
)
SELECT
    sub_grade,
    loan_count,
    ROUND(total_net_loss * 100.0 / total_amount, 2)          AS loss_rate_pct,
    ROUND(
        SUM(total_amount) OVER (ORDER BY sub_grade DESC) * 100.0
        / SUM(total_amount) OVER (),
        2
    )                                                         AS cum_amount_share_pct,
    ROUND(
        SUM(total_net_loss) OVER (ORDER BY sub_grade DESC) * 100.0
        / SUM(total_net_loss) OVER (),
        2
    )                                                         AS cum_loss_share_pct
FROM by_sub_grade
ORDER BY sub_grade DESC;

-- Finding: Losses are concentrated in the riskier sub-grades, but not extremely.
-- Sub-grades E1-G5 are 7.81% of the lent amount but cause 17.01% of net losses (2.2x their weight).
-- All D-G sub-grades are 20.33% of the amount and cause 38.31% of losses.
-- To avoid half of all losses, Lending Club would have to stop lending to everything from C4 down,
-- giving up 29.33% of the lent amount.
-- At the other end, A1-A5 are 22.65% of the amount but cause only 7.74% of losses.
-- Loss rate is not perfectly ordered within G (e.g. G4 11.16% vs G3 14.95%) because these
-- sub-grades have only 182-765 loans; from F2 downward the order is almost perfect.
-- Rejecting risky loans also gives up their interest income, so the trade-off is examined in 07_policy_scenario.sql.