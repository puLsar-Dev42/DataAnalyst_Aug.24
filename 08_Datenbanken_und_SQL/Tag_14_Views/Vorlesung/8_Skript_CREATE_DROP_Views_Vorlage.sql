/* ----------------------------------------
 * Skript: CREATE, DROP, Views
 * ----------------------------------------
 * 
 * SELECT - Daten aus bestehenden Objekten auswählen
 * 
 * ------vv-- heute neu --vv-------
 * CREATE - Ein Objekt erstellen (z.B. Schema,
 * 			Tabelle, View, Funktion, Prozedur)
 * DROP   - Ein Objekt löschen
 * 
 */

/* --------------------
 * 1. Views 
 * --------------------
 * Views sind Pseudo-Tabellen, welche unter dem
 * Reiter Views bzw. Materialized Views sichtbar sind
 * (beides unter Schema auffindbar)
 * 
 * SELECT Abfragen können sich auf Views
 * beziehen (wie auf Tabellen)
 * 
 * -- 	Views werden immer neu erstellt wenn die
 * 		Tabelle aufgerufen / verändert wird
 * -- 	Vorteil: Aktuell -> Änderungen werden
 * 		mit aufgenommen
 * -- 	Nachteil: Langsam und rechenintensiv
 */

-- Wir arbeiten mit 'dvd_rental'

-- Erstellen von Views:

-- 1. Welche Daten soll der View überhaupt enthalten?
SELECT film_id,
	   title,
	   release_year,
	   length
FROM film
WHERE length > 100
ORDER BY length DESC;

-- 2. Den eigentlichen View erstellen:
CREATE VIEW long_movies AS
SELECT film_id,
	   title,
	   release_year,
	   length
FROM film
WHERE length > 100
ORDER BY length DESC;

-- Anschließend kann View wie eine Tabelle
-- abgerufen werden:
SELECT *
FROM long_movies;


-- View ist aber nicht unter dem Reiter
-- "Tabellen" zu finden, sondern unter
-- "Views" bzw. "Ansichten"

-- Möchte man View ersetzen: CREATE OR REPLACE
CREATE OR REPLACE VIEW long_movies AS
SELECT film_id,
	   title,
	   release_year,
	   length
FROM film
WHERE length > 120
ORDER BY length DESC;

-- Einschränkungen bei CREATE OR REPLACE:
-- 		Neue Spalten hinzufügen erlaubt.
-- 		Bestehende Spalten löschen geht nicht.
--		Muss vorher gelöscht werden.


-- Views zu erstellen hilft uns, Tabellen zu
-- erzeugen, auf die wir häufiger zugreifen wollen.
-- Beispiel:
-- Top ten Kunden unseres DVD-Geschäfts

-- Die Query:
SELECT last_name,
	   first_name,
	   SUM(amount) AS total_amount
FROM payment
		 JOIN customer
			  USING (customer_id)
GROUP BY customer_id
ORDER BY total_amount DESC
LIMIT 10;

-- Der View:
CREATE VIEW top_ten_customers AS
SELECT last_name,
	   first_name,
	   SUM(amount) AS total_amount
FROM payment
		 JOIN customer
			  USING (customer_id)
GROUP BY customer_id
ORDER BY total_amount DESC
LIMIT 10;

-- Reinschauen:
SELECT *
FROM top_ten_customers;

/* Übungsaufgaben: 1. Erstelle einen View, in dem alle Kunden des Geschäfts
   mit der store_id 1 mit customer_id, Nach- und Vornamen angeführt werden.
   Nenne ihn store_one_customers. Teste deinen View.
   2. Erstelle einen View german_customers, in dem alle deutschen Kunden
   mit Nachnamen, Vornamen, Mail, Stadt und Land (müsste immer Germany sein)
   angeführt werden. Teste deinen View.
   */

CREATE VIEW store_one_customers AS
SELECT customer_id,
	   last_name,
	   first_name,
	   store_id
FROM customer
WHERE store_id = 1;

SELECT *
FROM store_one_customers;

---
DROP VIEW german_customers;

CREATE VIEW german_customers AS
SELECT cu.customer_id,
	   cu.last_name,
	   cu.first_name,
	   a.address,
	   ci.city,
	   co.country
FROM customer AS cu
		 JOIN address AS a ON cu.address_id = a.address_id
		 JOIN city AS ci ON a.city_id = ci.city_id
		 JOIN country AS co ON ci.country_id = co.country_id
WHERE co.country = 'Germany';

SELECT *
FROM german_customers;

-- Abfragen aus einem View
-- Man kann einen View wie eine Tabelle behandeln!

-- Spalten auswählen:
SELECT title, length
FROM long_movies;

-- Bedingungen hinzufügen:
SELECT *
FROM long_movies
WHERE film_id BETWEEN 300 AND 500
  AND length > 160
  AND title LIKE 'G%';

-- Aggregationen durchführen geht natürlich auch:
SELECT ROUND(AVG(length), 2) AS average_length
FROM long_movies;
-- Allerdings ist dieses Beispiel etwas "bemüht".

-- Löschen eines Views
-- DROP
DROP VIEW long_movies;

-- Gelöschte Views lassen sich nicht
-- mehr aufrufen. Error:
SELECT *
FROM long_movies;

-- Views zu erstellen, spart nicht nur Tipparbeit. Es kann auch
-- die Sichtbarkeit von gewissen Inhalten einschränken und damit
-- dem Datenschutz im Unternehmen dienen.

-- Erstellen wir dafür ein neues Schema 'sekretariat'
CREATE SCHEMA secretariat;

-- Unser Sekretariat soll die Namen unserer Mitarbeiter sehen können,
-- aber NICHT die Spalten nach store_id, insbesondere nicht deren Passwörter!
-- Das soll das Sekretariat also sehen können:
SELECT staff_id,
	   first_name,
	   last_name,
	   address_id,
	   email,
	   store_id
FROM staff;

-- Views lassen sich direkt in richtigen Schemata
-- speichern. Dafür Zielschema festlegen mit
-- CREATE VIEW ziel_schema.view AS
-- (oder oben von public zu sekretariat wechseln!)

CREATE VIEW secretariat.staff_info AS
SELECT staff_id,
	   first_name,
	   last_name,
	   address_id,
	   email,
	   store_id
FROM staff;

-- Hätten wir jetzt Mitarbeiter und würden denen Zugangsdaten geben
-- könnten wir einstellen, dass sie z.B. nur auf 'sekretariat' Zugriff haben.
-- Damit würden sie die Passwörter unserer Mitarbeiter gar nicht erst einsehen können.

-- Folgendermaßen können wir auch auf Views zugreifen,
-- die nicht im aktuellen Schema vorhanden sind:
SELECT *
FROM secretariat.staff_info;

SELECT *
FROM public.top_ten_customers;

SELECT *
FROM customer;

/* Übungsaufgabe:
 * Erstelle einen View für das Schema 'sekretariat', in dem Kunden mit
   Kunden-ID, Vornamen, Nachnamen sowie den ersten fünf Buchstaben der Mailadresse, gefolgt von '***'
   erscheinen sowie dem Nachnamen des Mitarbeiters, der sie bedient.
   Nenne den View 'customer_with_staff'.
   */
-- DROP VIEW secretariat.customer_with_staff;

CREATE VIEW secretariat.customer_with_staff AS
	SELECT c.customer_id,
	       c.last_name,
	       c.first_name,
	       LEFT(c.email, 5) || '***' AS secret_email,
	       s.last_name AS staff_last_name
FROM customer AS c
JOIN staff AS s ON c.store_id = s.store_id;

--
-- Aus bestehenden Views lassen sich weitere
-- Views erzeugen
CREATE OR REPLACE VIEW secretariat.mikes_customers AS
SELECT *
FROM secretariat.customer_with_staff AS cws
WHERE cws.staff_last_name = 'Hillyer';

-- DROP VIEW mikes_customers;

SELECT *
FROM secretariat.mikes_customers;

-- Zwischen diesen Views besteht jetzt
-- eine Abhängigkeit. Will man den
-- ursprünglichen View (customer_with_staff)
-- löschen, muss man auch den davon
-- abhängigen View (mikes_customers) löschen

-- Geht nicht mehr:
DROP VIEW customer_with_staff;

-- Möglichkeit 1: Zuerst abhängigen View löschen, dann den anderen:
DROP VIEW mikes_customers;
DROP VIEW customer_with_staff;

-- Noch einfacher (aber auch gefährlicher, weil Kettenreaktion!):
DROP VIEW secretariat.customer_with_staff CASCADE;

/* --------------------
 * 2. Materialized Views 
 * --------------------
 * -- Materialized Views werden in Form von
 * 	  Daten + Abfrage fest gespeichert
 *     -> Keine Aktualisierung nach Änderungen der Daten (!!!)
 *     -> Nur manuelles Update
 * 
 * -- Vorteil: 	 - Schneller Zugriff
 * -- Nachteile: - Manuelle Überarbeitung notwendig
 *               - Speicherintensiv (Hohe Kosten)
 */
CREATE MATERIALIZED VIEW staff_names AS
SELECT last_name, first_name
FROM staff;

SELECT *
FROM staff_names;

-- Was passiert mit dem View, wenn ich einen neuen Mitarbeiter hinzufüge?
INSERT INTO staff
VALUES (3, 'Bach', 'Johann Sebastian', 1, 'jsbach@einfach-klassisch.de',
		1, true, 'Basti', 'e323213213213213', '2024-03-06 11:30:22');

-- Blick in Staff
SELECT *
FROM staff;

-- Und wie sieht es jetzt in unserem materialisiertem View aus?
SELECT *
FROM staff_names;

-- Soll ein solcher View aktualisiert werden, dann hilft nur REFRESH:
REFRESH MATERIALIZED VIEW staff_names;

SELECT *
FROM staff_names;

-- Materialized Views können nicht einfach
-- ersetzt werden. Error:
CREATE OR REPLACE MATERIALIZED VIEW staff_names AS
SELECT first_name AS vorname,
	   last_name  AS nachname,
	   staff_id   AS ID
FROM staff;

-- Wollen wir diesen ersetzen, müssen wir ihn
-- zuerst löschen mit DROP
DROP MATERIALIZED VIEW staff_names;

-- Spuren beseitigen (Bach aus 'staff' wieder entfernen):
DELETE
FROM staff
WHERE staff_id = 3;

-- Alle Drops, die man so brauchen könnte ;)
DROP VIEW IF EXISTS long_movies;
DROP VIEW IF EXISTS top_ten_customers;
DROP VIEW IF EXISTS store_one_customers;
DROP VIEW IF EXISTS german_customers;
DROP VIEW IF EXISTS customer_with_staff CASCADE;
DROP MATERIALIZED VIEW IF EXISTS staff_names;
DROP SCHEMA IF EXISTS secretariat CASCADE;