/* 
 * Neuerungen in Postgres und Arrays
 * ---------------------------------------
 */

-- ADD ORDER BY YEAR AND QUARTER!

/*
 * -------------
 * 1. Datetime
 * -------------
 * 
 * Link zur Postgres-Dokumentation  (Date-Funktionen):
 * https://www.postgresql.org/docs/current/datatype-datetime.html
 */
-- Wir arbeiten mit der dvd_rental! --

-- Datumsarithmetik
-- Integer abziehen basiert auf Tagen, nicht
-- auf Jahren wie bei SQLite
SELECT '2024-02-26'::DATE - 10 AS ten_days_before;
SELECT '2024-02-26'::DATE + MAKE_INTERVAL(days => 10) AS ten_days_later;

-- Wollen wir etwas Eindeutigeres/Komplexeres, dann brauchen wir MAKE_INTERVAL:
SELECT '2024-02-26'::DATE + MAKE_INTERVAL(months => 10) AS ten_months_later;
SELECT '2024-02-26'::DATE + MAKE_INTERVAL(years => 1, months => 10) AS much_later;
-- Auch in für Postgres typischer Schreibweise möglich mit '::':
SELECT '2024-02-26'::DATE + '10 MONTHS'::INTERVAL AS ten_months_later;

-- Bei timestamp: ERROR bei einfacher Subtraktion:
SELECT '2023-02-10 00:00:00'::timestamp;
SELECT '2023-02-10 00:00:00'::timestamp - 10;
-- Mit MAKE_INTERVAL Arbeit dagegen möglich:
SELECT '2023-02-10 00:00:00'::timestamp - MAKE_INTERVAL(years => 10);

-- rental-Tabelle: 1 Jahr zum Rechnungsdatum hinzufügen
-- In Tagen:
SELECT rental_date,
       rental_date + '365 days'::INTERVAL
FROM rental;

SELECT rental_date,
       rental_date + make_interval(days => 365)
FROM rental;

-- In Jahren:
SELECT rental_date,
       rental_date + '1 year'::INTERVAL AS next_year
FROM rental;

-- In Jahren + Umwandlung in Datum:
SELECT rental_date::date,
       (rental_date + '1 year'::INTERVAL)::date
	       AS next_year
FROM rental;

-- Berechnen mit zwei Daten (Unterschied)
SELECT '2009-02-09'::date - '2008-04-17'::date;
-- Erzeugt Ganzzahl für Anzahl von Tagen.

-- Age-Funktion -> Interval berechnen zwischen zwei timestamps
SELECT AGE('2009-02-09'::date, '2008-04-17'::date);
-- erzeugt Intervall-Datentypen

-- Ein paar nützliche Extraktionen:
SELECT rental_date::DATE,
       DATE_PART('DOW', rental_date)     AS day_of_week,
       TO_CHAR(rental_date, 'Day')       AS day_name,
       DATE_PART('QUARTER', rental_date) AS quarter,
       DATE_PART('YEAR', rental_date)    AS year
FROM rental;

-- Gemeinsame Aufgabe: Wir wollen nach Jahr und Quartal Einnahmen summieren!


/* --------------------------
 * 2. String-Funktionen
 * --------------------------
 */
-- split_part(TEXT, TRENNZEICHEN, BESTANDTEIL)
-- SMILAR TO

-- Auftrennen von Strings am Beispiel von Mails:
SELECT email,
       SPLIT_PART(email, '@', 2)
FROM customer;

-- Ein bisschen mehr (und komplexer):
SELECT SPLIT_PART(email, '@', 1)                     AS name,
       SPLIT_PART(SPLIT_PART(email, '@', 2), '.', 1) AS domain,
       SPLIT_PART(SPLIT_PART(email, '@', 2), '.', 2) AS domain_endung
FROM customer;

-- Bei LIKE haben nur % und _ Spezialbedeutung
SELECT title
FROM film
WHERE title LIKE 'S_______'
   OR title LIKE 'K%';

-- SIMILAR TO kann mehr als Like,
-- und nutzt einen Teil der Regex-Zeichen z.B. Klammern
-- Ohne dass ^ oder $ genutzt werden, gehen die Pattern immer auf einen fullmatch.
SELECT title
FROM film
WHERE title SIMILAR TO '[L|K]%';

-- Was ist das hier?
SELECT title
FROM film
WHERE title SIMILAR TO '[L|K]%e+';
-- Beschreibung:

/* 2.1. Reguläre Ausdrücke / Regular expressions / Regex
 * -----------
 * 
 * Reguläre Ausdrücke können in Postgres in Vergleichen
 * mit dem '~'-Operator durchgeführt werden.
 * 
 * Hier ist das ganze Regex-Spektrum verfügbar
 * 
 * regexp_replace: Text mittels Regex ersetzen
 * regexp_match(es): Text (Gruppen) extrahieren
 */
SELECT title
FROM film
WHERE title ~ '^[KL].*';

-- Aufgabe: Suche nach Filmnamen, die an zweiter Stelle ein 'a' haben und auf ein
-- 'e' enden.
SELECT title
FROM film
WHERE title SIMILAR TO '_a%e';

SELECT title
FROM film
WHERE title ~ '^.a.*e$';

-- Ersetzen von Textbestandteilen
SELECT *
FROM language;

SELECT REGEXP_REPLACE(name, 'German', 'Deutsch')
FROM language;

SELECT REGEXP_REPLACE(email, 'sakilacustomer', 'august_kurs')
FROM customer;

-- Mit Regexp_Match die Domain extrahieren (statt zwei Split_Parts):
SELECT REGEXP_MATCH(email, '@(.*)\.') AS domain_name
FROM customer;
-- Das Ergebnis ist die jeweils extrahierte Gruppe als Array (kommt später!)

/* Übung: SONGS ABOUT LOVE */
-- 1. Alle Songs finden, in denen Love
-- vorkommt (mittels Regex)


-- 2. In den entsprechenden Filmen "Love"
-- durch "Hate" ersetzen (mittels Regexp)  


-- Demo zu Flag 'g'...
SELECT REGEXP_REPLACE('Life is Life, bla blaa blablablaaa', 'Life', 'Death', 'g');

-- TRIM(string_spalte)
-- Anfang abschneiden LEADING
SELECT TRIM(LEADING '+' FROM '+++Hallo+++');

-- Ende abschneiden TRAILING
SELECT TRIM(TRAILING '+' FROM '+++Hallo+++');

-- Beide Enden gleichzeitig BOTH
SELECT TRIM(BOTH '+-!' FROM '-!++-+Hallo! Mein Freund+++');
-- Ohne Angabe macht TRIM standardmäßig BOTH!:
SELECT TRIM('+-!' FROM '-!++-+Hallo! Mein Freund+++');

-- LTRIM, RTRIM als einfache Versionen
SELECT LTRIM('+++Hallo+++', '+');

SELECT RTRIM('+++Hallo+++', '+');

-- Standardverhalten entfernt überhängende Leerzeichen rechts und links:
SELECT TRIM('   Hey    ');
-- Das Ergebnis des Trimmens ist in der Tat nur noch der rein String (Länge 3):
SELECT LENGTH(TRIM('   Hey    '));

/* --------------------------
 * 3. Arrays
 * --------------------------
 * 
 * Bei Postgres können in einzelnen Zellen
 * auch Arrays gespeichert werden. 
 * So ist es z.B. möglich, mehrere Adressen
 * pro Kunde zu speichern.
 * 
 * - Ein Array wird mit ARRAY [] erstellt.
 * 
 * - Beim Erstellen einer Tabelle wird eine
 * 	 Array-Spalte mit dem dtype und eckigen 
 *   Klammern erstellt. Also z.B. "text[]".
 * 	 Ist es ein 2-dimensionales Array, so 
 *   werden zwei Klammern verwendet "text[][]".
 * 
 * - Mit eckigen Klammern können (genau wie
 * 	 bei Python) Elemente aus Arrays
 * 	 herausgenommen werden:
 *   "array_spalte[1]"
 *   Achtung: Indizierung beginnt bei 1 und nicht bei 0!
 * 
 * - unnest - Arrays in einzelne Zeilen
 * 			  entpacken
 *   any    - testen, ob ein Wert im Array
 * 			  enthalten ist.
 */
SELECT ARRAY [1, 2, 3, 4];

-- Mit [] Elemente extrahieren
SELECT (ARRAY [5, 6, 7, 8])[2];

-- Slicing mit : möglich
SELECT (ARRAY [5, 6, 7, 8])[2:3];

-- Länge des Arrays bestimmen
-- Dimension muss immer mit angegeben werden
SELECT ARRAY_LENGTH(ARRAY [5, 6, 7, 8], 1);

-- Zweidimensionales Array
SELECT ARRAY [[1, 2, 3, 4], [4, 5, 6, 7]];

-- Bei mehrdimensionalen Arrays können wir
-- nach Länge der einzelnen Dimensionen fragen
SELECT ARRAY_LENGTH(ARRAY [[1, 2, 3, 4], [4, 5, 6, 7]], 1);
SELECT ARRAY_LENGTH(ARRAY [[1, 2, 3, 4], [4, 5, 6, 7]], 2);

-- Texte in Arrays zerlegen
-- STRING_TO_ARRAY(TEXT, TRENNZEICHEN)
SELECT STRING_TO_ARRAY('Hallo Du', ' ');

SELECT STRING_TO_ARRAY(email, '@')
FROM customer;

SELECT STRING_TO_ARRAY(address, ' ')
FROM address;

SELECT STRING_TO_ARRAY(email, '@')
FROM customer;

-- Array auf Zeilen entpacken mit UNNEST
SELECT UNNEST(ARRAY [5, 6, 7, 8]);
-- Wenn ein Array entpackt wird, entstehen i.d.R. in der Tabelle Mehrfach-Einträge:
SELECT title, UNNEST(special_features)
FROM film;

-- Bei mehrdimensionalen Arrays werden
-- Werte untereinander gelegt (wie flatten bei Numpy)
SELECT UNNEST(ARRAY [[5, 6, 7, 8], [1, 2, 3, 4]]);

-- Logische Überprüfungen mit Arrays
-- All = Alle
SELECT 1 = ALL (ARRAY [1, 1, 1]);

SELECT 3 = ALL (ARRAY [3, 3, 1]);

-- Any = Mindestens eins
SELECT 2 = ANY (ARRAY [1, 2, 3]);

SELECT 5 = ANY (ARRAY [1, 2, 3]);

-- Mit Match/Matches kann man Gruppen extrahieren!
-- Zurück kommt eine Gruppe oder ein ganzes Array,
-- das an den geschwungenen Klammern erkennbar ist.
-- Zunächst extrahieren wir nur die Domain.
SELECT REGEXP_MATCH(email, '@(.*)\.') AS domain_name
FROM customer;

-- Falls uns die Array-Klammern nerven, gibt es einen Trick:
SELECT ARRAY_TO_STRING(REGEXP_MATCH(email, '@(.*)\.'), 'TEXT') AS domain_name
FROM customer;

-- Mehrere Gruppen herausholen!
SELECT REGEXP_MATCHES(email, '(.*)@(.*)\.(.*)') AS mail_parts
FROM customer;

-- Nicht wirklich, was wir wollen, oder?
SELECT UNNEST(REGEXP_MATCHES(email, '(.*)@(.*)\.(.*)')) AS mail_parts
FROM customer;

-- Ein Weg, das Array auf Spalten zu verteilen:
SELECT mail_parts[1] AS username,
       mail_parts[2] AS domain,
       mail_parts[3] AS top_level_domain
FROM (SELECT REGEXP_MATCHES(email, '(.*)@(.*)\.(.*)') AS mail_parts
      FROM customer) AS subquery;

