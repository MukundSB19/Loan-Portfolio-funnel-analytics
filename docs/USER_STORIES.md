# 👤 Agile User Stories & Acceptance Criteria
## Project: Loan Portfolio Funnel & Risk Analytics Platform

---

### Epic 1: Funnel Diagnostic & Bottleneck Analytics
**Epic Goal:** Provide end-to-end visibility into the 7-stage loan origination funnel to isolate drop-off gates and SLA delays.

#### 🎫 Story US-01: Funnel Conversion Waterfall View
- **As a** VP of Lending Operations,
- **I want** to view the application volume, pass rate, and drop-off rate across all 7 stages of the loan funnel,
- **So that** I can identify which milestone causes the greatest leakage in our origination pipeline.

**Acceptance Criteria (Gherkin Format):**
```gherkin
Scenario: Calculating stage-to-stage pass rates
  Given 26,500 application leads have been captured in the system
  When the user views the Funnel Performance page
  Then the dashboard should display all 7 stages in sequential order
  And Stage 1 (Lead Captured) must represent 100% of the baseline volume
  And Stage 7 (Disbursement) must display 39.5% conversion (9,166 loans)
  And each stage transition must show the exact drop-off count and percentage.
```

---

#### 🎫 Story US-02: Drop-Off Root Cause Breakdown
- **As an** Operations Process Analyst,
- **I want** to filter dropped applications by documented failure reason (e.g., Doc Mismatch, SLA Timeout, Competitor Offer),
- **So that** I can design targeted operational and UI fixes to recover lost borrowers.

**Acceptance Criteria:**
```gherkin
Scenario: Diagnosing Document Verification failure causes
  Given an applicant was marked as "Dropped" at Stage 3 (Document Verification)
  When the analyst drills down into the Stage 3 drop-off bar chart
  Then the chart must rank failure reasons by volume
  And "Income Proof Mismatch" must be flagged as the top failure driver (42% of stage drops)
  And average hours spent before dropping must be displayed in the tooltip.
```

---

### Epic 2: Credit Risk Governance & Vintage Analytics
**Epic Goal:** Equip credit risk officers with cross-dimensional risk matrices and vintage cohort monitoring.

#### 🎫 Story US-03: FICO $\times$ DTI Delinquency Matrix
- **As a** Chief Risk Officer (CRO),
- **I want** to view a two-way heatmap matrix of Delinquency Rates segmented by Credit Tier and DTI Brackets,
- **So that** I can set strict underwriting boundaries and adjust interest rate pricing.

**Acceptance Criteria:**
```gherkin
Scenario: Viewing high-risk delinquency concentrations
  Given funded loan applications are loaded into the risk model
  When the CRO selects the Risk Matrix visual
  Then the grid must display 5 rows (Tier A to Tier E) and 4 columns (DTI <20%, 20-35%, 35-45%, >45%)
  And cells with delinquency rate > 7.5% must be formatted in red
  And Tier E with DTI > 45% must display a delinquency rate exceeding 25.0%.
```

---

#### 🎫 Story US-04: Vintage Delinquency Cohort Curves
- **As a** Senior Credit Risk Analyst,
- **I want** to track cumulative default rates across origination quarters over 36 months on book,
- **So that** I can detect deteriorating credit vintages early and adjust loan loss reserves.

**Acceptance Criteria:**
```gherkin
Scenario: Plotting vintage default curves
  Given origination cohorts from 2022-Q1 to 2024-Q3
  When the user selects the Vintage Curves visual
  Then the X-axis must display Months on Book (1 to 36)
  And separate trend lines must represent each origination quarter
  And cumulative default rate must increase monotonically as loans mature.
```

---

### Epic 3: Business Optimization & Reporting Automation
**Epic Goal:** Automate weekly reporting workflows and model business scenarios for conversion growth.

#### 🎫 Story US-05: 14% Conversion Lift Scenario Simulator
- **As a** Business Strategy Lead,
- **I want** to interactively adjust document verification and underwriting SLA sliders,
- **So that** I can simulate the projected origination volume resulting from a 14% conversion lift.

**Acceptance Criteria:**
```gherkin
Scenario: Simulating a 14% conversion lift
  Given the baseline origination volume of $180,500,000
  When the user applies the 14% lift scenario lever
  Then the projected conversion rate must update from 39.5% to 45.1%
  And projected funded volume must display $205,770,000
  And incremental volume gained must display +$25,270,000.
```

---

#### 🎫 Story US-06: 1-Click Scheduled Reporting Refresh
- **As a** BI Reporting Analyst,
- **I want** to click "Refresh" in Power BI / Excel to update all views from live SQL endpoints,
- **So that** I reduce weekly manual reporting effort from 7.5 hours down to 2.5 hours.

**Acceptance Criteria:**
```gherkin
Scenario: Executing automated scheduled refresh
  Given new application and transition records exist in the database
  When the scheduled refresh job executes at 06:00 AM
  Then all Power BI dashboard visuals and Excel pivot tables must update automatically
  And no manual formula adjustments or column re-mappings should be required.
```
