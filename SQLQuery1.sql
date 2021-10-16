use coronadb

select location, date, total_cases, new_cases, total_deaths, population
from coviddeath
order by 1

--Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeath
where location like '%states%'

--Total Cases vs Population

select location, population, date, total_cases, (total_cases/population)*100 as DeathPercentage
from coviddeath
where location like 'india'
group by location,population
order by location asc

-- countries with highest infection rate compared to population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from coronaDB..coviddeath
--where location like '%state%'
group by location,population 
order by PercentPopulationInfected desc

--Countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeath
--where location = 'India'
where continent is null
group by location
order by TotalDeathCount desc

-- Breaking down by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeath
--where location = 'India'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select  sum(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from coronaDB..coviddeath
where continent is not null
--group by date
order by 1,2;

select * from covidvaccination as vac
join coviddeath as dea
on vac.location = dea.location
and vac.date = dea.date

---Total population vs vaccination

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeath as dea
join covidvaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * from popvsvac


--Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeath as dea
join covidvaccination as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--- Creating View for the stored procedure

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeath as dea
join covidvaccination as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated