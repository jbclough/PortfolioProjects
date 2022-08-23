SELECT *
FROM PortfolioProject..CovidDeaths
--WHERE continent IS NOT NULL
ORDER BY location, date;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY location, date;

--select the date that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

--Looking at total cases vs total deaths
--Shows likelihood of  dying if you contract covid in your country
SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE'%Canada%'
ORDER BY location, date 

--Looking at total cases vs population
--shows % of population that got covid

SELECT
	Location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE'%Canada%'
ORDER BY location, date 

--what countries have highest infection count vs. pop

SELECT
	Location,
	population,
	MAX(total_cases) AS MaxInfectionCount,
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--what countries have highest death count vs. pop

SELECT
	Location,
	MAX(CAST(total_deaths AS INT)) AS MaxDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeathCount DESC

--break down by continent

SELECT
	location,
	MAX(CAST(total_deaths AS INT)) AS MaxDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY MaxDeathCount DESC

--showing continents with highest death count

SELECT
	location,
	MAX(CAST(total_deaths AS INT)) AS MaxDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY MaxDeathCount DESC

--global numbers

SELECT
	date,
	SUM(new_cases) AS TotalDailyCases,
	SUM(CAST(new_deaths AS INT)) AS TotalDailyDeaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at total pop. vs vaccinations

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
	)

INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

--Bonus tables

--diabetes prevalance (vax table) vs deaths - ideally scatter plot

SELECT
	dea.location
	MAX(CONVERT(DECIMAL(6,2),dea.total_deaths_per_million)) AS TotalDeathsPM,
	MAX(vac.diabetes_prevalence) AS DiabetesPrevalence
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.iso_code = vac.iso_code
WHERE dea.continent IS NOT NULL
AND dea.total_deaths_per_million IS NOT NULL
GROUP BY dea.location
ORDER BY DiabetesPrevalence DESC 

--human development index (vax table) vs infections



--population density (vax table) vs reproduction rate

SELECT 
	dea.Location,
	MAX(dea.reproduction_rate) AS reproduction_rate,
	MAX(vac.population_density) AS pop_density
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
WHERE dea.continent IS NOT NULL 
AND dea.reproduction_rate IS NOT NULL
GROUP BY dea.location
ORDER BY pop_density DESC


