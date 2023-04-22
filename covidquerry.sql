Select*
From 
PortfolioProject..CovidDeaths$
where continent is not null and location is not null
order by 3,4

--Select * 
--From 
--PortfolioProject..CovidVac$
--Where continent is not null
--Order by 3, 4

-- select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2


-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying from covid in nigeria  
Select location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float)) as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Nigeria%'
and continent is not null
order by 1,2 


--Looking at Total cases vs Population
-- what percentage of population got covid
Select location, date, population,total_cases,(cast(total_cases as float) / population)* 100 as PercPerPop
From PortfolioProject..CovidDeaths$
Where continent is not null
-- Where location like '%Nigeria%'
order by 1,2 

-- looking at countries with Highest Infection Rate compared to population
Select location, population,max(total_cases) as HighestInfectionCount ,(Max(cast(total_cases as float)) / population)* 100 as PercentageofPopulationInfect
From PortfolioProject..CovidDeaths$
-- Where location like '%Nigeria%'
Where continent is not null
Group by location, population
order by PercentageofPopulationInfect desc

-- Death count per population
Select location, MAX(cast(total_deaths as int)) as TotaldeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotaldeathCount desc

-- breaking by continent

-- continent by totaldeath 
Select continent, MAX(cast(total_deaths as int)) as TotaldeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null 
Group by continent
order by TotaldeathCount desc


-- Global numbers 
--Set ARITHABORT OFF
--SET ANSI_WARNINGS OFF
Select date, sum(cast(new_cases as float)) as total_cases,sum(cast(new_deaths as float)) as total_deaths,
CASE 
	WHEN sum(cast(new_cases as float)) = 0
	THEN NULL 
	else sum(cast(new_deaths as float)) / sum(cast(new_cases as float))*100 
	End as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null and new_cases is not null and new_deaths is not null
Group by date 
order by 1,2 


Select sum(cast(new_cases as float)) as total_cases,sum(cast(new_deaths as float)) as total_deaths,
CASE 
	WHEN sum(cast(new_cases as float)) = 0
	THEN NULL 
	else sum(cast(new_deaths as float)) / sum(cast(new_cases as float))*100 
	End as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null and new_cases is not null and new_deaths is not null 
order by 1,2 

-- looking at total population vs vaccinations 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) Over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVac$ vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use cte 
with PopvsVac (Continent, Location,Date, Population,new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) Over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVac$ vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2  ,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
 
 Drop table if exists #PercentPopulationVaccinated
 create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric 
 )

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) Over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVac$ vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2  ,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as float)) Over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVac$ vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null

-- Tablaeu prompts 
--1

Select sum(cast(new_cases as float)) as total_cases,sum(cast(new_deaths as float)) as total_deaths,
CASE 
	WHEN sum(cast(new_cases as float)) = 0
	THEN NULL 
	else sum(cast(new_deaths as float)) / sum(cast(new_cases as float))*100 
	End as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
Where continent is not null and new_cases is not null and new_deaths is not null
--Group by date 
order by 1,2 


--2 

select location, sum(cast(new_deaths as float)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%nigeria%'
where continent is null and location not in ('world', 'European Union') and location not like '%income%'
Group by location 
order by TotalDeathCount desc

-- 3
select location, population, max(cast(total_cases as float)) as HighestInfectionCount, 
Max((cast(total_cases as float)/population))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths$
--where location like '%nigeria%'
Group by location, population 
order by PercentPopulationInfected desc


--4
select location, population, date, max(cast(total_cases as float)) as HighestInfectionCount, 
Max((cast(total_cases as float)/population))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths$
--where location like '%nigeria%'
Group by location, population, date
order by PercentPopulationInfected desc

