# SQL_ETL_Datawarehouse
# 🧱 Data Warehouse Project: ETL Pipeline with Bronze, Silver, Gold Layers

## 📌 Overview
This project showcases a fully developed SQL-based ETL pipeline, structured across Bronze (raw ingestion), Silver (data cleaning), and Gold (business-ready modeling) layers. It is designed to demonstrate scalable data architecture, logical transformations, and analytical precision.

## 🎯 Objectives
- Ingest and standardize raw CRM and ERP datasets
- Apply cleansing logic to build refined Silver layer tables
- Create star schema models in the Gold layer for KPI tracking and reporting
- Document ETL logic, schemas, and design decisions

## 🧠 Technologies Used
- SQL Server
- Draw.io (for data model diagrams)
- GitHub (version control)
- VS Code  (development environment)

## 🛠️ Layer Structure

### 🔹 Bronze Layer
Raw data ingestion, unmodified structure  
Example: `crm_sales_raw.sql`, `erp_product_raw.sql`

### 🔸 Silver Layer
Data cleaning, formatting, null handling, filters  
Example: `clean_crm_sales.sql`, `clean_customer.sql`

### 🥇 Gold Layer
Dimensional modeling, business logic, aggregated KPIs  
Example: `dim_customers.sql`, `fact_sales_summary.sql`, reporting views

 
