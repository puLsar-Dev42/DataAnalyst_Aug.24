----- Tagesaufgaben Funktionen

-- Wir arbeiten mit dvd_rental!

-- -------------------------------------------------------------
--   Aufgabe 1 : Erstelle eine Funktion, die die Länge des längsten
--               Films ausgibt
-- -------------------------------------------------------------
-- a) Lass dir nur die Länge des längsten Films ausgeben
CREATE OR REPLACE FUNCTION f_film_max_length(
	OUT max_tp INTEGER)
LANGUAGE plpgsql
AS
$$
BEGIN
	SELECT MAX(length)
	INTO max_tp
	FROM film;
END;
$$;

-- Test:
SELECT *
FROM f_film_max_length();

-- b) Lass dir Namen sowie Länge des
--    längsten Films ausgeben
CREATE OR REPLACE FUNCTION f_filmname_with_max_length()
RETURNS TABLE(filmname VARCHAR,
              max_laufzeit SMALLINT)
LANGUAGE plpgsql
AS
$$
BEGIN
RETURN QUERY
	SELECT title,
	       length
	FROM film
	WHERE length = (SELECT MAX(length)
						  FROM film)
	ORDER BY length DESC, title;
END;
$$;

-- Test:
SELECT *
FROM f_filmname_with_max_length();

-- ----------------------------------------------------------------------------------------------------------------------
--   Aufgabe 2 : Erstelle eine Funktion, die die staff_id
--               als Parameter nimmt, und den entsprechenden
--               Vornamen und Nachnamen aller Kunden ausgibt.
--               (Bitte nach Nachnamen sortiert.)
-- ------------------------------------------------------------------------------------------------------------------------

-- Die relevanten Tabellen:
SELECT *
FROM staff;
SELECT *
FROM payment;
SELECT *
FROM customer;

-- Eine Beispiel-Abfrage:
SELECT DISTINCT
       c.last_name AS customer_lastname,
       c.first_name AS customer_firstname
FROM customer c
JOIN payment
USING (customer_id)
JOIN staff
USING (staff_id)
WHERE staff_id = 1
ORDER BY c.last_name;

-- Die eigentliche Funktion:
CREATE OR REPLACE FUNCTION f_get_customers_by_staff_id(employee_id int)
RETURNS TABLE(
	customer_lastname VARCHAR(45),
	customer_firstname VARCHAR)
LANGUAGE plpgsql
AS
$$
BEGIN
	RETURN query
		SELECT DISTINCT
			c.last_name,
			c.first_name
    FROM customer c
    JOIN payment
    USING (customer_id)
    JOIN staff s
    USING (staff_id)
    WHERE s.staff_id = employee_id
	ORDER BY c.last_name;
END;
$$;

-- Test:
SELECT *
FROM f_get_customers_by_staff_id(1);

-- -------------------------------------------------------------------------------------------------------
--   Aufgabe 3 : Erstelle eine Funktion, die das Genre als
--               Parameter nimmt, und die minimale, die maximale,
--               sowie die Durchschnittsdauer der Filme in diesem
--               Genre zurückgibt.
-- -------------------------------------------------------------------------------------------------------

-- Die benötigten Tabellen:
SELECT *
FROM film;
SELECT *
FROM film_category;
SELECT *
FROM category;

-- Die verfügbaren Genres:
SELECT DISTINCT name
FROM category;

-- Beispiel-Query mit 'Drama':
SELECT c.name AS category_name,
       MIN(f.length) AS shortest_movie,
       MAX(f.length) AS longest_movie,
       ROUND(AVG(f.length), 2) AS average_length
FROM film f
JOIN film_category
USING (film_id)
JOIN category c
USING (category_id)
WHERE c.name = 'Drama'
GROUP BY c.name;

-- Die eigentliche Funktion:
CREATE OR REPLACE FUNCTION f_category_statistics(category VARCHAR)
RETURNS TABLE(
	category_name VARCHAR,
	shortest_movie SMALLINT,
	longest_movie SMALLINT,
	average_length FLOAT)
LANGUAGE plpgsql
AS
$$
BEGIN
RETURN QUERY
	SELECT c.name,
	       MIN(f.length) AS shortest_movie,
	       MAX(f.length) AS longest_movie,
	       ROUND(AVG(f.length), 2)::FLOAT AS average_length
    FROM film f
    JOIN film_category
    USING (film_id)
    JOIN category c
    USING (category_id)
    WHERE c.name = category
    GROUP BY c.name;
END;
$$;

SELECT *
FROM f_category_statistics('Comedy');

-- -----------------------------------------------------------------------------------------------
--   Aufgabe 4 : Erstelle eine Funktion, mit der man mittels
--               Wörtern oder Wortteilen nach Schauspielernamen
--               suchen kann (Stichwort: Regex) und ID, Nachnamen und Vornamen
--               zurückgibt.
-- -----------------------------------------------------------------------------------------------
-- Bezugstabelle:
SELECT *
FROM actor;

-- Beispiel-Abfrage:
SELECT actor_id,
       last_name,
       first_name
FROM actor
WHERE last_name ~ '^G.*s$';

CREATE OR REPLACE FUNCTION f_artistname_by_regex(artist_pattern VARCHAR)
    RETURNS TABLE
            (
                actor_id   INT,
                last_name  VARCHAR,
                first_name VARCHAR
            )
    LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
        SELECT a.actor_id,
               a.last_name,
               a.first_name
        FROM actor a
        WHERE a.last_name ~ artist_pattern;
END;
$$;

SELECT *
FROM f_artistname_by_regex('^G.*s$');

SELECT *
FROM f_artistname_by_regex('Cruise');

-- ----------------------------------------------------------------------------------------------------------------------------
--   Aufgabe 5 : Lösche alle soeben erstellten Funktionen
-- ----------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS f_film_max_length;
DROP FUNCTION IF EXISTS f_filmname_with_max_length;
DROP FUNCTION IF EXISTS f_get_customers_by_staff_id;
DROP FUNCTION IF EXISTS f_artistname_by_regex;
