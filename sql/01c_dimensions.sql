-- =====================================================
-- 01c - Dimension tables
-- Safe to re-run: small tables, rebuilt from scratch.
-- =====================================================

-- ---------- dim_date: one row per month ----------
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    month_date    DATE         PRIMARY KEY,   -- first day of month, e.g. 2015-12-01
    year          SMALLINT     NOT NULL,
    quarter       SMALLINT     NOT NULL,      -- 1..4
    year_quarter  VARCHAR(6)   NOT NULL,      -- e.g. 2015Q4 (same format as loans.issue_quarter)
    month         SMALLINT     NOT NULL,      -- 1..12
    month_name    VARCHAR(9)   NOT NULL,      -- e.g. December
    year_month    CHAR(7)      NOT NULL       -- e.g. 2015-12
);

INSERT INTO dim_date
SELECT
    d::date,
    EXTRACT(YEAR FROM d)::smallint,
    EXTRACT(QUARTER FROM d)::smallint,
    EXTRACT(YEAR FROM d)::int || 'Q' || EXTRACT(QUARTER FROM d)::int,
    EXTRACT(MONTH FROM d)::smallint,
    TRIM(TO_CHAR(d, 'Month')),
    TO_CHAR(d, 'YYYY-MM')
FROM generate_series('2007-05-01'::date, '2018-12-01'::date, INTERVAL '1 month') AS d;

-- ---------- dim_state: one row per US state (+ DC) ----------
-- Regions follow the US Census Bureau definition.
DROP TABLE IF EXISTS dim_state;

CREATE TABLE dim_state (
    state_code  CHAR(2)      PRIMARY KEY,
    state_name  VARCHAR(30)  NOT NULL,
    region      VARCHAR(10)  NOT NULL     -- Northeast, Midwest, South, West
);

INSERT INTO dim_state (state_code, state_name, region) VALUES
    ('CT', 'Connecticut', 'Northeast'), ('ME', 'Maine', 'Northeast'),
    ('MA', 'Massachusetts', 'Northeast'), ('NH', 'New Hampshire', 'Northeast'),
    ('RI', 'Rhode Island', 'Northeast'), ('VT', 'Vermont', 'Northeast'),
    ('NJ', 'New Jersey', 'Northeast'), ('NY', 'New York', 'Northeast'),
    ('PA', 'Pennsylvania', 'Northeast'),

    ('IL', 'Illinois', 'Midwest'), ('IN', 'Indiana', 'Midwest'),
    ('MI', 'Michigan', 'Midwest'), ('OH', 'Ohio', 'Midwest'),
    ('WI', 'Wisconsin', 'Midwest'), ('IA', 'Iowa', 'Midwest'),
    ('KS', 'Kansas', 'Midwest'), ('MN', 'Minnesota', 'Midwest'),
    ('MO', 'Missouri', 'Midwest'), ('NE', 'Nebraska', 'Midwest'),
    ('ND', 'North Dakota', 'Midwest'), ('SD', 'South Dakota', 'Midwest'),

    ('DE', 'Delaware', 'South'), ('FL', 'Florida', 'South'),
    ('GA', 'Georgia', 'South'), ('MD', 'Maryland', 'South'),
    ('NC', 'North Carolina', 'South'), ('SC', 'South Carolina', 'South'),
    ('VA', 'Virginia', 'South'), ('DC', 'District of Columbia', 'South'),
    ('WV', 'West Virginia', 'South'), ('AL', 'Alabama', 'South'),
    ('KY', 'Kentucky', 'South'), ('MS', 'Mississippi', 'South'),
    ('TN', 'Tennessee', 'South'), ('AR', 'Arkansas', 'South'),
    ('LA', 'Louisiana', 'South'), ('OK', 'Oklahoma', 'South'),
    ('TX', 'Texas', 'South'),

    ('AZ', 'Arizona', 'West'), ('CO', 'Colorado', 'West'),
    ('ID', 'Idaho', 'West'), ('MT', 'Montana', 'West'),
    ('NV', 'Nevada', 'West'), ('NM', 'New Mexico', 'West'),
    ('UT', 'Utah', 'West'), ('WY', 'Wyoming', 'West'),
    ('AK', 'Alaska', 'West'), ('CA', 'California', 'West'),
    ('HI', 'Hawaii', 'West'), ('OR', 'Oregon', 'West'),
    ('WA', 'Washington', 'West');

    -- ---------- dim_grade: one row per Lending Club grade ----------
-- Risk levels based on mature-loan default rates (Q4):
-- Low: A-B (5-11%), Medium: C-D (18-24%), High: E-G (29-37%)
DROP TABLE IF EXISTS dim_grade;

CREATE TABLE dim_grade (
    grade        CHAR(1)      PRIMARY KEY,
    grade_order  SMALLINT     NOT NULL,   -- 1 (A) .. 7 (G), for sorting
    risk_level   VARCHAR(10)  NOT NULL    -- Low, Medium, High
);

INSERT INTO dim_grade (grade, grade_order, risk_level) VALUES
    ('A', 1, 'Low'),
    ('B', 2, 'Low'),
    ('C', 3, 'Medium'),
    ('D', 4, 'Medium'),
    ('E', 5, 'High'),
    ('F', 6, 'High'),
    ('G', 7, 'High');

SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM dim_date
UNION ALL
SELECT 'dim_state', COUNT(*) FROM dim_state
UNION ALL
SELECT 'dim_grade', COUNT(*) FROM dim_grade;
SELECT * FROM dim_date ORDER BY month_date LIMIT 5;
