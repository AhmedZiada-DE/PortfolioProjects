SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4
--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Select Data that we are going to use
Select Location , date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Total cases vs total deaths
--Shows the likelihood of death in case of infection

Select Location , date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%' and continent is not null
order by 1,2


--Looking at Total cases vs Population
--Showing Total cases against population
--Shows what percentage of population has gotten Covid.

Select Location , date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location like '%states%' and continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location , population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Group by Location,population
order by PercentPopulationInfected DESC


--Showing Countries with the Highest Death Count Per Population


Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount DESC


--Showing Continents with the Highest Death Count Per Population


--Select location, Max(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
----Where Location like '%states%'
--Where continent is null
--Group by location
--order by TotalDeathCount DESC

--Wrong way but for learning

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount DESC



--Global Numbers Per Day


Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%' 
where continent is not null
Group by date
order by 1,2


--Global Numbers of the Overall Cases and Deaths

Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER 
 (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER 
 (Partition by dea.location order by dea.location, dea.date) as Num_of_Vaccinated_People

From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER 
 (Partition by dea.location order by dea.location, dea.date) as Num_of_Vaccinated_People

From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create View to store data for later Visualizations

Drop View if exists PercentPopulationVaccinated;

USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER 
 (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..CovidVaccinations  vac
	On dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

/*

--Queries Used  in Tableau

--1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- 2 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

*/