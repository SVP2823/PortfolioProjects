Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3, 4

--Select *
--From PortfolioProject..Covidvaccinations
--Order by 3, 4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..CovidDeaths
	Order by 1, 2


--Looking at Total Cases vs Total Deaths 
--Shows the likelihood of dying from covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathRate
	From PortfolioProject..CovidDeaths
	Where location = 'United States'
	Order by 1, 2

--Looking at total cases vs population 
--Shows what percentage of Population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 As CovidRate
	From PortfolioProject..CovidDeaths
	Where location = 'United States'
	Order by 1, 2

-- Looking at countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 As InfectionRate
	From PortfolioProject..CovidDeaths
	Group by location, population
	order by InfectionRate desc

--Showing the countries with the highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by location, population
	Order by TotalDeathCount desc

-- Breaking things down by Continents

--total death county broken down by continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by continent
	Order by TotalDeathCount desc

--total infection rate broken down by continent
Select continent, MAX(cast (total_cases as int)) as HighestInfectionCount
	From PortfolioProject..CovidDeaths
	where continent is not null
	Group by continent 
	order by HighestInfectionCount desc

--Global Numbers

--Cases and deaths globally by date
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 As DeathRate
	From PortfolioProject..CovidDeaths
	--Where location = 'United States'
	where continent is not null
	Group by date
	Order by 1, 2

--Overall totals worldwide
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 As DeathRate
	From PortfolioProject..CovidDeaths
	--Where location = 'United States'
	where continent is not null

--Looking at Total Population vs Vaccinations	
--With rolling count of new vaccinations total
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
	SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date)
		as RollingCountVaccinated
From PortfolioProject..CovidDeaths as Deaths
Join PortfolioProject..Covidvaccinations as Vacc
	ON deaths.location = vacc.location
	and deaths.date = vacc.date
Where deaths.continent is not null
Order by 2,3

--USE CTE 

WITH PopVsVacc (Continent, Location, Date, Population, new_vaccinations, RollingCountVaccinated)
	As (
		Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
			SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date)
			as RollingCountVaccinated
		From PortfolioProject..CovidDeaths as Deaths
			Join PortfolioProject..Covidvaccinations as Vacc
			ON deaths.location = vacc.location
			and deaths.date = vacc.date
		Where deaths.continent is not null
		--Order by 2,3 
		--(can't be used in here)
		)
Select *, (RollingCountVaccinated/Population)*100 As PercentVaccinated
From PopVsVacc

--USE Temp Table
Drop table is exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(250),
	Location nvarchar(250),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingCountVaccinated numeric
	)
	Insert into #PercentPopulationVaccinated
		Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
				SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date)
				as RollingCountVaccinated
			From PortfolioProject..CovidDeaths as Deaths
				Join PortfolioProject..Covidvaccinations as Vacc
				ON deaths.location = vacc.location
				and deaths.date = vacc.date
			Where deaths.continent is not null

Select *, (RollingCountVaccinated/Population)*100 As PercentVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Use PortfolioProject
Go
Create View PercetPopulationVaccinated As
	Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
				SUM(Cast(vacc.new_vaccinations as int)) OVER (Partition by deaths.location Order by deaths.location, deaths.date)
				as RollingCountVaccinated
			From PortfolioProject..CovidDeaths as Deaths
				Join PortfolioProject..Covidvaccinations as Vacc
				ON deaths.location = vacc.location
				and deaths.date = vacc.date
			Where deaths.continent is not null

drop view [PercetPopulationVaccinated]
			