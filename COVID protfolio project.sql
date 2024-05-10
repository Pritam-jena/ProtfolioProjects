select *
from ProtfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from ProtfolioProject..CovidVaccinations
--order by 3,4

-- select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from ProtfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from ProtfolioProject..CovidDeaths
where location like '%india%'
order by 1,2


-- looking at the total cases vs population
--shows what percentage of population got Covid

select location, date, population, total_cases,  (total_cases/population)*100 as CovidCasePercentage
from ProtfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
order by 1,2


--looking at countries with hightes infection rate compare to population

select location, population, max(total_cases) as HighestInfectionCount,  (max(total_cases)/population)*100 as PercentPopulationInfected
from ProtfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc


--showing the country with highest death count per population

select location, population, max(cast(total_deaths as int)) as HighestDeathCount, (max(total_deaths)/population)*100 as percenPopulationDied
from ProtfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
group by location,population
order by HighestDeathCount desc


--let's break things bown by continent

select location, max(cast(total_deaths as int)) as TotalDeathCount
from ProtfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


--Showing the same thing with respest to the total population along with the total death count.
select continent , 
case
	when continent ='Asia' or 
	continent = 'Europe' or
	continent ='North America' or
	continent = 'South America' or 
	continent = 'Africa' or 
	continent = 'oceania' then sum(population)
end as TotalPopulation,
case
	when continent ='Asia' or 
	continent = 'Europe' or
	continent ='North America' or
	continent = 'South America' or 
	continent = 'Africa' or 
	continent = 'oceania' then sum(cast(total_deaths as int))
end as TotalDeathCounts
from ProtfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
group by continent
order by TotalDeathCounts desc


--showing the continents with highest death count per populaition

select  continent, max(cast(total_deaths as int)) as TotalDeathCount
from ProtfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBER

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
from ProtfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

-- showing global total case and total death
select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
from ProtfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


-- loking total population vs vacctinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--use CTE
--here it will show the rolling percentage
with PopvsVac (continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- to show particular percentage accroding to the locations

with PopvsVac2 (continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, 
(max(RollingPeoplevaccinated) over (partition by location)/population)*100 as PercentVaccinated
from PopvsVac2



--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacctinations numeric,
RollingpeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, 
(max(RollingPeoplevaccinated) over (partition by location)/population)*100 as PercentVaccinated
from #PercentPopulationVaccinated



--creating view to store data for later visualtization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, 
(max(RollingPeoplevaccinated) over (partition by location)/population)*100 as PercentVaccinated
from PercentPopulationVaccinated