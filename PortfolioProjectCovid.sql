Select *
From PortfolioProjectCovid.dbo.CovidDeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProjectCovid.dbo.CovidVaccinations
Where continent is not null
order by 3,4

-- Data that will be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
order by 1,2

-- Total cases vs Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProjectCovid..CovidDeaths
Where location = 'Malaysia' and continent is not null
order by 1,2

-- Total cases vs Population

Select location, date,population, total_cases, (total_cases/population)*100 as covid_percentage
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
--Where location = 'Malaysia'
order by 1,2

-- countries with highest infection rate compared to population

Select location,population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentage_population_infected
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by location, population
order by 4 desc

-- countries with highest death count

Select location, Max(cast(total_deaths as int)) as total_deaths_count
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by location
order by 2 desc

-- total death count by continent (assuming location <> continent)

With CTE_MaxCountryDeaths as
(Select continent,location, Max(cast(total_deaths as int)) as total_deaths_count
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by continent,location
)
Select continent, sum(total_deaths_count)
From CTE_MaxCountryDeaths
Group by continent
order by 2 desc

-- total death count by continent 

Select location, Max(cast(total_deaths as int)) as total_deaths_count
From PortfolioProjectCovid..CovidDeaths
Where continent is null and location NOT IN ('World', 'International')
Group by location
order by 2 desc

-- highest death in continent by countries

Select continent, Max(cast(total_deaths as int)) as total_deaths_count
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by continent
order by 2 desc

-- Global numbers

Select date, sum(new_cases) as global_daily_cases, sum(cast(new_deaths as int)) as global_daily_death, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
From PortfolioProjectCovid..CovidDeaths
where continent is not null
Group by date
order by 1

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
From PortfolioProjectCovid..CovidDeaths
where continent is not null
order by 1

-- Total population vs vaccinations (CTE)

With population_vaccinated (continent, location, date, population, new_vaccinations, rolling_vaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
Over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
Select *, (rolling_vaccinated/population)*100 as percentage_vaccinated
From population_vaccinated

-- Total population vs vaccinations (Temp Table)

Drop table if exists #table_population_vaccinated
Create table #table_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinated numeric
)

Insert into #table_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
Over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select *
From #table_population_vaccinated

Select *, (rolling_vaccinated/population)*100 as percentage_vaccinated
From #table_population_vaccinated

-- view for visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
Over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinated
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid.dbo.CovidVaccinations vac
On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated

