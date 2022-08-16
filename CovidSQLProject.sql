-- SELECTING THE DATA THAT WE ARE GOING TO USE

SELECT
	location, date, total_cases, new_cases, total_deaths, population
FROM
	PortfolioProject..CovidDeaths

SELECT
	*
FROM
	PortfolioProject..CovidDeaths

SELECT
	*
FROM
	PortfolioProject..CovidVaccinations


-- LOOKING AT TOTAL CASES VS POPULATION
-- SHOWS PERCENTAGE OF POPULATION WHO GOT COVID IN U.S.

SELECT
	location, date, total_cases, population, (total_cases/population) * 100 AS Covid_Cases_Percent
FROM
	PortfolioProject..CovidDeaths
WHERE
	location LIKE '%states%'
ORDER BY 1,2


-- LOOKING AT COUNTRY WITH HIGHEST INFECTIONS RATE COMPARED TO POPULATIONS

SELECT
	location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population)) * 100 AS Infection_Rate
FROM
	PortfolioProject..CovidDeaths
GROUP BY
	location, population
ORDER BY Infection_Rate DESC

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN U.S.

SELECT
	location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	location LIKE '%states%'
ORDER BY 1,2


-- GLOBAL NUMBERS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID AROUND THE GLOBE

SELECT
	location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 1,2

-- TOTAL DEATHS VS TOTAL CASES GLOBALLY
SELECT
	SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS Death_Percentage 
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 1,2


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT 

SELECT
	location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY Total_Death_Count DESC


-- SHOWING COUNTRIES WITH HIGHEST DEATH RATE COMPARED TO POPULATIONS

SELECT
	location, population, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count, MAX((total_deaths/population)) * 100 AS Death_Rate
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location, population
ORDER BY Death_Rate DESC


-- LET'S BREAK THINGS DOWN BY CONTINENTS

-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER LOCATION

SELECT
	location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY Total_Death_Count DESC


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

WITH 
	PopvsVac(continent, location, date, population, new_vaccinations, Num_getting_vaccinated)
AS
(
SELECT
	CD.continent, CD.location, CD.date,CD.population, CV.new_vaccinations,
	SUM(CAST(CV.new_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Num_getting_vaccinated
FROM
	PortfolioProject..CovidDeaths CD
JOIN
	PortfolioProject..CovidVaccinations CV
ON
	CD.location = CV.location
AND
	CD.date = CV.date
WHERE
	CD.continent IS NOT NULL
	)
SELECT 
	*, (Num_getting_vaccinated/population) * 100 AS Vaccinated_Percent
FROM
	PopvsVac

-- TEMP TABLE FOR TOTAL POPULATIONS VS VACCINATIONS

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR (255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
Num_getting_vaccinated NUMERIC
)

INSERT INTO 
	#PercentPopulationVaccinated
SELECT
	CD.continent, CD.location, CD.date,CD.population, CV.new_vaccinations,
	SUM(CAST(CV.new_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Num_getting_vaccinated
FROM
	Portfolio_Project..CovidDeaths CD
JOIN
	Portfolio_Project..CovidVaccinations CV
ON
	CD.location = CV.location
AND
	CD.date = CV.date
WHERE
	CD.continent IS NOT NULL

SELECT 
	*, (Num_getting_vaccinated/population) * 100 AS Vaccinated_Percent
FROM
	#PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR VISUALIZATIONS 

-- TOTAL POPULATION VS VACCINATION
CREATE VIEW Percent_Population_Vaccinated AS
SELECT
	CD.continent, CD.location, CD.date,CD.population, CV.new_vaccinations,
	SUM(CAST(CV.new_vaccinations AS BIGINT)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Num_getting_vaccinated
FROM
	PortfolioProject..CovidDeaths CD
JOIN
	PortfolioProject..CovidVaccinations CV
ON
	CD.location = CV.location
AND
	CD.date = CV.date
WHERE
	CD.continent IS NOT NULL

SELECT 
	*
FROM 
	Percent_Population_Vaccinated
ORDER BY 1,2,3

-- 
