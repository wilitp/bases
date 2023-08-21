-- Devuelva una lista de los nombres y las regiones a las que pertenece cada país ordenada alfabéticamente.
select Name, Region
from country
order by Name ASC; 

-- Liste el nombre y la población de las 10 ciudades más pobladas del mundo.
select Name, Population
from city
order by Population DESC
limit 10

-- Liste el nombre, región, superficie y forma de gobierno de los 10 países con menor superficie.
select Name, Region, SurfaceArea, GovernmentForm 
from country
order by SurfaceArea ASC
limit 10

-- Liste todos los países que no tienen independencia
select Name, Region, SurfaceArea, GovernmentForm 
from country
where country.IndepYear is NULL

-- Liste el nombre y el porcentaje de hablantes que tienen todos los idiomas declarados oficiales.
select c.`Language`, c.Percentage
from countrylanguage c
where c.IsOfficial like "T"
order by c.`Language` 