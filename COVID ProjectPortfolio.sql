Select *
From CovidDeaths
order by 1, 2

--Select data we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1, 2

--looking at Total cases v Total Deaths
-- Shows likelihood of dying if you contract Covid in your country (United Kingdom)
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'United Kingdom'
order by 1, 2

--Looking at Total Cases v Population
-- Shows what percentage of population got Covid
Select Location, Date, total_cases,Population, (total_deaths/Population)*100 as CovidInfectdPercentage
From CovidDeaths
Where location = 'United Kingdom'
order by 1, 2

-- Looking at countries with highest infection rate compared to Population

Select Location, Population, MAX (total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as Maxinfectionpercentage
From CovidDeaths
Group By location, population
order by Maxinfectionpercentage desc

--Showing Countries with Highest Death count per population

 Select Location, MAX (total_deaths) as TotalDeatchCount
From CovidDeaths
Group By location
order by TotalDeatchCount desc

--Total_deaths data is varcchar (255) and not an int, so data returned is not accurate, so :

Select Location, MAX (Cast(total_deaths as int)) as TotalDeatchCount
From CovidDeaths
Group By location
order by TotalDeatchCount desc

--Data exploration- The previous command returned locations such as World, AFrica and  North America, giving the total of the whole continent rather than the country.
--went to the original dataset and found where continent is Null the location would be a continent:

Select Location, MAX (Cast(total_deaths as int)) as TotalDeatchCount
From CovidDeaths
Where continent is not null
Group By location
order by TotalDeatchCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT(ACCURATE CONTINENT TOTAL)
--Contninents with highest death count

Select location, MAX (Cast(total_deaths as int)) as TotalDeatchCount
From CovidDeaths
Where continent is null
Group By location
order by TotalDeatchCount desc


--GLOBAL NUMBERS 

--BY TOTAL deaths spanning from JAN 2020- APRIL 2021
--new_deaths is varchar (255) hence, Cast

Select sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From CovidDeaths
where continent is not null 
--group by date
order by 1, 2

--BY DATE
Select date, sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From CovidDeaths
where continent is not null 
Group by date
order by 1, 2


--Looking at Total Population v Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,deat.date) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--To get the percentage we need to divide the (RollingPeopleVaccinated/population)*100 But we cant do that with a column name we just created(RollingPeopleVaccinated)
--USE CTE

With PopvsVac (continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



--USE TEMP

cREATE TABLE #PercentPopulationVaccinated
(
Contnient nvarchar(255),
Location nvarchar (255),
Date datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
 
--To Amend

Drop table if exists #PercentPopulationVaccinated
cREATE TABLE #PercentPopulationVaccinated
(
Contnient nvarchar(255),
Location nvarchar (255),
Date datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.Location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Create view for later vizualisation

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From CovidDeaths dea 
Join CovidVaccinations vac
	on dea.Location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

 
