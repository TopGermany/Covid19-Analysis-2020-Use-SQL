# 🦠 COVID-19 Data Analysis (SQL Project)

## 📌 Introduction  
This project focuses on **analyzing COVID-19 data using SQL**.  
Main objectives:  
- Calculate the death rate compared to total cases.  
- Analyze infection rate relative to population in each country.  
- Compare the impact of COVID-19 across countries and continents.  
- Provide a global overview of the pandemic.  

## 📂 Dataset  
- Table used: **CovidDeaths**  
- Key columns:  
  - `location` (country/territory)  
  - `continent` (continent)  
  - `date` (recorded date)  
  - `total_cases` (total confirmed cases)  
  - `new_cases` (new daily cases)  
  - `total_deaths` (total confirmed deaths)  
  - `new_deaths` (new daily deaths)  
  - `population` (population of the country)  

## 🛠️ Tools  
**Excel** (Data Cleaning)

- **SQL Server** (Used to query data and perform in-depth SQL analysis)  

## 🚀 SQL Queries  

### 1. Death rate per country compared to total cases  
```sql
SELECT LOCATION,
       total_cases,
       total_deaths,
       (total_deaths/total_cases) * 100 AS DeathsPercentage
FROM CovidDeaths
ORDER BY 2,3;
```
- Purpose: To calculate the total number of cases, deaths, and death percentage for each country.

- Result: Countries with higher death rates can be identified and compared.


### 2. Infection rate per country compared to population
```sql
SELECT LOCATION,
       population,
       total_cases,
       (total_cases / population) * 100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL;
```

- Purpose: To determine what percentage of the population was infected in each country.

- Result: Shows the spread of COVID-19 across different populations.

### 3. Countries with the highest infection rate compared to population
```sql
SELECT LOCATION,
       population,
       MAX(total_cases) AS HighestInfectionCount,
       (MAX(total_cases)/population) * 100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION, population
ORDER BY PercentagePopulationInfected DESC;
```

- Purpose: To identify countries with the highest infection count relative to their population.

- Result: Provides a ranking of countries most impacted by COVID-19 in terms of infection rate.

### 4. Countries with the highest number of deaths
```sql
SELECT LOCATION,
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC;
```

- Purpose: To find out which countries recorded the highest number of deaths.

- Result: Shows countries with the largest death toll during the pandemic.

### 5. Total deaths by continent
```sql
SELECT continent,
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
```

- Purpose: To calculate the cumulative deaths for each continent.

- Result: Provides a comparison between continents to see which regions were most affected.

### 6. Global death rate compared to total cases
```sql
SELECT SUM(new_cases) AS Total_Cases,
       SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
       SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;
```

- Purpose: To analyze the global death rate relative to confirmed cases.

vResult: Provides the overall mortality rate of COVID-19 worldwide.

### 7. Vaccination progress by country (rolling calculation)  
```sql
WITH Total_Vaccination (continent, LOCATION, population, date, new_cases, new_vaccinations, RollingPeopleVaccinated) AS (
    SELECT cd.continent,
           cd.location,
           cd.population,
           cd.date,
           cd.new_cases,
           cv.new_vaccinations,
           SUM(CONVERT(INT, cv.new_vaccinations)) 
               OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
    FROM CovidDeaths AS cd
    INNER JOIN CovidVaccinations AS cv 
           ON cd.location = cv.location
          AND cd.date = cv.date
    WHERE cd.continent IS NOT NULL 
)
SELECT *,
       (RollingPeopleVaccinated/population)*100 AS PercentagePopulationVacinated
FROM Total_Vaccination
ORDER BY location, date;
```

- Purpose: To calculate the cumulative number of vaccinated people per country and compare it with the total population.

- Result: Shows vaccination progress over time, with the percentage of the population vaccinated in each country.

📊 Conclusion

This SQL-based analysis provides insights into:

Mortality rates by country and globally.

Infection percentages relative to population.

Comparative impacts across countries and continents.

