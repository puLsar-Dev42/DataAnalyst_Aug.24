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
-- CREATE DATABASE user_management;

-- Nicht vergessen, zu dieser Datenbank zu verbinden!

-- Test-Tabelle anlegen
CREATE TABLE test_table
(
    user_id SERIAL PRIMARY KEY,
    name    VARCHAR(100),
    age     SMALLINT
);

INSERT INTO test_table
VALUES (1, 'Chen', 31);

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
   rolconnlimit: Maximale Anzahl Verbindungen, die eine Rolle zulässt (-1 heißt unbegrenzt)
   rolpassword: gespeichertes gehashtes Passwort
   rolvaliduntil: Gültigkeitszeitraum der Rolle (bei Null unbegrenzt)
   rolbypassrls: Ist von Sicherheit auf Zeilenebene (row level security) betroffen
   rolconfig: zusätzliche Rollenkonfigurationen (wird i.d.R. nicht genutzt)
   oid: object identifier (eindeutige, dieser Rolle zugeordnete Zahl)
 */
-- So sehen wir nur die Rollen, die sich einloggen können:
SELECT rolname,
       rolcanlogin
FROM pg_roles
WHERE rolcanlogin = TRUE;

-- Es gibt also bereits einige voreingestellte Rollen
-- mit unterschiedlichen Berechtigungen.
-- Aber was bedeutet eigentlich so etwas wie der Rollenname pg_read_all_data
-- ohne Login-Berechtigung und wozu könnte so etwas nützlich sein?
-- Antwort: Die Rollen sind keine eigentlichen Nutzer, sondern vielmehr Attribute / Fähigkeiten,
-- die Nutzern zugewiesen (und auch wieder entzogen) werden können.

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
INSERT INTO test_table
VALUES (2, 'Müller', 77);

-- Überprüfen, ob wir Lese- und Schreibprivilegien haben:
SELECT schemaname,
       tablename,
       has_table_privilege(tablename, 'SELECT') AS can_select,
       has_table_privilege(tablename, 'UPDATE') AS can_update,
       has_table_privilege(tablename, 'DELETE') AS can_delete
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
SELECT schemaname,
       tablename,
       has_table_privilege(tablename, 'SELECT') AS can_select,
       has_table_privilege(tablename, 'UPDATE') AS can_update,
       has_table_privilege(tablename, 'DELETE') AS can_delete
FROM pg_tables
WHERE schemaname NOT LIKE 'pg_%'
  AND schemaname != 'information_schema';

INSERT INTO test_table
VALUES (2, 'Müller', 77);

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

SET ROLE mega_user;

SELECT *
FROM test_table;

SET ROLE NONE;

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

CREATE ROLE megauser;
CREATE USER megauser2;

SELECT *
FROM pg_roles;

DROP ROLE megauser;
DROP ROLE megauser2;

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
    LOGIN PASSWORD 'dora123';

SELECT *
FROM pg_roles;

-- Alternativ ohne LOGIN direkt als Nutzer erstellen:
CREATE USER nathanael_netzmacher
    PASSWORD 'nathan123';

SELECT *
FROM pg_roles;

-- Kann Dora lesen?
SET ROLE dora_datenfels;

SELECT *
FROM test_table;
-- nein, weil die Rechte fehlen.

-- Wenn eine Rolle bereits besteht, können wir diese mit
-- ALTER ROLE verändern. z.B. Passwort ändern.
SET ROLE postgres;

ALTER ROLE dora_datenfels
    LOGIN PASSWORD 'test';

-- BERECHTIGUNGEN ERTEILEN
-- -----------------------
-- Leseberechtigung für dora_datenfels erteilen: GRANT SELECT
GRANT SELECT ON test_table TO dora_datenfels;

SET ROLE dora_datenfels;

SELECT *
FROM test_table;

-- Insert geht nach wie vor nicht:
INSERT INTO test_table
VALUES (3, 'Yusuf', 41);

-- Wie wäre es, wir loggen uns mal als Dora ein, statt immer in ihre Rolle zu schlüpfen?

-- Erledigt (über Pycharm sowie über Terminal (psql))

-- Sollte Dora nicht direkt auf die Datenbank zugreifen können, hilft Folgendes:
-- GRANT CONNECT ON DATABASE user_management TO dora_datenfels;
-- Wurde mit dem SELECT mit vergeben.

-- Zum Einloggen über die Kommandozeile:
-- https://www.prisma.io/dataguide/postgresql/connecting-to-postgresql-databases

SELECT current_role;
SET ROLE postgres;

-- Weitere Berechtigungen über entsprechende Statements
-- GRANT UPDATE
-- GRANT ALTER

-- Mehrere Rechte auf einmal vergeben
-- TABLE keyword ist optional
GRANT SELECT, UPDATE, DELETE ON TABLE test_table TO nathanael_netzmacher;

SET ROLE nathanael_netzmacher;

SELECT schemaname,
       tablename,
       has_table_privilege(tablename, 'SELECT') AS can_select,
       has_table_privilege(tablename, 'UPDATE') AS can_update,
       has_table_privilege(tablename, 'DELETE') AS can_delete
FROM pg_tables
WHERE schemaname NOT LIKE 'pg_%'
  AND schemaname != 'information_schema';

SET ROLE dora_datenfels;

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
REVOKE DELETE ON TABLE test_table FROM nathanael_netzmacher;

-- Eine Rolle erstellen, die Attribute von vordefinierten Rollen erhält:
SET ROLE postgres;

CREATE USER oliver_overfloh
    PASSWORD 'floh123';

SELECT rolname
FROM pg_roles;

GRANT pg_read_all_data, pg_write_all_data TO oliver_overfloh;

SET ROLE oliver_overfloh;

SELECT *
FROM test_table;

INSERT INTO test_table
VALUES (3, 'Schmidt', 28);

-- Oliver kann lesen und schreiben. Aber Datenbanken erstellen?
CREATE DATABASE ollis_dolle_db;
-- Nö. Datenbanken sind ein eigenes Sonderprivileg.

-- Lasst uns ihm eine Berechtigung auch dafür zuweisen:
SET ROLE postgres;

ALTER USER oliver_overfloh CREATEDB;

SET ROLE oliver_overfloh;

CREATE DATABASE ollis_dolle_db;
-- Ja, jetzt geht es!

-- Kann auch in der DB:
CREATE TABLE test
(
    id   INT,
    name TEXT
);

-- Genug Spaß mit Oliver gehabt, jetzt wird gekündigt:
SET ROLE postgres;

-- Solange seine DB von ihm abhängt, geht das nicht:
DROP ROLE oliver_overfloh;

-- DB entfernen:
DROP DATABASE ollis_dolle_db;

DROP ROLE oliver_overfloh;

SELECT *
FROM pg_roles;

-- Um selbst definierte Rollen zu vererben, muss ein Nutzer als Mitglied
-- der zu erbenden Rolle erstellt werden.
-- Lasst uns die Rolle Datenbankingenieur (Spielzeugbeispiel) erstellen,
-- an der mehrere Nutzer teilhaben sollen:
CREATE ROLE database_engineer
    CREATEDB CREATEROLE BYPASSRLS;

-- Jetzt erstellen wir ein paar Nutzer, die Mitglieder dieser Rolle sind:
CREATE USER bernd_bithold
    PASSWORD 'bernd123'
    IN ROLE database_engineer;

-- Oder alternative Schreibweise:
CREATE USER valerie_verbinder
    PASSWORD 'vali123';

GRANT database_engineer TO bernd_bithold;

-- Dann lasst uns einmal als Bernd versuchen, eine Datenbank zu erstellen:
SET ROLE bernd_bithold;

-- Warum geht das nicht?
CREATE DATABASE bernds_base;

-- Schauen wir auf Bernds Rechte:
SELECT *
FROM pg_roles;



-- Warum geht das nicht?


-- Achtung, sie verfügen weiterhin NICHT über diese Kräfte!


-- Aber Bernd kann in einer Session in die Rolle database_engineer schlüpfen
-- und kann dann seine Kräfte entfalten!
-- Wir stellen eine weitere Verbindung mit Bernd her und führen dann das Nachfolgende aus:

-- Wir sind Bernd:
SELECT current_role;

-- geht nicht direkt:
CREATE DATABASE bernds_base;

-- geht nicht: SET ROLE postgres;

-- Aber wie wäre es damit?
SET ROLE database_engineer;

SELECT current_role;

CREATE DATABASE bernds_base;

-- Ebenfalls interessant:
-- Man kann Rollen ein Ablaufdatum geben
-- (zum Beispiel Gastrolle für einen Tag im Unternehmen)
SET ROLE NONE;

CREATE ROLE guest_user
    LOGIN PASSWORD 'be my guest!'
    VALID UNTIL '2025-12-31 23:59:59';

-- Nutzer, der gleich abläuft:
CREATE ROLE kurznutzer
    LOGIN PASSWORD 'beeil dich!'
    VALID UNTIL '2025-01-02 11:25:00';

SET ROLE kurznutzer;
SET ROLE NONE;

SELECT *
FROM pg_roles;

ALTER USER kurznutzer
    VALID UNTIL '2025-01-02 10:27:00';

--> muss ein Timestamp sein, Datum reicht nicht aus
SELECT *
FROM pg_roles;

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

-- Erst die Abhängigkeiten entfernen ODER
-- Wir ändern erstmal den Besitzer der super wichtigen Datenbank bernds_base
-- mit: ALTER DATABASE db_name OWNER TO new_owner_name:
ALTER DATABASE bernds_base OWNER TO postgres;

-- Dann die Gruppe:
DROP ROLE database_engineer;

-- Alternativ hätte man auch den Nutzern die Gruppenzugehörigkeit entziehen können.

-- Eine Rolle erstellen, in die nicht über SET geschlüpft wird:
CREATE ROLE minimal_user;
GRANT SELECT ON test_table TO minimal_user;

CREATE USER heinz_peter
    PASSWORD 'heinz123'
    IN ROLE minimal_user;

-- Hier geht das nicht, weil heinz_peter direkt den SELECT erbt von minimal_user
-- er schlüpft dafür nicht erst in die Gruppenrolle!
DROP ROLE minimal_user;

-- D.h. wir müssen zuerst Nutzer und dann die Gruppe entfernen:
DROP USER heinz_peter;

REVOKE SELECT ON test_table FROM minimal_user;
DROP ROLE minimal_user;
-- OFFIZIELLES ENDE VORLESUNG

-- Nur zum Spaß:
SET ROLE NONE;

DROP DATABASE heaven;
DROP ROLE god;

CREATE ROLE god
SUPERUSER LOGIN
PASSWORD 'holy spirit';

SET ROLE god;

CREATE DATABASE heaven;

-- Da könnten beliebig viele Leute als god unterwegs sein,
-- aber hat Nachteile, was die Nachvollziehbarkeit betrifft.
-- Bei allgemeinem Gast, der fast nichts kann, könnte man so etwas durchaus machen.

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

