# Project Documentation

## Overview
This project analyzes food delivery data for marketing performance, fleet management, and customer service operations.

## Model Layers

### Staging
Raw data cleaning and standardization for downstream use.

### Intermediate
Joins and transformations across multiple sources to create reusable aggregates.

### Mart
Business-level KPIs and metrics based on domain context.

### Report
Final report-level tables used directly in dashboards.

---

## Key Models

### model_stg_order_transactions
- Cleans raw order transactions.
- Ensures `order_id`, `customer_id`, and `order_status` are not null.
- Used as base for delivery performance and complaints metrics.

### model_int_order_delivery_summary
- Aggregates delivery performance by order.
- Used in driver and zone performance metrics.

### model_mart_driver_performance
- Shows summary metrics of driver performance.
- Joined with driver master for ratings, incentives, and CSAT.

---

## Test Strategy
- `not_null`, `unique`, `relationships` in `schema.yml`
- Custom test SQL for additional logic

