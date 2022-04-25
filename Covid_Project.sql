-- Looking at Total Cases vs. Total Deaths
SELECT 
	location,
	date,
	total_cases,
	total_deaths,
	population,
	(total_deaths/total_cases) *100 AS percentage_of_deaths 
FROM
	Portofolio..Covid_Deaths
WHERE
	location like '%states%'
AND
	continent IS NOT null
ORDER BY
 location, date

-- Looking at Total Cases vs. Population
SELECT 
	location,
	date,
	total_cases,
	population,
	(total_cases/population) *100 AS percentage_of_cases 
FROM
	Portofolio..Covid_Deaths
WHERE
	location like '%ypt%'
AND
	continent IS NOT null
ORDER BY
 location, date

-- Lookint at countries with highest infection rates compared to population
SELECT 
	location,
	population,
	MAX(total_cases) AS highest_infected_cases,
	MAX((total_deaths/population)*100) AS percentage_of_poulation_infected
FROM
	Portofolio..Covid_Deaths
WHERE
	continent IS NOT null
GROUP BY
	location,
	population
ORDER BY
	percentage_of_poulation_infected DESC

-- Showing countries with highest Death Count per Population
SELECT 
	location,
	population,
	MAX(CAST(total_deaths AS int)) AS highest_deaths_count,
	MAX((total_deaths/population)*100) AS percentage_of_deaths 
FROM
	Portofolio..Covid_Deaths
WHERE
	continent IS NOT null
GROUP BY
	location,
	population
ORDER BY
	highest_deaths_count DESC
	
-- Showing continents with highest Death Count per Population
SELECT 
	continent,
	MAX(CAST(total_deaths AS int)) AS highest_deaths_count
FROM
	Portofolio..Covid_Deaths
WHERE
	continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	highest_deaths_count DESC
-- Percentage of deaths in new cases
SELECT
	SUM(new_cases) AS world_new_cases,
	SUM(CAST(new_deaths AS int)) AS world_new_deaths,
	SUM(CAST(new_deaths AS int))/ SUM(new_cases) * 100 AS world_percnet_of_deaths
FROM
	Portofolio..Covid_Deaths
WHERE
	continent IS NOT NULL
GROUP BY
	date
ORDER BY
	date

-- Calculating the cumulative number of vaccinated people 
SELECT
	dea.date,
	dea.location,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,new_vaccinations))
OVER
	(PARTITION BY dea.location ORDER BY dea.date,dea.location) AS total_vaccination --To add up to the total vaccination instead of giving number per each day
FROM
	Portofolio..Covid_Deaths dea
FULL OUTER JOIN
	Portofolio..Covid_Vaccination vac
ON
	dea.location = vac.location
AND
	dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
ORDER BY
	dea.location,
	dea.date

-- Create CTE
WITH PopvsVac (date, location, continent, population, new_vaccination, total_vaccinated)
AS
(
SELECT
	dea.date,
	dea.location,
	dea.continent,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,new_vaccinations))
OVER
	(PARTITION BY dea.location ORDER BY dea.date,dea.location) AS total_vaccination --To add up to the total vaccination instead of giving number per each day
FROM
	Portofolio..Covid_Deaths dea
FULL OUTER JOIN
	Portofolio..Covid_Vaccination vac
ON
	dea.location = vac.location
AND
	dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
)
SELECT *, (total_vaccinated/population)*100
FROM
	PopvsVac
