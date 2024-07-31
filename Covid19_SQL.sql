SELECT *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

----select * 
---from PortfolioProject..CovidVaccinations
---order by 3,4


---select data that we re going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


---Looking at Total Cases vs Total Deaths
----shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 asc


----Looking at the total cases vs the population
----shows what % of population got covid
select location, date, population, total_cases, (total_cases / NULLIF(population, 0)) * 100 AS PopulationPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 asc


---What country has the highest infection rate vs Population
select location, population, MAX(total_cases) as highestInfection, MAX(total_cases / NULLIF(population, 0)) * 100 AS PopulationPercentage
from PortfolioProject..CovidDeaths
Group by location, population
order by 4 DESC



---Showing countries with highest deathcount Population
select continent, MAX(total_deaths) as highestdeaths
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by 2 DESC



---Showing the continent with the highest death count
select continent, MAX(total_deaths) as highestdeaths
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by 2 DESC



---Global number
select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,  (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY DATE 
order by 1,2


---Looking at total population vs vacinations
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS total_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


---Use CTE
With PopVsVac(continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
from PopVsVac



---Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



---Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint, ISNULL(vac.new_vaccinations, 0))) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



Select * 
from PercentPopulationVaccinated