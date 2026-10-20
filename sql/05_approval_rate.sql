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
    d.month_date,
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
ORDER BY d.month_date;
