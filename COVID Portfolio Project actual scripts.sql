select *
from CovidDeaths
where continent is not null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--Select the Data that we are going to be using

select location, date, total_cases, new_cases,
total_deaths, population
from CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying
-- if you contract covid in your country

select location, date, total_cases, 
total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'israel'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, population, 
(total_cases/population)*100 as percentagePopulationInfected
from CovidDeaths
where location like 'israel'
order by 1,2

-- Looking at Countries with highest
--Infection Rate compared to Population

select location, population, max(total_cases) as highest,
max(total_cases/population)*100 as 
percentagePopulationInfected
from CovidDeaths
group by location, population
order by 4 desc

-- Showing Countries with Highest Death
-- Count per Population

select location, max(cast(total_deaths as int))
as totalDeathCount
from CovidDeaths
where continent is not null
group by location
order by 2 desc

-- Let's BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the highest
-- death count per population

select location, max(cast(total_deaths as int))
as totalDeathCount
from CovidDeaths
where continent is null
group by location
order by 2 desc

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Looking at Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and 
	   dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

with PopvsVac (continent, location, date, population,
new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and 
	   dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and 
	   dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and 
	   dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated