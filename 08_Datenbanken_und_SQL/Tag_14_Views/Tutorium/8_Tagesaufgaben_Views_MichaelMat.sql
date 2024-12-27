/*
Tagesaufgaben (VIEWs)

Arbeite mit der Datenbank 'dvd_rental'.

1. Erstelle einen View, der nur über eine Spalte mit den vollständigen Namen
von Schauspielern aus der Tabelle 'actor' verfügt.
*/

CREATE VIEW actor_names AS
SELECT a.first_name || ' ' || a.last_name AS actor_name
FROM actor AS a;

/*
2. Lass dir deinen neuen View ausgeben.
 */

SELECT *
FROM actor_names;

/*
3. Lösche den View wieder, den du in Aufgabe 1 erzeugt hast.
*/

DROP VIEW actor_names;

/*
4. Erstelle den gleichen View, wie in Aufgabe 1. Nutze dieses Mal allerdings nur die Einträge,
bei denen der Vorname mit einem 'A' anfängt. Nenne den View, 'actor_names_a'.
*/

CREATE VIEW actor_names_a AS
SELECT a.first_name || ' ' || a.last_name AS actor_name
FROM actor AS a
WHERE a.first_name LIKE 'A%';

SELECT *
FROM actor_names_a;

/*
5. Erstelle den gleichen View, wie in Aufgabe 1. Nutze dieses Mal allerdings nur die Einträge,
bei denen der Vorname mit einem 'D' anfängt. Nenne den View 'actor_names_d'.
*/

CREATE VIEW actor_names_d AS
SELECT a.first_name || ' ' || a.last_name AS actor_name
FROM actor AS a
WHERE a.first_name LIKE 'D%';

SELECT *
FROM actor_names_d;

/*
6. Lass dir nun alle Einträge aus dem View aus Aufgabe 4 und 5 in einer Spalte anzeigen.
*/

SELECT actor_name
FROM actor_names_a
UNION
SELECT actor_name
FROM actor_names_d
ORDER BY actor_name;

/*
7. Erstelle einen Materialized View, in dem man alle Titel der Tabelle 'film' und die Sprache des
Films (ausgeschrieben) sieht.
*/

CREATE MATERIALIZED VIEW title_and_language AS
SELECT f.title,
	   l.name
FROM film AS f
		 JOIN language AS l on l.language_id = f.language_id
GROUP BY l.name, f.title
ORDER BY l.name;

/*
8. Lass dir deinen neuen View aus Aufgabe 7 anzeigen.
*/

SELECT *
FROM title_and_language;

/*
9. Erkläre den Unterschied zwischen einem Materialized View und einem normalen View!

--> ANTWORT: <--
-->	Also die Unterschiede liegen darin das VIEWS immer Aktuell sind, sprich alle änderungen werden mit übernommen.
	Und MATERIALIZED VIEWS müssen immer manuell per REFRESH aktualisiert werden. <--

*/

/*
10. Lass dir alle Film-IDs anzeigen, bei denen die category 'Comedy' ist. Nutze dafür
Subqueries, verwende keinen JOIN
*/

SELECT film_id
FROM film_category
WHERE category_id = (SELECT category_id
					 FROM category
					 WHERE name = 'Comedy');

/*
11. Optional: Finde heraus, welche 10 Kunden die meisten Filme ausgeliehen haben.
*/


/*
12. Lass dir den durchschnittlichen Verleihpreis zu den verschiedenen Ratings ausgeben.
*/

SELECT rating,
	   ROUND(AVG(rental_rate), 2) AS avg_rental_price
FROM film
GROUP BY rating
ORDER BY avg_rental_price;

/*
13. Optional: Zähle, wie häufig Filme mit dem Rating 'R' ausgeliehen wurden. Nutze
keine JOINS, sondern Subqueries!
*/

