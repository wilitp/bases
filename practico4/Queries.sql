use world;

-- 1. Listar el nombre de la ciudad y el nombre del país de todas las ciudades que 
-- pertenezcan a países con una población menor a 10000 habitantes.

SELECT 
	c.Name, c2.Name, c.population
FROM 
	country c 
JOIN
	city c2 ON c.Code = c2.CountryCode 
WHERE 
	c.Population < 10000;

-- 2. Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.

select
	c.name,
	c.Population
from
	city c
where
	c.Population > (
	select
		avg(c2.population)
	from
		city c2);

-- 3. Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total de algún país de Asia.
SELECT 
	c.name
from
	city c
join
country c2 on
	c.CountryCode = c2.Code
WHERE
	c2.Continent != "Asia"
	and
	c.Population > (
	select
		min(Population)
	from
		country
	WHERE
		continent = "Asia");


-- 4. Listar aquellos países junto a sus idiomas no oficiales, 
-- que superen en porcentaje de hablantes a cada uno de los idiomas oficiales del país.

-- Nose pq poniendo > max funciona distinto (da varios menos)

SELECT  c2.name, GROUP_CONCAT(c.`Language`) AS "Oficial languages"
FROM countrylanguage c
JOIN country c2 ON
c.CountryCode = c2.Code
WHERE c.IsOfficial = "F"
AND c.Percentage > ALL (SELECT c3.Percentage
FROM countrylanguage c3
WHERE c3.CountryCode = c2.Code AND c3.IsOfficial LIKE "T")
GROUP BY c.CountryCode 

-- 5. Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 y exista (en el país) 
-- al menos una ciudad con más de 100000 habitantes. 
-- (Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas).

-- con subquery
select
	DISTINCT c.Region 
from
	country c
where
	c.SurfaceArea < 1000
	and
 exists(
	SELECT
		NULL
	from
		city c2
	where
		c2.CountryCode = c.Code
		and c2.Population > 100000)

-- sin subquery
SELECT DISTINCT c.Region
FROM country c
JOIN city c2 ON
c2.CountryCode = c.Code
WHERE c2.Population > 100000 AND c.SurfaceArea < 1000;

-- 6. Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada. 
-- (Hint: Hay dos maneras de llegar al mismo resultado. 
--        Usando consultas escalares o usando agrupaciones, encontrar ambas).

-- Agrupacion
SELECT c.Name, max(c2.Population) AS "Max city population"
FROM country c
INNER JOIN city c2 ON
c.Code = c2.CountryCode
GROUP BY c.Code

-- query escalar
SELECT c.Name,(SELECT c2.Population
FROM city c2
ORDER BY c2.Population DESC
LIMIT 1)
FROM country c

-- 7.Listar aquellos países y sus lenguajes no oficiales 
-- cuyo porcentaje de hablantes sea mayor al promedio de hablantes de los lenguajes oficiales.

SELECT c.Name AS Country, c2.`Language` AS `Language`
FROM country c
JOIN countrylanguage c2 ON
c.Code = c2.CountryCode
WHERE c2.IsOfficial LIKE "T"
AND 
c2.Percentage > (
SELECT avg(c3.percentage)
FROM countrylanguage c3
WHERE c3.CountryCode = c.Code
AND c3.IsOfficial LIKE "T"
	
	)

-- 8. Listar la cantidad de habitantes por continente ordenado en forma descendente.

SELECT c.Name AS `Continent`, SUM(c2.Population) AS `Total population`
FROM continent c
JOIN country c2 ON
c2.Continent = c.Name 
GROUP BY c.Name
ORDER BY `Total population` DESC

-- 9. Listar el promedio de esperanza de vida (LifeExpectancy) 
-- por continente con una esperanza de vida entre 40 y 70 años.


SELECT * FROM 
(SELECT c.Name AS `Continent`, avg(c2.LifeExpectancy) AS `Life expectancy` 
FROM continent c
JOIN country c2 ON
c2.Continent = c.Name 
GROUP BY c.Name) AS c3
WHERE `Life expectancy` BETWEEN 40 AND 70

-- 10 Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente.
SELECT c.Name AS `Continent`, max(c2.Population), min(c2.Population), avg(c2.Population), SUM(c2.Population)
FROM continent c
JOIN country c2 ON
c2.Continent = c.Name
GROUP BY c.Name

