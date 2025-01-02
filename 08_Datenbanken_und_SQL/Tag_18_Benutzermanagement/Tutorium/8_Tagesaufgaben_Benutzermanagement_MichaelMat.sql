-- Tagesaufgaben PostgreSQL: Benutzermanagement und Rollen
-- =======================================================
-- ---------
-- Aufgabe 1
-- ---------
-- 1. Erstelle eine neue postgresql-Datenbank mit dem Namen hogwarts.

CREATE DATABASE hogwarts;

-- 2. Führe das Skript "harry_potter_Daten.sql" aus um die Daten wiederherzustellen.

--    Optional: Versuche den Import mit den Daten aus den CSV-Dateien im ZIP-Archiv.
--              Achtung, schwer: Dabei müssen eventuell mehrere Import Einstellungen geändert werden
--              und eventuell auch Sonderzeichen aus den CSV Dateien entfernt werden.

-- ---------
-- Aufgabe 2
-- ---------
-- 1. Erstelle eine Rolle schueler, welche auf die Tabellen spells und potions lesend zugreifen kann.

CREATE ROLE schüler;

GRANT SELECT ON spells, potions TO schüler;

SET ROLE schüler;
SELECT current_role;

SELECT *
FROM spells;

SELECT *
FROM potions;

-- 2. Erstelle eine Rolle vertrauensschueler, welche auf die Tabelle characters lesend zugreifen kann.

SET ROLE postgres;

CREATE ROLE vertrauensschüler;
GRANT SELECT ON "Characters" TO vertrauensschüler;

SET ROLE vertrauensschüler;
SELECT current_role;

SELECT *
FROM "Characters";

-- 3. Erstelle eine Rolle lehrer, welche einem erlaubt, lesend und schreibend (auch löschen!)
-- auf die Tabellen potions und spells und nur lesend auf die Tabelle characters zugreifen zu können.

SET ROLE postgres;

CREATE ROLE lehrer;
GRANT SELECT, INSERT, UPDATE, DELETE ON spells, potions TO lehrer;
GRANT SELECT ON "Characters" TO	lehrer;

SET ROLE lehrer;
SELECT current_role;

SELECT *
FROM spells;

INSERT INTO spells
VALUES ('xyZdesdfwrwf','acdsd','sfwefg','afwgw','srregfw');

DELETE FROM spells
WHERE "Name" = 'xyZdesdfwrwf';

SELECT *
FROM potions;

INSERT INTO potions
VALUES ('xyZdesdfwrwf','acdsd','sfwefg','afwgw','srregfw');

DELETE FROM potions
WHERE "Name" = 'xyZdesdfwrwf';


SELECT *
FROM "Characters";

INSERT INTO "Characters"
VALUES (140, 'O', 'Male', 'Student', 'Gryffindor', 'Unknown', 'Unknown', 'Human', 'Pure-bloodorHalf-blood', '', '', 'Hogwarts School of Witchcraft and Wizardry', 'Keeper|  Captain of the Gryffindor Quidditch team', 'October1975-31 August1976', '');
-- blöd... er kann nur lesen 😅😅😅

-- 4. Erstelle eine Rolle schulverwaltung, die Lesezugriff auf die Tabelle characters
-- sowie Veränderungen an ihr erlaubt

SET ROLE postgres;

CREATE ROLE schulverwaltung;
GRANT SELECT, INSERT, UPDATE, DELETE ON "Characters" TO schulverwaltung;

-- 5. Erstelle eine Rolle schulleiter, die über alle Rechte verfügt.

CREATE ROLE schulleiter
SUPERUSER LOGIN
PASSWORD 'god';

SELECT *
FROM pg_roles;
-- ---------
-- Aufgabe 3
-- ---------
-- 1. Füge dich selbst bei characters hinzu. Es ist dir frei gestellt, wie du die Felder befüllst.

INSERT INTO "Characters"
VALUES (420, 'Michael "HyBriZ" Matthiesen', 'Male', 'Student', 'Slytherin', 'Elder Wand', 'The 4 Horsemen of the Apocalypse', 'Shapeshifter', 'Hybrid', '', 'black', '', 'shapeshifting, telekinetics, flying, and a lot more unkown...🐈‍⬛', 'Big Bang', '');

-- 2. Zähle, wie viele Schüler in den verschiedenen Häusern sind (Tabelle characters)

SELECT house, COUNT(*) AS student_count
FROM "Characters"
WHERE job = 'Student'
GROUP BY house
ORDER BY student_count DESC;

-- ---------
-- Aufgabe 4
-- --------- 

-- 1. Erstelle deinen eigenen Nutzer und gib ihm entsprechend deines Jobs (Student)
-- bei der Tabelle Characters eine entsprechende Role.

CREATE USER hybriz
PASSWORD '42';
GRANT schüler TO hybriz;

SELECT *
FROM pg_roles;

-- 2. Erstelle folgende Nutzer: Severus_Snape, A_P_W_B_Dumbledore, Minerva_McGonagall, Harry_Potter, H_J_Granger

CREATE USER Severus_Snape
PASSWORD 'tbagger666';

CREATE USER A_P_W_B_Dumbledore
PASSWORD '00101010';

CREATE USER Minerva_McGonagall
PASSWORD '01100100 01110101 01101101 01101101 01100101 00100000 01101011 01110101 01101000';

CREATE USER Harry_Potter
PASSWORD 'ERROR:404';

CREATE USER H_J_Granger
PASSWORD 'sxybtch69';

-- 3. Weise dem Nutzer Harry_Potter die Rolle schueler zu.

GRANT schüler TO harry_potter;

-- 4. Weise dem Nutzer H_J_Granger die Rollen schueler und vertrauensschueler zu.

GRANT schüler, vertrauensschüler TO h_j_granger;

-- 5. Weise den Nutzern Severus_Snape, Minerva_McGonagall die Rollen lehrer, schulverwaltung zu.

GRANT lehrer, schulverwaltung TO severus_snape,	minerva_mcgonagall;

-- 6. Weise den Nutzern Severus_Snape, A_P_W_B_Dumbledore die Rolle schulleiter zu.

GRANT schulleiter TO a_p_w_b_dumbledore, severus_snape;

-- 7. Entferne bei dem Nutzer Severus_Snape die Rollen schulleiter und schulverwaltung wieder.

REVOKE schulverwaltung, schulleiter FROM severus_snape;

-- 8. Wechsel den Nutzer zu Severus_Snape.

SET ROLE severus_snape;

-- 9. Versuche nun als Nutzer Severus_Snape, deinen in Aufgabe 3 erstellten Charakter zu löschen.

DELETE FROM "Characters"
WHERE id = 420;

-- 10. Falls nicht möglich, schreibe die Fehlermeldung hier nieder.
-- Andernfalls erkläre, welche Rolle das Löschen ermöglicht hat.
-- Es ist nicht möglich, da Snape nicht über die Rechte dafür verfügt.
-- Nur schulverwaltung und schulleiter dürfen das.

---- ANTWORT:

---- [42501] FEHLER: keine Berechtigung für Tabelle Characters

---- da der olle snape jetzt nur noch ein '0815' Lehrer ist und wir am Anfang in Aufgabe 3 gesagt haben,
---- GRANT SELECT ON "Characters" TO	lehrer;
---- kann snape natürlich jetzt auch nichts mehr rauslöschen!!!


-- 11. Lösche alle erstellten Nutzer und alle erstellten Rollen.

SET ROLE postgres;

DROP USER
	Severus_Snape,
	A_P_W_B_Dumbledore,
	Minerva_McGonagall,
	Harry_Potter,
	H_J_Granger,
	hybriz;

REVOKE SELECT ON spells, potions FROM schüler;
REVOKE SELECT ON "Characters" FROM vertrauensschüler;
REVOKE SELECT, INSERT, UPDATE, DELETE ON spells, potions FROM lehrer;
REVOKE SELECT ON "Characters" FROM 	lehrer;
REVOKE SELECT, INSERT, UPDATE, DELETE ON "Characters" FROM schulverwaltung;


DROP ROLE
	schüler,
	vertrauensschüler,
	lehrer,
	schulverwaltung,
	schulleiter;