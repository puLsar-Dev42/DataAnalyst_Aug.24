/*
SQL – Lernkontrolle 2 (PostgreSQL)
Die möglichen Punkte stehen bei der jeweiligen Aufgabe dabei.

Verbinde dich mit dvd_rental.

Viel Erfolg!
*/


/*
1. Wie viele Kunden haben wir?
Wie viele Mitarbeiter haben wir? (Tipp: staff)
In der Ausgabe wird jeweils die Anzahl erwartet.
5 Pkt.
*/
SELECT COUNT(customer_id) AS number_of_customers
FROM customer;

SELECT COUNT(staff_id) AS number_of_employees
FROM staff;
/*
2. Wie viele Filme haben unsere top 10 (!) Kunden mit ID
jeweils ausgeliehen?
Bonus: Füge die Namen hinzu! (3 Pkt)
15 Pkt.
*/
WITH top_customers AS (SELECT r.customer_id,
                              COUNT(r.rental_id) AS counted_rentals
                       FROM rental AS r
                       GROUP BY r.customer_id
                       ORDER BY counted_rentals DESC
                       LIMIT 10)
SELECT tc.customer_id,
       c.first_name,
       c.last_name,
       tc.counted_rentals
FROM top_customers AS tc
	     JOIN customer AS c ON tc.customer_id = c.customer_id
ORDER BY tc.counted_rentals DESC;


/*
3. In der Tabelle 'film' gibt es in der Spalte 'rating' 5 verschiedene
Einstufungen der Filme als Abkürzungen aus Buchstaben und Zahlen
(G, NC-17, PG, R, PG-13)
Hier sind ihre Entsprechungen:
G: General Audience
NC-17: No Children Under 17
PG: Parental Guidance Suggested
R: Restricted
PG-13: Parents Strongly Cautioned

Dein Ziel: Filmnamen, Ratingkürzel sowie die ausgeschriebenen
Entsprechungen zu den Abkürzungen ausgeben lassen.
Die letzte Spalte soll dabei den Namen 'meaning' tragen.
15 Pkt.
*/
SELECT title,
       rating,
       CASE
	       WHEN rating = 'G'
		       THEN 'General Audience'
	       WHEN rating = 'NC-17'
		       THEN 'No Children Under 17'
	       WHEN rating = 'PG'
		       THEN 'Parental Guidance Suggested'
	       WHEN rating = 'R'
		       THEN 'Restricted'
	       WHEN rating = 'PG-13'
		       THEN 'Parents Strongly Cautioned'
	       END AS meaning
FROM film;

/*
4. Suche dir alle Filmtitel zusammen, die den Substring 'Doc' enthalten.
Lasse dir Filmtitel und Beschreibung ausgeben.
Achtung: Es soll case-sensitiv gesucht werden!
5 Pkt.
*/
SELECT title,
       description
FROM film
WHERE title ~ 'Doc';

/*
5. Lasse dir alle Filme ausgeben, die aus genau zwei vier Buchstaben langen
Worten bestehen.
10 Pkt.
*/
SELECT title
FROM film
WHERE title ~ '^\w{4} \w{4}$';


/*
6. Ersetze in allen diesen Filmtiteln das erste Wort durch 'DataCraft'.
5 Pkt.
*/
SELECT REGEXP_REPLACE(title, '^\w{4}', 'DataCraft')
FROM film
WHERE title ~ '^\w{4} \w{4}$';

/*
7. In rental bezeichnet die rental_id Ausleihen von Filmen.
Wie lange haben diese verschiedenen Ausleihen in Tagen jeweils gedauert?

Hinweis: Wir haben einen Automaten, der rund um die Uhr Filme annimmt.
Eine Tagesgebühr fällt erst an, wenn ein Tag voll ist.
Deswegen interessieren uns wirklich nur die Tage, nicht aber die Stunden etc.

Lass dir in der Ausgabe rental_id Ausleihdatum, Rückgabedatum sowie Ausleihdauer anzeigen.
Sortiere außerdem absteigend, um zu sehen, welche Ausleihe die längste war.
Filtere so, dass Filme, die nie zurückgegeben wurden, nicht erscheinen.

20 Pkt.
*/
SELECT rental_id,
       rental_date,
       return_date,
       (return_date::DATE - rental_date::DATE) AS rental_duration
FROM rental
WHERE return_date IS NOT NULL
ORDER BY rental_duration DESC;

/*
8. Wie kriegen wir die Wochentage zu den Ausleihdaten?
5 Pkt.
*/
SELECT TO_CHAR(rental_date, 'DAY') AS rental_day
FROM rental;

/*
9. Wie viele Filme wurden an den verschiedenen Wochentagen ausgeliehen?
Sortiere absteigend.
10 Pkt.
*/
SELECT TO_CHAR(rental_date, 'DAY') AS rental_day,
       COUNT(*)                    AS amount_of_rentals
FROM rental
GROUP BY rental_day
ORDER BY amount_of_rentals DESC;

/*
10. In 'film' gibt es die Spalte 'special_features', die Arrays enthält.
Die längsten Arrays bestehen dabei aus vier Teilen, siehe Code weiter unten.
Deine Aufgabe: Lasse dir die Filmtitel sowie die Features ausgeben,
wobei du die Features auf vier Spalten verteilst.
Nenne die Spalten: feature1, feature2, feature3, feature4.
10 Pkt.
*/

SELECT array_length(special_features, 1) AS arr_length
FROM film
ORDER BY arr_length DESC;

SELECT title,
       (special_features[1]) AS feature1,
       (special_features[2]) AS feature2,
       (special_features[3]) AS feature3,
       (special_features[4]) AS feature4
FROM film;