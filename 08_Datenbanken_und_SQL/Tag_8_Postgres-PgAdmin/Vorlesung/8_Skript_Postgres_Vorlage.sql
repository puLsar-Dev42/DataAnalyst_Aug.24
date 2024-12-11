/* 
 * Neuerungen in Postgres
 * -------------
 * 
 */

/*
 * -------------
 * 1. Grundlegendes
 * -------------
 */

/*
 * PostgreSQL achtet sehr auf Groß- und
 * Kleinschreibung.
 */
-- Wir arbeiten mit der Northwind-Datenbank.

-- Bevor wir loslegen, erstellen wir eine Testtabelle in Northwind,
-- um etwas zu demonstrieren.
DROP TABLE IF EXISTS "Testing";
CREATE TABLE "Testing"
(
	"TestID"     SERIAL PRIMARY KEY,
	"SomeValues" VARCHAR(25)
);
INSERT INTO "Testing" ("SomeValues")
VALUES ('Joseph Roth');
INSERT INTO "Testing" ("SomeValues")
VALUES ('Irmgard Keun');
INSERT INTO "Testing" ("SomeValues")
VALUES ('Wladimir Woinowitsch');

-- Unter SQLite wäre es egal, wie wir
-- einen Spalten- und Tabellennamen schreiben
-- SQLite-Möglichkeiten:
SELECT *
FROM testing;

SELECT *
FROM TESTING;

SELECT *
FROM tESting;

-- Postgres reicht aber nicht einmal
-- eine exakte Bezeichnung
SELECT *
FROM Album;

-- In Postgres werden Tabellen- und Spaltennamen
-- in einer Abfrage immer als kleingeschrieben interpretiert
-- Lösung: Anführungszeichen um den Tabellennamen!
SELECT *
FROM "Testing";

-- Deshalb sollten Tabellen und Spalten
-- möglichst immer kleingeschrieben werden
-- Was für Tabellennamen gilt, gilt auch für Spaltennamen
-- Auch bei anderen Abfragebestandteilen funktioniert Postgres anders.
-- Folgende Abfrage würde unter SQLite
-- einen Namen zurückgeben (denn LIKE is 'case insensitive'):
SELECT *
FROM "Testing"
WHERE "SomeValues" LIKE '%ro%';

-- Unter Postgres muss es entweder '%Ro% heißen'
SELECT *
FROM "Testing"
WHERE "SomeValues" LIKE '%Ro%';

-- Für case insensitivity dagegen nutzt man ILIKE:
SELECT *
FROM "Testing"
WHERE "SomeValues" ILIKE '%ro%';

-- Lasst uns Testing nun wegschmeißen, das sie nix in Northwind verloren hat.
DROP TABLE IF EXISTS "Testing";

-- Sollte nun einen Fehler geben:
SELECT *
FROM "Testing";

-- Typenumwandlung
-- -------------
-- CAST

-- Wir haben bereits CAST als Möglichkeit
-- kennengelernt, Datentypen zu verändern
SELECT CAST(500.2 AS INT);

-- Übrigens wird bei Postgres beim Umwandeln in Ganzzahlen gerundet!
SELECT CAST(500.5 AS INT);

-- Umwandlung in Text:
SELECT CAST(500 AS VARCHAR);

-- ::

-- Postgres gibt uns weitere Möglichkeit,
-- mit der wir Datentypen anpassen können
SELECT 500.7::INT;

SELECT 500::VARCHAR;

SELECT "TestID"::VARCHAR,
       "TestID"
FROM "Testing";

-- Die '::'-Schreibweise ist spezifisch für Postgres
-- und kommt in anderen SQL-Formen nicht
-- vor.

/*
 * -------------
 * 2. Datetime
 * -------------
 * 
 * Link zur Postgres-Dokumentation  (Datumsfunktionen):
 * https://www.postgresql.org/docs/current/datatype-datetime.html
 */

-- Datumskonstanten in SQL
-- Heutiges Datum
SELECT CURRENT_DATE;

-- Aktuelle Zeit
SELECT CURRENT_TIME;

-- Aktueller Zeitstempel (nach SQL-Standard)
SELECT CURRENT_TIMESTAMP;

-- Aktueller Zeitstempel (nur in Postgres)
SELECT NOW();

-- Aktuelle Uhrzeit
SELECT LOCALTIME;

/* Befehle zum Erstellen von Daten:
 * -------------
 *   - 	make_date: Erstellt ein Datum
 * 		in der Form (Year, Month, Day)
 *   - 	make_time: Erstellt eine Uhrzeit
 * 		mit Stunde, Minute und Sekunde
 *   - 	make_timestamp: Erstellung eines
 * 		timestamps (Datum+Uhrzeit)
 *      -> Year,Month,Day,Hour,Min,Sec
 **/
-- Doku: https://www.postgresql.org/docs/16/functions-datetime.html

-- Datum erstellen
SELECT MAKE_DATE(2022, 2, 9) AS date;

-- Zeit erstellen
SELECT MAKE_TIME(16, 30, 45) AS time;

-- Zeitstempel erstellen
SELECT MAKE_TIMESTAMP(2023, 01, 25, 11, 30, 22)
	       AS timestamp;

-- Zeitstempel mit Zeitzone erstellen
SELECT MAKE_TIMESTAMPTZ(2023, 01, 25, 11, 30, 22, 'PST')
	       AS timestamp_with_zone;

-- Zeitzonen-Systemvariable in Postgres
-- mit SHOW anzeigen lassen
SHOW timezone;

-- Mit SET kann Zeitzone geändert werden
SET timezone = 'America/Los_Angeles';
SELECT NOW();

SET timezone = 'Europe/Berlin';
SELECT NOW();

SHOW TIME ZONE;
-- Ist nur für die Session gültig! Wird später wieder auf UTC zurückgesetzt!

-- Intervalle erstellen
SELECT MAKE_INTERVAL(days => 10) AS days;
SELECT MAKE_INTERVAL(years => 2) AS years;


/* Konvertieren von Strings zu Date
 * Datumsfunktionen in Postgres sind deutlich ausgeprägter!
 * -------------
 *  SQLite:   DATE()
 *  Postgres: to_date()
 * -------------
 *   - MON  -> Monat als drei Buchstaben Text
 *   - MM   -> Monat als zweistellige Zahl
 *   - YYYY -> Jahr als vierstellige Zahl
 *   - DD   -> Tag als zweistellige Zahl
 */
SELECT TO_DATE('10 02 2023', 'DD MM YYYY');

SELECT TO_DATE('10 Feb 2023', 'DD.MON.YYYY');

SELECT TO_DATE('02.10.2023', 'MM.DD.YYYY');

SELECT TO_DATE('10-02-2023', 'DD-MM-YYYY');

/* Konvertieren von Date zu Strings
 * -------------
 *  SQLite:   strftime(date, string_format)
 *  Postgres: to_char(date, string_format)
 * -------------
 */

SELECT TO_CHAR('2023-11-23'::DATE, 'MM');

SELECT TO_CHAR(orderdate, 'DD.YYYY')
FROM orders;

-- Age-Funktion -> Interval berechnen
-- zwischen zwei Timestamps
SELECT AGE(
		       NOW(),
		       MAKE_DATE(1985, 09, 03)
       ) AS alter;

-- Nur in Jahren interessant?
SELECT DATE_PART('YEAR',
                 AGE(
		                 NOW(),
		                 MAKE_DATE(1985, 09, 03)
                 )
       ) AS alter;

-- Das Jahr aus einer Datumsspalte holen:
SELECT EXTRACT('YEAR' FROM orderdate)
FROM orders;

-- Wie viel Zeit liegt zwischen heute und den Bestellungen?
SELECT orderid,
       orderdate                                AS too_much_timestamp,
       DATE(orderdate),
       DATE_PART('YEAR', AGE(NOW(), orderdate)) AS age_in_years,
       AGE(NOW(), orderdate)                    AS precise_age
FROM orders;

-- Überschneiden sich die zwei Zeitintervalle? -> OVERLAPS
SELECT (DATE '2001-02-16', DATE '2001-12-21') OVERLAPS
       (DATE '2001-10-30', DATE '2002-10-30');

SELECT (DATE '2001-02-16', DATE '2001-10-29') OVERLAPS
       (DATE '2001-10-30', DATE '2002-10-30');
      
