USE olympics;

-- views que uso luego

DROP VIEW IF EXISTS medalsPerRegion;
CREATE VIEW medalsPerRegion AS (SELECT medals_dedup.id, region_name, 
    sum(medals_dedup.medal_name = "Gold") AS gold,
    sum(medals_dedup.medal_name = "Silver") AS silver,
    sum(medals_dedup.medal_name = "Bronze") AS bronze,
    count(*) AS total_medals
    FROM
    (SELECT DISTINCT
        nr.id, nr.region_name, m.medal_name, ce.event_id
    FROM person p 
    JOIN games_competitor gc 
        ON gc.person_id = p.id 
    JOIN 
        competitor_event ce 
        ON ce.competitor_id = gc.id
    JOIN medal m 
        ON ce.medal_id = m.id
    JOIN person_region pr 
        ON p.id = pr.person_id 
    JOIN noc_region nr 
        ON pr.region_id = nr.id       
    WHERE m.medal_name <> "NA" ) medals_dedup
GROUP BY id)

-- 1. Crear un campo nuevo `total_medals` en la tabla `person` que almacena la cantidad de medallas ganadas por cada persona. Por defecto, con valor 0.

ALTER TABLE person 
ADD COLUMN total_medals int DEFAULT 0;

-- 2. Actualizar la columna  `total_medals` de cada persona con el recuento real de medallas que ganó. Por ejemplo, para Michael Fred Phelps II, luego de la actualización debería tener como valor de `total_medals` igual a 28.

-- INSERT INTO person (total_medals) ... 

UPDATE person
JOIN 
(SELECT p.id, count(ce.medal_id) total_medals
FROM person p
JOIN games_competitor gc ON
gc.person_id = p.id
JOIN competitor_event ce ON
ce.competitor_id = gc.id
JOIN medal m ON
m.id = ce.medal_id
WHERE m.medal_name <> "NA"
GROUP BY p.id) medalsPerPerson
ON
medalsPerPerson.id = person.id
SET
person.total_medals = medalsPerPerson.total_medals;

-- 3.Devolver todos los medallistas olímpicos de Argentina, es decir, los que hayan logrado alguna medalla de oro, plata, o bronce, enumerando la cantidad por tipo de medalla.

SELECT p.full_name , m.medal_name, count(DISTINCT m.id) FROM 
person p
JOIN games_competitor gc ON gc.person_id = p.id
JOIN competitor_event ce ON gc.id = ce.competitor_id 
JOIN medal m ON ce.medal_id = m.id
JOIN person_region pr ON pr.person_id = p.id
JOIN noc_region nr ON pr.region_id = nr.id
WHERE nr.region_name LIKE "Argentina"
GROUP BY p.id, m.medal_name 
HAVING (m.medal_name LIKE "Gold"
       OR 
       m.medal_name LIKE "Silver"
       OR
       m.medal_name LIKE "Bronze")
       
-- 4. Listar el total de medallas ganadas por los deportistas argentinos en cada deporte.

SELECT s.sport_name , count(m.id) FROM person p 
JOIN games_competitor gc 
    ON gc.person_id = p.id 
JOIN 
    competitor_event ce 
    ON ce.competitor_id = gc.id
JOIN medal m 
    ON ce.medal_id = m.id
JOIN event e 
    ON ce.event_id = e.id
JOIN sport s
    ON e.sport_id = s.id
JOIN person_region pr 
    ON p.id = pr.person_id 
JOIN noc_region nr 
    ON pr.region_id = nr.id       
WHERE m.medal_name <> "NA" AND region_name LIKE "Argentina"
GROUP BY s.id

-- 5.Listar el número total de medallas de oro, plata y bronce ganadas por cada país (país representado en la tabla `noc_region`), agruparlas los resultados por pais.

SELECT 
    region_name, gold, silver, bronze
FROM medalsPerRegion;

-- 6. Listar el país con más y menos medallas ganadas en la historia de las olimpiadas. 

(SELECT region_name, total_medals FROM medalsPerRegion 
ORDER BY total_medals DESC
LIMIT 1)
union
(SELECT region_name, total_medals FROM medalsPerRegion 
ORDER BY total_medals ASC
LIMIT 1)

-- 7.

CREATE TRIGGER increase_number_of_medals

delimiter //
CREATE TRIGGER IF NOT EXISTS increase_number_of_medals AFTER INSERT ON competitor_event
FOR EACH ROW
BEGIN 
    DECLARE medal_name varchar(256);
    DECLARE person_id varchar(256);
    
    
    SELECT m.medal_name INTO medal_name
    FROM medal m
    WHERE m.id = NEW.medal_id;

    SELECT gc.person_id INTO person_id
    FROM games_competitor gc
    WHERE gc.id = NEW.competitor_id;
    
    IF (medal_name IS NOT NULL AND medal_name <> "NA")
    THEN
        UPDATE person
        SET person.total_medals = person.total_medals + 1
        WHERE person.id = person_id;
    END IF;

END//
delimiter ;




delimiter //
CREATE TRIGGER IF NOT EXISTS decrease_number_of_medals BEFORE DELETE ON competitor_event
FOR EACH ROW
BEGIN 
    DECLARE medal_name varchar(256);
    DECLARE person_id varchar(256);
    
    
    SELECT m.medal_name INTO medal_name
    FROM medal m
    WHERE m.id = OLD.medal_id;

    SELECT gc.person_id INTO person_id
    FROM games_competitor gc
    WHERE gc.id = OLD.competitor_id;
    
    IF (medal_name IS NOT NULL AND medal_name <> "NA")
    THEN
        UPDATE person
        SET person.total_medals = person.total_medals - 1
        WHERE person.id = person_id;
    END IF;

END//
delimiter ;

-- 8 Crear un procedimiento  `add_new_medalists` que tomará un `event_id`, y tres ids de atletas `g_id`, `s_id`, y `b_id` donde se deberá insertar tres registros en la tabla `competitor_event`  asignando a `g_id` la medalla de oro, a `s_id` la medalla de plata, y a `b_id` la medalla de bronce.

DROP PROCEDURE IF EXISTS add_new_medalists;
delimiter //
CREATE PROCEDURE IF NOT EXISTS add_new_medalists(
    IN event_id int,
    IN g_id int, 
    IN s_id int,
    IN b_id int
)
BEGIN 
    DECLARE cg_id int;
    DECLARE cs_id int;
    DECLARE cb_id int;

    DECLARE gm_id int;
    DECLARE sm_id int;
    DECLARE bm_id int;

    -- obtener claves de competidor usando
    -- las claves de persona

    SELECT gc.id INTO cg_id
    FROM games_competitor gc
    WHERE gc.person_id = g_id;

    SELECT gc.id INTO cs_id
    FROM games_competitor gc
    WHERE gc.person_id = s_id;

    SELECT gc.id INTO cb_id
    FROM games_competitor gc
    WHERE gc.person_id = b_id;

    -- obtener ids de medallas
    SELECT m.id INTO gm_id
    FROM medal m
    WHERE m.medal_name = "Gold";

    SELECT m.id INTO sm_id
    FROM medal m
    WHERE m.medal_name = "Silver";

    SELECT m.id INTO bm_id
    FROM medal m
    WHERE m.medal_name = "Bronze";

    -- insertar nuevas medallas

    INSERT INTO competitor_event (event_id, competitor_id, medal_id) VALUES (event_id, cg_id, gm_id);

    INSERT INTO competitor_event (event_id, competitor_id, medal_id) VALUES (event_id, cs_id, sm_id);
    
    INSERT INTO competitor_event (event_id, competitor_id, medal_id) VALUES (event_id, cb_id, bm_id);
END//
delimiter ;

-- 9. Crear el rol `organizer` y asignarle permisos de eliminación sobre la tabla `games` y permiso de actualización sobre la columna `games_name`  de la tabla `games` .


CREATE ROLE organizer;
GRANT DELETE ON games TO organizer;
GRANT UPDATE (games_name) ON games TO organizer;

