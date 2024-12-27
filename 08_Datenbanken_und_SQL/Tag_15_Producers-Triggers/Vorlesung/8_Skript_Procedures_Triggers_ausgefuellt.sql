/* 
 * -------------------------------------------
 * Skript: 	Procedures & Triggers
 * -------------------------------------------
 * 
 * Benötigte Datensätze: Werden im Skript erstellt
 */

/* In Postgres besteht der Hauptunterschied zwischen
einer Funktion und einer gespeicherten Prozedur darin,
dass eine Funktion ein Ergebnis zurückgibt, während eine
gespeicherte Prozedur etwas durchführt, aber nichts zurückgibt.
*/

-- Allgemeiner Aufbau von Procedures -- 
/*
create [or replace] procedure procedure_name(parameter_list)
language plpgsql
as 
$$
declare
	variable declaration
begin
	procedure body
end; 
$$;
*/

-- Aufbau von Procedures damit eigentlich 1:1 gleich zu Funktionen.

-- Neue Spielzeug-Datenbank anlegen (und damit verbinden):
DROP DATABASE IF EXISTS wohnungsverlauf;
CREATE DATABASE wohnungsverlauf;

-- Tabelle erstellen:
CREATE TABLE wohnorte
(
    id      SERIAL,
    wohnort VARCHAR(100),
    jahr    SMALLINT
);

-- Normalerweise würden wir über INSERT INTO neue Einträge in Tabelle
-- eintragen
INSERT INTO wohnorte(wohnort, jahr)
VALUES ('Potsdam', 2001);

SELECT *
FROM wohnorte;

-- Wir erstellen nun eine Prozedur dafür:
CREATE OR REPLACE PROCEDURE add_city(
    city_wohnort TEXT,
    city_jahr INT
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO wohnorte(wohnort, jahr)
    VALUES (city_wohnort, city_jahr);
END;
$$;

-- Aufrufen einer Prozedur mit CALL:
CALL add_city('New York', 2010);
CALL add_city('Boston', 2015);
CALL add_city('Los Angeles', 2020);

SELECT *
FROM wohnorte;

-- Korrigieren eines früheren Eintrages (Update):

-- "Von Hand":
UPDATE wohnorte
SET wohnort = 'Hörnum',
    jahr    = 2012
WHERE id = 1;

SELECT *
FROM wohnorte;

-- Das Ganze als Prozedur
-- Jahr wird optional behandelt und COALESCE erhält im Fall, dass city_jahr NULL ist, jahr.

SELECT COALESCE(NULL, 'Hallo');
SELECT COALESCE('Welt', NULL);
SELECT COALESCE('Hallo', 'Welt');

CREATE OR REPLACE PROCEDURE update_city(
    city_id INT,
    city_wohnort TEXT,
    city_jahr INT DEFAULT NULL
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE wohnorte
    SET wohnort = city_wohnort,
        jahr    = COALESCE(city_jahr, jahr)
    WHERE id = city_id;
END;
$$;

SELECT *
FROM wohnorte;

CALL update_city(3, 'New Boston', 2017);
CALL update_city(3, 'Boston');

SELECT *
FROM wohnorte;

-- Löschen eines früheren Eintrags (DELETE FROM)
CREATE OR REPLACE PROCEDURE delete_city(city_id INT)
    LANGUAGE plpgsql
AS
$$
BEGIN
    DELETE
    FROM wohnorte
    WHERE id = city_id;
END;
$$;

CALL delete_city(3);

SELECT *
FROM wohnorte;

/* Übungsaufgabe (Bank transfer Procedure):
 * Wir wollen eine Bank in SQL simulieren. Wichtige Funktionen:
 * 1. Überweisen/Transfer von Geld -> Von einem Konto auf ein anderes
 * --> Eine Überweisung braucht die Parameter Geldgeber (id),
 * 	   Geldempfänger (id), Betrag
 * --> Tipp: Rufe die Geldgeber/Empfänger anhand Ihrer id auf
 * 2. Geld abheben
 * 3. Geld einzahlen
 * Nutze die dir gegebenen Daten um diese Funktionalitäten
 * einer Bank in Form von stored procedures abzubilden
 *
 * Teste die Funktionalität deiner erstellten stored procedures in dem du
 * folgendes ausführst:
 * 1. Bill überweist Jerry 1000 Geldeinheiten
 * 2. Bill hebt 500 Geldeinheiten von seinem Konto ab
 * 3. Bill zahlt 750 Geldeinheiten in sein Konto ein
 */
CREATE TABLE konten
(
    id         serial PRIMARY KEY,
    "name"     text    NOT NULL,
    kontostand numeric NOT NULL
);

INSERT INTO konten("name", kontostand)
VALUES ('Bill', 10500);

INSERT INTO konten("name", kontostand)
VALUES ('Joe', 20500);

INSERT INTO konten("name", kontostand)
VALUES ('Jerry', 1000);

SELECT *
FROM konten;

-- Lösung:
-- Einzahlen
CREATE OR REPLACE PROCEDURE einzahlen(
    kunden_id int,
    betrag NUMERIC)
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE konten
    SET kontostand = kontostand + betrag
    WHERE id = kunden_id;
END;
$$;

CALL einzahlen(1, 750);

SELECT *
FROM konten;

-- Abheben
CREATE OR REPLACE PROCEDURE abheben(
    kunden_id int,
    betrag NUMERIC)
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE konten
    SET kontostand = kontostand - betrag
    WHERE id = kunden_id;
END;
$$;

CALL abheben(1, 500);

SELECT *
FROM konten;


-- Überweisen
CREATE OR REPLACE PROCEDURE transfer(
    sender_id int,
    empfaenger_id int,
    betrag NUMERIC)
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE konten
    SET kontostand = kontostand - betrag
    WHERE id = sender_id;
    UPDATE konten
    SET kontostand = kontostand + betrag
    WHERE id = empfaenger_id;
END;
$$;

CALL transfer(1, 2, 1000);

SELECT *
FROM konten;


-- TRIGGER --
-- Einstiegsfrage: Was passiert, wenn jemand von etwas "getriggert" wird?

-- Trigger in SQL
/* Trigger sind Abläufe in Postgres, welche automatisch aufgerufen werden,
sobald eine Abfrage wie ein Insert, Delete oder Update ausgeführt wird.
Dazu braucht es zwei Teile:
1) eine Funktion, die bestimmte Aktionen durchführt
2) den Trigger selbst, der die Funktion mit einer Tabelle verknüpft
und eine Bedingung formuliert, unter der die Funktion automatisch startet.
*/

-- Aufbau von Funktionen ist bereits bekannt.

/*Aufbau von Triggern:

CREATE TRIGGER trigger_name [BEFORE|AFTER|INSTEAD OF] event_name
ON table_name
[
 -- Hier kommt die Trigger-Logik zum Tragen:
 -- Besonders wichtig für uns heute:
 -- FOR EACH ROW/ STATEMENT EXECUTE FUNCTION
 -- mehr hier: https://www.postgresql.org/docs/current/sql-createtrigger.html
];
*/

/*
BEFORE | AFTER | INSTEAD OF legt dabei fest, WANN der Trigger greifen soll.
Event_name bezeichnet das Ereignis, das den Trigger auslöst,
wie INSERT, DELETE, UPDATE, TRUNCATE.
*/

/*
Beispiel:
Bei jedem Hinzufügen einer neuen Stadt in wohnorte soll in
einer anderen Tabelle der Zeitpunkt des Schreibzugriffs gespeichert
werden. Hier brauchen wir die id des Wohnorts und den Zeitstempel.
*/

-- Neue Speichertabelle anlegen
DROP TABLE IF EXISTS wohnort_log;

CREATE TABLE wohnort_log
(
    city_id    SERIAL,
    entry_date TIMESTAMP
);

-- 1. Funktion zum Anlegen von Wohnort-Logs schreiben
-- Weil die Funktion nie von uns aufgerufen wird, KEINE Parameter
CREATE OR REPLACE FUNCTION f_wohnort_log_func()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO wohnort_log (entry_date)
    VALUES (CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$;

-- 2. Trigger selbst erstellen (in Beziehung zur richtigen Tabelle)
CREATE TRIGGER wohnort_insert_trigger
    AFTER INSERT
    ON wohnorte
    FOR EACH ROW
EXECUTE FUNCTION f_wohnort_log_func();
-- Trigger, der für geschriebene Zeile in wohnorte die Funktion
-- f_wohnort_log_func ausführt

-- Nachdem Trigger-Funktion und Trigger selbst erstellt sind,
-- wird er automatisch bei einem Insert ausgeführt
SELECT *
FROM wohnorte;

SELECT *
FROM wohnort_log;

CALL add_city('Zutzenhausen', 2021);
CALL add_city('Duisburg', 2023);
CALL add_city('Bern', 2024);

SELECT *
FROM wohnorte;

SELECT *
FROM wohnort_log;

-- Aber irgendwas will noch nicht passen!
-- Was haben wir falsch gemacht?
-- Nicht spicken!

-- Kommentar: SERIAL ist doof. Wir brauchen eigentlich die city_ids, die
-- in wohnorte entstehen, wenn dort hineingeschrieben wird.

/* OLD und NEW!
 * Im Falle einer Wertaktualisierung erlauben Trigger
 * die Ansteuerung des alten und neuen Wertes.
 * So kann in Log-Tabellen nachvollzogen werden, was
 * geändert wurde und wie der Wert vorher war.
 */

-- wohnort_log von vorne aufziehen:
DROP TABLE IF EXISTS wohnort_log;

CREATE TABLE wohnort_log
(
    city_id    INT,
    entry_date TIMESTAMP
);

-- Funktion mit Bestandteilen von NEW
CREATE OR REPLACE FUNCTION f_wohnort_log_func()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO wohnort_log (city_id, entry_date)
    VALUES (NEW.id, CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$;

-- Beim Schreiben in der Tabelle wohnorte holen wir uns den neuen Wert in der
-- Spalte id, der nach dem Schreibvorgang dort steht und tragen den in unserem
-- wohnort_log in der Spalte city_id ein!
CALL add_city('Isengard', 0);

SELECT *
FROM wohnorte;

SELECT *
FROM wohnort_log;

-- Mit old und new
CREATE TABLE wohnort_update_log
(
    city_id       INT,
    mod_date      TIMESTAMP,
    from_cityname VARCHAR(100),
    to_cityname   VARCHAR(100)
);

CREATE OR REPLACE FUNCTION f_wohnupdate_log_func()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT INTO wohnort_update_log(city_id, mod_date, from_cityname,
                                   to_cityname)
    VALUES (NEW.id, CURRENT_TIMESTAMP, OLD.wohnort, NEW.wohnort);
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER wohnort_update_trigger
    AFTER UPDATE
    ON wohnorte
    FOR EACH ROW
EXECUTE FUNCTION f_wohnupdate_log_func();

SELECT *
FROM wohnorte;

CALL update_city(2, 'New Jersey');

SELECT *
FROM wohnorte;

SELECT *
FROM wohnort_update_log;

-- Was passiert bei mehreren Zeilen auf einen Schlag?

INSERT INTO wohnorte(wohnort, jahr)
VALUES ('München', 1930),
       ('Pforzheim', 2293),
       ('Bielefeld', 1887);

SELECT *
FROM wohnorte;

SELECT *
FROM wohnort_log;