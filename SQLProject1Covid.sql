/*

Covid 19 Data Exploration
Skills used: Joins, CTEs, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types (Cast and Convert)

*/


--Selecting whole data

use CovidPortfolioProject
select *  from CovidPortfolioProject.dbo.CovidDeaths$
order by 3,4

select *  from CovidPortfolioProject.dbo.CovidVaccinations1$
order by 3,4


--Select data that is going to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
order by 1,2

--Total Cases vs Total Deaths in country "India"

Select Location, date, total_cases, total_deaths
From CovidDeaths$
Where location='India'
order by 1,2


--Shows likelihood of dying if you contract covid through column DeathPercentage

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location='India'
and Continent is not null
order by 1,2


--Total Cases vs Population
--Shows what percentage of population were infected with Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidPortfolioProject.dbo.CovidDeaths$
--Where location='India'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject.dbo.CovidDeaths$
--Where location='India'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(Cast(Total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths$
--Where location like '%India'
--Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths$
--Where location='India'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
--Where location='India'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalPeopleVaccinated
--, (RollingTotalPeopleVaccinated/population)*100
From CovidPortfolioProject..CovidDeaths$ dea
Join CovidPortfolioProject..CovidVaccinations1$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalPeopleVaccinated
--, (RollingTotalPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations1$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingTotalPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalPeopleVaccinated
--, (RollingTotalPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations1$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingTotalPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingTotalPeopleVaccinated
--, (RollingTotalPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations1$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated


