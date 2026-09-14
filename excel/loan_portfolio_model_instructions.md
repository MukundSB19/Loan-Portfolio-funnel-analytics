# Excel Financial Model & Dashboard Guide: Loan Portfolio Analytics

This guide provides the complete formulas, Pivot Table layouts, and dynamic KPI architectures to build an interactive, executive-ready Excel workbook using native Excel tools (Advanced Excel, Dynamic Arrays, `XLOOKUP`, `SUMIFS`, `LET`).

---

## 1. Excel Workbook Tab Structure

1. **`Data_Applications`**: Linked to `loan_applications_25k.csv` via Power Query.
2. **`Data_Transitions`**: Linked to `loan_stage_transitions.csv` via Power Query.
3. **`KPI_Summary_Engine`**: Formula calculation tab for dynamic KPI metrics.
4. **`Risk_Matrix`**: Two-way data table evaluating Delinquency Rates across FICO tiers and DTI brackets.
5. **`Executive_Dashboard`**: Front-facing presentation layer with KPI tiles, slicers, and interactive charts.

---

## 2. Core Advanced Excel Formulas Catalog

### A. Dynamic KPI Cards (`KPI_Summary_Engine` Tab)

- **Total Application Leads**:
  ```excel
  =COUNTA(Data_Applications[application_id])
  ```

- **Total Funded / Disbursed Loans**:
  ```excel
  =COUNTIFS(Data_Applications[final_stage_reached], "Disbursed")
  ```

- **Funnel Conversion Rate %**:
  ```excel
  =COUNTIFS(Data_Applications[final_stage_reached], "Disbursed") / COUNTA(Data_Applications[application_id])
  ```

- **Total Funded Volume ($)**:
  ```excel
  =SUMIFS(Data_Applications[loan_amount], Data_Applications[final_stage_reached], "Disbursed")
  ```

- **Active Outstanding Portfolio ($)**:
  ```excel
  =SUM(Data_Applications[outstanding_balance])
  ```

- **Weighted Average Portfolio APR (%)**:
  ```excel
  =SUMPRODUCT(Data_Applications[loan_amount], Data_Applications[interest_rate_pct], --(Data_Applications[final_stage_reached]="Disbursed")) / SUMIFS(Data_Applications[loan_amount], Data_Applications[final_stage_reached], "Disbursed")
  ```

- **Portfolio at Risk (PAR 30+) Balance ($)**:
  ```excel
  =SUMIFS(Data_Applications[outstanding_balance], Data_Applications[portfolio_loan_status], "Delinquent (30-59 DPD)") + SUMIFS(Data_Applications[outstanding_balance], Data_Applications[portfolio_loan_status], "Delinquent (60-89 DPD)") + SUMIFS(Data_Applications[outstanding_balance], Data_Applications[portfolio_loan_status], "Default / Charge-Off (90+ DPD)")
  ```

- **PAR 30+ Delinquency Rate %**:
  ```excel
  =PAR_30_Balance / Active_Outstanding_Portfolio
  ```

---

## 3. Dynamic Two-Way Risk Matrix (DTI vs FICO Risk Tier)

In the `Risk_Matrix` tab, create a dynamic grid using `COUNTIFS` and `SUMIFS` to populate bad loan ratios:

| Risk Tier (Rows) | Low DTI (<20%) | Moderate DTI (20-35%) | High DTI (35-45%) | Critical DTI (>45%) |
| :--- | :--- | :--- | :--- | :--- |
| **Tier A (750+)** | `=SUMIFS(...) / COUNTIFS(...)` | `=SUMIFS(...) / COUNTIFS(...)` | `=SUMIFS(...) / COUNTIFS(...)` | `=SUMIFS(...) / COUNTIFS(...)` |
| **Tier B (700-749)**| ... | ... | ... | ... |
| **Tier C (640-699)**| ... | ... | ... | ... |
| **Tier D (580-639)**| ... | ... | ... | ... |
| **Tier E (<580)**   | ... | ... | ... | ... |

Formula for Cell `[Tier A, Low DTI]`:
```excel
=LET(
    bad_count, COUNTIFS(Data_Applications[risk_tier], "Tier A (Excellent)", Data_Applications[debt_to_income_ratio], "<0.20", Data_Applications[portfolio_loan_status], "*Delinquent*") + COUNTIFS(Data_Applications[risk_tier], "Tier A (Excellent)", Data_Applications[debt_to_income_ratio], "<0.20", Data_Applications[portfolio_loan_status], "*Default*"),
    total_count, COUNTIFS(Data_Applications[risk_tier], "Tier A (Excellent)", Data_Applications[debt_to_income_ratio], "<0.20", Data_Applications[final_stage_reached], "Disbursed"),
    IF(total_count=0, 0, bad_count / total_count)
)
```

---

## 4. Automated 14% Conversion Lift Scenario Modeler

Build interactive Excel sliders (Form Controls) or input cells in `Executive_Dashboard`:

- Cell `G4` (User Input / Scenario Lever): `14.0%` (Projected Conversion Lift)
- Baseline Originations: `=B4`
- Scenario Disbursals: `=B4 * (1 + G4)`
- Scenario Funded Volume ($): `=B5 * (1 + G4)`
- Incremental Revenue Generated ($): `=Scenario_Funded_Volume - Baseline_Funded_Volume`
