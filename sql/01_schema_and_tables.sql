-- =====================================================================
-- Project: Loan Portfolio Funnel & Risk Analytics
-- Script: 01_schema_and_tables.sql
-- Description: Creates the production tables, staging schemas, constraints,
--              and performance indexes for the loan portfolio data warehouse.
-- Compatible with: PostgreSQL, MySQL 8+, MS SQL Server, SQLite, Snowflake
-- =====================================================================

-- Drop existing tables if re-running
DROP TABLE IF EXISTS loan_stage_transitions;
DROP TABLE IF EXISTS loan_applications;

-- ---------------------------------------------------------------------
-- 1. Main Fact Table: Loan Applications
-- ---------------------------------------------------------------------
CREATE TABLE loan_applications (
    application_id               VARCHAR(20) PRIMARY KEY,
    customer_id                  VARCHAR(20) NOT NULL,
    application_date             DATE NOT NULL,
    channel                      VARCHAR(30) NOT NULL,
    applicant_age                INTEGER CHECK (applicant_age >= 18),
    employment_type              VARCHAR(30) NOT NULL,
    housing_status               VARCHAR(20) NOT NULL,
    annual_income                DECIMAL(12, 2) NOT NULL,
    credit_score                 INTEGER CHECK (credit_score BETWEEN 300 AND 850),
    risk_tier                    VARCHAR(30) NOT NULL,
    debt_to_income_ratio         DECIMAL(5, 3) NOT NULL,
    loan_purpose                 VARCHAR(40) NOT NULL,
    loan_amount                  DECIMAL(10, 2) NOT NULL,
    loan_term_months             INTEGER NOT NULL,
    interest_rate_pct            DECIMAL(5, 2) NOT NULL,
    final_stage_reached          VARCHAR(40) NOT NULL,
    application_status           VARCHAR(40) NOT NULL,
    portfolio_loan_status        VARCHAR(40) NOT NULL,
    outstanding_balance          DECIMAL(10, 2) DEFAULT 0.00,
    total_funnel_duration_hours  DECIMAL(8, 2) NOT NULL
);

-- ---------------------------------------------------------------------
-- 2. Audit / Event Log Table: Stage Transitions
-- ---------------------------------------------------------------------
CREATE TABLE loan_stage_transitions (
    transition_id                INTEGER PRIMARY KEY,
    application_id               VARCHAR(20) NOT NULL,
    stage_number                 INTEGER NOT NULL,
    stage_name                   VARCHAR(50) NOT NULL,
    status                       VARCHAR(20) NOT NULL, -- 'Completed' or 'Dropped'
    timestamp                    TIMESTAMP NOT NULL,
    duration_hours               DECIMAL(8, 2) NOT NULL,
    drop_reason                  VARCHAR(100),
    CONSTRAINT fk_loan_app FOREIGN KEY (application_id) 
        REFERENCES loan_applications (application_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- 3. High-Performance Indexes for Rapid Analytical Querying
-- ---------------------------------------------------------------------
CREATE INDEX idx_app_date ON loan_applications(application_date);
CREATE INDEX idx_app_risk ON loan_applications(risk_tier);
CREATE INDEX idx_app_status ON loan_applications(portfolio_loan_status);
CREATE INDEX idx_app_channel ON loan_applications(channel);
CREATE INDEX idx_trans_app_stage ON loan_stage_transitions(application_id, stage_number);
CREATE INDEX idx_trans_status ON loan_stage_transitions(status);
