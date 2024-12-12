/* Tagesaufgaben PostgreSQL und Datetime
 * ------------------------------------------------------
 */


-- Verbinde dich mit dvd_rental

/* 1.
 * ----
 * Extrahiere die ersten drei Buchstaben der Filmnamen
 * aus der Tabelle film.
 */
SELECT SUBSTRING(title FROM 1 FOR 3) AS first_three_letters
FROM film;

/* 2.
 * ----
 * Wandle nun dieselbe Spalte in einen VARCHAR(3) um.
 * Was fällt auf?
 */
SELECT title::VARCHAR(3) AS first_three_letters
FROM film;
-->> Es ist das selbe Resultat wie in Aufgabe 1!

/* 3.
 * ----
 * Dich interessiert folgende Information:
 * Wer sind die Top 10 Kunden unseres Verleihs mit ID, Nachnamen und Vornamen?
 * Und wie viel Geld hat jeder dieser Kunden bei uns insgesamt gelassen?
 */
SELECT c.customer_id AS customer_id,
       c.last_name   AS lastname,
       c.first_name  AS firstname,
       SUM(p.amount) AS total_spent
FROM customer AS c
	     JOIN payment AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.last_name, c.first_name
ORDER BY total_spent DESC
LIMIT 10;

/* 4.
 * ----
 * Lass dir eine Liste aller Filme ausgeben, die
   a) auf einen beliebigen Buchstaben, gefolgt von 'ee' anfangen
   b) auf einen der Buchstaben 'L' bis 'P' anfangen und auf ein 'e' enden.
 */
SELECT title
FROM film
WHERE title ~ '^.ee.*$';

SELECT title
FROM film
WHERE title ~ '^[L-P].*e$';

/* 6.
 * ----
 * Lass dir die Spalte rental_date
 * aus der Tabelle rental anzeigen.
 */
SELECT rental_date
FROM rental;

/* 7.
 * ----
 * Lass dir nur Monat und Tag für jede Rechnungsnummer anzeigen.
 * (Zieltabelle hat zwei Spalten!)
 */
SELECT rental_id,
       TO_CHAR(rental_date, 'MM-DD') AS month_and_day
FROM rental
ORDER BY rental_id;

/* 8.
 * ----
 * Lass dir a) alle Infos zu Rechnungen der Tabelle rental
 * vom 15. Juni bis (einschließlich) 30. Juni
 * des Jahres 2005 für die Kundennummern zwischen 100 und 300 anzeigen.
 * b) Wie viele Einträge umfasst dieser Ausschnitt?
 * c) Welche top 5 Kunden (mit ID + Namen) haben sich
 * die meisten Filme ausgeliehen?
 */

-- a.)
SELECT *
FROM rental
WHERE rental_date BETWEEN '2005-06-15' AND '2005-06-30'
  AND customer_id BETWEEN 100 AND 300;

-- b.)
SELECT COUNT(*)
FROM rental
WHERE rental_date BETWEEN '2005-06-15' AND '2005-06-30'
  AND customer_id BETWEEN 100 AND 300;

-- c.)
SELECT c.customer_id,
       c.last_name,
       c.first_name,
       COUNT(r.rental_id) AS counted_rentals
FROM rental AS r
	     JOIN customer AS c ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.last_name, c.first_name
ORDER BY counted_rentals DESC
LIMIT 5;

/* 9.
 * ----
 * Gruppiere die payment-Tabelle nach
 * dem Jahr des Rechnungsdatums und zeige
 * das jeweilige Jahr als Text, sowie
 * den Gesamtumsatz und Durchschnittsumsatz
 * pro Rechnung des Jahres an.
 */
SELECT TO_CHAR(payment_date, 'YYYY') AS year_text,
       SUM(amount)                   AS total_revenue,
       AVG(amount)                   AS average_revenue
FROM payment
GROUP BY TO_CHAR(payment_date, 'YYYY')
ORDER BY year_text;


/* 10. Bonus
 * ----
 * In der Tabelle film gibt es die Spalte special_features.
 * special_features enthält Arrays mit Bonus-Materialien zu den Filmen.
 * Entpacke die Arrays auf Spalten.
 * Benenne die entstehenden Spalten first_feature, second_feature ...
 * In der ausgegebenen Tabelle sollen die jeweiligen Filmtitel, gefolgt von den
 * Features als Spalten erscheinen.
 */
SELECT title,
       (special_features[1]) AS first_feature,
       (special_features[2]) AS second_feature,
       (special_features[3]) AS third_feature,
       (special_features[4]) AS fourth_feature
FROM film;
