USE sakila;

-- 1. Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de Películas.

CREATE TABLE director (
	first_name varchar(32),
	last_name varchar(32),
	num_films int
);

-- El top 5 de actrices y actores de la tabla `actors` que tienen la mayor experiencia 
-- (i.e. el mayor número de películas filmadas) son también directores de las películas en las que participaron. 
-- Basados en esta información, inserten, 
-- utilizando una subquery los valores correspondientes en la tabla `directors`.
INSERT INTO director
SELECT actor.first_name, actor.last_name, count(film_actor.film_id) AS num_films
FROM actor
JOIN film_actor ON
film_actor.actor_id = actor.actor_id
GROUP BY actor.actor_id 
ORDER by num_films DESC 
LIMIT 5;

-- 2. Agregue una columna `premium_customer` que tendrá 
-- un valor 'T' o 'F' de acuerdo a si el cliente es "premium" o no.
-- Por defecto ningún cliente será premium.

ALTER TABLE customer ADD COLUMN premium_customer char;
ALTER TABLE customer ADD CHECK (customer.premium_customer = "T"
OR customer.premium_customer = "F"
OR customer.premium_customer = NULL);

-- 4. Modifique la tabla customer. 
-- Marque con 'T' en la columna `premium_customer` 
-- de los 10 clientes con mayor dinero gastado en la plataforma.

UPDATE customer
SET
premium_customer = "T"
WHERE customer.customer_id IN (
	SELECT *
FROM(
	SELECT c.customer_id
FROM customer c
JOIN payment p ON
	c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY sum(p.amount) DESC
LIMIT 10) top10) ;

-- 5. Listar, ordenados por cantidad de películas (de mayor a menor), 
-- los distintos ratings de las películas existentes 
-- (Hint: rating se refiere en este caso a la clasificación según edad: G, PG, R, etc).
SELECT f.rating, count(f.film_id)
FROM film f
GROUP BY f.rating

-- 6. ¿Cuáles fueron la primera y última fecha donde hubo pagos?
SELECT min(payment_date), MAX(payment_date) FROM payment p 

-- 7. Calcule, por cada mes, el promedio de pagos 
-- (Hint: vea la manera de extraer el nombre del mes de una fecha).

SELECT MONTH(payment_date) AS Mes, avg(amount) FROM payment p
GROUP BY Mes

-- 8. Listar los 10 distritos que tuvieron mayor cantidad de alquileres 
-- (con la cantidad total de alquileres).
SELECT a.district, count(r.rental_id)
FROM address a
JOIN customer c ON c.address_id = a.address_id 
JOIN rental r ON r.customer_id = c.customer_id 
GROUP BY a.district 

-- 9. Modifique la table `inventory_id` agregando una columna `stock` que sea un número entero y 
-- representa la cantidad de copias de una misma película que tiene determinada tienda. 
-- El número por defecto debería ser 5 copias.

-- No tiene sentido esto pero bueno ejecicio

ALTER TABLE inventory 
ADD COLUMN stock int DEFAULT 5;


-- 10. Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la tabla rental, 
-- haga un update en la tabla `inventory` restando una copia al stock de la película rentada 
-- (Hint: revisar que el rental no tiene información directa sobre la tienda, 
-- sino sobre el cliente, que está asociado a una tienda en particular).

CREATE TRIGGER inventory_stock AFTER INSERT ON
rental FOR EACH ROW
UPDATE inventory
SET
stock = stock - 1
WHERE (inventory_id = NEW.inventory_id);


-- 11. Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. 
-- El primero es una clave foránea a la tabla rental y el segundo es un valor numérico con dos decimales.

CREATE TABLE fines (
	rental_id int
	amount numeric(10, 2)
);



















