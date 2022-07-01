select *
from CovidDeaths
order by 3,4

--select *
--from CovidVaccination
--order by 3,4

--seleccionar os dados a usar

select location, date, total_cases,new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--total_cases vs total_deaths
--Probabilidade de morrer se você contrair covid em seu país

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Angola%'
order by 1,2


--total_cases vs Population
--Percentagem de pessoas com covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths
--where location like '%Angola%'
order by 1,2


--Paises com maior taxa de infecção comparado a população

select location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
--where location like '%Angola%'
Group by location, Population
order by PercentagePopulationInfected Desc


--Paises com maior numero de Mortes

select location,  Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%Angola%'
where continent is not null
Group by location
order by TotalDeathCount Desc


--Continentes com maior numero de Mortes

select continent,  Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%Angola%'
where continent is not null
Group by continent
order by TotalDeathCount Desc


-- Numeros Globais

select Sum(new_cases) as NewCases, Sum(cast(new_deaths as int)) as NewDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%Angola%'
where continent is not null
--Group by date
order by 1,2


-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(convert(decimal,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from CovidDeaths as dea
Join CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%Angola%'
order by 2,3


-- Use CTE

with PopVsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(convert(decimal,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--,(rollingPeopleVaccinated/population)*100
from CovidDeaths as dea
Join CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100
from PopVsVac



-- TEMP TABLE

--Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(convert(decimal,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from CovidDeaths as dea
Join CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%Angola%'
order by 2,3

select *, (rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
order by 2,3



-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(convert(decimal,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from CovidDeaths as dea
Join CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%Angola%'
--order by 2,3

select *
from PercentPopulationVaccinated
