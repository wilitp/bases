-- 1. Lista el nombre de la ciudad, nombre del país, región y forma de gobierno de las 10 ciudades más pobladas del mundo.
use world;

select cy.Name, ct.Name, ct.Region, ct.GovernmentForm 
from city cy
join country ct
where ct.Code = cy.CountryCode 
ORDER by cy.Population DESC
limit 10;

-- 2. Listar los 10 países con menor población del mundo, 
-- junto a sus ciudades capitales 
-- (Hint: puede que uno de estos países no tenga ciudad capital asignada, en este caso deberá mostrar "NULL").

select ct.Name, cy.Name as "Capital" 
from city cy
join country ct
where ct.Capital = cy.ID
ORDER by ct.Population ASC
limit 10;

-- 3. Listar el nombre, continente y todos los lenguajes oficiales de cada país. 
-- (Hint: habrá más de una fila por país si tiene varios idiomas oficiales).

select cl.`Language`, ct.Name, ct.Continent from countrylanguage cl 
join country ct
where ct.Code = cl.CountryCode;

-- 4. Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.

SELECT ct.Name, c.Name as `Capital` FROM country ct
join city c
where ct.Capital = c.ID 
order by ct.SurfaceArea DESC
limit 20;


-- 5. Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) 
-- y el porcentaje de hablantes del idioma.

select cy.Name, cl.`Language`, cl.Percentage from city cy
join 
  countrylanguage cl, 
  country ct 
where 
  cl.CountryCode = ct.Code 
  and cy.CountryCode = ct.Code 
  and cl.IsOfficial = "T"
order by cy.Population;

-- 6. Listar los 10 países con mayor población 
-- y los 10 países con menor población (que tengan al menos 100 habitantes) en la misma consulta.

select
	Name
from
	(
(
	select
		*
	from
		country c
	order by
		c.Population DESC
	LIMIT 10)
union
(
select
	*
from
	country c2
where
	c2.Population >= 100
order by
	c2.Population ASC
LIMIT 10)
) c;

-- 7. Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés (hint: no debería haber filas duplicadas).
-- Si interpretaramos esto como SOLO Frances e Ingles, deberiamos hacer un filtrado posterior donde joineamos otra vez con countrlanguage


select name from 
(select c.Name, (COUNT(DISTINCT cl.`Language`) - 1) as keep from countrylanguage cl
join country c 
where 
	cl.CountryCode = c.Code 
	and
	(cl.`Language` like "French" or cl.`Language` like "English")
	and
	cl.IsOfficial = "T"
group by CountryCode 
having keep = 1) as c2;

-- 8. Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.
-- Busco todas instancias de el idioma español y las uno a todas las del idioma inglés
-- Luego agrupo esta union por pais
-- ahora que tengo una fila por país, puedo filtrar en donde "english" sea no nulo y "spanish" sea 0
select c.name from (select c.name, SUM(c.spanish) as spanish, SUM(c.english) as english from ((select c.Name , 0 as spanish, 1 as english from countrylanguage cl
join country c
where cl.CountryCode = c.Code 
and (
	cl.`Language` like "English" and cl.Percentage > 0
))
union
(select c.Name, 1 as spanish, 0 as english from countrylanguage cl
join country c
where cl.CountryCode = c.Code 
and (
	cl.`Language` like "Spanish" and cl.Percentage > 0
))) as c
group by c.name
having spanish = 0 and english >= 1) as c

