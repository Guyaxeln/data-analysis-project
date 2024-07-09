select location,date,total_cases,new_cases,total_deaths,population
from portifolio.coviddeaths
where continent is not null
order by 1,2

#select location,date,total_cases,new_cases,total_deaths,population
#from portifolio.covidvaccinations
#order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from portifolio.coviddeaths
where location like '%Rwanda%'
order by 1,2

# Looking at Total deaths vs total cases
#This show the percent of death

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portifolio.coviddeaths
#where location like '%Rwanda%' and continent is not null
order by 1,2


# Looking at Total cases vs population
#This show the percent of population got covid

select location,date,population,total_cases, (total_cases/population)*100 as populationinfectedpercentage
from portifolio.coviddeaths
where location like '%Rwanda%' and continent is not null
order by 3,4

# Looking at countries with highest infection count compared to  population

select location,population,MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as populationinfectedpercentage
from portifolio.coviddeaths
where  continent is not null
group by location, population

# Looking at countries with highest death count per population

select location,MAX(cast(total_deaths as int)) as totaldeathcount
from portifolio.coviddeaths
where continent is not null
group by location
order by totaldeathcount desc

# let's break it down by continent
# Looking at continent with highest death count per population

select continent,MAX(convert(total_deaths, UNSIGNED)) as totaldeathcount
from portifolio.coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc;

# Global numbers per day

select date,SUM(new_cases) as totalcases,SUM(Convert( new_deaths, UNSIGNED)) as totaldeaths, (SUM(Convert( new_deaths,UNSIGNED))/SUM(new_cases))*100 as deathpercentage
from portifolio.coviddeaths
where continent is not null
group by date
order by 1,2

# Global numbers

select SUM(new_cases) as totalcases,SUM(convert(new_deaths, UNSIGNED)) as totaldeaths, (SUM(convert(new_deaths,UNSIGNED))/SUM(new_cases))*100 as deathpercentage
from portifolio.coviddeaths
where continent is not null
#group by date
order by 1,2

# joining two tables coviddeaths and covidvaccinations
# looking at total population vs vaccinations

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
SUM(convert(cv.new_vaccinations,UNSIGNED)) over (partition by cd.location order by cd.location, cd.date) as rollingpeoplevaccinated
from portifolio.coviddeaths cd
join portifolio.covidvaccinations cv
      on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3;



# use CTE

WITH popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) 
AS (
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
SUM(convert(cv.new_vaccinations, UNSIGNED)) over (partition by cd.location order by cd.location, cd.date) as rollingpeoplevaccinated
from portifolio.coviddeaths cd
join portifolio.covidvaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
#order 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac


# Use TEMP TABLE
drop table if exists percentpopulationvaccinated;
CREATE TABLE percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolligpeoplevaccinated numeric
);
INSERT INTO percentpopulationvaccinated (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as rollingpeoplevaccinated
from portifolio.coviddeaths cd
join portifolio.covidvaccinations cv
on cd.location=cv.location and cd.date=cv.date
#where cd.continent is not null
#order 2,3

select *, (rollingpeoplevaccinated/population)*100
from percentpopulationvaccinated

# Creating view for later Visualization

create view  percentpopulationvaccinated (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, SUM(CONVERT(cv.new_vaccinations, UNSIGNED)) over (partition by cd.location order by cd.location, cd.date) as rollingpeoplevaccinated
from portifolio.coviddeaths cd
join portifolio.covidvaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3;

select *
FROM percentpopulationvaccinated