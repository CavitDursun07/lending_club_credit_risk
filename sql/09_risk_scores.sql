CREATE TABLE IF NOT EXISTS loan_risk_scores (
    id                   BIGINT       PRIMARY KEY,
    sample               VARCHAR(5)   NOT NULL,   -- 'train' (2007-2014) or 'test' (2015)
    default_probability  NUMERIC(6,4) NOT NULL,
    risk_band            VARCHAR(10)  NOT NULL,
    risk_band_order      SMALLINT     NOT NULL
);

-- Check: actual default rate by risk band (test loans only)
SELECT
    r.risk_band,
    COUNT(*)                                AS loan_count,
    ROUND(AVG(r.default_probability) * 100, 2) AS predicted_pct,
    ROUND(AVG(l.is_default) * 100, 2)       AS actual_pct
FROM loan_risk_scores AS r
JOIN loans AS l ON r.id = l.id
WHERE r.sample = 'test'
GROUP BY r.risk_band, r.risk_band_order
ORDER BY r.risk_band_order;