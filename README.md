# End-to-End E-Commerce Analytics & BI Platform

## Overview

This project is a **production-style, end-to-end data analytics solution** built using the Brazilian Olist e-commerce dataset. It simulates how a data analyst supports business decision-making by transforming raw transactional data into **actionable insights and executive dashboards**.

The project focuses on solving core business problems across three critical areas:

- Product Performance & Catalog Efficiency  
- Customer Behavior & Revenue Distribution  
- Operations & Delivery Performance  

---

## Tech Stack

- **PostgreSQL** → Data modeling, transformation, and analytics  
- **Advanced SQL** → CTEs, window functions, aggregations, ranking, segmentation  
- **Power BI** → Interactive dashboards and data storytelling  
- **Olist Dataset** → Real-world e-commerce data  

---

## Data Architecture

A structured **analytics layer approach** was used to ensure scalability and clarity:

### Base Layer
Raw datasets:
- `orders_dataset`
- `order_items_dataset`
- `products_dataset`

---

### Transformation Layer (SQL Views)

Key analytical views:

#### `monthly_revenue`
- Time-series revenue analysis  
- Orders, items sold, and AOV  

#### `category_revenue`
- Category-level performance  
- Revenue contribution by month  

#### `product_performance`
- Product-level KPIs:
  - Revenue  
  - Orders  
  - Contribution %  
  - Revenue ranking  

#### `product_segmentation`
- Pareto-based segmentation:
  - Top performers (top 80% revenue)  
  - Mid performers (80–95%)  
  - Low performers  

#### `customer_performance`
- Customer-level revenue and order metrics  

#### `customer_spending_pattern`
- Quartile-based segmentation:
  - Top / High / Mid / Low spenders  

#### `delivery_performance`
- Operational KPIs:
  - Actual vs estimated delivery time  
  - Delivery delays  

---

## Key Insights

### Product & Catalog Insights
- Revenue is **highly concentrated** among a small subset of products  
- Over **60% of products generate minimal sales**  
- Strong **long-tail distribution** observed  

**Business Impact:**  
Significant opportunity to optimize catalog and reduce inefficiencies  

---

### Customer Behavior
- Majority of customers are **one-time buyers**  
- Extremely low repeat purchase rate  

**Business Impact:**  
Growth is driven by acquisition rather than retention  

---

### Customer Revenue Distribution
- Revenue is driven by **high-value transactions**, not frequency  
- Small subset of customers contributes disproportionately  

**Business Impact:**  
High-value customers are not being effectively retained  

---

### Operations & Delivery
- ~90% of orders are delivered **ahead of schedule**  
- Very low delay rate (~6–7%)  

**Business Impact:**  
Logistics performance is strong, but delivery estimates are overly conservative  

---

## Power BI Dashboards

A **multi-page, business-focused dashboard** was built:

### Executive Dashboard
- KPIs: Revenue, Orders, Customers, Products  
- Revenue trend analysis  
- Delivery performance overview  
- Catalog distribution  

---

### Product Analytics
- Top-performing products  
- Category revenue contribution  
- Product segmentation (Pareto analysis)  
- Demand vs revenue analysis  

---

### Customer & Operations
- Customer spending segmentation  
- Revenue distribution across customers  
- Delivery performance (early/on-time/late)  
- Operational efficiency metrics  

---

## Key Skills Demonstrated

- **Data Modeling & Transformation (SQL)**
- **Advanced SQL Techniques (Window Functions, CTEs, Ranking)**
- **Business-Oriented Data Analysis**
- **Data Cleaning & Handling Real-World Data Issues**
- **KPI Design & Analytical Thinking**
- **Dashboard Design & Data Visualization (Power BI)**
- **Insight Communication & Storytelling**

---

## Outcome

This project demonstrates the ability to:

- Design scalable analytical data models  
- Translate raw data into **business insights**  
- Identify inefficiencies and opportunities in operations and product strategy  
- Build **executive-level dashboards** for decision-making  

---

## Future Enhancements

- Customer cohort and retention analysis  
- Profitability analysis (cost vs revenue)  
- Regional delivery performance insights  
- Real-time data pipeline integration  

---


<img width="1212" height="682" alt="image" src="https://github.com/user-attachments/assets/e72def8c-ba0f-43fe-8362-c18f4567965e" />
<img width="1215" height="688" alt="image" src="https://github.com/user-attachments/assets/7d6fb38b-6616-41d4-a610-e4ad7c8ae1dc" />

