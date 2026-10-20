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