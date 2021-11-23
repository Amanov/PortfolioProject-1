
SELECT *



SELECT *
from [Portfolio Projectt New21] ..CovidDeaths
where continent is not NULL
order by 3,4


--Select data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Projectt New21] ..CovidDeaths
where continent is not NULL
order by 1,2

--Looking at the Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Projectt New21] ..CovidDeaths
Where location like '%thailand%'
order by 1,2

-- Looking at the Total case vs Population
-- Show what Percentage of Population got Covid
Select Location, date, population, total_cases,  (total_cases/population)*100 as InfectedPercentage
from [Portfolio Projectt New21] ..CovidDeaths
Where location like '%kyrgyzstan%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Projectt New21] ..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projectt New21] ..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


--Let's break things down by continent
Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projectt New21] ..CovidDeaths
--Where location like '%states%'
Where continent is null 
Group by Location
order by TotalDeathCount desc

--Let's break things down by continent
Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projectt New21] ..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Projectt New21] ..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from [Portfolio Projectt New21] ..CovidDeaths
Where continent is not Null
Group by date
order by 1,2

--Global in total
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from [Portfolio Projectt New21] ..CovidDeaths
Where continent is not Null
--Group by date
order by 1,2

-- Vaccinations
Select * 
from [Portfolio Projectt New21] ..CovidDeaths

--Joining Two Tables
--Looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.location) as RollingVaccinations
--(RollingVaccinations/population)
--sum(convert(int, vac.new_vaccinations))
from [Portfolio Projectt New21] ..CovidDeaths dea
Join [Portfolio Projectt New21] ..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


--use CTE [Common Table Expression]

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingVaccinations)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
--(RollingVaccinations/population)
--sum(convert(int, vac.new_vaccinations))
from [Portfolio Projectt New21] ..CovidDeaths dea
Join [Portfolio Projectt New21] ..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)

Select *
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Projectt New21] ..CovidDeaths dea
Join [Portfolio Projectt New21] ..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinations
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Projectt New21] ..CovidDeaths dea
Join [Portfolio Projectt New21] ..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated