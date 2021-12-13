
--1. The cases, death and vaccinations by continent

select dea.location1, max(dea.population), sum(dea.new_cases) as total_cases, SUM(dea.new_deaths) as total_deaths, 
SUM(dea.new_deaths::float)/SUM(dea.new_cases::float)*100 as DeathPercentage, 
max(vac.total_vaccinations) as totalVaccinations,
max(vac.people_fully_vaccinated)as fullyVaccinated,
max(vac.people_fully_vaccinated::float)/max(dea.population::float)*100 as VaccinationPercentage
from death dea
join vaccine vac
on dea.location1 = vac.location1 and dea.date1 = vac.date1
where dea.continent is null and dea.location1 != 'International'
group by dea.location1


--2. The cases, deaths and vaccinations by countries
select dea.location1, max(dea.population), sum(dea.new_cases) as total_cases, SUM(dea.new_deaths) as total_deaths, 
SUM(dea.new_deaths::float)/SUM(dea.new_cases::float)*100 as DeathPercentage, 
max(vac.total_vaccinations) as totalVaccinations,
max(vac.people_fully_vaccinated)as fullyVaccinated,
max(vac.people_fully_vaccinated::float)/max(dea.population::float)*100 as VaccinationPercentage
from death dea
join vaccine vac
on dea.location1 = vac.location1 and dea.date1 = vac.date1
where dea.continent is not null 
group by dea.location1

--.3 The cases by continent by date
Select location1, population, date1, max(total_cases) as HighestInfectionCount,  max(total_cases::float)/(population::float)*100 as PercentPopulationInfected
From death
where continent is not null
Group by location1, date1, population
order by location1, date1