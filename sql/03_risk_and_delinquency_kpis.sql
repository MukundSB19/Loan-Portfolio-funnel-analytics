-- =====================================================================
-- Project: Loan Portfolio Funnel & Risk Analytics
-- Script: 03_risk_and_delinquency_kpis.sql
-- Description: Credit Risk Matrices, Vintage Delinquency Curves,
--              Portfolio at Risk (PAR-30/60/90), and Expected Loss Models.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Credit Risk Matrix: Risk Tier x DTI Distribution & Bad Rates
-- ---------------------------------------------------------------------
SELECT 
    risk_tier,
    CASE 
        WHEN debt_to_income_ratio < 0.20 THEN '1. Low (< 20%)'
        WHEN debt_to_income_ratio < 0.35 THEN '2. Moderate (20-35%)'
        WHEN debt_to_income_ratio < 0.45 THEN '3. High (35-45%)'
        ELSE '4. Critical (> 45%)'
    END AS dti_bracket,
    COUNT(application_id) AS total_funded_loans,
    ROUND(SUM(loan_amount), 2) AS total_principal_disbursed,
    ROUND(AVG(interest_rate_pct), 2) AS avg_coupon_rate,
    
    -- Delinquency counts
    SUM(CASE WHEN portfolio_loan_status LIKE '%Delinquent%' OR portfolio_loan_status LIKE '%Default%' THEN 1 ELSE 0 END) AS bad_loans_count,
    
    -- Bad Rate % (Delinquency Rate)
    ROUND(
        SUM(CASE WHEN portfolio_loan_status LIKE '%Delinquent%' OR portfolio_loan_status LIKE '%Default%' THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(COUNT(application_id), 0), 2
    ) AS delinquency_rate_pct,
    
    -- Total Balance at Risk
    ROUND(SUM(outstanding_balance), 2) AS current_outstanding_exposure
FROM loan_applications
WHERE final_stage_reached = 'Disbursed'
GROUP BY 
    risk_tier,
    CASE 
        WHEN debt_to_income_ratio < 0.20 THEN '1. Low (< 20%)'
        WHEN debt_to_income_ratio < 0.35 THEN '2. Moderate (20-35%)'
        WHEN debt_to_income_ratio < 0.45 THEN '3. High (35-45%)'
        ELSE '4. Critical (> 45%)'
    END
ORDER BY risk_tier, dti_bracket;


-- ---------------------------------------------------------------------
-- 2. Vintage Delinquency Analysis by Origination Quarter (Cohort Tracking)
-- ---------------------------------------------------------------------
WITH cohort_data AS (
    SELECT 
        -- Extract Year-Quarter (e.g., 2022-Q1)
        SUBSTR(application_date, 1, 4) || '-Q' || ((CAST(SUBSTR(application_date, 6, 2) AS INTEGER) - 1) / 3 + 1) AS origination_quarter,
        COUNT(application_id) AS cohort_originated_loans,
        SUM(loan_amount) AS cohort_originated_volume,
        SUM(outstanding_balance) AS cohort_current_balance,
        SUM(CASE WHEN portfolio_loan_status = 'Current (Good Standing)' THEN loan_amount ELSE 0 END) AS current_performing_volume,
        SUM(CASE WHEN portfolio_loan_status = 'Delinquent (30-59 DPD)' THEN loan_amount ELSE 0 END) AS par_30_volume,
        SUM(CASE WHEN portfolio_loan_status = 'Delinquent (60-89 DPD)' THEN loan_amount ELSE 0 END) AS par_60_volume,
        SUM(CASE WHEN portfolio_loan_status = 'Default / Charge-Off (90+ DPD)' THEN loan_amount ELSE 0 END) AS charge_off_volume,
        SUM(CASE WHEN portfolio_loan_status = 'Fully Paid Off' THEN loan_amount ELSE 0 END) AS paid_off_volume
    FROM loan_applications
    WHERE final_stage_reached = 'Disbursed'
    GROUP BY SUBSTR(application_date, 1, 4) || '-Q' || ((CAST(SUBSTR(application_date, 6, 2) AS INTEGER) - 1) / 3 + 1)
)
SELECT 
    origination_quarter,
    cohort_originated_loans,
    ROUND(cohort_originated_volume, 2) AS cohort_originated_volume,
    ROUND(cohort_current_balance, 2) AS cohort_current_balance,
    -- PAR 30+ Ratio %
    ROUND(((par_30_volume + par_60_volume + charge_off_volume) * 100.0 / cohort_originated_volume), 2) AS par_30_plus_rate_pct,
    -- PAR 90+ / Cumulative Default Rate %
    ROUND((charge_off_volume * 100.0 / cohort_originated_volume), 2) AS cumulative_default_rate_pct,
    -- Recovery / Payoff Rate %
    ROUND((paid_off_volume * 100.0 / cohort_originated_volume), 2) AS full_payoff_rate_pct
FROM cohort_data
ORDER BY origination_quarter;


-- ---------------------------------------------------------------------
-- 3. Portfolio Health & Expected Loss (EL = PD x LGD x EAD) Proxy Model
-- Assumptions: Average LGD (Loss Given Default) = 65% for unsecured personal loans
-- ---------------------------------------------------------------------
SELECT 
    risk_tier,
    COUNT(application_id) AS total_active_loans,
    ROUND(SUM(outstanding_balance), 2) AS exposure_at_default_ead,
    ROUND(AVG(interest_rate_pct), 2) AS weighted_avg_rate_pct,
    -- Empirical Probability of Default (PD) by Tier
    ROUND(
        SUM(CASE WHEN portfolio_loan_status LIKE '%Default%' THEN 1 ELSE 0 END) * 1.0 / 
        NULLIF(COUNT(application_id), 0), 4
    ) AS empirical_pd,
    -- Constant LGD Assumption of 65%
    0.65 AS loss_given_default_lgd,
    -- Expected Loss ($) = EAD * PD * LGD
    ROUND(
        SUM(outstanding_balance) * 
        (SUM(CASE WHEN portfolio_loan_status LIKE '%Default%' THEN 1.0 ELSE 0.0 END) / NULLIF(COUNT(application_id), 0)) * 
        0.65, 2
    ) AS expected_loss_dollars
FROM loan_applications
WHERE final_stage_reached = 'Disbursed'
GROUP BY risk_tier
ORDER BY risk_tier;
