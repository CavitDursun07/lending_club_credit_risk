-- Q10. How many applications were accepted and rejected each month?
WITH accepted AS (
    SELECT
        month,
        SUM(accepted_count) AS accepted_count
    FROM accepted_monthly
    GROUP BY month
),
rejected AS (
    SELECT
        application_month AS month,
        COUNT(*)          AS rejected_count
    FROM rejected_applications
    GROUP BY application_month
)
SELECT
    d.year_month,
    COALESCE(a.accepted_count, 0)                                  AS accepted_count,
    COALESCE(r.rejected_count, 0)                                  AS rejected_count,
    COALESCE(a.accepted_count, 0) + COALESCE(r.rejected_count, 0)  AS total_applications,
    ROUND(
        COALESCE(a.accepted_count, 0) * 100.0
        / NULLIF(COALESCE(a.accepted_count, 0) + COALESCE(r.rejected_count, 0), 0),
        2
    )                                                              AS approval_rate_pct
FROM dim_date AS d
LEFT JOIN accepted AS a ON d.month_date = a.month
LEFT JOIN rejected AS r ON d.month_date = r.month
ORDER BY d.year_month;


-- Q11. How did the approval rate change by year?
WITH accepted AS (
    SELECT
        month,
        SUM(accepted_count) AS accepted_count
    FROM accepted_monthly
    GROUP BY month
),
rejected AS (
    SELECT
        application_month AS month,
        COUNT(*)          AS rejected_count
    FROM rejected_applications
    GROUP BY application_month
)
SELECT
    d.year,
    SUM(COALESCE(a.accepted_count, 0))  AS accepted_count,
    SUM(COALESCE(r.rejected_count, 0))  AS rejected_count,
    ROUND(
        SUM(COALESCE(a.accepted_count, 0)) * 100.0
        / NULLIF(SUM(COALESCE(a.accepted_count, 0) + COALESCE(r.rejected_count, 0)), 0),
        2
    )                                   AS approval_rate_pct
FROM dim_date AS d
LEFT JOIN accepted AS a ON d.month_date = a.month
LEFT JOIN rejected AS r ON d.month_date = r.month
GROUP BY d.year
ORDER BY d.year;
-- Finding: The approval rate peaked in 2013 (15.05%) and then fell to 4.96% in 2018.
-- Accepted loans kept growing every year, but much more slowly after 2015 (421,095 to 495,242, +18%),
-- while rejected applications grew 3.3x (2,859,379 to 9,496,782).
-- So the falling approval rate after 2015 comes from a flood of applications, not from fewer loans.
-- The decline coincides with the rising default rates of the 2014-2015 vintages (Q9b),
-- which suggests Lending Club tightened its credit policy, although this data cannot prove the cause.
-- Note: the rejected file may not include every application (e.g. withdrawn ones), so the rates are approximate.

-- Q12. How does the approval rate differ by state? (all years)
WITH accepted AS (
    SELECT
        addr_state,
        SUM(accepted_count) AS accepted_count
    FROM accepted_monthly
    GROUP BY addr_state
),
rejected AS (
    SELECT
        addr_state,
        COUNT(*) AS rejected_count
    FROM rejected_applications
    GROUP BY addr_state
)
SELECT
    s.state_name,   
    COALESCE(a.accepted_count, 0) AS accepted_count,
    COALESCE(r.rejected_count, 0) AS rejected_count,
    ROUND(
        COALESCE(a.accepted_count, 0) * 100.0
        / NULLIF(COALESCE(a.accepted_count, 0) + COALESCE(r.rejected_count, 0), 0),
        2
    )                             AS approval_rate_pct
FROM dim_state AS s
LEFT JOIN accepted AS a ON s.state_code = a.addr_state
LEFT JOIN rejected AS r ON s.state_code = r.addr_state
ORDER BY approval_rate_pct DESC;
-- Finding: Approval rates range from 9.91% (Minnesota) to 4.36% (Mississippi), a 2.3x gap,
-- much larger than the gap in default rates between states (about 1.2x in Q8).
-- Most of the lowest approval rates are in the South: Mississippi, Alabama, Arkansas,
-- South Carolina, Louisiana, Tennessee and Kentucky are all below 6%.
-- Several of these states (Alabama, Tennessee, Louisiana, Oklahoma) were also in the top 10
-- for default rate (Q8), so Lending Club approved fewer applicants there and those it approved
-- still defaulted more often.
-- Nevada is an exception: a high approval rate (8.92%) together with the highest default rate (18.08%).
-- The largest markets are close to the average: California 8.84%, New York 8.56%, Texas and Florida 6.95%.
-- Note: states whose applications came mostly in 2016-2018 may show lower rates because the overall approval rate fell over time (Q11).
-- Q12b. How does the approval rate differ by US region? (all years)

WITH accepted AS (
    SELECT
        addr_state,
        SUM(accepted_count) AS accepted_count
    FROM accepted_monthly
    GROUP BY addr_state
),
rejected AS (
    SELECT
        addr_state,
        COUNT(*) AS rejected_count
    FROM rejected_applications
    GROUP BY addr_state
)
SELECT
    s.region,
    SUM(COALESCE(a.accepted_count, 0)) AS accepted_count,
    SUM(COALESCE(r.rejected_count, 0)) AS rejected_count,
    ROUND(
        SUM(COALESCE(a.accepted_count, 0)) * 100.0
        / NULLIF(SUM(COALESCE(a.accepted_count, 0) + COALESCE(r.rejected_count, 0)), 0),
        2
    )                                  AS approval_rate_pct
FROM dim_state AS s
LEFT JOIN accepted AS a ON s.state_code = a.addr_state
LEFT JOIN rejected AS r ON s.state_code = r.addr_state
GROUP BY s.region
ORDER BY approval_rate_pct DESC;
-- Finding: The South has the lowest approval rate (6.65%), about 2 points below the West (8.60%)
-- and Northeast (8.30%), while it sends the most applications (about 41% of all applications).
-- In Q8b default rates were almost the same in every region (14.50%-15.16%).
-- Together this suggests that Lending Club screened Southern applicants more strictly,
-- and this stricter screening brought the default rate of approved loans close to other regions.
-- At state level the screening did not fully close the gap (Q12: Alabama, Tennessee, Louisiana).

-- Q13. Is there a link between the approval rate and the default rate by year?
WITH accepted AS (
    SELECT
        month,
        SUM(accepted_count) AS accepted_count
    FROM accepted_monthly
    GROUP BY month
),
rejected AS (
    SELECT
        application_month AS month,
        COUNT(*)          AS rejected_count
    FROM rejected_applications
    GROUP BY application_month
),
approval AS (
    SELECT
        d.year,
        SUM(COALESCE(a.accepted_count, 0)) AS accepted_count,
        SUM(COALESCE(r.rejected_count, 0)) AS rejected_count
    FROM dim_date AS d
    LEFT JOIN accepted AS a ON d.month_date = a.month
    LEFT JOIN rejected AS r ON d.month_date = r.month
    GROUP BY d.year
),
performance AS (
    SELECT
        d.year,
        COUNT(*)                                           AS mature_loan_count,
        ROUND(AVG(l.is_default) * 100, 2)                  AS default_rate_pct,
        ROUND(SUM(l.net_loss) / SUM(l.loan_amnt) * 100, 2) AS loss_rate_pct
    FROM loans_mature AS l
    JOIN dim_date AS d ON l.issue_date = d.month_date
    WHERE l.term_months = 36
    GROUP BY d.year
)
SELECT
    ap.year,
    ROUND(
        ap.accepted_count * 100.0
        / NULLIF(ap.accepted_count + ap.rejected_count, 0),
        2
    )                      AS approval_rate_pct,
    p.mature_loan_count,
    p.default_rate_pct,
    p.loss_rate_pct
FROM approval AS ap
LEFT JOIN performance AS p ON ap.year = p.year
ORDER BY ap.year;
-- Finding: The approval rate alone does not explain the default rate.
-- 2009-2011: approval stayed at 8.5%-10% and these were the safest vintages (default 10.6%-13.7%).
-- 2012: approval jumped from 9.07% to 13.66% and default rose from 10.63% to 13.58%,
-- consistent with looser approval leading to higher risk.
-- 2013: approval reached its peak (15.05%) but default fell to 12.33%, helped by the highest
-- interest rates of the period (Q9b), so risk was priced well.
-- 2014: approval dropped to 10.86% but default still rose to 13.73%, the opposite direction.
-- Default depends not only on how many applicants are approved, but also on who applies and on
-- pricing: applications grew about 2.4x in 2014 (Q11), so a lower approval rate can come from a
-- weaker applicant pool rather than a stricter policy.
-- 2016-2018: approval fell to 4.96%, but these loans had not matured, so their outcome is unknown.