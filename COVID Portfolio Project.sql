
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4
--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in yout country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%uruguay%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%uruguay%'
Where continent is not null
order by 1,2

--Looking at Countries with Higest Infection Rate comparate to Population

Select Location, MAX(total_cases) as HigestInfectionCount, population, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%uruguay%'
Where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc

--Showing countries with the Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%uruguay%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Showing continent with the Highest Death Count per Population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%uruguay%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM (new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Death, SUM (cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%uruguay%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
    On vac.location = dea.location
    and vac.date = dea.date 
where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
    On vac.location = dea.location
    and vac.date = dea.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
    On vac.location = dea.location
    and vac.date = dea.date 
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating  View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidVaccinations vac
Join PortfolioProject..CovidDeaths dea
    On vac.location = dea.location
    and vac.date = dea.date 
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated