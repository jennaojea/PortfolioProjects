SELECT *
FROM coviddeaths
ORDER BY 3,4;

SELECT *
FROM coviddeaths
WHERE continent is not null
ORDER BY 3,4;

SELECT *
FROM covidvaccinations
ORDER BY 3,4;

ALTER TABLE coviddeaths
RENAME COLUMN date to day;
ALTER TABLE covidvaccinations
RENAME COLUMN date to day;

-- Select Data that we are going to be using
SELECT Location, day, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,3;

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
SELECT Location, day, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE Location LIKE '%states%'
ORDER BY 1,3;

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got COVID
SELECT Location, day, Population, total_cases, (total_cases/Population)*100 AS InfectionRate
FROM coviddeaths
WHERE Location LIKE '%states%'
ORDER BY 1,3;

-- Looking at countries with highest Infection Rate compared to Population
SELECT Location,Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS InfectionRate
FROM coviddeaths
-- WHERE Location LIKE '%states%'
GROUP BY Location, Population
ORDER BY InfectionRate desc;


-- Showing Countries with highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths as FLOAT)) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY Location
Order by TotalDeathCount desc;

-- BREAKING DOWN BY CONTINENT
-- SELECT Location, MAX(CAST(total_deaths as FLOAT)) as TotalDeathCount
-- FROM coviddeaths
-- WHERE continent is null
-- GROUP BY Location
-- Order by TotalDeathCount desc;



-- Showing continents with the highest death count
SELECT Continent, MAX(CAST(total_deaths as FLOAT)) as TotalDeathCount
FROM coviddeaths
WHERE continent is not null
GROUP BY Continent
Order by TotalDeathCount desc;


-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent is not null
-- GROUP BY day
ORDER BY 1,3;

SELECT DISTINCT Location 
FROM coviddeaths;

-- Looking at Total Population vs. Vaccinatipon
SELECT dea.continent, dea.location, dea.day, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location ORDER BY dea.location, dea.day) AS RollingVaccineCount
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.Location = vac.Location
    AND dea.day = vac.day 
WHERE dea.continent is not null
ORDER BY 2,3;

-- USING CTE (Common Table Expression) to Show Percent of Population Vaccinated at any given time 
WITH PopvsVac(Continent, Location, day, Population, new_vaccinations, RollingVaccineCount)
AS
(
SELECT dea.continent, dea.location, dea.day, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location ORDER BY dea.location, dea.day) AS RollingVaccineCount
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.Location = vac.Location
    AND dea.day = vac.day 
WHERE dea.continent is not null
)
SELECT *, (RollingVaccineCount/Population)*100
FROM PopvsVac;

-- USING TEMP TABLE to Show Percent of Population Vaccinated at any given time 
-- CREATE TABLE #PercentPopulationVaccinated
-- (Continent nvarchar(255),
-- Location nvarchar(255), 
-- day string, 
-- Population numeric, 
-- new_vaccinations numeric, 
-- RollingVaccineCount numeric)
-- INSERT INTO #PercentPopulationVaccinated
-- SELECT dea.continent, dea.location, dea.day, dea.population, vac.new_vaccinations,
-- SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location ORDER BY dea.location, dea.day) AS RollingVaccineCount
-- FROM coviddeaths dea
-- JOIN covidvaccinations vac
	-- ON dea.Location = vac.Location
     -- AND dea.day = vac.day 
-- WHERE dea.continent is not null

-- SELECT *, (RollingVaccineCount/Population)*100
-- FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.day, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location ORDER BY dea.location, dea.day) AS RollingVaccineCount
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.Location = vac.Location
    AND dea.day = vac.day 
WHERE dea.continent is not null;
