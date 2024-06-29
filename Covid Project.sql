
-- Select Data that we are oing to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows liklihood of dying if you contract covid in your country 
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPrentage
from PortfolioProject..CovidDeaths$ 
where location like '%saudi%'
order by 1,2

-- looking at total cases vs population
select location,date, Population, total_cases,(total_cases/Population)*100 as PrecentPopulationInfected
from PortfolioProject..CovidDeaths$ 
where location like '%saudi%'
order by 1,2
-- Looking at countries with highest infection rate compared to Population
select location,Population, MAX(total_cases) AS HighestInfectionCount ,MAX(total_cases/Population)*100 as PrecentPopulationInfected
from PortfolioProject..CovidDeaths$ 
group by Population,location
order by PrecentPopulationInfected desc

-- Showing countries with highest Death count per population 
select location, MAX(cast(total_deaths as int)) AS TotalDeaths
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by location
order by TotalDeaths desc

--	BREAK THINGS DOWN BY CONTINENT 
-- SHOWING THE CONTINENT WIHT THE HIGHEST DEATH COUNT PER POPULATION
select continent, MAX(cast(total_deaths as int)) AS TotalDeaths
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by continent
order by TotalDeaths desc

-- GLOBAL NUMBERS by date 
select date,SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int))as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPrentage
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by date
order by 1,2
-- global numbers 
select SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPrentage
from PortfolioProject..CovidDeaths$ 
where continent is not null
order by 1,2


-- looking at total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use cte 
With PopvsVac  (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$  dea
join PortfolioProject..CovidVaccinations$  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Creating a View for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$  dea
join PortfolioProject..CovidVaccinations$  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null