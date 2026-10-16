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