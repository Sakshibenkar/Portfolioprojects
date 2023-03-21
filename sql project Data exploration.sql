/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select *
from Porfolioproject..CovidDeaths$
where continent is not null
order by 3,4


--select *
--from Porfolioproject..CovidVaccinations$
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from Porfolioproject..CovidDeaths$
order by 1,2

--looking at total_cases vs total_deaths
--shows likelyhood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,  (total_deaths/total_cases)*100 as Deathpercentage
from Porfolioproject..CovidDeaths$
WHERE location = 'india'
order by 1,2

--looking at total_cases vs population
--shows what percentage of population got covid

select location,date,population,total_cases , (total_cases/population)*100 as percentpopulationinfected
from Porfolioproject..CovidDeaths$
--WHERE location = 'india'
order by 1,2

--looking for countries with highest infection rate compared to population

select location,population,max (total_cases) , max((total_cases/population))*100 as percentpopulationinfected
from Porfolioproject..CovidDeaths$
where continent is not null
group by location, population
order by percentpopulationinfected desc

--showing countries with highest death count per population

select location,max (cast (total_deaths as int)) as totaldeathcount
from Porfolioproject..CovidDeaths$  
where continent is not null
group by location
order by totaldeathcount desc

--LETS BREAK THINGS DOWN TO CONTINENT


--Showing continents with highest death count

select continent,max (cast (total_deaths as int)) as totaldeathcount
from Porfolioproject..CovidDeaths$  
where continent is not null
group by continent
order by totaldeathcount desc


--Global numbers

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Porfolioproject..CovidDeaths$
--WHERE location = 'india'
where continent is not null
group by date
order by 1,2


--looking at total populationvs total vaccination  

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,new_vaccinations))
over Partition by(dea.location order by dea.date,dea.location as rollingpepoplevaccinated
,--( rollingpeoplevaccinated/population) *100
from Porfolioproject..CovidDeaths$ dea
join porfolioproject..covidvaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--USE CTC


with PopvsVac (continent,location,date,population,new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over( Partition by dea.location order by dea.date,dea.location) as rollingpepoplevaccinated
--,( rollingpeoplevaccinated/population) *100
from Porfolioproject..CovidDeaths$ dea
join porfolioproject..covidvaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

select*, (Rollingpeoplevaccinated/population)*100
from PopvsVac



--TEMP TABLE

drop table if exists #PercentofPopulationVaccinated
Create table #PercentofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated Numeric
)

Insert into #PercentofPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over( Partition by dea.location order by dea.date,dea.location) as rollingpepoplevaccinated
--,( rollingpeoplevaccinated/population) *100
from Porfolioproject..CovidDeaths$ dea
join porfolioproject..covidvaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *,( rollingpeoplevaccinated/population)*100
from   #PercentofPopulationVaccinated 




-- Creating View to store data for later visualizations


Create View PercentofPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over( Partition by dea.location order by dea.date,dea.location) as rollingpepoplevaccinated
--,( rollingpeoplevaccinated/population) *100
from Porfolioproject..CovidDeaths$ dea
join porfolioproject..covidvaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select*
from percentofpopulationvaccinated





