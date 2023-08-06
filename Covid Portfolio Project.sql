SELECT *
FROM CovidDeaths
ORDER BY 3, 4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

-- Comparing total_cases with total_deaths
-- Shows the likelihood of death in Canada if you contracted COVID-19

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location LIKE '%Canada%'
ORDER BY 1, 2

-- Looking at total_cases with populations
-- Shows the likelhood of contracting COVID-19

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM CovidDeaths
-- WHERE Location LIKE '%Canada%'
ORDER BY 1, 2	

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(CAST(total_cases AS int)) as HighestInfectionCount, MAX((total_cases/population))*100 AS HighestInfectionPercentage  
FROM CovidDeaths
-- WHERE Location LIKE '%Canada%'
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC
  
-- Looking at countries with highest death count per Population

SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidDeaths
WHERE location NOT LIKE '%income%' AND continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Looking at data by continent

-- Looking at continents with highest death count

SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidDeaths
WHERE location NOT LIKE '%income%' AND continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- GLOBAL NUMBERS 

SELECT SUM(new_cases) AS SumofCases, SUM(new_deaths) AS SumofDeaths,  SUM(new_deaths)/sum(nullif(new_cases,0))*100  AS DeathPercentage
FROM CovidDeaths    
-- WHERE Location LIKE '%Canada%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2


-- Vaccination Data

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.location ORDER by dea.location, dea.date) AS RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE to get PercentVaccinated
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.location ORDER by dea.location, dea.date) AS RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL -- AND dea.location = 'Canada'
-- ORDER BY 2, 3
)
SELECT *, (RollingVaccinationCount/Population) * 100 AS PercentofVaccinesperPerson
FROM PopvsVac

-- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.location ORDER by dea.location, dea.date) AS RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL -- AND dea.location = 'Canada'
-- ORDER BY 2, 3

SELECT *, (RollingVaccinationCount/Population) * 100 AS PercentofVaccinesperPerson
FROM #PercentPopulationVaccinated

-- Creating view to store data for visualization in BI software

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dea.location ORDER by dea.location, dea.date) AS RollingVaccinationCount
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL -- AND dea.location = 'Canada'
-- ORDER BY 2, 3 


