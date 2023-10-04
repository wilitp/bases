-- 1. Lista el nombre de la ciudad, nombre del país, región y forma de gobierno de las 10 ciudades más pobladas del mundo.
USE world;

SELECT cy.Name, ct.Name, ct.Region, ct.GovernmentForm
FROM city AS cy
INNER JOIN country ct
WHERE ct.Code = cy.CountryCode
ORDER BY
	cy.Population DESC
LIMIT 10;
-- 2. Listar los 10 países con menor población del mundo, 
-- junto a sus ciudades capitales 
-- (Hint: puede que uno de estos países no tenga ciudad capital asignada, en este caso deberá mostrar "NULL").

SELECT ct.Name, cy.Name AS "Capital"
FROM city cy
RIGHT JOIN country ct ON
ct.Capital = cy.ID
ORDER BY ct.Population ASC
LIMIT 10;
-- 3. Listar el nombre, continente y todos los lenguajes oficiales de cada país. 
-- (Hint: habrá más de una fila por país si tiene varios idiomas oficiales).

SELECT cl.`Language`, ct.Name, ct.Continent
FROM countrylanguage cl
JOIN country ct
ON ct.Code = cl.CountryCode
WHERE cl.isOfficial = "T";

-- 4. Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.

SELECT ct.Name, c.Name AS `Capital`
FROM country ct
LEFT JOIN city c
ON
ct.Capital = c.ID
ORDER BY ct.SurfaceArea DESC
LIMIT 20;
-- 5. Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) 
-- y el porcentaje de hablantes del idioma.

SELECT cy.Name, cl.`Language`, cl.Percentage
FROM city cy
INNER JOIN 
  countrylanguage cl
ON cl.CountryCode = cy.CountryCode 
WHERE cl.IsOfficial = "T"
ORDER BY cy.Population DESC;

-- 6. Listar los 10 países con mayor población 
-- y los 10 países con menor población (que tengan al menos 100 habitantes) en la misma consulta.
(SELECT name
FROM country c
ORDER BY
		c.Population DESC
LIMIT 10)
UNION
(SELECT name
FROM country c2
WHERE c2.Population >= 100
ORDER BY c2.Population ASC
LIMIT 10)

-- 7. Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés (hint: no debería haber filas duplicadas).
-- Si interpretaramos esto como SOLO Frances e Ingles, deberiamos hacer un filtrado posterior donde joineamos otra vez con countrylanguage

SELECT c.Name
FROM countrylanguage cl
JOIN country c
ON
cl.CountryCode = c.Code
WHERE cl.`Language` LIKE "French" AND cl.IsOfficial like "T"
INTERSECT 
SELECT c.Name
FROM countrylanguage cl
JOIN country c
ON
cl.CountryCode = c.Code
WHERE cl.`Language` LIKE "English"  AND cl.IsOfficial like "T"

-- 8. Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.
-- Busco todas instancias de el idioma español y las uno a todas las del idioma inglés
-- Luego agrupo esta union por pais
-- ahora que tengo una fila por país, puedo filtrar en donde "english" sea no nulo y "spanish" sea 0

SELECT c.Name
FROM countrylanguage cl
JOIN country c
ON
cl.CountryCode = c.Code
WHERE cl.`Language` LIKE "English"
AND
	cl.Percentage > 0
EXCEPT 
SELECT c.Name
FROM countrylanguage cl
JOIN country c
ON
cl.CountryCode = c.Code
WHERE cl.`Language` LIKE "Spanish"
AND
	cl.Percentage > 0
