SELECT *
FROM PortfolioProject1..CovidDeaths
ORDER BY 3,4

ALTER TABLE CovidVaccinations
ALTER COLUMN human_development_index float; 

UPDATE PortfolioProject1..CovidVaccinations
SET human_development_index = NULLIF(human_development_index, ' ');

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject1..CovidDeaths

--Looking at total cases vs. total deaths
--Shows likelihood of dying from covid infection in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at total_cases vs. population
-- What percentage of population was infected with Covid
	
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS InfectedPopPercent
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
	
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS InfectedPopPercent
FROM PortfolioProject1..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPopPercent desc

-- Showing Countries w/ Highest Death Count per Population
	
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Break things down by continent!
	
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing continents w/ highest death count per population
	
SELECT continent, total_deaths, population, (total_deaths / population) AS DeathCountPerPop
FROM PortfolioProject1..CovidDeaths

-- GLOBAL NUMBERS

SELECT 
	-- date, 
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths, 
	SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2; 

-- Look at total population vs. vaccinations

SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRT
	--USE CTE
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

SELECT * 
FROM PortfolioProject1..CovidVaccinations

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinationRT)
AS 
	(
	SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRT
	--USE CTE
	FROM PortfolioProject1..CovidDeaths dea
	JOIN PortfolioProject1..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	)
SELECT *, (VaccinationRT / Population) * 100
FROM PopvsVac;

-- USE TEMP TABLE

DROP table if exists #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	VaccinationRT numeric
)

INSERT INTO #PercentPopVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRT
	--USE CTE
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
----WHERE dea.continent is not null

SELECT *, (VaccinationRT / Population) * 100
FROM #PercentPopVaccinated;

-- Creating View to store data for later visualiations

CREATE VIEW PercentPopVaccinated AS
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VaccinationRT
	--USE CTE
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3;
