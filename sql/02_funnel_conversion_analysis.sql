-- =====================================================================
-- Project: Loan Portfolio Funnel & Risk Analytics
-- Script: 02_funnel_conversion_analysis.sql
-- Description: End-to-end Funnel Conversion, Drop-off Diagnostics, SLA
--              Turnaround Bottlenecks, and 14% Conversion Lift Simulation.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Full Funnel Conversion Waterfall (Stage 1 to Stage 7)
-- ---------------------------------------------------------------------
WITH stage_counts AS (
    SELECT 
        stage_number,
        stage_name,
        COUNT(DISTINCT application_id) AS applications_entered,
        COUNT(DISTINCT CASE WHEN status = 'Completed' THEN application_id END) AS applications_passed,
        COUNT(DISTINCT CASE WHEN status = 'Dropped' THEN application_id END) AS applications_dropped,
        ROUND(AVG(duration_hours), 2) AS avg_stage_duration_hours
    FROM loan_stage_transitions
    GROUP BY stage_number, stage_name
),
funnel_summary AS (
    SELECT 
        stage_number,
        stage_name,
        applications_entered,
        applications_passed,
        applications_dropped,
        avg_stage_duration_hours,
        -- Stage-to-Stage Pass Rate %
        ROUND((CAST(applications_passed AS DECIMAL(10,2)) / applications_entered) * 100, 2) AS stage_pass_rate_pct,
        -- Cumulative Conversion % from Top of Funnel (Stage 1)
        ROUND((CAST(applications_passed AS DECIMAL(10,2)) / FIRST_VALUE(applications_entered) OVER (ORDER BY stage_number)) * 100, 2) AS cumulative_conversion_pct,
        -- Stage Drop-off % relative to stage entries
        ROUND((CAST(applications_dropped AS DECIMAL(10,2)) / applications_entered) * 100, 2) AS stage_dropoff_rate_pct
    FROM stage_counts
)
SELECT * FROM funnel_summary
ORDER BY stage_number;


-- ---------------------------------------------------------------------
-- 2. Drop-off Root Cause Diagnostics (Where & Why Borrowers Exit)
-- ---------------------------------------------------------------------
SELECT 
    stage_name,
    drop_reason,
    COUNT(application_id) AS drop_count,
    ROUND((COUNT(application_id) * 100.0 / SUM(COUNT(application_id)) OVER(PARTITION BY stage_name)), 2) AS pct_within_stage,
    ROUND(AVG(duration_hours), 1) AS avg_hours_before_drop
FROM loan_stage_transitions
WHERE status = 'Dropped' AND drop_reason IS NOT NULL AND drop_reason != ''
GROUP BY stage_name, drop_reason
ORDER BY stage_name, drop_count DESC;


-- ---------------------------------------------------------------------
-- 3. Acquisition Channel Funnel Efficiency & Turnaround Comparison
-- ---------------------------------------------------------------------
SELECT 
    a.channel,
    COUNT(a.application_id) AS total_leads,
    SUM(CASE WHEN a.final_stage_reached = 'Disbursed' THEN 1 ELSE 0 END) AS total_disbursed,
    ROUND(SUM(CASE WHEN a.final_stage_reached = 'Disbursed' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.application_id), 2) AS overall_conversion_rate_pct,
    ROUND(AVG(a.total_funnel_duration_hours) / 24.0, 1) AS avg_turnaround_days,
    ROUND(SUM(CASE WHEN a.final_stage_reached = 'Disbursed' THEN a.loan_amount ELSE 0 END) / 1000000.0, 2) AS total_funded_volume_millions
FROM loan_applications a
GROUP BY a.channel
ORDER BY total_funded_volume_millions DESC;


-- ---------------------------------------------------------------------
-- 4. Underwriting & Document Verification Bottleneck Deep-Dive
-- ---------------------------------------------------------------------
SELECT 
    a.employment_type,
    a.risk_tier,
    COUNT(a.application_id) AS submitted_apps,
    SUM(CASE WHEN a.application_status = 'Doc Verification Failed' THEN 1 ELSE 0 END) AS doc_fails,
    ROUND(SUM(CASE WHEN a.application_status = 'Doc Verification Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.application_id), 2) AS doc_fail_rate_pct,
    SUM(CASE WHEN a.application_status = 'Credit Declined' THEN 1 ELSE 0 END) AS credit_declines,
    ROUND(SUM(CASE WHEN a.application_status = 'Credit Declined' THEN 1 ELSE 0 END) * 100.0 / COUNT(a.application_id), 2) AS credit_decline_rate_pct,
    ROUND(AVG(t.duration_hours), 1) AS avg_underwriting_sla_hours
FROM loan_applications a
JOIN loan_stage_transitions t ON a.application_id = t.application_id AND t.stage_number = 4
GROUP BY a.employment_type, a.risk_tier
ORDER BY doc_fail_rate_pct DESC;


-- ---------------------------------------------------------------------
-- 5. Business Opportunity Simulation: 14% Conversion Lift Model
-- Optimization Levers:
--  - Automated OCR & Instant Bank Verification (+8% lift in Stage 3 pass rate)
--  - Sub-4-hour SLA Underwriting decisioning (+5% lift in Stage 4)
--  - Dynamic Rate Discounting matching competitor APRs (+6% lift in Stage 6)
-- ---------------------------------------------------------------------
WITH baseline_metrics AS (
    SELECT 
        COUNT(application_id) AS total_leads,
        SUM(CASE WHEN final_stage_reached = 'Disbursed' THEN 1 ELSE 0 END) AS baseline_disbursals,
        SUM(CASE WHEN final_stage_reached = 'Disbursed' THEN loan_amount ELSE 0 END) AS baseline_origination_volume,
        ROUND(SUM(CASE WHEN final_stage_reached = 'Disbursed' THEN 1 ELSE 0 END) * 100.0 / COUNT(application_id), 2) AS baseline_conversion_pct
    FROM loan_applications
),
simulation_model AS (
    SELECT 
        total_leads,
        baseline_disbursals,
        baseline_origination_volume,
        baseline_conversion_pct,
        -- Projected 14% relative lift in conversions (e.g. 38% -> 43.3%)
        ROUND(baseline_disbursals * 1.14) AS projected_disbursals_lift,
        ROUND(baseline_origination_volume * 1.14, 2) AS projected_origination_volume_lift,
        ROUND(baseline_conversion_pct * 1.14, 2) AS projected_conversion_pct_lift,
        ROUND((baseline_origination_volume * 1.14) - baseline_origination_volume, 2) AS incremental_portfolio_growth_dollars
    FROM baseline_metrics
)
SELECT 
    total_leads,
    baseline_disbursals,
    projected_disbursals_lift,
    (projected_disbursals_lift - baseline_disbursals) AS incremental_loans_funded,
    baseline_conversion_pct,
    projected_conversion_pct_lift,
    (projected_conversion_pct_lift - baseline_conversion_pct) AS conversion_points_gain,
    baseline_origination_volume,
    projected_origination_volume_lift,
    incremental_portfolio_growth_dollars
FROM simulation_model;
