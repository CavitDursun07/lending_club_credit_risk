-- =====================================================
-- 01d - Data checks: every fact row must match a dimension row
-- Each query should return 0 rows. Any row returned is a code without a match.
-- Result (2026-10-18): all checks passed, 0 unmatched rows.
-- =====================================================

-- 1. States in loans that are missing from dim_state
SELECT l.addr_state, COUNT(*) AS loan_count
FROM loans AS l
LEFT JOIN dim_state AS s ON l.addr_state = s.state_code
WHERE s.state_code IS NULL
GROUP BY l.addr_state;

-- 2. States in rejected_applications that are missing from dim_state
SELECT r.addr_state, COUNT(*) AS application_count
FROM rejected_applications AS r
LEFT JOIN dim_state AS s ON r.addr_state = s.state_code
WHERE s.state_code IS NULL
GROUP BY r.addr_state;

-- 3. States in accepted_monthly that are missing from dim_state
SELECT a.addr_state, SUM(a.accepted_count) AS loan_count
FROM accepted_monthly AS a
LEFT JOIN dim_state AS s ON a.addr_state = s.state_code
WHERE s.state_code IS NULL
GROUP BY a.addr_state;

-- 4. Months in any fact table that are missing from dim_date
SELECT 'loans' AS source, COUNT(*) AS missing_rows
FROM loans AS l
LEFT JOIN dim_date AS d ON l.issue_date = d.month_date
WHERE d.month_date IS NULL
UNION ALL
SELECT 'rejected_applications', COUNT(*)
FROM rejected_applications AS r
LEFT JOIN dim_date AS d ON r.application_month = d.month_date
WHERE d.month_date IS NULL
UNION ALL
SELECT 'accepted_monthly', COUNT(*)
FROM accepted_monthly AS a
LEFT JOIN dim_date AS d ON a.month = d.month_date
WHERE d.month_date IS NULL;

-- 5. Grades in loans that are missing from dim_grade
SELECT l.grade, COUNT(*) AS loan_count
FROM loans AS l
LEFT JOIN dim_grade AS g ON l.grade = g.grade
WHERE g.grade IS NULL
GROUP BY l.grade;