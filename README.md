# Loan Portfolio Funnel & Risk Analytics Dashboard

[![Tech: SQL](https://img.shields.io/badge/SQL-Advanced%20Analytics-blue.svg)](#)
[![Tech: Power BI](https://img.shields.io/badge/Power%20BI-DAX%20Modeling-yellow.svg)](#)
[![Tech: Advanced Excel](https://img.shields.io/badge/Excel-Power%20Query%20%26%20Dynamic%20Arrays-green.svg)](#)

An enterprise-grade portfolio analytics project analyzing **25,000+ loan applications** across 7 sequential funnel gates to identify stage-level drop-offs, bottleneck SLAs, and credit risk distributions, unlocking a **14% projected lift in conversions** and reducing scheduled reporting overhead by **65% (5 hours/week)**.

---

## 📌 Project Highlights & Executive Summary
- **Funnel Diagnostics**: Evaluated 26,500+ records to pinpoint major applicant drop-offs at Document Verification (31.5% drop) and Underwriting SLA delays (17.8% drop).
- **14% Conversion Lift Playbook**: Engineered data-backed interventions (Instant OCR KYC, automated sub-4hr underwriting, dynamic rate-matching) projecting a **+$25.2M increase in funded origination volume**.
- **Reporting Automation**: Architected automated SQL views and Power Query refresh pipelines reducing reporting cycle time from 7.5 hours/week to 2.5 hours/week (**65% time savings**).
- **Risk Governance**: Developed a two-way FICO $\times$ DTI credit risk matrix, vintage delinquency tracking, and Portfolio at Risk (PAR 30/60/90) monitoring.

---

## 📂 Repository Structure

```text
├── data/
│   ├── loan_applications_25k.csv       # 26,500 rows master dataset (ready to load)
│   ├── loan_stage_transitions.csv      # 129,555 timestamped funnel event logs
│   └── data_dictionary.md              # Column schemas, data types, and business rules
├── sql/
│   ├── 01_schema_and_tables.sql        # Production DDL, staging tables, and indexes
│   ├── 02_funnel_conversion_analysis.sql # Funnel pass rates, stage SLAs, 14% lift model
│   ├── 03_risk_and_delinquency_kpis.sql  # DTI vs FICO matrix, vintage cohorts, PAR 30/60/90
│   └── 04_automated_reporting_views.sql  # Automated SQL views reducing manual reporting
├── powerbi/
│   ├── dax_measures_library.dax        # Production DAX measures & calculation logic
│   ├── star_schema_relationships.md    # Star schema dimensional modeling guide
│   └── dashboard_wireframes_and_specs.md # 4-page Power BI visual layout blueprints
├── excel/
│   ├── loan_portfolio_model_instructions.md # Excel dynamic formula model & risk matrix guide
│   └── power_query_m_scripts.txt       # Copy-paste Power Query M-scripts for 1-click refresh
├── reports/
│   └── executive_summary_and_insights.md # Full executive strategic presentation & findings
└── README.md                           # Main repository documentation
```

---

## 🛠️ How to Use This Project

### 1. SQL Database Setup & Analysis
Execute the SQL files in any SQL database (PostgreSQL, MySQL, SQL Server, SQLite, Snowflake, BigQuery):
1. Run `sql/01_schema_and_tables.sql` to initialize tables.
2. Import `data/loan_applications_25k.csv` and `data/loan_stage_transitions.csv`.
3. Execute `sql/02_funnel_conversion_analysis.sql` for conversion analytics and the 14% lift model.
4. Execute `sql/03_risk_and_delinquency_kpis.sql` for vintage curves and risk metrics.
5. Deploy `sql/04_automated_reporting_views.sql` to enable automated reporting feeds.

### 2. Power BI Dashboard Setup
1. Open Power BI Desktop $\to$ Get Data $\to$ Select `data/loan_applications_25k.csv` and `data/loan_stage_transitions.csv`.
2. Follow the dimensional star schema in `powerbi/star_schema_relationships.md`.
3. Create a new measure table and paste the DAX measures from `powerbi/dax_measures_library.dax`.
4. Build the 4 dashboard pages following `powerbi/dashboard_wireframes_and_specs.md`.

### 3. Advanced Excel Model
1. Open Microsoft Excel $\to$ Data $\to$ Get Data from CSV.
2. Paste the M-code from `excel/power_query_m_scripts.txt` into the Advanced Editor.
3. Build the dynamic KPI formulas and Risk Matrix following `excel/loan_portfolio_model_instructions.md`.
