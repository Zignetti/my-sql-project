

# 🌍 Demographic & Economic Patterns in Global Cities
## Table of Contents
- [Overview](#overview)
- [Objectives](#-objectives)
- [Data Preparation & Cleaning](#%EF%B8%8F-data-preparation--cleaning)
- [Data Integration](#data-integration)
- [Analysis & Results](#analysis--results)
- [Key Learnings Points](#key-learnings-points)
- [Summary](#-summary)
- [Assumptions](#-assumptions)
- [Recommendations & Next Steps](#recommendations--next-steps)
- [Limitations](#-limitations)

---  
# Overview
A full-cycle SQL project that stages, cleans, and analyzes data from the `world` database. 
The workflow focuses on city and country-level insights, such as district populations, 
global life expectancy patterns, and population distribution.

---

## 📌 Objectives

- Explore and stage `city` and `country` tables
- Clean distorted and missing data
- Engineer relevant features for analysis
- Join datasets for district-country correlations
- Analyze:
  - Top 5 most populous districts
  - Life expectancy vs GNP correlation
  - Continental life expectancy differences
  - Population scale against global average

---

## 🏗️ Data Preparation & Cleaning

### 🔹 City Table (`city_staging`)

- Duplicate the `city` table for safe cleaning
- Check dimensions:
  - ✅ 5 columns
  - ✅ 4079 rows → cleaned to 4075
- Fix inconsistencies:
  - Replaced distorted names (`[San Cristóbal de] la Laguna`)
  - Filled missing `district` values (IDs: 129, 61, 62)
- Renamed `Population` → `districtPopulation`
- Verified no nulls across all key columns

### 🔹 Country Table (`country_staging`)

- Dropped irrelevant columns:
  - `region`, `surfacearea`, `governmentform`, `headofstate`, `code2`
- Identified and resolved missing values:
  - ❌ Dropped 17 records with null `lifeexpectancy`
  - 🛠️ Replaced null `capital` with mean value: **2053.17**
- Renamed `name` → `contryName` for clarity

---

## 🔗 Data Integration

Created a combined dataset:
```sql
SELECT *
FROM city_staging ct
JOIN country_staging cy
ON ct.countrycode = cy.code;
```

- Resulting in a unified view across districts and country features.

---

## Analysis & Results

### 📊 Analysis Highlights

#### 📍 Top 5 Most Populous District

```sql
    SELECT district, SUM(districtpopulation) AS total_population
    FROM combined_table
    GROUP BY district
    ORDER BY total_population DESC
    LIMIT 5;
```

#### Top Districts:
- São Paulo – 26,316,966
- Maharashtra – 23,659,433
- England – 19,978,543
- Punjab – 19,708,438
- California – 16,716,706

#### 💡 Correlation: Life Expectancy vs GNP
 ``` sql
    SELECT (...) AS correlation
    FROM combined_table;
```

- Correlation Coefficient: 0.4262
- Indicates a moderate positive relationship — wealthier countries tend to have longer life expectancies.

### 🧬 Life Expectancy Insights
- Calculated global average: @avg_lifeexp
- Compared by continent and country
- 🔝 Europe leads with average 83.5 years, followed by Asia at 81.6years
  
#### Example:
```sql
    SELECT contryName, lifeexpectancy
    FROM combined_table
    WHERE continent = 'Europe'
    ORDER BY lifeexpectancy DESC
    LIMIT 5;
```

#### 📍 Andorra shines with one of the highest life expectancies globally (~84 years)

### 🌐 Population Analysis
- Calculated global population average: @avg_population
- Identified countries exceeding it

```sql
    SELECT contryName, population, (@avg_population) AS avg_world_population,
       (population/@avg_population)*100 AS percentageOfWorld
    FROM combined_table
    WHERE population > @avg_population
    ORDER BY population DESC;
```

#### 📈 China exceeds the global average by 465%

---

### 🧠 Key Learning points
- Structured staging allows safe and scalable cleaning.
- Correlation analysis in SQL requires careful calculation.
- Feature engineering and missing value treatment are essential for trustworthy insights.
- SQL can be used for statistical investigation with creativity and rigor.


### ✅ Summary
This SQL-driven analysis illustrates how staging, cleaning, and integrating datasets enables meaningful insights. 
From correlation to population breakdown, each query contributes to a rich understanding of global demographics.
Notably, the data highlights São Paulo, Maharashtra, England, Punjab, and California as the five most populous 
districts worldwide. It also reveals that life expectancy tends to be higher in Europe compared to other regions, 
while China continues to hold its position as the most populous country on the planet.

### ⚖️ Assumptions
- City populations represent latest available figures in the database.
- GNP and LifeExpectancy data are aligned by country code and assumed to be contemporaneous.
- Aggregates exclude countries with missing data to avoid skew.

### 💡 Recommendations & Next Steps

- 📈 Add visualizations (heatmaps, scatter plots) via BI tools or Python.
- 🔁 Integrate with time-series datasets to explore trends over decades.
- 📚 Expand to include education, infrastructure, or environmental factors for richer multidimensional analysis.

### 🚧 Limitations
- 📅 No date stamps—cannot evaluate time trends or causality.
- 🗺️ Data may lack full global coverage (e.g., underrepresentation of smaller nations or territories).
