CREATE DATABASE Project_Covid

-- Sử dụng DataBase
USE Project_Covid

-- SỬ DỤNG TABLE
SELECT * FROM CovidDeaths
SELECT * FROM CovidVaccinations



-- CHỌN NHỮNG CỘT CẦN SỬ DỤNG
SELECT location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population 
FROM CovidDeaths
ORDER BY 1,2


-- TỶ LỆ TỬ VONG CỦA CÁC QUỐC GIA SO VỚI SỐ CA MẮC BỆNH Ở QUỐC GIA ĐÓ
SELECT LOCATION,
       total_cases,
       total_deaths,
       (total_deaths/total_cases) * 100 AS DeathsPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;


-- TỶ LỆ MẮC BỆNH TẠI CÁC QUỐC GIA SO VỚI DOANH SỐ Ở QUỐC GIA ĐÓ
SELECT LOCATION,
       population,
       total_cases,
       (total_cases /population) * 100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL;


-- TỶ LỆ MẮC BỆNH CAO NHẤT Ở CÁC QUỐC GIA SO VỚI DOANH SỐ Ở QUỐC GIA ĐÓ
SELECT LOCATION,
       population,
       MAX(Total_Cases) AS HighestInfectionCount,
       (MAX(total_cases)/population) * 100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION,
         population
ORDER BY PercentagePopulationInfected DESC;


-- SỐ CA TỬ VONG CAO NHẤT CỦA CÁC QUỐC GIA  
SELECT LOCATION,
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC;


-- TỔNG SỐ CA TỬ VONG CỦA CÁC LỤC ĐỊA
SELECT continent,
       MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- TỶ LỆ TỬ VONG TRÊN TOÀN THẾ GIỚI SO VỚI SỐ CA MẮC
SELECT SUM(new_cases) AS Total_Cases,
       SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
       SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;


/*SỬ DỤNG CTE VÀ TEMP TABLE ĐỂ DỄ DÀNG TÍNH TOÁN TỶ LỆ TIÊM CHỦNG CỦA CÁC QUỐC GIA SO VỚI DOANH SỐ CỦA HỌ */
--Sử dụng CTE 
WITH Total_Vaccination (continent, LOCATION, population,date,new_cases, new_vaccinations, RollingPeopleVaccinated) AS (
SELECT cd.continent,
       cd.location,
       cd.population,
       cd.date,
       cd.new_cases,
       cv.new_vaccinations,
       SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS cd
INNER JOIN CovidVaccinations AS cv ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS PercentagePopulationVacinated FROM Total_Vaccination
ORDER BY  location,date;


-- Sử dụng Temp Table
CREATE TABLE #PercentagePopulationVacinated (continent NVARCHAR(255), LOCATION NVARCHAR(255), Population NUMERIC, date DATETIME, new_cases INT, new_vaccinations INT, RollingPeopleVaccinated NUMERIC)
INSERT INTO #PercentagePopulationVacinated
SELECT cd.continent,
       cd.location,
       cd.population,
       cd.date,
       cd.new_cases,
       cv.new_vaccinations,
       SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS cd
INNER JOIN CovidVaccinations AS cv ON cd.location = cv.location
AND cd.date = cv.date
SELECT *,(RollingPeopleVaccinated * 100.0 / Population)
FROM #PercentagePopulationVacinated;


-- Tạo bảng view để trực quan 
CREATE VIEW PercentagePopulationVacinated AS
SELECT cd.continent,
       cd.location,
       cd.population,
       cd.date,
       cd.new_cases,
       cv.new_vaccinations,
       SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location
                                                   ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS cd
INNER JOIN CovidVaccinations AS cv ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL