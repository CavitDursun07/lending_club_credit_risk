-- Clean Lending Club loans table (completed loans only)
DROP VIEW IF EXISTS loans_mature;
DROP TABLE IF EXISTS loans;

CREATE TABLE loans (
    id                   BIGINT PRIMARY KEY,

    -- origination date
    issue_date           DATE        NOT NULL,

    -- loan
    loan_amnt            NUMERIC(10, 2),
    term_months          SMALLINT,               -- 36 or 60
    int_rate             NUMERIC(5, 2),          -- percent
    installment          NUMERIC(10, 2),
    grade                CHAR(1),                -- A..G
    sub_grade            VARCHAR(2),             -- A1..G5
    purpose              VARCHAR(30),

    -- borrower
    emp_length           VARCHAR(10),            -- includes 'Unknown'
    emp_length_years     SMALLINT,               -- NULL when unknown
    home_ownership       VARCHAR(10),
    annual_inc           NUMERIC(12, 2),
    verification_status  VARCHAR(20),
    addr_state           CHAR(2),

    -- credit history
    dti                  NUMERIC(6, 2),          -- debt-to-income, percent
    fico_avg             NUMERIC(5, 1),
    revol_util           NUMERIC(5, 1),          -- percent
    open_acc             SMALLINT,
    delinq_2yrs          SMALLINT,
    inq_last_6mths       SMALLINT,

    -- outcome (known only after origination: never use as model inputs)
    loan_status          VARCHAR(60),
    is_default           SMALLINT    NOT NULL,   -- 1 = Charged Off / Default
    total_pymnt          NUMERIC(12, 2),
    recoveries           NUMERIC(12, 2),
    net_loss             NUMERIC(12, 2) NOT NULL
);

-- Mature loans only: loans whose full term had ended before the data was collected.
-- 36-month loans issued up to 2015, 60-month loans issued up to 2013.
-- Used for all trend and segment analysis to avoid selection bias in recent years.
CREATE VIEW loans_mature AS
SELECT *
FROM loans
WHERE (term_months = 36 AND issue_date < DATE '2016-01-01')
   OR (term_months = 60 AND issue_date < DATE '2014-01-01');

SELECT COUNT(*) FROM loans LIMIT 5;
SELECT COUNT(*) FROM loans_mature LIMIT 5;

