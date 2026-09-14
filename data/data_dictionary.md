# Data Dictionary: Loan Portfolio Funnel & Risk Analytics

This document defines the schema, table relationships, and column definitions for the **Loan Portfolio Funnel & Risk Analytics** project.

---

## 1. Table: `loan_applications` (26,500 rows)
Primary entity containing borrower demographics, credit characteristics, requested loan terms, and final lifecycle status.

| Column Name | Data Type | Description & Domain Values |
| :--- | :--- | :--- |
| `application_id` | `VARCHAR(20)` **(PK)** | Unique identifier for each loan application (e.g., `APP-000001`). |
| `customer_id` | `VARCHAR(20)` | Unique identifier for the borrower. |
| `application_date` | `DATE` | Date when the initial loan application lead was captured (`YYYY-MM-DD`). |
| `channel` | `VARCHAR(30)` | Originating acquisition channel: `Direct Web`, `Mobile App`, `Affiliate Partner`, `Broker Aggregator`. |
| `applicant_age` | `INTEGER` | Borrower age in years (Range: 21–68). |
| `employment_type` | `VARCHAR(30)` | Employment status: `Full-Time`, `Self-Employed`, `Part-Time`, `Contractor`, `Unemployed`. |
| `housing_status` | `VARCHAR(20)` | Housing arrangement: `Mortgage`, `Rent`, `Own`, `Other`. |
| `annual_income` | `DECIMAL(12,2)` | Gross annual verifiable income in USD ($18,000 – $280,000). |
| `credit_score` | `INTEGER` | FICO Credit Score at application date (Range: 380–850). |
| `risk_tier` | `VARCHAR(30)` | Credit risk rating band: `Tier A (750+)`, `Tier B (700-749)`, `Tier C (640-699)`, `Tier D (580-639)`, `Tier E (<580)`. |
| `debt_to_income_ratio` | `DECIMAL(5,3)` | Monthly non-housing debt payments divided by gross monthly income (Range: 0.05 – 0.65). |
| `loan_purpose` | `VARCHAR(40)` | Stated purpose: `Personal`, `Debt Consolidation`, `Home Improvement`, `Small Business`, `Auto Refinance`. |
| `loan_amount` | `DECIMAL(10,2)` | Principal loan amount requested ($3,000 – $45,000). |
| `loan_term_months` | `INTEGER` | Amortization term in months (`36` or `60`). |
| `interest_rate_pct` | `DECIMAL(5,2)` | Assigned annual percentage rate (APR) based on risk tier and DTI. |
| `final_stage_reached` | `VARCHAR(40)` | Last stage completed before exit or disbursement. |
| `application_status` | `VARCHAR(40)` | Lifecycle outcome: `Active/Funded`, `Abandoned`, `Doc Verification Failed`, `Credit Declined`, `Offer Declined`. |
| `portfolio_loan_status`| `VARCHAR(40)` | Repayment status: `Current (Good Standing)`, `Delinquent (30-59 DPD)`, `Delinquent (60-89 DPD)`, `Default / Charge-Off (90+ DPD)`, `Fully Paid Off`, `Incomplete`, `Rejected_Docs`, `Declined_Credit`, `Offer_Rejected`. |
| `outstanding_balance` | `DECIMAL(10,2)` | Remaining unpaid principal balance as of report date. |
| `total_funnel_duration_hours` | `DECIMAL(8,2)` | Total elapsed time (hours) from Lead Captured to terminal state. |

---

## 2. Table: `loan_stage_transitions` (129,555 rows)
Granular audit log capturing stage-by-stage progression, SLAs, timestamps, and drop-off reasons.

| Column Name | Data Type | Description & Domain Values |
| :--- | :--- | :--- |
| `transition_id` | `INTEGER` **(PK)** | Auto-incrementing surrogate key. |
| `application_id` | `VARCHAR(20)` **(FK)** | References `loan_applications.application_id`. |
| `stage_number` | `INTEGER` | Sequence number of the funnel gate (1 to 7). |
| `stage_name` | `VARCHAR(50)` | Name of the stage: `1. Lead Captured`, `2. Application Submission`, `3. Document Verification`, `4. Underwriting & Risk`, `5. Credit Approved`, `6. Offer Acceptance`, `7. Disbursement`. |
| `status` | `VARCHAR(20)` | Gate outcome: `Completed` or `Dropped`. |
| `timestamp` | `DATETIME` | Date and time when the stage transition occurred (`YYYY-MM-DD HH:MM:SS`). |
| `duration_hours` | `DECIMAL(8,2)` | Elapsed SLA turnaround time spent in this specific stage. |
| `drop_reason` | `VARCHAR(100)` | Documented root-cause failure (e.g., `Income Proof Mismatch`, `High DTI Ratio`, `Competitor Rate Cheaper`, `SLA Timeout`). |
