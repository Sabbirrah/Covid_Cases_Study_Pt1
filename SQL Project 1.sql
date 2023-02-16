-- Checking the tables ater connecting them to the server 

select *
From PortfolioProject1..CovidDeaths
Order by 3,4

--select *
--From PortfolioProject1..CovidVaccinations
--Order by 3,4


-- Select Data that we are going to be using 

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Order by 1,2


-- Total Cases vs Total Death
-- Shows the possibility of dying if you contract covid in different country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percrntage
From PortfolioProject1..CovidDeaths
Where Location like '%bangla%'
order by 1,2


-- Querying  Total Cases vs Population
-- Shows what percentage of population is contaminated with Covid 

Select Location, Date, population, total_cases, (total_cases/population)*100 as Contamination_Percrntage
From PortfolioProject1..CovidDeaths
--Where Location like '%states%'
order by 1,2


-- Querying countries with Highest Infection Rate Compared to Population 

Select Location, population, MAX(total_cases) as Highest_Infected_Country, MAX((total_cases/population))*100 as Percentage_Population_Infected
From PortfolioProject1..CovidDeaths
--Where Location like '%states%'
Group by Location, Population
order by Percentage_Population_Infected desc


--Querying Countries with Death per Populations

Select Location, MAX(Cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject1..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group by Location
order by Total_Death_Count desc


-- Querying Continet With Highest Death Count per Population

Select continent, MAX(Cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject1..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group by continent
order by Total_Death_Count desc


-- Global Numbers (Aggregation Fuction)

Select Date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage 
From PortfolioProject1..CovidDeaths
--Where Location like '%bangla%'
Where continent is not null 
--Group by date
order by 1,2


-- Global Numbers by Date

Select Date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage 
From PortfolioProject1..CovidDeaths
--Where Location like '%bangla%'
Where continent is not null 
Group by date
order by 1,2


-- Joining the Tables 

Select * 
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Querying Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null 
	order by 2,3


-- Querying Total Population vs Vaccination with "Rolling count" (Converting format)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_count_of_people_vaccinated
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null 
	order by 2,3


-- Querying Total Population vs Vaccination (using Common Table Expression (CTE))

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_count_of_people_vaccinated
--, (Rolling_count_of_people_vaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null 
	order by 2,3


-- Query does not work without using Common Table Expression (CTE)

with PopvsVac (Continent, Location,Date, Populations ,New_vaccinations, Rolling_count_of_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_count_of_people_vaccinated
--, (Rolling_count_of_people_vaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null 
	)

Select *, (Rolling_count_of_people_vaccinated/Populations)*100
From PopvsVac


-- Query does not work without or using TEMPORARY Table (TEMP TABLE)

Drop  table if exists #Percentage_Population_vaccinated --( Is good to have in case of alteration in the code) 
Create table #Percentage_Population_vaccinated
(
Continet nvarchar(255), 
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinantion numeric,
Rolling_count_of_people_vaccinated numeric,
)

Insert into #Percentage_Population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_count_of_people_vaccinated
--, (Rolling_count_of_people_vaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null 
	order by 2,3

Select *, (Rolling_count_of_people_vaccinated/Population)*100
From #Percentage_Population_vaccinated


-- Creating view to store data for visualisation

Create View Percentage_Population_vaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location Order by dea.location, dea.date) as Rolling_count_of_people_vaccinated

From PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null 	