# Aircraft Performance Database ✈️  


This project transforms a raw dataset of aircraft specifications into a fully normalized (2NF) relational database. Using ETL (Extract, Transform, Load) techniques, it cleans noisy strings, separates composite units (e.g., ft/in), and builds structured lookup tables for companies, engine types, and aircraft models. Advanced SQL views and procedures generate performance metrics, rankings, and insights for pilots and engineers.

---
![aircraft-db (1)](https://github.com/user-attachments/assets/82748436-a682-49c6-bbbe-b2acae5d98f7)

## 🚀 Features

- **ETL Workflow**  
  - Created a staging table  from raw CSV data.  
  - Layered **Regex cleaning** to remove noise.  
  - Normalized data and cleared composite fields.

- **2NF Relational Schema**  
  - Separated lookup tables: `companies`, `engine_types`, and `aircraft_models`.  
  - Fact table `aircraft_specs` with foreign key references.

- **Analytical Queries**  
  - Stored procedures to retrieve the fastest models.  
  - Views for performance metrics such as **power-to-weight ratios** and **prop vs. jet stats**.  
  - Aircraft ranking by speed, range, and weight using **RANK()** and **ROW_NUMBER()**.

- **Pilot Recommendations**  
  - Compatibility table mapping aircraft to **Student**, **Private**, and **Commercial** pilot levels based on speed and weight limits.

---

## 🧱 Technologies Used

- **MySQL 8.0** (with analytic window functions)  
- **ETL techniques** (staging, transformation, normalization)  
- **Regex and substring parsing** for complex text cleaning  

---





