/*
SQL – Lernkontrolle 1
Die möglichen Punkte stehen bei der jeweiligen Aufgabe dabei.

Benutze die sqlite-sakila.db-Datenbank.

Achtung: In gewissen Spalten sind die Einträge komplett großgeschrieben!

1. Lass dir die komplette Tabelle film anzeigen. 2 Pkt.
*/
SELECT *
FROM film;

/*
2. Lass dir nur die ersten 20 Titel der Tabelle film anzeigen. 3 Pkt.
*/
SELECT *
FROM film
LIMIT 20;

/*
3. Lass dir von den Videothek-Kunden Nachname, Vorname und Email anzeigen.
Die Einträge sollen nach Nachnamen alphabetisch aufsteigend sortiert sein.
5 Pkt.
*/
SELECT first_name,
       last_name,
       email
FROM customer
ORDER BY last_name;

/*
4. Wähle erneut dieselben Spalten aus, aber benenne sie dieses Mal um in:
Nachname, Vorname, Email.
5 Pkt.
*/
SELECT last_name AS Nachname,
       first_name AS Vorname,
       email AS Email
FROM customer
ORDER BY last_name;

/*
5. Lass dir den Titel, das Rating und die Leihgebühr der zehn teuersten Filme ausgeben
("teuersten" bezogen auf die Leihgebühr). 10 Pkt.
*/
SELECT title,
       rating,
       rental_rate
FROM film
ORDER BY rental_rate DESC
LIMIT 10;

/*
6. Lass dir nur die Einträge anzeigen, die eine Leihdauer (rental duration)
von 7 haben (Tabelle film). 5 Pkt.
*/
SELECT title,
       rating,
       rental_duration
FROM film
WHERE rental_duration = 7;

/*
7. Lass dir alle Titel anzeigen, die kürzer als 120 Minuten sind und ein Rating
von PG-13 haben (Tabelle film). 10 Pkt.
*/
SELECT title
FROM film
WHERE length < 120
AND rating = 'PG-13';

/*
8. Lass dir alle Einträge der Tabelle actor ausgeben, die zu Personen gehören,
deren Vorname entweder Bob oder Cameron ist. 5 Pkt.
*/
SELECT *
FROM actor
WHERE first_name like 'bob'
   OR first_name like 'cameron';

/*
9. Lass dir alle Schauspieler mit den Vornamen Reese und Penelope ausgeben,
die nicht den Nachnamen Guiness haben. 5 Pkt.
*/
SELECT *
FROM actor
WHERE first_name LIKE 'reese'
   OR first_name LIKE 'penelope'
   AND NOT last_name LIKE 'guiness';


/*
10. Lass dir alle Vornamen der Familie Hoffman anzeigen und sortiere sie alphabetisch
(Tabelle actor). 5 Pkt.
*/
SELECT first_name
FROM actor
WHERE last_name LIKE 'hoffman'
ORDER BY first_name;


/*
11. Lass dir alle Ländernamen ausgeben, die mit dem Wort "United" anfangen
(Tabelle country). 5 Pkt.
*/
SELECT country
FROM country
WHERE country LIKE 'united%';


/*
12. Lass dir alle Länder-IDs und Ländernamen von Ländern ausgeben,
die ein "ou" im Namen tragen
(Tabelle country). 5 Pkt.
*/
SELECT country_id,
       country
FROM country
WHERE country LIKE '%ou%';


/*
13. Welche unterschiedlichen typischen Bezahlbeträge gibt es in der Tabelle
payment?
5 Pkt.
*/
SELECT DISTINCT amount
FROM payment;


/*
14. Welche Vornamen haben deine Kunden? (Ohne Duplikate!).
Bitte alphabetisch sortiert.
5 Pkt.
*/
SELECT DISTINCT first_name AS Vorname
FROM customer
ORDER BY first_name ASC;


/*
15. Lass dir Titel, Erscheinungsjahr und Sprache (als String, z.B. "English")
von Filmen ausgeben, deren Titel kürzer als 10 Zeichen ist (Leerzeichen inklusive).
10 Pkt.
*/
SELECT f.title AS Title,
       f.release_year AS Erscheinungsjahr,
       l.name AS Sprache
FROM language AS l
JOIN film AS f
USING (language_id)
WHERE title LIKE '_________';


/*
16. Lass dir die ausgeschriebene Adresse der beiden Stores aus Tabelle store zusammen
mit der Videothek-ID (store id) anzeigen. 5 Pkt.
*/
SELECT ad.address AS Addresse,
       s.store_id AS VideotheksID
FROM address AS ad
JOIN store AS s
USING (address_id);



/*
17. Lass dir Ausleihdatum, Filmtitel sowie Nachnamen und Vornamen von Kunden
sowie Mitarbeitern ausgeben. Über den Spalten mit Von- und Nachnamen sollte Folgendes
stehen: customer_lastname, customer_firstname, staff_lastname, staff_firstname
10 Pkt.
*/
SELECT r.rental_date AS rental_date,
       f.title AS movie_title,
       c.last_name AS customer_lastname,
       c.first_name AS customer_firstname,
       s.last_name AS staff_lastname,
       s.first_name AS staff_firstname
FROM rental AS r
JOIN inventory AS i
    USING (inventory_id)
JOIN film AS f
USING (film_id)
JOIN customer AS c
    USING (customer_id)
JOIN staff AS s
USING (staff_id);


