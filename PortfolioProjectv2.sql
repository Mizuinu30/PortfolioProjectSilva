SELECT *
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 3,4

 ---Select Data we are going to be using

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


--Creating view to store data for later visualizations

CREATE VIEW DeathPercentage AS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
Group By date
--order by 1,2

CREATE VIEW TotalDeathCount AS

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
--order by TotalDeathCount desc

CREATE VIEW PercentPopulationInfected AS
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
--order by PercentPopulationInfected desc



CREATE VIEW PercentPopulationInfected2 AS
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
--order by PercentPopulationInfected desc

CREATE VIEW RollingPeopleVaccinated AS


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac
