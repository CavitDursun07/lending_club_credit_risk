-- =====================================================
-- 01b - Application tables (for approval rate analysis)
-- WARNING: running this file drops and recreates both tables.
-- rejected_applications has 27.6M rows and takes a while to reload.
-- =====================================================

-- Rejected loan applications (one row per application)
DROP TABLE IF EXISTS rejected_applications;

CREATE TABLE rejected_applications (
    application_id     BIGSERIAL     PRIMARY KEY,   -- generated, the source has no id
    application_date   DATE          NOT NULL,
    application_month  DATE          NOT NULL,      -- first day of month, joins to dim_date
    amount_requested   NUMERIC(12, 2),
    risk_score         NUMERIC(5, 1),               -- not comparable across years, mostly missing after 2014
    dti                NUMERIC(6, 2),               -- percent, NULL if invalid
    addr_state         CHAR(2)       NOT NULL,
    emp_length         VARCHAR(10)   NOT NULL,      -- includes 'Unknown'
    policy_code        SMALLINT
);


-- Accepted loans per month and state, all statuses (one row per month and state)
DROP TABLE IF EXISTS accepted_monthly;

CREATE TABLE accepted_monthly (
    month            DATE            NOT NULL,      -- first day of month, joins to dim_date
    addr_state       CHAR(2)         NOT NULL,
    accepted_count   INTEGER         NOT NULL,
    accepted_amount  NUMERIC(14, 2)  NOT NULL,
    PRIMARY KEY (month, addr_state)
);

CREATE INDEX idx_rejected_month_state
       ON rejected_applications (application_month, addr_state);

ANALYZE rejected_applications;