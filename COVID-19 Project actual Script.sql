

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

--Looking at Total cases vs Total Deaths
--Shows likelihood of dyin if you  contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%India%' 
and continent is not null
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
and continent is not null
order by 1,2

--Looking at the Total cases vs Population
--Shows What percentatage of population got Covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as CovidInfectedPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%' and continent is not null
order by 1,2

--Looking at Countries with Highest Infection rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location,population
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT


--showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc
--above approach is not perfect as north america only showing data of US



Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group By date
order by 1,2

--without group by date query
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
order by 1,2

--Joining both the tables and 
---Looking at Total Population vs Vaccination

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--sum of new vaccination

--Looking at Total Population vs Vaccinations

Select distinct dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
 -- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select distinct dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
 -- ,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
     On dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
 -- ,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

----------------------------------------------

---Creating View To tstore data for later visualizations
DROP View If Exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
  dea.Date) as RollingPeopleVaccinated
 -- ,
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
--------------------------------------------

Select * 
From PercentPopulationVaccinated
