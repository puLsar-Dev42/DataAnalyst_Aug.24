/*
 * -------------------------------------------
 * Skript: 	Funktionen
 * -------------------------------------------
 * 
 *
 */
-- Wir arbeiten wieder mit dvd_rental

-- Wie in Python, können wir auch in SQL Funktionen definieren,
-- die dann größeren Code für uns ausführen.

-- Typischer Aufbau von Funktionen:
/*
create [or replace] function function_name(param_list param_type, param2 param typ)
   returns return_type 
   language plpgsql (oder andere prozedurale Sprache)
  as
$$
declare 
   variable_name variable_typ
begin
   logic
end;
$$;
*/

-- 1. Mit create function function_name wählen wir den Namen
-- 	  der neuen Funktion
-- 2. (param_list param_type) enthält alle Parameter und
--     deren Datentyp für die zu erstellende Funktion
-- 3. returns return_type gibt an, welcher Outputtyp (integer,
--    varchar...) ausgegeben werden soll 
-- 4. language gibt an, in welcher Sprache der Befehl
--    geschrieben werden soll. Neben plpgsql ist auch C und
--    vieles Weitere erlaubt.
-- 5. Zwischen den $$ wird die Funktion mit declare (Variablen
--    werden angegeben), begin (befehl wird eingegeben) bis
--    end; angegeben.

-- Das Pl in 'plpgsql' steht für Procedural Language innerhalb von PostgreSQL
-- und erweitert die PSQL um die Möglichkeit, Prozeduren/Funktionen zu schreiben.
-- Mehr: https://de.wikipedia.org/wiki/PL/pgSQL

/* Zeit für die erste Probefunktion.
   1. Beispiel: Erstelle eine Funktion, die eine Versandgebühr von 2,50
   zu einem Wert/ einer Spalte addiert.
 */

CREATE OR REPLACE FUNCTION f_add_postal_fee(amount float)
	RETURNS float
	LANGUAGE plpgsql
AS
$$
BEGIN
	RETURN amount + 2.50;
END;
$$;

-- Test:
SELECT f_add_postal_fee(13.49);

-- Test mit unseren Filmen:
SELECT film_id,
       rental_rate,
       f_add_postal_fee(rental_rate) AS postal_rental
FROM film;

-- Funktion wieder entfernen:
DROP FUNCTION f_add_postal_fee;

/* Übrigens gibt es auch eine Prozeduralsprache für Python.
   Die muss man allerdings dann für jede Datenbank installieren und sie ist
   eingeschränkter und gilt als nicht vertrauenswürdig.
   https://www.postgresql.org/docs/current/plpython.html
 */

-- 2. Beispiel: Rechnen ohne Mehrwertsteuer
-- := weist einer Variable einen Wert zu.
CREATE OR REPLACE FUNCTION f_remove_tax(amount numeric)
	RETURNS numeric
	LANGUAGE plpgsql
AS
$$
DECLARE
	taxfree_amount numeric;
BEGIN
	taxfree_amount := ROUND(amount / 1.19, 2);
	RETURN taxfree_amount;
END;
$$;

-- Test mit einem Wert:
SELECT f_remove_tax(100);

-- Test mit unseren Filmen:
SELECT title,
       rental_rate,
       f_remove_tax(rental_rate) AS rate_without_taxes
FROM film;

-- In der Datenbank, mit der wir verbunden sind, finden wir nun in Pycharm
-- unter public > routines die Funktion. In Pgadmin wäre das:
-- Schemas > public > Functions

-- Wir behalten f_remove_tax noch für eine Demo später. ;)

---- ** IN & OUT & INOUT in Funktionen **
/*
IN (Standard) -> Wir geben Parameter ein und bekommen
                 einen anderen zurück (return). 
OUT -> Unsere Funktionsparameter sind Ausgaben, keine Eingaben.
INOUT -> Gib einen Wert ein und bekomme einen aktualisierten
         Wert zurück. 
*/

SELECT *
FROM film;

-- Solche Abfragen soll die Funktion durchführen (Sprache nach Titel finden)
-- Sie soll also einen Titel als Input erhalten und die Sprache des Films ausgeben.
SELECT name
FROM film
	     JOIN language
	          USING (language_id)
WHERE title = 'Academy Dinosaur';

-- Die eigentliche Funktion:
-- $1 steht für Parameter 1, $2 für Param 2 usw.

CREATE OR REPLACE FUNCTION f_find_language_by_movie_title(IN film_title TEXT)
	RETURNS TEXT
	LANGUAGE plpgsql
AS
$$
DECLARE
	lang TEXT;
BEGIN
	SELECT name
	INTO lang
	FROM film
		     JOIN language
		          USING (language_id)
	WHERE title = $1;
-- oder: WHERE title = film_title (geht auch)
	RETURN lang;
END;
$$;

-- Test:
SELECT f_find_language_by_movie_title('Academy Dinosaur');

-- Funktion wieder entfernen (ohne Fehlermeldung, falls die Funktion nicht existiert)
DROP FUNCTION IF EXISTS f_find_language_by_movie_title;

-- Möglichkeit, mehrere Funktionen auf einmal zu "droppen"
-- Einfach durch Kommata abtrennen.
-- Bsp: DROP FUNCTION IF EXISTS f_get_customers_by_staff_id, f_get_total_amount_stats;

/* Gruppenübungsaufgabe:
   Schreibt eine Funktion, mit der ihr über Vornamen und Nachnamen von Kunden
   die Stadt erhaltet, in der der Kunde ansässig ist.
   Zurückgegeben soll einfach die Stadt werden.
   Benennt die Funktion: f_cityname_by_customer_name.
   Achtung: customer lässt sich nicht direkt mit city verbinden!
 */

CREATE OR REPLACE FUNCTION f_cityname_by_customer_name(IN first_name TEXT, IN last_name TEXT)
	RETURNS TEXT
	LANGUAGE plpgsql
AS
$$
DECLARE
	city TEXT;
BEGIN
	SELECT ci.city
	INTO city
	FROM customer AS cu
		     JOIN address AS ad ON cu.address_id = ad.address_id
		     JOIN city AS ci ON ad.city_id = ci.city_id
	WHERE cu.first_name = $1
	  AND cu.last_name = $2;
	IF city IS NULL
		THEN
			RETURN 'Kunde nicht gefunden';
	END IF;
	RETURN city;
END;
$$;

SELECT f_cityname_by_customer_name('Jared', 'Ely');

-- Funktion wieder entfernen
DROP FUNCTION IF EXISTS f_cityname_by_customer_name;

-- Beispiel OUT 
-- Wir wollen jetzt Informationen aus Tabelle bekommen,
-- ohne Parameter eingeben zu müssen. Gib minimalen, maximalen,
-- durchschnittlichen und Summe von 'amount' an
SELECT *
FROM payment;

CREATE OR REPLACE FUNCTION f_get_total_amount_stats(
	OUT min_amount float,
	OUT max_amount float,
	OUT avg_amount float,
	OUT sum_amount float)
	LANGUAGE plpgsql
AS
$$
BEGIN
	SELECT min(amount),
	       max(amount),
	       ROUND(avg(amount), 2) AS avg,
	       sum(amount)
	INTO min_amount, max_amount, avg_amount, sum_amount
	FROM payment;
END;
$$;

-- Einfache OUT-Funktionen erfordern kein RETURN!

-- Einfaches Ausführen der Funktion geht zwar, gibt
-- Infos aber gebündelt wieder
SELECT *
FROM f_get_total_amount_stats();

-- Bei mehreren ausgegebenen Infos besser:
SELECT *
FROM f_get_total_amount_stats();

DROP FUNCTION IF EXISTS f_get_total_amount_stats;

-- BEISPIEL INOUT
-- Ein Parameter wird der Funktion übergeben, aktualisiert
-- und zurückgegeben.
-- Beispiel: Gib eine Zahl ein, die dann +10 gerechnet wird.

CREATE OR REPLACE FUNCTION f_addition(INOUT num int)
	LANGUAGE plpgsql
AS
$$
BEGIN
	num := num + 10;
END;
$$;

-- Durch INOUT keine Definition des RETURN nötig,
-- definiert sich quasi selbst
SELECT f_addition(50);

DROP FUNCTION IF EXISTS f_addition;
-- ** Funktionen mit Tabelle als Ergebnis **
--> Ausgabe als RETURNS TABLE
-- Beispiel: Ausgabe aller Filme, die wie REGEX_Ausdruck
-- geschrieben werden.
SELECT *
FROM film;

-- Beispiel: Filme, die auf A anfangen, gefolgt von vier beliebigen
-- Nicht-Leerzeichen, dann von einem Leerzeichen und schließlich Beliebigem.
SELECT title,
       description
FROM film
WHERE title ~ 'A\S{4} .*';

-- Die eigentliche Funktion:
CREATE OR REPLACE FUNCTION f_movie_info_by_regex(regex_pattern TEXT)
	RETURNS TABLE
	        (
		        title       VARCHAR(255),
		        description TEXT
	        )
	LANGUAGE plpgsql
AS
$$
BEGIN
	RETURN QUERY
		SELECT f.title,
		       f.description
		FROM film AS f
		WHERE f.title ~ regex_pattern;
END;
$$;

-- Suche mit festem Wort:
SELECT *
FROM f_movie_info_by_regex('Love');
-- Suche mit Pattern:
SELECT *
FROM f_movie_info_by_regex('^A\S{4} .*');

-- Zurückgegebene Tabelle muss also vorher definiert werden
-- Außerdem wird BEGIN Block um RETURN query erweitert

-- Funktion entfernen:
DROP FUNCTION IF EXISTS f_movie_info_by_regex;

-- OVERLOADING
/* "Overloading" bezeichnet den Umstand, dass wir mehrere
 * Funktionen anlegen können, die exakt gleiche Namen haben.
 * Diese müssen sich aber in ihren Parametern unterscheiden -
 * nur dann können wir diese auch tatsächlich anlegen und ansteuern.
   HIER Versicherung hinzufügen!
*/

CREATE OR REPLACE FUNCTION f_remove_tax(amount numeric, lowered numeric)
	RETURNS numeric
	LANGUAGE plpgsql
AS
$$
DECLARE
	taxfree_amount numeric;
BEGIN
	taxfree_amount := ROUND(amount / (1.19 - lowered), 2);
	RETURN taxfree_amount;
END;
$$;

-- Test mit einem Wert:
SELECT f_remove_tax(100, 0.03);

-- Test mit unseren Filmen:
SELECT title,
       rental_rate,
       f_remove_tax(rental_rate)       AS without_normal_taxes,
       f_remove_tax(rental_rate, 0.03) AS without_lowered_taxes
FROM film;
-- Beide Versionen unserer Funktion existieren und funktionieren!

DROP FUNCTION IF EXISTS f_remove_tax(numeric);
DROP FUNCTION IF EXISTS f_remove_tax(numeric, numeric);

/* Übungsaufgabe 2:
   Schreibe eine Funktion, die Nachname und Vorname von Schauspielern entgegen-
   nimmt und ihre Namen sowie rechts daneben Titel + Beschreibung von Filmen
   ausgibt, in denen diese mitgespielt haben.
   Achtung: actor und film sind NICHT direkt verbunden.
   Es gibt eine vermittelnde Tabelle film_actor!

   Einfachere Version der Aufgabe: Verbinde film_actor und film und suche über
   actor_ids nach Filmen, in denen Schauspieler mit der betreffenden ID
   mitgespielt haben.

   Benennt die Funktion f_movie_info_by_artist_name
 */


-- Wieder entfernen:
DROP FUNCTION IF EXISTS f_movie_info_by_artist_name;