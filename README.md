# lmwn_ae_exam

This repository contains the solution for the **Analytics Engineering Exam** from a food delivery platform company.  
The objective is to build a modular and scalable data model using `dbt` and `DuckDB`, and generate multiple reports for business use cases.

---

## 🛠 Tools Used

- [dbt](https://www.getdbt.com/) — data modeling and transformation
- [DuckDB](https://duckdb.org/) — in-process SQL OLAP database
- Git + GitHub — version control
- Visual Studio Code — development environment

---

## 🧱 Project Structure

The data model follows a **modular layered structure**:

- `model_stg_*` → **Staging Layer** (cleaned raw data)
- `model_int_*` → **Intermediate Layer** (business logic / joins / calculations)
- `model_mart_*` → **Data Marts** for reporting
- `report_*` → Final report outputs written into `ae_exam_db.duckdb`

All models use the naming convention: `model_<layer>_<name>`  
Final reports use: `report_<report_name>`

---

## 📊 Reports Created

1. **Fleet Management**
   - `report_driver_performance`
   - `report_delivery_zone_heatmap`
   - `report_driver_incentive_impact`

2. **Customer Service**
   - `report_complaint_summary_dashboard`
   - `report_driver_related_complaints`
   - `report_restaurant_quality_complaints`

3. **Performance Marketing**
   - `report_campaign_effectiveness`
   - `report_customer_acquisition`

---

## 📁 Output File

All models and reports are written into:
