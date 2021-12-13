drop table if exists public.death

create table public.death
(iso_code varchar(20),	
continent varchar(20),	
location1 varchar(50), 	
date1 date,	
population varchar(20),	
total_cases int,	
new_cases int,	
new_cases_smoothed float,	
total_deaths int,	
new_deaths int,	
new_deaths_smoothed float,	
total_cases_per_million float,	
new_cases_per_million float,	
new_cases_smoothed_per_million float,	
total_deaths_per_million float,	
new_deaths_per_million float,	
new_deaths_smoothed_per_million float,	
reproduction_rate float, 	
icu_patients int,	
icu_patients_per_million float,	
hosp_patients int,	
hosp_patients_per_million float,	
weekly_icu_admissions int,	
weekly_icu_admissions_per_million float, 	
weekly_hosp_admissions int,	
weekly_hosp_admissions_per_million float
);

copy public.death
from '/Users/sarahzhao/Documents/SQL/portfolio/CovidDeaths.csv' delimiters ',' csv;

select iso_code from death



drop table if exists public.vaccine

create table public.vaccine
(iso_code varchar(20),	
continent varchar(20),	
location1 varchar(50),	
date1 date,	
new_tests int,	
total_tests int,	
total_tests_per_thousand float,	
new_tests_per_thousand float,	
new_tests_smoothed int,	
new_tests_smoothed_per_thousand float, 	
positive_rate float,	
tests_per_case float,	
tests_units varchar(20),
total_vaccinations varchar(20),	
people_vaccinated varchar(20),	
people_fully_vaccinated varchar(20),	
total_boosters int,	
new_vaccinations int,	
new_vaccinations_smoothed int,	
total_vaccinations_per_hundred float, 	
people_vaccinated_per_hundred float, 	
people_fully_vaccinated_per_hundred float, 	
total_boosters_per_hundred float, 	
new_vaccinations_smoothed_per_million int, 	
new_people_vaccinated_smoothed int, 	
new_people_vaccinated_smoothed_per_hundred float,	
stringency_index float,	
population_density float,	
median_age float,	
aged_65_older float, 	
aged_70_older float, 	
gdp_per_capita float, 	
extreme_poverty float,	
cardiovasc_death_raten float, 	
diabetes_prevalence float, 	
female_smokers float,	
male_smokers float,	
handwashing_facilities float, 	
hospital_beds_per_thousand float, 	
life_expectancy float, 	
human_development_index float, 	
excess_mortality_cumulative_absolute float,	
excess_mortality_cumulative float, 	
excess_mortality float, 	
excess_mortality_cumulative_per_million float
);

copy public.vaccine
from '/Users/sarahzhao/Documents/SQL/portfolio/CovidVaccine.csv' delimiters ',' csv;

select * from vaccine

--check if everthing is normal
select location1, date1, total_cases, new_cases, total_deaths, population
from death
where continent is not null
order by 1, 2


--looking at total_cases vs. total_death in United States
select location1, date1, total_cases, total_deaths, (total_deaths::float/total_cases::float)*100 as DeathPercentage
from death
where continent is not null and location1 ilike '%united states%'
order by 1,2

--looking at total_cases vs Population
select location1, date1, population, total_cases, (total_cases::float/population::float)*100 as CasePercentage
from death
where continent is not null and location1 ilike '%united states%'
order by 1,2

--looking at Countries with Highest Infection Rate compared to Population
select location1, population, max(total_cases) as HighestInfectionCount, Max((total_cases::float/population::float))*100 
as PercentPopulationInfected
from death 
where continent is not null
group by location1, population
order by 4 desc 

--countries with highest death rate by population
select location1, population, max(total_deaths) as HighestDeathCount, Max((total_deaths::float/population::float))*100 
as PercentPopulationDeath
from death 
where continent is not null
group by location1, population
order by 4 desc 

--countries with highest death count 
select location1, max(total_deaths) as HighestDeathCount
from death 
where continent is not null
group by location1 
order by 2 desc 

--continents by highest death count
select location1, max(total_deaths) as TotalDeathCount
from death 
where continent is null
group by location1
order by 2 desc

--showing the continents with the highest death count per population
select continent, max(total_deaths) as TotalDeathCount
from death
where continent is not null
group by continent
order by 2 desc

-- Global numbers
select date1, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(new_deaths::float)/sum(new_cases::float)*100 as DeathPercentage 
from death
where continent is not null
group by 1
order by 1, 4

--looking at total population vs vaccinations
select  dea.continent, dea.location1, dea.date1, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location1 order by dea.date1) as RollingVaccinated
from death dea
join vaccine vac
on dea.location1 = vac.location1 and dea.date1 = vac.date1
where dea.continent is not null 
order by 2,3

--looking at vaccinations/popultion
select continent,location1,date1, population, new_vaccinations,  (RollingVaccinated/population::float)*100 as RollVacPercentage from (
select  dea.continent, dea.location1, dea.date1, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location1 order by dea.date1) as RollingVaccinated
from death dea
join vaccine vac
on dea.location1 = vac.location1 and dea.date1 = vac.date1
where dea.continent is not null 
order by 2,3) deaVSvac

--temp table
drop table if exists PercentPopulationVaccine
create table PercentPopulationVaccine
(continent varchar(20),
location1 varchar(20),
date1 date,
population varchar(50),
new_vaccinations numeric,
RollingVaccinated numeric)

insert into PercentPopulationVaccine 
select  dea.continent, dea.location1, dea.date1, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location1 order by dea.date1) as RollingVaccinated
from death dea
join vaccine vac
on dea.location1 = vac.location1 and dea.date1 = vac.date1
where dea.continent is not null