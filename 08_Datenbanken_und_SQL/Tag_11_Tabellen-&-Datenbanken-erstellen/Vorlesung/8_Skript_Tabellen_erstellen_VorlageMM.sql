/* 
 * -------------------------------------------
 * Skript: 	Erstellen und Füllen von Tabellen,
 * 			Constraints
 * -------------------------------------------
 * 
 */

DROP DATABASE IF EXISTS haushalt;

-- Befehl, um eine neue Datenbank zu erstellen:
CREATE DATABASE haushalt;

/*
 * --------------------------------------------------
 * 1. Erstellen, Befüllen und Verändern von Tabellen
 * --------------------------------------------------
 */

-- Tabellenname, Variable, Datentyp
DROP TABLE IF EXISTS budget;

-- Bei numerischen Spalten lohnt sich ein Blick hier drauf:
-- https://www.postgresql.org/docs/current/datatype-numeric.html

CREATE TABLE budget
(
	id      INT,
	date    DATE,
	balance DECIMAL(12, 2) -- Bis zu 9.99... (nahezu 10) Billionen möglich.
);

-- Zugreifen auf erstellte Tabelle
-- -> Diese wird noch leer sein (nur Header)
SELECT *
FROM budget;

-- Befüllen mit INSERT INTO
-- Aufbau: INSERT INTO tabellenname (spalte1, spalte2, ...) VALUES (wert1, wert2, ...)
INSERT INTO budget
VALUES (1, '2020-01-05', 5500);

-- Alternative Schreibweise mit angeführten Spaltennamen:
INSERT INTO budget (id, date, balance)
VALUES (2, '2020-01-14', 4300);
-- Wenn alle Spalten ohnehin aufgefüllt werden, sind Spaltenangaben optional.

-- Check:
SELECT *
FROM budget;

-- Mehrere Zeilen hinzufügen (einfach mehrere Werte-Tupel nach VALUES):
INSERT INTO budget
VALUES (3, '2020-01-26', 2900),
       (4, '2020-01-29', 2100),
       (5, '2020-02-03', 15300);

-- Wieder das Ergebnis checken:
SELECT *
FROM budget;

-- Was, wenn ein Eintrag entfernt werden soll? (Hier ID 13)
INSERT INTO budget
VALUES (13, '2020-01-26', -999);

-- Tabelle vor Entfernung:
SELECT *
FROM budget;

-- Jetzt wird nach ID 13 entfernt:
DELETE
FROM budget
WHERE id = 13;

-- Tabelle nach Entfernung:
SELECT *
FROM budget;

-- Fehler bei Eintrag 5 gemacht und wir wollen nicht eine ganze Zeile entfernen?
-- Kein Problem mit UPDATE.
UPDATE budget
SET balance = 5300
WHERE id = 5;

SELECT *
FROM budget;

/* Übungsaufgabe 1:
   Erstelle eine Tabelle lifestyle mit den Spalten:
   id, date, work, hobbies, sleep
   Darin sollen Stunden eingegeben werden, die den Tätigkeiten gewidmet wurden.
   Füge eine Zeile mit frei gewählten Werten (ID ist aber 1) hinzu.
   Dann füge vier weitere Zeilen auf einmal hinzu.
   Füge noch eine Zeile hinzu und schreibe diesmal ausdrücklich,
   dass du die Spalten mit Ausnahme von sleep mit Werten befüllst.
   Was ist die Folge davon?
   Du hast dich nach dem Anlegen erinnert, dass du ja doch geschlafen hast,
   wenn auch nur 4.5 Stunden. Trage in der Zeile über die ID des Eintrags
   nachträglich den Wert ein!
   Entferne schließlich die Zeile mit der ID 3.
   Schaue immer wieder zwischendurch, ob alles nach Plan läuft!
 */

CREATE TABLE lifestyle
(
	id      INT,
	date    DATE,
	work    DECIMAL,
	hobbies DECIMAL,
	sleep   DECIMAL
);

INSERT INTO lifestyle
VALUES (1, '2024-12-16', 7, 2, 7);

INSERT INTO lifestyle
VALUES (2, '2024-10-06', 9, 0.5, 8),
       (3, '2024-09-03', 12, 3, 7.5),
       (4, '2024-11-22', 6.5, 1.5, 6.5),
       (5, '2024-08-12', 7.5, 3.5, 7);

INSERT INTO lifestyle
VALUES (42, '1985-09-03', 13.5, 0.5);

UPDATE lifestyle
SET sleep = 4.5
WHERE id = 42;

DELETE
FROM lifestyle
WHERE id = 3;
/*
 * --------------------------------------------------
 * 2. Primärschlüssel gegen böse Duplikate und NULLs
 * --------------------------------------------------
 */
-- Wir erinnern uns an 'budget':
SELECT *
FROM budget;

-- Lasst uns "aus Versehen" Eintrag 5 zwei Mal einfügen:
INSERT INTO budget
VALUES (5, '2020-02-03', 5300);

-- Sieht nicht gut aus:
SELECT *
FROM budget;

-- Quizfrage: Wie entfernen wir den letzten Eintrag?
DELETE
FROM budget
WHERE id = 5;

-- Was wurde alles entfernt?
SELECT *
FROM budget;
-- Das war zu viel.

-- Lösung: Immer einen PRIMÄRSCHLÜSSEL in jeder Tabelle haben,
-- über den man jeden einzelnen Eintrag ansteuern kann.

-- Dieselbe Tabelle mit einem Primärschlüssel:
DROP TABLE IF EXISTS budget;

CREATE TABLE budget
(
	id      INT PRIMARY KEY,
	date    DATE,
	balance DECIMAL(12, 2)
);

INSERT INTO budget
VALUES (1, '2020-01-05', 5500),
       (2, '2020-01-14', 4300),
       (3, '2020-01-26', 2900),
       (4, '2020-01-29', 2100),
       (5, '2020-02-03', 5300);

-- Was passiert, wenn wir jetzt die 5 ein weiteres Mal hinzufügen?
INSERT INTO budget
VALUES (5, '2020-02-03', 5300);
-- Beobachtung:

-- Was passiert, wenn wir nur Spalte date und balance ausfüllen?
INSERT INTO budget (date, balance)
VALUES ('2020-02-07', 4900);
-- Postgres erhält keinen Wert für ID und versucht, NULL einzutragen.
-- NULL-Werte sind aber in Primärschlüsseln verboten.

-- Wie wäre es mit IDs, die automatisch erzeugt werden, wenn wir neue
-- Einträge anlegen? Das Stichwort lautet SERIAL
-- (oder nach Bedarf smallserial/bigserial)
-- Erstellen wir also wieder die Tabelle von vorne:
DROP TABLE IF EXISTS budget;

CREATE TABLE budget
(
	id      SMALLSERIAL PRIMARY KEY,
	date    DATE,
	balance INT
);

-- Lassen wir einmal die IDs weg und schauen, was dann passiert
INSERT INTO budget (date, balance)
VALUES ('2020-01-05', 5500),
       ('2020-01-14', 4300),
       ('2020-01-26', 2900),
       ('2020-01-29', 2100),
       ('2020-02-03', 5300);

-- Schauen, was passiert ist:
SELECT *
FROM budget;

-- Quizfrage: Warum ist so eine automatisch um eins ansteigende (auto-incrementing)
-- ID-Spalte sinnvoll?


/* Übungsaufgabe 2:
   Erstelle die Tabelle 'lifestyle' von oben, aber diesmal mit
   einem Primärschlüssel, wo die IDs automatisch aufsteigend erstellt werden.
   Füge die ersten fünf Zeilen auf einen Schlag und ohne Angaben von IDs
   der Tabelle hinzu.
 */
-- Hier lösen und NICHT nach unten spicken!
DROP TABLE IF EXISTS lifestyle;

CREATE TABLE lifestyle
(
	id      SMALLSERIAL PRIMARY KEY,
	date    DATE,
	work    DECIMAL(4, 2),
	hobbies DECIMAL(4, 2),
	sleep   DECIMAL(4, 2)
);


INSERT INTO lifestyle (date, work, hobbies, sleep)
VALUES ('2024-12-16', 7.25, 2.75, 7.5),
       ('2024-10-06', 9.75, 0.5, 8.25),
       ('2024-09-03', 11.75, 3.25, 7.25),
       ('2024-11-22', 6.5, 1.5, 6.5),
       ('2024-08-12', 7.5, 3.5, 5.25);

SELECT *
FROM lifestyle;

-- Alternative Schreibweise:
DROP TABLE IF EXISTS budget;

CREATE TABLE budget
(
	id      SERIAL,
	date    DATE,
	balance DECIMAL,
	PRIMARY KEY (id)
);

INSERT INTO budget (date, balance)
VALUES ('2020-01-05', 5500),
       ('2020-01-14', 4300),
       ('2020-01-26', 2900),
       ('2020-01-29', 2100),
       ('2020-02-03', 5300);

-- Führt zum selben Ergebnis:
SELECT *
FROM budget;

-- Primärschlüssel bei Tabellenerstellung vergessen?
-- Nachträglich mit ALTER TABLE auch möglich!

DROP TABLE IF EXISTS budget;

-- Wir vergessen, Primärschlüssel zu setzen:
CREATE TABLE budget
(
	id      SERIAL,
	date    DATE,
	balance DECIMAL(12, 2)
);

-- Frage: Wird das hier nun funktionieren?
INSERT INTO budget (date, balance)
VALUES ('2020-01-05', 5500),
       ('2020-01-14', 4300),
       ('2020-01-26', 2900),
       ('2020-01-29', 2100),
       ('2020-02-03', 5300);
-- Antwort:

SELECT *
FROM budget;

-- Nachträglich die ID-Spalte zum Primärschlüssel erheben.
ALTER TABLE budget
	ADD PRIMARY KEY (id);

-- Quizfrage: Wenn Serial alles vermeidet, was der Primärschlüssel nicht erlaubt
-- (keine doppelten Werte, keine NULL-Werte) – wozu dann überhaupt Primärschlüssel?
-- Antwort: ...über PRIMARY KEYS können Verknüpfungen erzeugt werden was nur mit SERIAL nicht klappt!

/*
 * --------------------------------------------------
 * 3. Einschränkungen (Constraints) an Spalten
 * --------------------------------------------------
 */
-- NOT NULL / UNIQUE bei "gewöhnlichen" Spalten
-- Lasst uns die Tabelle 'lifestyle' anders nachbauen:
DROP TABLE IF EXISTS lifestyle;

CREATE TABLE lifestyle
(
	id      SERIAL PRIMARY KEY,
	date    DATE UNIQUE,
	work    DECIMAL,
	hobbies DECIMAL,
	sleep   DECIMAL NOT NULL
);
-- Quizfrage: Was passiert mit date und sleep?

-- Wird diese Eintragung klappen?
INSERT INTO lifestyle (date, work, hobbies, sleep)
VALUES ('2024-02-26', 8, 1.5, 7.5),
       ('2024-02-27', 6, 3, 6),
       ('2024-02-27', 6, 3, 6),
       ('2024-02-29', 7, 2, 7.5);
-- Kommentar: ...NEIN!

-- Wie versprechend ist dieser Versuch?
INSERT INTO lifestyle (date, work, hobbies, sleep)
VALUES ('2024-02-26', 8, 1.5, 7.5),
       ('2024-02-27', 6, 3, 6),
       ('2024-02-28', 7, 0.5, 8),
       ('2024-03-01', 7, 2, NULL);
-- Kommentar: ...

/*
 * --------------------------------------------------------------
 * 4. Die großen Drops: Spalten, Tabellen, Datenbanken entfernen
 * --------------------------------------------------------------
 */
-- Lasst uns eine weitere Datenbank erstellen:

CREATE DATABASE nothing_special;

-- Wechsel von Datenbank haushalt zur Datenbank nothing_special
-- oben bei der Verbindung!
-- Sonst wird alles Nachfolgende in 'haushalt' geschrieben.

CREATE TABLE boring_stuff
(
	id            SERIAL PRIMARY KEY,
	activity      VARCHAR(255),
	secret_number INT
);

INSERT INTO boring_stuff (activity, secret_number)
VALUES ('Spießrutenlauf', 666),
       ('Kursvorbereitung', 142),
       ('Wohnung aufräumen', 222);

SELECT *
FROM boring_stuff;

-- Ups, 'secret_number' sollte da aber nicht hin:
-- Kein Problem: Mit ALTER TABLE Tabelle nennen, die verändert werden soll,
-- mit DROP <column_name> die Spalte entfernen, die weg soll:
ALTER TABLE boring_stuff
	DROP secret_number;

-- Check:
SELECT *
FROM boring_stuff;

-- Aber eigentlich brauchen wir die ganze Tabelle nicht:
DROP TABLE boring_stuff;

-- Tabelle sollte nicht mehr existieren und eine Fehlermeldung kommen:
SELECT *
FROM boring_stuff;

-- Und wenn wir schon dabei sind, dann schmeißen wir gleich
-- die ganze Datenbank weg.
-- Vorher müssen wir uns aber zu einer anderen verbinden (klassisch: postgres).
DROP DATABASE nothing_special;

-- Abschließendes zu PRIMARY KEY:
-- Das Spannende an Primärschlüsseln ist, dass sie
-- bei der Verknüpfung von Tabellen den Wertebereich
-- der Tabelle einschränken, auf die sie als Fremdschlüssel verweisen.
-- Mehr dazu am Tag zu Foreign Keys und ERD!


/* Übungsaufgabe 3:
   Erstellt in der Gruppe eine Datenbank datacraft_kurs.
   Erstellt darin wieder eine Tabelle namens kurs_verlauf,
   die über die Spalten Datum, Modul, Tagesthema und
   eventuell weitere verfügt. Ergänzt um eine Spalte
   'verschlafen', die die Werte true oder false annehmen kann.
   Füllt die Tabelle mit Inhalten für mindestens fünf Tage
   unseres SQL-Moduls.
   Entfernt dann doch die Spalte 'verschlafen'.
   Dann könnt ihr die Tabelle wieder entfernen.
   Und schließlich auch die Datenbank.
   Umsetzungen können gern am Folgetag gezeigt werden!
 */

DROP DATABASE IF EXISTS datacraft_course;

DROP TABLE IF EXISTS course_history;

CREATE DATABASE datacraft_course;

CREATE TABLE course_history
(
	module       VARCHAR(255) NOT NULL,
	day          SERIAL PRIMARY KEY,
	date         DATE         NOT NULL UNIQUE,
	daily_topics VARCHAR(255) NOT NULL,
	notes        VARCHAR(255) NOT NULL,
	overslept    BOOLEAN      NOT NULL
);

INSERT INTO course_history(module, date, daily_topics, notes, overslept)
VALUES ('sql', '2024-12-02', 'database-introduction',
        'script day 1', FALSE),
       ('sql', '2024-12-03', 'select-statement',
        'script day 2', FALSE),
       ('sql', '2024-12-04', 'distinct-strings-logic',
        'script day 3', FALSE),
       ('sql', '2024-12-05', 'joins-union-subqueries',
        'script day 4', FALSE),
       ('sql', '2024-12-06', 'group_by-having-aggregation',
        'script day 5', FALSE),
       ('sql', '2024-12-09', 'case_when',
        'script day 6', FALSE),
       ('sql', '2024-12-10', 'regexp',
        'script day 7', FALSE),
       ('sql', '2024-12-11', 'postgresql-pgadmin',
        'script day 8', FALSE),
       ('sql', '2024-12-12', 'further_psql_special_features',
        'script day 9', FALSE),
       ('sql', '2024-12-13', 'functions',
        'script day 10', FALSE),
       ('sql', '2024-12-16', 'create_database-&-tables',
        'script day 11', FALSE),
       ('sql', '2024-12-17', '???',
        'script day 12', FALSE);

ALTER TABLE course_history
	DROP overslept;

DROP TABLE IF EXISTS course_history;

DROP DATABASE IF EXISTS datacraft_course;
