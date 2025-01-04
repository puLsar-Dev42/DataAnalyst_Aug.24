-- Tagesaufgaben PostgreSQL: Benutzermanagement und Rollen
-- =======================================================
-- ---------
-- Aufgabe 1
-- ---------
-- 1. Erstelle eine neue postgresql-Datenbank mit dem Namen hogwarts.


-- 2. Führe das Skript "harry_potter_Daten.sql" aus um die Daten wiederherzustellen.

--    Optional: Versuche den Import mit den Daten aus den CSV-Dateien im ZIP-Archiv.
--              Achtung, schwer: Dabei müssen eventuell mehrere Import Einstellungen geändert werden
--              und eventuell auch Sonderzeichen aus den CSV Dateien entfernt werden.

-- ---------
-- Aufgabe 2
-- ---------
-- 1. Erstelle eine Rolle schueler, welche auf die Tabellen spells und potions lesend zugreifen kann.
CREATE ROLE schueler;
GRANT SELECT ON spells, potions TO schueler;

-- Test:
SET ROLE schueler;
SELECT *
FROM spells;

SET ROLE postgres;

-- 2. Erstelle eine Rolle vertrauensschueler, welche auf die Tabelle characters lesend zugreifen kann.
CREATE ROLE vertrauensschueler;
GRANT SELECT ON "Characters" TO vertrauensschueler;

-- Test:
SET ROLE vertrauensschueler;
SELECT *
FROM "Characters";

SET ROLE postgres;

-- 3. Erstelle eine Rolle lehrer, welche einem erlaubt, lesend und schreibend (auch löschen!)
-- auf die Tabellen potions und spells und nur lesend auf die Tabelle characters zugreifen zu können.
CREATE ROLE lehrer;
GRANT SELECT, INSERT, UPDATE, DELETE ON spells, potions TO lehrer;
GRANT SELECT ON "Characters" TO lehrer;

-- Test:
SET ROLE lehrer;

SELECT *
FROM potions;

UPDATE potions
SET effect = 'makes intelligent'
WHERE "Name" = 's brain power';

SELECT *
FROM potions
WHERE "Name" = 's brain power';

SET ROLE postgres;

-- 4. Erstelle eine Rolle schulverwaltung, die Lesezugriff auf die Tabelle characters
-- sowie Veränderungen an ihr erlaubt
CREATE ROLE schulverwaltung;
GRANT SELECT, INSERT, UPDATE, DELETE ON "Characters" TO schulverwaltung;

-- 5. Erstelle eine Rolle schulleiter, die über alle Rechte verfügt.
CREATE ROLE schulleiter SUPERUSER;

-- ---------
-- Aufgabe 3
-- ---------
-- 1. Füge dich selbst bei characters hinzu. Es ist dir frei gestellt, wie du die Felder befüllst.
SELECT *
FROM "Characters";
INSERT INTO "Characters" (id, "Name", gender, job)
VALUES (140, 'Dora Datenfels', 'Female', 'Lehrerin bei DataCraft');

-- 2. Zähle, wie viele Schüler in den verschiedenen Häusern sind (Tabelle characters)
SELECT house,
       count(house)
FROM "Characters"
WHERE job = 'Student'
GROUP BY house;

-- ---------
-- Aufgabe 4
-- --------- 

-- 1. Erstelle deinen eigenen Nutzer und gib ihm entsprechend deines Jobs (Student)
-- bei der Tabelle Characters eine entsprechende Role.
CREATE USER dora PASSWORD 'password1234' IN ROLE lehrer;

-- 2. Erstelle folgende Nutzer: Severus_Snape, A_P_W_B_Dumbledore, Minerva_McGonagall, Harry_Potter, H_J_Granger
CREATE USER Severus_Snape;
CREATE USER A_P_W_B_Dumbledore;
CREATE USER Minerva_McGonagall;
CREATE USER Harry_Potter;
CREATE USER H_J_Granger;

-- 3. Weise dem Nutzer Harry_Potter die Rolle schueler zu.
GRANT schueler TO Harry_Potter;

-- 4. Weise dem Nutzer H_J_Granger die Rollen schueler und vertrauensschueler zu.
GRANT schueler, vertrauensschueler TO H_J_Granger;

-- 5. Weise den Nutzern Severus_Snape, Minerva_McGonagall die Rollen lehrer, schulverwaltung zu.
GRANT lehrer, schulverwaltung TO Severus_Snape, Minerva_McGonagall;

-- 6. Weise den Nutzern Severus_Snape, A_P_W_B_Dumbledore die Rolle schulleiter zu.
GRANT schulleiter TO Severus_Snape, A_P_W_B_Dumbledore;

-- 7. Entferne bei dem Nutzer Severus_Snape die Rollen schulleiter und schulverwaltung wieder.
REVOKE schulleiter, schulverwaltung FROM Severus_Snape;

-- 8. Wechsel den Nutzer zu Severus_Snape.
SET ROLE Severus_Snape;

-- 9. Versuche nun als Nutzer Severus_Snape, deinen in Aufgabe 3 erstellten Charakter zu löschen.
DELETE
FROM "Characters"
WHERE id = 140;

-- 10. Falls nicht möglich, schreibe die Fehlermeldung hier nieder.
-- Andernfalls erkläre, welche Rolle das Löschen ermöglicht hat.
-- Es ist nicht möglich, da Snape nicht über die Rechte dafür verfügt.
-- Nur schulverwaltung und schulleiter dürfen das.

-- 11. Lösche alle erstellten Nutzer und alle erstellten Rollen.
SET ROLE NONE;

-- Option 1:
DROP ROLE Severus_Snape, A_P_W_B_Dumbledore, Minerva_McGonagall, H_J_Granger, Harry_Potter, nils;

REVOKE SELECT ON spells, potions FROM schueler;

REVOKE SELECT ON "Characters" FROM vertrauensschueler;

REVOKE SELECT, INSERT, UPDATE, DELETE ON spells, potions FROM lehrer;

REVOKE SELECT, INSERT, UPDATE, DELETE ON "Characters" FROM schulverwaltung;

REVOKE SELECT, INSERT, UPDATE, DELETE ON "Characters", spells, potions FROM schulleiter;

DROP ROLE schueler, vertrauensschueler, lehrer, schulverwaltung, schulleiter;

-- Option 2:
-- Alles auf einmal entfernen
DROP ROLE Severus_Snape, A_P_W_B_Dumbledore, Minerva_McGonagall, H_J_Granger, Harry_Potter, nils;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM schueler, vertrauensschueler, lehrer, schulverwaltung, schulleiter;

DROP ROLE schueler, vertrauensschueler, lehrer, schulverwaltung, schulleiter;
