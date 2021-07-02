
select *
from PortfolioProject_Covid..covid_deaths

-- Select data that we are going to be using

select location, date, total_Cases, new_Cases, total_deaths, population
from PortfolioProject_Covid..covid_deaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths in United States
-- Shows the liklehood of dying if you contract Covid-19

select location, date, total_Cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject_Covid..covid_deaths
where continent is not null
order by 1,2

select location, date, total_Cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject_Covid..covid_deaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population in United States

select location, date, total_Cases, population, (total_deaths/population)*100 as PercentPopulationInfected
from PortfolioProject_Covid..covid_deaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject_Covid..covid_deaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject_Covid..covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc


-- Let's break the above data by continent
-- Showing the continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject_Covid..covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

-- Overall across the world

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as DeathPercentage
from PortfolioProject_Covid..covid_deaths
where continent is not null
order by 1,2


-- Total Cases vs Total Deaths by day

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) * 100 as DeathPercentage
from PortfolioProject_Covid..covid_deaths
where continent is not null
group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject_Covid..covid_deaths dea
join PortfolioProject_Covid..covid_vaccinations vac
	on (dea.location = vac.location
	and dea.date = vac.date)
where dea.continent is not null
order by 2,3


-- USE CTE to get Rolling percetage of people vaccinated

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject_Covid..covid_deaths dea
join PortfolioProject_Covid..covid_vaccinations vac
	on (dea.location = vac.location
	and dea.date = vac.date)
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- USE TEMP TABLE, let's try the same as above

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject_Covid..covid_deaths dea
join PortfolioProject_Covid..covid_vaccinations vac
	on (dea.location = vac.location
	and dea.date = vac.date)
where dea.continent is not null


select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



-- Creating view to store data

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject_Covid..covid_deaths dea
join PortfolioProject_Covid..covid_vaccinations vac
	on (dea.location = vac.location
	and dea.date = vac.date)
where dea.continent is not null


select * from PortfolioProject_Covid..PercentPopulationVaccinated