# SQL Data Warehouse Project

An end-to-end **SQL Data Warehouse** built using **SQL Server**, following a **Bronze → Silver → Gold** layered architecture.

---

## 🧱 Architecture

* **Bronze** – Raw data loaded from CSV files (no transformations)
* **Silver** – Cleaned, standardized, and deduplicated data
* **Gold** – Analytics-ready fact and dimension tables (star schema)

---

## 📊 Data Sources

* **CRM** – Customers, products, sales transactions
* **ERP** – Customer master, locations, product categories

---

## 🔄 ETL Highlights

* CSV ingestion using `BULK INSERT`
* Data cleansing (NULL handling, trimming, standardization)
* Deduplication using window functions
* Business-friendly transformations
* Idempotent loads using `TRUNCATE + INSERT`

---

## 📐 Data Model (Gold Layer)

* **fact_sales**
* **dim_customers**
* **dim_products**

---

## 🛠️ Tech Stack

* SQL Server (Docker / Local)
* T-SQL
* VS Code 
* Git & GitHub

---

## 📁 Repository Structure

```
├── datasets/      # Source CSV files
├── scripts/
│   ├── bronze/    # Raw data loads
│   ├── silver/    # Transformations
│   └── gold/      # Analytics models
├── docs/          # Diagrams & design docs
└── README.md
```
---





