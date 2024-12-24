select* from 
PortfolioProjects..CovidDeaths
where continent is not NULL
order by 3,4

select* from 
PortfolioProjects..CovidVaccinations
where continent is not NULL
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProjects..CovidDeaths
where continent is not NULL
order by 1,2

--Looking at Total cases vs Total Deaths(Death Percentage)
--Showing the probability of Dying from Covid in your country..

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 DeathPercentage
from PortfolioProjects..CovidDeaths
where location='India' and continent is not NULL
order by DeathPercentage desc

--Looking at Total Cases vs Population
--Showing the Likelihood of COVID-19 Infection in Your Country..

select location,date,population,total_cases,(total_cases/population)*100 InfectionProbability
from PortfolioProjects..CovidDeaths
where location='India' and continent is not NULL
order by 2,5 desc

--Looking at countries with highest Infection rate compared to population

select location,population,Max(total_cases) HighestInfectionCount,(Max(total_cases)/population)*100 InfectedPopulation
from PortfolioProjects..CovidDeaths
where continent is not NULL
group by location,population
order by InfectedPopulation desc

--Showing Countries with Highest Death Rate compared to population

select location,population,Max(cast(total_deaths as int)) HighestDeathCount,(Max(total_deaths)/population)*100 DeadPopulation
from PortfolioProjects..CovidDeaths
where continent is not NULL
group by location,population
order by HighestDeathCount desc

--Now let's take a look at continents
--Continents with Highest death count

select continent,Max(cast(total_deaths as int)) HighestDeathCount,max(total_deaths/population)*100 DeadPopulation
from PortfolioProjects..CovidDeaths
where continent is not NULL
group by continent
order by HighestDeathCount desc

--Globally data on different dates

select date,sum(new_cases) Total_Cases,sum(cast(new_deaths as int)) Total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null 
group by date
order by 1

--Global value
select sum(new_cases) Total_Cases,sum(cast(new_deaths as int)) Total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null 
order by 1

--Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where vac.continent is not NULL and dea.continent is not NULL
order by 1,2,3

--Data of People Rolling down for vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) RollingDownVaccination
from PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where vac.continent is not NULL and dea.continent is not NULL

--We will use CTE for calculating the percentage of population getting vaccinated

with PopVsVac (Continent,Location,date,population,new_vaccinations,RollingDownVaccinations)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingDownVaccination 
from PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where vac.continent is not NULL and dea.continent is not NULL
)
select Continent,Location,date,population,new_vaccinations,RollingDownVaccinations,(RollingDownVaccinations/population)*100 VaccniationPercent
from PopVsVac

--We will use temp table for calculating the percentage of population getting vaccinated

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(Continent varchar(100),Location varchar(100),date datetime,population numeric,new_vaccinations numeric,RollingDownVaccinations numeric)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingDownVaccination 
from PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where vac.continent is not NULL and dea.continent is not NULL

select Continent,Location,date,population,new_vaccinations,RollingDownVaccinations,(RollingDownVaccinations/population)*100 VaccniationPercent
from #PercentPopulationVaccinated

--Creating View

create view PercentPopulationVaccinated
as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingDownVaccination 
from PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where vac.continent is not NULL and dea.continent is not NULL

--We can now use view directly for viewing a particular set of data 

select* from PercentPopulationVaccinated