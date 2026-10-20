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