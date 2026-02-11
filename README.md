# Smart-Warehouse-Management-System

A portfolio-ready, end-to-end **data analytics** project simulating a real Warehouse & Transport Data Analyst role in a logistics environment.[web:7][web:10]

---

## 📖 Project Overview

This project uses a messy, realistic warehouse dataset to walk through the full lifecycle from data exploration to automated reporting and business insights.[web:7][web:10] You will clean and transform data, build a semantic model, and create Power BI dashboards and documentation suitable for interviews and portfolio showcase.[web:3][web:8]

---

## 📁 Repository Contents

- `Warehouse_Management_Raw_Data.xlsx`  
  - 8,650 records across 4 worksheets: Inventory, Orders, Transport, Suppliers.[web:7][web:10]

- `Project_Guide.md`  
  - Detailed instructions, tasks, and objectives for each phase of the project.[web:3][web:8]

- `README.md`  
  - This quick reference and onboarding guide.

---

## 📊 Dataset Description

The raw Excel file contains four core operational areas commonly found in warehouse and transport analytics projects.[web:7][web:10]

### Inventory (5,000 records)

- Stock levels, locations, costs, reorder points, supplier info.  
- Key issues:  
  - ~5% negative stock quantities  
  - ~200 duplicate SKUs  
  - ~8% missing unit costs  
  - Inconsistent location formats and mixed warehouse naming

### Orders (3,000 records)

- Customer orders, delivery tracking, pricing.  
- Key issues:  
  - ~15% orphaned SKUs (not in inventory)  
  - ~30% inconsistent total values  
  - ~5% delivery dates before order dates  
  - Mixed date formats and inconsistent status values

### Transport (500 records)

- Vehicle routing, driver performance, fuel consumption.  
- Key issues:  
  - Vehicles overloaded (load > capacity)  
  - ~30% missing actual arrival times  
  - ~8% missing driver names  
  - Inconsistent status formatting

### Suppliers (150 records)

- Supplier performance metrics and contact details.  
- Key issues:  
  - ~15% missing email addresses  
  - ~20% missing phone numbers  
  - Inconsistent payment terms and mixed date formats

---

## 🚀 Quick Start

1. **Explore the data (30 min)**  
   - Open `Warehouse_Management_Raw_Data.xlsx`, review each worksheet, note patterns, issues, and initial observations.

2. **Profile the data (1–2 hours)**  
   - Count records, nulls, duplicates; check data types and formats; document anomalies and create an issue log.

3. **Design a cleaning plan (1 hour)**  
   - Prioritise issues by business impact, define cleaning logic, validation rules, and acceptance criteria.

4. **Clean high-impact issues first (2–4 hours)**  
   - Duplicate SKUs, negative stock quantities, date format standardisation, warehouse name consolidation, missing critical values.

5. **Build a foundation (3–6 hours)**  
   - Create clean master tables, write SQL transformation queries, design an ETL pipeline, implement validation rules.

6. **Create analytics & dashboards (4–8 hours)**  
   - Calculate KPIs, build Power BI dashboards, design automated reports, and generate business insights.[web:6][web:12]

---

## 📈 Key Metrics to Build

Use the cleaned datasets to calculate metrics that mirror real warehouse and logistics KPIs.[web:7][web:10]

### Must-have KPIs

- Stock turnover rate  
- On-time delivery percentage  
- Vehicle utilisation percentage  
- Items below reorder point  
- Order cycle time

### Should-have KPIs

- ABC classification  
- Stock-out rate  
- Supplier reliability score  
- Route efficiency  
- Fuel efficiency

### Nice-to-have KPIs

- Obsolete stock value  
- Backorder rate  
- Cost per delivery  
- Quality score trends  
- Spend concentration

---

## 🔧 Recommended Tech Stack

### Essential

- Excel – initial exploration and quick checks.[web:10]  
- SQL – core data transformation, cleaning, and metric logic.[web:12]  
- Power BI – data modelling and interactive dashboards.[web:6]

### Helpful

- Python + pandas – advanced cleaning and automation.[web:6][web:10]  
- VS Code – code editing.  
- Git – version control and portfolio history.[web:3][web:8]

### Optional

- Microsoft Fabric – advanced analytics and end-to-end pipelines.[web:5]  
- DAX Studio – Power BI performance tuning.[web:6]

---

## 💡 Working Guidelines

### Data Cleaning

- Use SQL `CASE` expressions and lookup tables to standardise statuses, locations, and warehouse names.[web:12]  
- Document all transformation logic and keep original data read-only.

### Power BI

- Start with simple visuals, then add bookmarks, navigation, and drill-through pages.[web:6]  
- Test layouts on different screen sizes.

### SQL

- Use CTEs for complex logic, comment queries clearly, index appropriately, and test on smaller subsets first.[web:1][web:12]

### General Project Practice

- Commit frequently, keep a short project journal, time-box tasks, and always tie work back to business value.[web:3][web:8]

---

## 🎓 What You’ll Learn

- Real-world data quality challenges in warehousing and transport.[web:7][web:10]  
- ETL pipeline design and implementation.  
- BI dashboard design and storytelling.  
- Warehouse operations, transport logistics metrics, and supplier performance analysis.[web:7][web:10]  
- Process automation fundamentals and data governance concepts.[web:5][web:10]

---

## 📝 Expected Deliverables

### Phase 1 – Cleaning

- Data quality assessment report  
- Cleaned datasets (CSV/Excel)  
- Cleaning scripts (SQL/Python)  
- Data dictionary  
- Transformation documentation

### Phase 2 – Analytics

- SQL queries for metrics  
- Views and/or stored procedures  
- ETL pipeline code  
- Data validation rules

### Phase 3 – Reporting

- Power BI dashboard (`.pbix`)  
- Dashboard documentation  
- User guide  
- Automated refresh setup

### Phase 4 – Insights

- Insights report  
- Recommendations document  
- Process improvement plan  
- ROI analysis outline[web:7][web:10]

---

## ⏱️ Suggested Timeline

| Scope                  | Estimated Hours | Focus Areas                                                                 |
|------------------------|-----------------|-----------------------------------------------------------------------------|
| Minimum Viable Project | 10–15           | Basic cleaning, core SQL queries, simple dashboard, light documentation     |
| Comprehensive Project  | 25–35           | Full cleaning, advanced SQL/ETL, complete dashboards, full documentation    |
| Portfolio-Ready        | 40–50           | Above plus automation, advanced analytics, polished presentation, case study[web:3][web:8] |

---

## 🤝 How to Use This Repo

- Clone the repo, work in feature branches, and document progress in commits and markdown notes.  
- Treat this as a full case study you can present to hiring managers for warehouse and transport analytics roles.[web:3][web:8]
