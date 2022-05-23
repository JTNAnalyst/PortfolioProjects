-- Followed Alex The Analyst Guide/Tutorial --> https://youtu.be/qfyynHBFOsM
-- SQL Data Exploration

Select *
From PortfolioProject..CovidDeaths
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Selecting data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Likelihood of dying if you contract covid in your country
Select Location, date, population, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select Location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group By location, population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By location
order by TotalDeathCount desc

-- Breaking down by Continent

--Select location, max(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
--Where continent is null
--Group By location
--order by TotalDeathCount desc

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
order by TotalDeathCount desc

-- Showing continents with highest death count

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint,vac.new_vaccinations)) /*cast works here too*/ OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--and dea.location like '%states%'
order by 2,3

-- USE CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint,vac.new_vaccinations)) /*cast works here too*/ OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--and dea.location like '%states%'
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population) *100 as PercentPeopleVaccinated
from PopvsVac

-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_Vaccinations bigint,
RollingPeopleVaccinated numeric

)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint,vac.new_vaccinations)) /*cast works here too*/ OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--and dea.location like '%states%'
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint,vac.new_vaccinations)) /*cast works here too*/ OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPeopleVaccinated
