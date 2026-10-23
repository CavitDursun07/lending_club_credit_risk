-- vw_loans: one row per completed loan, with the bands and groups used in the analysis
CREATE OR REPLACE VIEW vw_loans AS
SELECT
    id,
    issue_date,
    addr_state,
    term_months,
    grade,
    sub_grade,
    CASE
        WHEN grade = 'A'         THEN 'A'
        WHEN grade IN ('B', 'C') THEN 'B-C'
        WHEN grade = 'D'         THEN 'D'
        ELSE 'E-G'
    END                                         AS grade_group,
    purpose,
    home_ownership,
    loan_amnt,
    int_rate,
    fico_avg,
    CASE
        WHEN fico_avg < 660 THEN '< 660'
        WHEN fico_avg < 680 THEN '660-679'
        WHEN fico_avg < 700 THEN '680-699'
        WHEN fico_avg < 720 THEN '700-719'
        WHEN fico_avg < 740 THEN '720-739'
        ELSE '740+'
    END                                         AS fico_band,
    CASE
        WHEN fico_avg < 660 THEN 1
        WHEN fico_avg < 680 THEN 2
        WHEN fico_avg < 700 THEN 3
        WHEN fico_avg < 720 THEN 4
        WHEN fico_avg < 740 THEN 5
        ELSE 6
    END                                         AS fico_band_order,
    dti,
    CASE
        WHEN dti IS NULL THEN 'Missing'
        WHEN dti < 10    THEN '< 10'
        WHEN dti < 20    THEN '10-19'
        WHEN dti < 30    THEN '20-29'
        ELSE '30+'
    END                                         AS dti_band,
    CASE
        WHEN dti IS NULL THEN 5
        WHEN dti < 10    THEN 1
        WHEN dti < 20    THEN 2
        WHEN dti < 30    THEN 3
        ELSE 4
    END                                         AS dti_band_order,
    is_default,
    net_loss,
    total_pymnt - loan_amnt                     AS net_return,
    CASE
        WHEN (term_months = 36 AND issue_date < DATE '2016-01-01')
          OR (term_months = 60 AND issue_date < DATE '2014-01-01')
        THEN 1 ELSE 0
    END                                         AS is_mature
FROM loans;

-- vw_approval_monthly: accepted and rejected applications per month and state
CREATE OR REPLACE VIEW vw_approval_monthly AS
WITH rejected AS (
    SELECT
        application_month AS month,
        addr_state,
        COUNT(*)          AS rejected_count
    FROM rejected_applications
    GROUP BY application_month, addr_state
)
SELECT
    COALESCE(a.month, r.month)           AS month,
    COALESCE(a.addr_state, r.addr_state) AS addr_state,
    COALESCE(a.accepted_count, 0)        AS accepted_count,
    COALESCE(r.rejected_count, 0)        AS rejected_count
FROM accepted_monthly AS a
FULL OUTER JOIN rejected AS r
    ON a.month = r.month
   AND a.addr_state = r.addr_state;


-- Check vw_loans
SELECT
    COUNT(*)        AS loan_count,      -- expected 1,347,698
    SUM(is_mature)  AS mature_count     -- expected 676,296
FROM vw_loans;

-- Check vw_approval_monthly
SELECT
    COUNT(*)            AS row_count,
    SUM(accepted_count) AS total_accepted,  -- expected 2,260,668
    SUM(rejected_count) AS total_rejected   -- expected 27,648,719
FROM vw_approval_monthly;

-- Checks: vw_loans has 1,347,698 loans (676,296 mature, same as loans_mature).
-- vw_approval_monthly has 6,564 month-state rows: 578 more than accepted_monthly,
-- because some month-state combinations have rejected applications but no accepted loans.
-- Totals match the source tables (2,260,668 accepted, 27,648,719 rejected).