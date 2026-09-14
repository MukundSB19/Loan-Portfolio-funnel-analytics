# Power BI Dashboard Visual Specifications: Loan Portfolio Analytics

This document outlines the detailed layout, visual cards, charts, slicers, and interactive configurations for all **4 pages** of the Power BI report.

---

## Page 1: Executive Portfolio Overview & Trends

### 1. Top KPI Summary Cards (Header Row)
- **Card 1: Total Leads Captured**: `[Total Leads]` (Formatted: `26,500`)
- **Card 2: Total Disbursals**: `[Total Disbursed Applications]` (Formatted: `10,480+`)
- **Card 3: Funnel Conversion Rate**: `[Overall Conversion Rate %]` (Target: `39.5%` with green/amber alert)
- **Card 4: Total Origination Volume**: `[Total Origination Volume ($)]` (Formatted: `$180M+`)
- **Card 5: Portfolio Delinquency Rate (PAR 30+)**: `[PAR 30 Rate %]` (Formatted: `4.2%`)
- **Card 6: Avg Turnaround SLA**: `[Average Turnaround Time (Days)]` (Formatted: `4.6 Days`)

### 2. Main Visuals
- **Visual 1 (Area / Line Chart - Top Left)**: *Monthly Origination Volume & Application Trajectory (2022–2024)*
  - X-Axis: `Dim_Date[Year_Quarter]` or `Dim_Date[Month]`
  - Y-Axis: `[Total Origination Volume ($)]` (Primary), `[Total Leads]` (Secondary)
- **Visual 2 (Clustered Bar Chart - Top Right)**: *Origination Volume by Loan Purpose*
  - Y-Axis: `loan_applications[loan_purpose]`
  - X-Axis: `[Total Origination Volume ($)]`
- **Visual 3 (Donut Chart - Bottom Left)**: *Applications by Channel Distribution*
  - Legend: `loan_applications[channel]`
  - Values: `[Total Leads]`
- **Visual 4 (Stacked Bar Chart - Bottom Right)**: *Portfolio Balance by Risk Tier & Repayment Status*
  - Y-Axis: `loan_applications[risk_tier]`
  - X-Axis: `[Total Active Outstanding Balance ($)]`
  - Legend: `loan_applications[portfolio_loan_status]`

### 3. Global Slicers & Filters (Top Slicer Panel)
- Date Range Slider (`Dim_Date[Date]`)
- Acquisition Channel (`Direct Web`, `Mobile App`, `Affiliate`, `Broker`)
- Risk Tier (`Tier A`, `Tier B`, `Tier C`, `Tier D`, `Tier E`)
- Loan Purpose (`Personal`, `Debt Consolidation`, `Home Improvement`, etc.)

---

## Page 2: End-to-End Funnel & Drop-Off Diagnostics

### 1. Visuals & Layout
- **Visual 1 (Funnel Visual - Left Half)**: *7-Stage Application Funnel Waterfall*
  - Stages:
    1. Lead Captured (100%)
    2. Application Submitted (88.2%)
    3. Document Verification (68.5%) $\to$ *Primary Bottleneck*
    4. Underwriting & Risk (51.4%)
    5. Credit Approved (49.3%)
    6. Offer Accepted (40.8%)
    7. Disbursement (39.5%)
- **Visual 2 (Decomposition Tree / Bar Chart - Top Right)**: *Root-Cause Drop-Off Reasons*
  - Category: `loan_stage_transitions[drop_reason]`
  - Metric: Count of Dropped Applications
  - Tooltip: Average SLA hours prior to drop
- **Visual 3 (Scatter Plot - Bottom Right)**: *Stage SLA Duration (Hours) vs Drop-Off Volume*
  - X-Axis: Average Stage SLA (Hours)
  - Y-Axis: Drop-Off Count
  - Bubble Size: Total Application Volume

---

## Page 3: Credit Risk, Underwriting & Delinquency Analytics

### 1. Visuals & Layout
- **Visual 1 (Heatmap Matrix - Top Half)**: *Delinquency Rate Matrix: FICO Risk Tier vs DTI Ratio*
  - Rows: `loan_applications[risk_tier]`
  - Columns: `DTI Bracket (<20%, 20-35%, 35-45%, >45%)`
  - Values: `[PAR 30 Rate %]` with conditional color gradient (Green $\to$ Red)
- **Visual 2 (Cohort Line Chart - Bottom Left)**: *Vintage Delinquency Curves (Origination Quarter vs PAR 30+)*
  - X-Axis: Months on Book (1 to 36)
  - Lines: Origination Cohorts (`2022-Q1`, `2022-Q2`, ..., `2024-Q3`)
  - Y-Axis: `Cumulative Default %`
- **Visual 3 (Clustered Column Chart - Bottom Right)**: *Expected Loss ($) & Exposure at Default by Risk Grade*
  - X-Axis: `risk_tier`
  - Y-Axis: `[Total Active Outstanding Balance ($)]` (Bar), Expected Loss ($) (Line)

---

## Page 4: SLA, Bottleneck & 14% Conversion Lift Scenario Modeler

### 1. Interactive What-If Scenario Controls
- **What-If Parameter 1 (Slider)**: *Doc Verification SLA Reduction (%)* (Range: 0% to 50%)
- **What-If Parameter 2 (Slider)**: *Underwriting Automation Lift (%)* (Range: 0% to 20%)
- **What-If Parameter 3 (Slider)**: *Offer Pricing Elasticity Boost (%)* (Range: 0% to 15%)

### 2. Comparative Impact Display (Before vs After 14% Lift)
- **Card 1**: Current Baseline Conversions vs **Target Lift Conversions (+14%)**
- **Card 2**: Current Origination Volume vs **Projected Origination Volume ($)**
- **Card 3**: Incremental Portfolio Revenue Unlocked: `+$25.2M`
- **Tornado / Bridge Chart**: *Conversion Leakage Recovery Bridge*
  - Baseline Disbursals $\to$ OCR Document Recovery (+5.2%) $\to$ Instant UW Decisioning (+4.8%) $\to$ Dynamic Rate Match (+4.0%) $\to$ **New Optimized Disbursal Run-Rate**.
