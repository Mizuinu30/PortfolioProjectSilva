SELECT *
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 3,4

 ---Select Data We are going to be using

 SELECT Location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2


 -- Looking at Total Cases vs Total Deaths
 -- Shows likelyhood of dying if you contract covid in your country

 SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths
 --WHERE location like'%dominican%'
 WHERE continent is not null
 ORDER BY 1,2

 --Looking at the Total Cases vs Population

 SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths 
 WHERE continent is not null AND location like'%dominican%'
 ORDER BY 1,2

 --Looking at Countries with Highest Infection Rate compared to Population

 SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS
 PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths
 --WHERE location like'%dominican%'
 WHERE continent is not null
 Group BY Location, Population
 ORDER BY PercentPopulationInfected DESC


 --Showing Countries with Highest Death Count per Population

 SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 --WHERE location like'%dominican%'
 WHERE continent is not null
 Group BY Location
 ORDER BY TotalDeathCount DESC


 ---LET'S BREAK THINGS DOWN BY CONTINENT

  --Showing the continents with the highest deathcount

 SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 --WHERE location like'%dominican%'
 WHERE continent is not null
 Group BY continent
 ORDER BY TotalDeathCount DESC



 --GLOBAL NUMBERS

SELECT  date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Percentage
 FROM PortfolioProject..CovidDeaths
 --WHERE location like'%dominican%'
 WHERE continent is not null
 GROUP BY date
 ORDER BY 1,2

 

 -- Total Number of cases World Wide
 
SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Percentage
 FROM PortfolioProject..CovidDeaths
 --WHERE location like'%dominican%'
 WHERE continent is not null
 ORDER BY 1,2

-- Join the 2 tables CovidDeaths and CovidVaccinations
 SELECT *
 FROM PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
       ON dea.location = vac.location
	   and dea.date = vac.date

--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



WITH  PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
       ON dea.location = vac.location
	   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeoplevaccinated/Population)*100
FROM PopvsVac



--TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)




INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
       ON dea.location = vac.location
	   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *, (RollingPeoplevaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Dropping TEMP TABLE


DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)




INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
       ON dea.location = vac.location
	   and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *, (RollingPeoplevaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store sdata for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
       ON dea.location = vac.location
	   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT*
FROM PercentPopulationVaccinated