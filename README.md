# DEPI Online Store – SQL Project

## 📌 Overview
This repository contains the SQL deliverables for the **DEPI Online Store Data Analysis Project**, part of the **Digital Egypt Pioneers Initiative (DEPI)**.  
As the SQL team, our main responsibility is to prepare database queries and views that answer the business-critical questions requested by the Board of Directors.

---

## 🎯 Objectives
- Build clean and reusable **SQL Views** for each KPI required by stakeholders.  
- Use **MySQL (Workbench 8.40)** to aggregate and analyze e-commerce data.  
- Support further steps of the workflow:  
  - Power Query (data import & cleaning)  
  - Power Pivot (star schema modeling)  
  - Excel (visualization & storytelling)  

---

## 📂 Scope of Work (SQL Team)
Our focus is on **Steps 1 & 2** of the workflow:
1. **Analyzing the data** in MySQL (sessions, orders, revenue, refunds, products, customers).  
2. **Building SQL Views** for each KPI required by stakeholders.  

The views will later be imported into Power Query and used for dashboards in Excel.

---

## 👥 Team Members
- **Mustafa Elshafey** (Team Leader)  
- Asmaa Saber  
- Yassin Osama  
- Yomna Khaled
- Riham Salah  

---

## 🏢 Stakeholders, KPIs & SQL Tasks
### CEO (Growth & Strategy)
- KPIs: Sessions, Orders, Revenue, Net Revenue, Conversion Rate (CVR), Revenue per Session (RPS), Average Order Value (AOV)  
- SQL Tasks: Aggregate sessions/orders, join orders to sessions, compute revenue & refunds  

### CFO (Financial Health & Profitability)
- KPIs: Revenue, Gross Margin, AOV, Refund %  
- SQL Tasks: Analyze refunds, compute margins  

### CMO (Marketing & Acquisition)
- KPIs: Sessions & Orders by Channel/Device, CVR, RPC, RPS, New vs Repeat Customers  
- SQL Tasks: Segment traffic by UTM and device, analyze new vs repeat  

### COO (Operations & Scalability)
- KPIs: Seasonality (monthly/weekly), Daily/Hourly traffic, Refund Rates by Product  
- SQL Tasks: Date-based aggregations, supplier quality check  

### Website Performance Manager
- KPIs: Top Pages, Entry Pages, Bounce Rates, Funnel Conversion %  
- SQL Tasks: Identify entry pages, calculate bounce, build funnel  

### Head of Customer Experience
- KPIs: Repeat vs New Customers (sessions, orders, revenue), Loyalty metrics (days between visits)  
- SQL Tasks: Use repeat flag, calculate DATEDIFF, compare repeat vs new  

### Head of Product
- KPIs: Orders, Revenue, Margin by Product, Conversion Funnels  
- SQL Tasks: Join orders with products, build product-level funnels, analyze cross-sell  

### Investor Relations
- KPIs: Growth over 3 years, Efficiency gains, Channel diversification, Product portfolio impact  
- SQL Tasks: Consolidate results across directors  

---

## 📂 Repository Structure
/tasks
/CEO
/CFO
/CMO
/COO
/WebsitePerformance
/CustomerExperience
/Product
/InvestorRelations
/docs
project_guide.md
data_dictionary.md (optional)
/scripts
common_queries.sql
helpers.sql


---

## 🚀 Workflow  
1. Each stakeholder has a dedicated folder under `/tasks`.  
   - Example: `/tasks/CEO`, `/tasks/CFO`, `/tasks/CMO`, `/tasks/COO`  
2. Inside each folder, there is **one `.sql` file** that contains all KPIs/queries for that stakeholder.  
   - Example: `ceo_kpis.sql`, `cfo_kpis.sql`  
3. Each member works on their own **branch**, then submits a Pull Request with updates to their stakeholder’s `.sql` file.  
4. Team Leader reviews and merges into the `main` branch.  


---

## 📄 License
This project is for **educational purposes only** as part of the DEPI Initiative.
