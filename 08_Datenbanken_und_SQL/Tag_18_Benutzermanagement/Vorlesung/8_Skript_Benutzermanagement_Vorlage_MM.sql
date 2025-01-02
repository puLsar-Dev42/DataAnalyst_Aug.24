/* 
 * ===============================================================
 * Skript: Benutzermanagement und Rollen 
 * ===============================================================
 * 
 * Verwendetes DBMS: PostgreSQL
 * Verwendete Datenbank: user_management (wird erstellt)
 */


/* ------------------------------------
 * Typische Rollen bei Datenbanken ----
 * ------------------------------------
 * Welche typischen Rollen beim Umgang mit Datenbanken gibt es 
 * und welche Aufgaben/ Rechte haben diese?
 * Eine Übersicht aller vordefinierten Rollen in postgres finden sich hier:
 * https://www.postgresql.org/docs/current/predefined-roles.html
 * Die Gesamtübersicht zu Benutzermanagement befindet sich hier:
 * https://www.postgresql.org/docs/current/user-manag.html
 */

CREATE DATABASE user_management;

-- Nicht vergessen, zu dieser Datenbank zu verbinden!

-- Test-Tabelle anlegen
CREATE TABLE test_table
(
    user_id SERIAL PRIMARY KEY,
    name    VARCHAR(100),
    age     INT
);

SELECT *
FROM test_table;


-- ROLLEN ERSTELLEN UND VERWALTEN
-- ------------------------------

-- Infos über alle verfügbaren vordefinierten Rollen:
SELECT *
FROM pg_roles;

/* Die Attribute von Rollen in dieser Tabelle:
   rolsuper: Hat dir Rolle "Superkräfte" (darf alles, Bsp.: postgres)?
   rolinherit: Erbt Privilegien anderer Rollen, zu denen die Rolle gehört
   rolcreaterole: Darf selbst weitere Rollen erstellen
   rolcreatedb: Darf Datenbanken erstellen
   rolcanlogin: Kann sich einloggen (ist ein Einzelnutzer und keine Gruppe)
   rolconnlimit: Maximale Anzahl Verbindungen, die eine Rolle zunlässt (-1 heißt unbegrenzt)
   rolpassword: gespeichertes gehashtes Passwort
   rolvaliduntil: Gültigkeitszeitraum der Rolle (bei Null unbegrenzt)
   rolbypassrls: Ist von Sicherheit auf Zeilenebene (row level security) betroffen
   rolconfig: zusätzliche Rollenkonfigurationen (wird i.d.R. nicht genutzt)
   oid: object identifier (eindeutige, dieser Rolle zugeordnete Zahl)
   to be continued
 */
-- So sehen wir nur die Rollen, die sich einloggen können:
SELECT rolname
FROM pg_roles
WHERE rolcanlogin;

-- Es gibt also bereits einige voreingestellte Rollen
-- mit unterschiedlichen Berechtigungen.
-- Aber was bedeutet eigentlich so etwas wie der Rollenname pg_read_all_data
-- ohne Login-Berechtigung und wozu könnte so etwas nützlich sein?
-- Antwort: ...

-- Was ist denn meine aktuelle Rolle?
SELECT current_role;

-- postgres ist der Admin (hier: superuser genannt) 
-- und hat damit alle Rechte.

-- Zuteilung zu einer vordefinierten Rolle 
-- (z.B. Rolle mit lediglich Leseberechtigung)
SET ROLE pg_read_all_data;

SELECT current_role;

--Damit können wir Tabellen weiterhin lesen...
SELECT *
FROM test_table;

--... allerdings können wir Tabellen jetzt nicht mehr ändern!
ALTER TABLE test_table
    ADD COLUMN neue_spalte int;

INSERT INTO test_table
VALUES (1, 'Chen', 31);

SELECT *
FROM pg_tables;

-- Überprüfen, ob wir Lese- und Schreibprivilegien haben:
SELECT schemaname,
       tablename,
       has_table_privilege(tablename, 'SELECT') AS can_select,
       has_table_privilege(tablename, 'UPDATE') AS can_update,
       has_table_privilege(tablename, 'DELETE') AS can_delete
FROM pg_tables
WHERE schemaname NOT LIKE 'pg_%'
  AND schemaname != 'information_schema';

SELECT schemaname,
       tablename,
       has_table_privilege(tablename, 'INSERT') AS can_insert
FROM pg_tables
WHERE schemaname NOT LIKE 'pg_%'
  AND schemaname != 'information_schema';
-- Zu Privilegien an Objekten: https://www.postgresql.org/docs/current/ddl-priv.html

-- Rückkehr zur superuser Rolle (In unserem Fall: postgres)
SET ROLE postgres;

-- Alternativ:
SET ROLE NONE;

-- Als superuser haben wir wieder die gewohnten Möglichkeiten,
-- unsere Tabellen und Datenbanken zu verändern:
INSERT INTO test_table
VALUES (1, 'Chen', 31);

SELECT *
FROM test_table;

-- Wir können und sollten aber abseits der vorgefertigten Rollen
-- auch eigene Rollen erstellen.

-- Erstellen einer Rolle:
CREATE ROLE mega_user;

-- Aber: Die Rolle existiert zwar, hat aber noch überhaupt 
--       keine Rechte
SELECT *
FROM pg_roles;

SET ROLE megauser;

SELECT *
FROM test_table;

SET ROLE postgres;

-- Löschen einer Rolle:
DROP ROLE mega_user;

/*
Übung: 
--------
Nutze ein Mal den Befehl 
create role megauser;

und ein Mal den Befehl 
create user megauser2;

Rufe die angelegten Rollen aus pg_roles auf.
Fällt dir beim Vergleichen etwas auf?
Entferne die Rollen schließlich wieder.
*/

CREATE ROLE mega_user;

CREATE USER mega_user2;

SELECT *
FROM pg_roles;

DROP ROLE mega_user;
DROP USER mega_user2;

/* Beim Erstellen von Rollen müssen die oben bereits betrachteten ATTRIBUTE vergeben werden
 * Diese beschreiben, was ein Nutzer darf und was nicht.

superuser status             --> Umgeht alle Sicherheiten bis auf Login.
                                 Attribut: SUPERUSER
database creation            --> Darf Datenbanken erstellen.
                                 Attribut: CREATEDB
role creation                --> Darf Rollen erstellen und verändern 
                                 (außer Superuser). Attribut: CREATEROLE
initiating replication       --> Darf mit Servern kommunizieren, 
                                 benötigt mindestens auch Login. Attribut: REPLICATION LOGIN
password                     --> Setzt Passwort für Nutzer. 
                                 Attribut: PASSWORD 'passwd'
login                        --> ermöglicht das Einloggen des users. Attribut: LOGIN
inheritance of privileges    --> Jede Rolle bekommt die 
                                 Eigenschaften von Rollen vererbt, in welcher sie 
                                 Mitglied ist. Dies lässt sich ausschalten. 
                                 Attribut: NOINHERIT
bypassing row-level security --> Darf jede Tabellenveränderung 
                                 vornehmen. Attribut: BYPASSRLS
connection limit             --> Gibt ein Limit an, wie viele 
                                 Verbindungen ein Nutzer herstellen kann. 
                                 Standard bei -1 (unendlich). 
                                 Attribut: CONNECTION LIMIT 'integer'
*/

-- Principle of least privileges (POLP)
-- -> Sparsam mit Rechte-Verteilung umgehen

-- Wenn wir eine Rolle erstellen, können wir ihr direkt
-- ein Passwort mitgeben:
CREATE ROLE dora_datenfels
    LOGIN PASSWORD '1337hax';

-- Alternativ ohne LOGIN direkt als Nutzer erstellen:
CREATE USER nathan_netzmacher
    PASSWORD '74!2d9n$';

SELECT *
FROM pg_roles;

-- Wenn eine Rolle bereits besteht, können wir diese mit 
-- ALTER ROLE verändern.
ALTER ROLE dora_datenfels WITH
    LOGIN PASSWORD 'test';

-- Kann Dora Tabellen auslesen?
SET ROLE dora_datenfels;

SELECT *
FROM test_table;

-- nein, weil ihr die Rechte fehlen

-- BERECHTIGUNGEN ERTEILEN
-- -----------------------
-- Leseberechtigung für dora_datenfels erteilen: GRANT SELECT
SET ROLE postgres;

GRANT SELECT ON test_table TO dora_datenfels;

SET ROLE dora_datenfels;

SELECT *
FROM test_table;

-- Insert geht nach wie vor nicht.
INSERT INTO test_table
VALUES (2, 'Yusuf', 41);

-- Wie wäre es, wir loggen uns mal als Dora ein, statt immer in ihre Rolle zu schlüpfen?

-- Sollte Dora nicht direkt auf die Datenbank zugreifen können, hilft Folgendes:
-- GRANT CONNECT ON DATABASE user_management TO dora_datenfels;

-- Zum Einloggen über die Kommandozeile:
-- https://www.prisma.io/dataguide/postgresql/connecting-to-postgresql-databases

-- Weitere Berechtigungen über entsprechende Statements
-- GRANT UPDATE
-- GRANT ALTER

-- Mehrere Rechte auf einmal vergeben
-- TABLE keyword ist optional
SET ROLE postgres;

GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE test_table TO nathan_netzmacher;

SET ROLE nathan_netzmacher;

SELECT schemaname,
       tablename,
       has_table_privilege(tablename, 'SELECT') AS can_select,
       has_table_privilege(tablename, 'UPDATE') AS can_update,
       has_table_privilege(tablename, 'DELETE') AS can_delete
FROM pg_tables
WHERE schemaname NOT LIKE 'pg_%'
  AND schemaname != 'information_schema';

-- Genau so können wir ihm die Delete-Berechtigung wieder entziehen
-- REVOKE
REVOKE DELETE ON test_table FROM nathan_netzmacher;

-- Eine Rolle erstellen, die Attribute von vordefinierten Rollen erhält:
DROP USER IF EXISTS oliver_overfloh;

CREATE USER oliver_overfloh
    PASSWORD 'floh123';

GRANT pg_read_all_data, pg_write_all_data TO oliver_overfloh;

SET ROLE oliver_overfloh;

SELECT *
FROM test_table;

INSERT INTO test_table
VALUES (2, 'Anna', 45);

-- Oliver kann lesen und schreiben. Aber Datenkbanken erstellen?
CREATE DATABASE ollis_dolle_db;
-- nööööööö

-- Lasst uns ihm eine Berechtigung auch dafür zuweisen:
SET ROLE postgres;
ALTER USER oliver_overfloh CREATEDB;

SET ROLE oliver_overfloh;
CREATE DATABASE ollis_dolle_db;
DROP DATABASE ollis_dolle_db;



-- Um selbst definierte Rollen zu vererben, muss ein Nutzer als Mitglied
-- der zu erbenden Rolle erstellt werden.
-- Lasst uns die Rolle Datenbankingenieur erstellen,
-- an der mehrere Nutzer teilhaben sollen:

SET ROLE postgres;

CREATE ROLE database_engineer
    CREATEDB CREATEROLE BYPASSRLS;

-- Jetzt erstellen wir ein paar Nutzer, die Mitglieder dieser Rolle sind:
CREATE USER valerie_verbinder
    PASSWORD 'vali123'
    IN ROLE database_engineer;

CREATE USER bernd_bithold
    PASSWORD 'bernd123'
    IN ROLE database_engineer;

-- Dann lasst uns einmal als Bernd versuchen, eine Datenbank zu erstellen:
SET ROLE bernd_bithold;

CREATE DATABASE bernds_base;
-- Warum geht das nicht?






-- Achtung, sie verfügen weiterhin NICHT über diese Kräfte!
SELECT *
FROM pg_roles;

-- Aber Bernd kann in einer Session in die Rolle database_engineer schlüpfen
-- und kann dann seine Kräfte entfalten!
-- Das schauen wir uns in der Kommandozeile an.

-- Ebenfalls interessant
-- Um Passwörter von Rollen ein Ablaufdatum zu geben
-- (zum Beispiel Gastrolle für einen Tag im Unternehmen)
SET ROLE postgres;

CREATE ROLE guest_user
    LOGIN PASSWORD 'be my guest!'
    VALID UNTIL '2025-12-31 23:59:59';
--> muss ein Timestamp sein, Datum reicht nicht aus

-- Mit den passenden Berechtigungen darf man Mitglieder 
-- zu Rollen hinzufügen und entfernen
GRANT postgres TO guest_user;

REVOKE postgres FROM guest_user;

-- ROLLEN LÖSCHEN
-- --------------

-- Löschen einer Rolle nur möglich, wenn sie keinerlei
-- Privilegien mehr besitzt. gastuser hat keine Privilegien:
DROP ROLE guest_user;

-- database_engineer kann nicht direkt gelöscht werden. Warum?
DROP ROLE database_engineer;

-- Erst die Abhängigkeiten:
DROP USER valerie_verbinder, bernd_bithold;

DROP DATABASE bernds_base;

-- Dann die Gruppe:
DROP ROLE database_engineer;

-- Alternativ hätte man auch den Nutzern die Gruppenzugehörigkeit entziehen können.

/* Übungsaufgabe ROLES
Erstelle für unseren Kurs passende Rollen zur Nutzung von postgres. 
Erstelle dabei folgende Rollen: 
- Dozent mit Superuser Status
- Tutoren mit database creation, role creation,
  initiating replication
- Studenten mit Login und ablaufenden Passwörtern nach einem Jahr.
  Die Studenten sollen sich außerdem nur zu einer Datenbank augustkurs
  verbinden können und dort Leserechte haben.
*/

CREATE ROLE dozent
SUPERUSER;

CREATE ROLE tutoren
CREATEDB CREATEROLE REPLICATION LOGIN;

CREATE USER studenten
PASSWORD 'das pw ist pw'
VALID UNTIL '2025-08-31 23:59:59';

GRANT SELECT ON august_kurs TO studenten;

