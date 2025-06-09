# lmwn_ae_exam

This project is a submission for the Analytics Engineering Exam by **LINE MAN Wongnai**, aiming to build a scalable data model with **dbt** and **DuckDB**, and deliver reports for multiple business use cases.

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

1.**Performance Marketing**
   - `report_campaign_effectiveness`
   - `report_customer_acquisition`
   - `report_retargeting_performance`
2. **Fleet Management**
   - `report_driver_performance`
   - `report_delivery_zone_heatmap`
   - `report_driver_incentive_impact`

3. **Customer Service**
   - `report_complaint_summary_dashboard`
   - `report_driver_related_complaints`
   - `report_restaurant_quality_complaints`

---

## 📁 Output File

All models and reports are written into:
