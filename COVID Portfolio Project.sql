	/****** Script for SelectTopNRows command from SSMS  ******/
	--SELECT  *
	--  FROM [PortfolioProject].[dbo].[CovidVaccinations]
	--Where continent IS NOT NULL
	--  ORDER BY 3,4 

	--SELECT  *
	--FROM [PortfolioProject]..coviddeath
	--ORDER BY 3,4 

	--Select Data we are going to be using

	SELECT  Location, date, total_cases,new_cases, total_deaths, population
	FROM PortfolioProject..coviddeath
	ORDER BY 1,2

	--Looking at Total Case vs Total Deaths
	--Showing Likely of dying if you contract covid in your country

	SELECT  Location, date, total_cases, total_deaths, Round((total_deaths/total_cases) * 100 , 2) AS 'Death Percentage'
	FROM PortfolioProject..coviddeath 
	WHERE location LIKE '%Nigeria%'
	--Where continent IS NOT NULL
	ORDER BY 1,2

	--Looking at Total case vs Population
	--Shows what percentage of population got covid 

	SELECT  Location, date, Population,total_cases, (total_cases/population) * 100  AS 'Percent of Population Infected'
	FROM PortfolioProject..coviddeath 
	--WHERE location LIKE '%Nigeria%'
	ORDER BY 1,2

	--Looking at Countries with Highest Infection Rate compared to Population 

	SELECT  Location, Population,  MAX (total_cases) AS 'Highest Infection Count' , Max((total_cases/population)) * 100  AS 'Percent of Population Infected'
	FROM PortfolioProject..coviddeath 
	--WHERE location LIKE '%Nigeria%'
	GROUP BY location, population
	ORDER BY  [Percent of Population Infected]  DESC


	--Showing Countries with Highest Death Count per Population

	SELECT  Location,  MAX (CAST (total_deaths AS int)) AS 'Total Death Counts' 
	FROM PortfolioProject..coviddeath
	Where continent IS NOT NULL
	GROUP BY location
	ORDER BY  [Total Death Counts]  DESC



	--Break down by continent 

	--Showing continent with the highest death counts per population 

	SELECT continent, MAX (CAST (total_deaths AS int)) AS 'Total Death Counts' 
	FROM PortfolioProject..coviddeath
	Where continent IS NOT NULL
	GROUP BY continent
	ORDER BY  [Total Death Counts]  DESC

  
	--Showing total_cases and total_death per day

	SELECT  date, SUM (new_cases) AS 'Total Cases' , SUM( CAST (new_deaths AS int)) AS 'Total Deaths' ,  SUM( CAST (new_deaths AS int)) / SUM (new_cases) *100 AS   'Death Percentage'
	FROM PortfolioProject..coviddeath 
	Where continent IS NOT NULL
	GROUP BY date
	ORDER BY 1,2


	-- Global 

		SELECT SUM (new_cases) AS 'Total Cases' , SUM( CAST (new_deaths AS int)) AS 'Total Deaths' ,  SUM( CAST (new_deaths AS int)) / SUM (new_cases) *100 AS   'Death Percentage'
	FROM PortfolioProject..coviddeath 
	Where continent IS NOT NULL
	ORDER BY 1,2

	--Joning the two tables together
	-- Looking at total population vs vaccinations 

	SELECT 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM (CONVERT (int, vac.new_vaccinations)) OVER  ( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'RollingPeopleVaccinated'
	FROM PortfolioProject..coviddeath dea
	JOIN PortfolioProject..CovidVaccinations  vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3

	--Creating Temp Table

	DROP TABLE IF EXISTS #percentpopulationvacinated
	CREATE TABLE #percentpopulationvacinated
	(
	continent nvarchar(255),
	location  nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
	INSERT into #percentpopulationvacinated
	SELECT 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM (CONVERT (int, vac.new_vaccinations)) OVER  ( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'RollingPeopleVaccinated'
	FROM PortfolioProject..coviddeath dea
	JOIN PortfolioProject..CovidVaccinations  vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	--WHERE dea.continent IS NOT NULL
		SELECT *, (RollingPeopleVaccinated/population) * 100
	FROM #percentpopulationvacinated

	--Creating views to store data for later visualizations

	CREATE VIEW percentpopulationvacinated 
	AS SELECT 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM (CONVERT (int, vac.new_vaccinations)) OVER  ( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'RollingPeopleVaccinated'
	FROM PortfolioProject..coviddeath dea
	JOIN PortfolioProject..CovidVaccinations  vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL