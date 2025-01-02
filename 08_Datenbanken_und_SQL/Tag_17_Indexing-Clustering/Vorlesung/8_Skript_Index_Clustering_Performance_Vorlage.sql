/* 
 * -------------------------------------------
 * Skript: 	Indexing, Clustering, Performance
 * -------------------------------------------
 * 
 * Verwendetes DBMS: PostgreSQL
 * Verwendete Datenbank: -
 * Benötigte Datensätze:	addresses.sql,
 * 							games.sql
 */

-- Indexing
-- Indexing wird genutzt, um die Performance (Geschwindigkeit)
-- unserer Queries zu steigern.
-- Wie können wir überhaupt die Performance unserer Queries messen?
--> explain analyse

-- normale Abfrage:
SELECT *
FROM game;

-- Untersuchung der Query mit explain (ohne analyze)
EXPLAIN
SELECT *
FROM game;

-- Seq Scan (sequential scan) liest die Daten in genau der Reihenfolge,
-- in der sie im Speicher (in unserer Tabelle) vorliegen.
-- Tiefere Info: https://www.percona.com/blog/decoding-sequential-scans-in-postgresql/

-- JSON-Format (mindestens) Felix gefallen:
EXPLAIN (FORMAT JSON)
SELECT *
FROM game;

-- Anderes Format:
EXPLAIN (FORMAT YAML)
SELECT *
FROM game;

-- Untersuchung der Query und Ausführung mit Explain Analyze:
EXPLAIN ANALYZE
SELECT *
FROM game;

/* 
Über Explain bekommen wir mehr Infos, was eigentlich gemacht
wird und in welchen Schritten SQL "denkt". Über Explain analyze
haben wir weitere Funktionen (z.B. Zeitmessung, Speichernutzung)
die wir bei unseren Funktionen messen können. 
Achtung: EXPLAIN überprüft VORHER, was passieren WIRD (Führt Query nicht aus,
aber zeigt den Plan).
EXPLAIN ANALYZE zeigt den Plan an, führt aber auch die Query aus und zeigt
die Ergebnisse der Analyse der Abfrage.

Info zum Planner: https://www.postgresql.org/docs/current/planner-optimizer.html
*/

-- Weiteres Beispiel!
SELECT *
FROM addresses;

EXPLAIN
SELECT country,
       count(city)
FROM addresses
GROUP BY country;

EXPLAIN ANALYZE
SELECT country,
       count(city)
FROM addresses
GROUP BY country;

EXPLAIN
SELECT *
FROM addresses
WHERE country = 'SPAIN';

EXPLAIN ANALYZE
SELECT *
FROM addresses
WHERE country = 'SPAIN';

-- Wie verbessern wir jetzt die Performance?

---> Indexing
-- Hintergrund (https://www.postgresql.org/docs/current/sql-createindex.html)
SELECT *
FROM addresses;

-- 2. Wie oft kommt das Land SPAIN vor?
SELECT count(*)
FROM addresses
WHERE country = 'SPAIN';

-- 3. Wie lang braucht SQL um zu berechnen, wie oft SPAIN
--    vorkommt? (Ohne Index)
EXPLAIN ANALYZE
SELECT count(*)
FROM addresses
WHERE country = 'SPAIN';
--> Execution time: ...

-- 4. Erstelle einen Index auf die Spalte country der Tabelle
CREATE INDEX addresses_country_idx
    ON addresses (country);
-- Wenn nichts weiter spezifiziert wird, erstellt das einen btree-Index
-- https://www.postgresql.org/docs/current/btree.html

-- 5. Zähle erneut das Vorkommen von Spanien
EXPLAIN ANALYZE
SELECT count(*)
FROM addresses
WHERE country = 'SPAIN';
--> Execution time: ...

-- 6. Welche Unterschiede zwischen Zeiten lassen sich erkennen?
---> ...

-- Man kann auch für besondere Nutzungsszenarien partielle Indices erstellen.
-- Siehe hier: https://www.postgresql.org/docs/current/indexes-partial.html

--- CLUSTER
/*
Wenn eine Tabelle geclustert wird, wird sie auf der Grundlage 
der Indexinformationen physisch neu geordnet. Dieses Clustering ist 
ein einmaliger Vorgang: Wenn die Tabelle später aktualisiert 
wird, werden die Änderungen nicht geclustert. 

Indexing und Clustern sorgen letztendlich dafür, dass unsere Daten
aufgrund der Indizes neu sortiert werden können, wodurch die Abfrage
durch entsprechende Queries um ein Vielfaches beschleunigt werden kann.
*/

--Beispiel!
-- Step 1: Erstelle die Tabelle game
SELECT *
FROM game;

-- Step 2: Wie lange dauert es, die id 2070 zu finden?
EXPLAIN ANALYZE
SELECT *
FROM game
WHERE id = 2070;
--> Execution Time: ...

-- Step 3: Wie lange dauert es, das Spiel genre_id = 3 und
-- game_name = 'Dragon Ball Z: Budokai Tenkaichi 3' zu finden?
EXPLAIN ANALYZE
SELECT *
FROM game
WHERE genre_id = 3
  AND game_name = 'Dragon Ball Z: Budokai Tenkaichi 3';
--> Execution Time: ...

-- Step 4: Wie lange dauert es, ein Spiel dem Datensatz hinzuzufügen? 
-- Füge dazu das Spiel 'Dragon Ball Z: Budokai Tenkaichi 4' mit der 
-- genre_id 3 und der id 11365 hinzu.
EXPLAIN ANALYZE
INSERT INTO game
VALUES (11365, 3, 'Dragon Ball Z: Budokai Tenkaichi 4');
--> Execution Time: ...

-- Step 5: Erstelle einen Multiindex auf genre_id und game_name und
-- führe Step 3 erneut aus! 
CREATE INDEX genreid_gamename_index
    ON game (genre_id, game_name);

EXPLAIN ANALYZE
SELECT *
FROM game
WHERE genre_id = 3
  AND game_name = 'Dragon Ball Z: Budokai Tenkaichi 3';
--> Execution Time: ...

-- Wird hier nicht genutzt:
EXPLAIN ANALYZE
SELECT *
FROM game
WHERE id > 1000;

-- Step 6: Lösche den Index aus Step 5 und erstelle stattdessen 
-- zwei neue Indizes, einen für genre_id, einen für game_name. 
-- Ergibt sich ein Unterschied zu der in Step 5 gemessenen Zeit? 
DROP INDEX genreid_gamename_index;

CREATE INDEX genreid_index
    ON game (genre_id);

CREATE INDEX gamename_index
    ON game (game_name);

EXPLAIN ANALYZE
SELECT *
FROM game
WHERE genre_id = 3
  AND game_name = 'Dragon Ball Z: Budokai Tenkaichi 3';
--> Execution Time: ...

EXPLAIN ANALYZE
SELECT *
FROM game
WHERE genre_id = 3;

-- Step 7: Wie lange dauert es, das Spiel mit 
-- id = 10000 ausgeben zu lassen? 
EXPLAIN ANALYZE
SELECT *
FROM game
WHERE id = 10000;
--> Execution Time: ...

-- Step 8: Erstelle einen Cluster auf den Index der 
-- genre_id (erstellt in Step 6). Lass dir die Tabelle
-- ausgeben
SELECT *
FROM game;

CLUSTER game
    USING genreid_index;

SELECT *
FROM game;

EXPLAIN ANALYZE
SELECT *
FROM game
WHERE genre_id = 10;

-- Step 9: Mache Schritt 8 rückgängig, indem du wieder
-- nach dem Primary Key clusterst. Schau dir das Resultat an.
CLUSTER game
    USING pk_game;

SELECT *
FROM game;

EXPLAIN ANALYZE
SELECT *
FROM game
WHERE genre_id = 10;


-- Übung
/*
Suche nun nicht mehr direkt nach dem Spiel Dragon Ball BT3,
sondern lasse dir alle Spiele mit Dragon Ball im Namen aus dem 
genre 3 anzeigen. Vergleiche dafür erst ohne Index dann mit Index
die Suchdauer!
*/
