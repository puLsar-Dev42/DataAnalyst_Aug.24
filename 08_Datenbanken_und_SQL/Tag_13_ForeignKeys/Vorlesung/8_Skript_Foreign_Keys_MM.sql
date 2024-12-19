/* 
 * -------------------------------------------
 * Skript: 	Foreign Keys
 * -------------------------------------------
 * 
 * Wir verbinden uns zur Datacraft-Datenbank.
 */

-- Verwendung von Schlüsseln beim Erstellen von Tabellen
-- =====================================================

-- WIEDERHOLUNG
-- Primärschlüssel (Primary Keys)

-- Primary Keys schränken eine Spalte mit zwei Bedingungen ein:
-- 1) die Werte in dieser sind einzigartig
-- 2) es kommen keine Null-Werte vor
-- Aber Primärschlüssel haben noch eine weitere wichtige Rolle im Datenbank-Design:
-- Sie schränken über FOREIGN KEYs den Wertebereich in anderen Tabellen ein.
-- In einfacheren Worten regeln sie, welche Werte in Spalten anderer Tabellen überhaupt vorkommen dürfen!
-- Damit verbinden PK und FK erst überhaupt unsere Tabellen zu einem funktionierenden Datenbankschema.

-- Bsp. anhand unserer Datenbank: Es können nur Studenten Feedback in der Faktentabelle abgegeben haben,
-- die auch in der students-Tabelle angelegt wurden (dort mindestens über eine ID verfügen).
-- Als Foreign Key würde student_id z.B. ein Feedback eines Studenten mit der 8 nicht zulassen.
-- Aber noch haben wir die student_id-Spalte NICHT als Foreign Key bestimmt.
-- Schauen wir also, was passiert, wenn wir eine Zeile mit einer ID 8 einfach mal hinzufügen:

-- Blick auf ERD vor jeder Veränderung >>> ein Haufen unverbundener Tabellen...

-- Einfügen funktioniert ohne Probleme:
INSERT INTO feedback
VALUES ('2024-12-12', 8, 15);

-- ID 8 ist am Start:
SELECT *
FROM feedback
ORDER BY student_id DESC;

-- Was passiert nun beim Joinen?
SELECT *
FROM feedback
		 FULL OUTER JOIN students
						 USING (student_id)
ORDER BY student_id DESC;
-- Wir sind in der unwünschenswerten Lage, dass wir "Unbekannte" in unserer Datenbank haben!
-- Lösung: Mit Foreign Keys solche Dinge im Vorfeld gar nicht erst möglich machen!

-- Wir entfernen wieder die "Problemzeile":
DELETE
FROM feedback
WHERE student_id = 8;

-- Mit ALTER TABLE fügt man auch FOREIGN KEYs (FK) hinzu:
-- Wir wollen in Feedback in der Spalte 'student_id'
-- nur IDs aus der Tabelle 'students' zulassen!
-- Neben der Fremdschlüssel-Spalte muss angegeben werden,
-- auf welchen Primärschlüssel einer anderen Tabelle der FK verweist (referenziert).

SELECT *
FROM students;


ALTER TABLE feedback
	ADD FOREIGN KEY (student_id)
		REFERENCES students (student_id);

SELECT *
FROM students;

SELECT *
FROM feedback;

-- Klappt das auch jetzt noch?
INSERT INTO feedback
VALUES ('2024-12-12', 8, 15);

-- Sehr schön! :)

-- Ein Blick auf das ERD sollte auch etwas Neues zeigen
-- Rechtsklick auf public > Diagrams > Show Diagram oder auf public Str+Alt+Shift+U drücken

-- Aber wie verfahren wir, wenn wir plötzlich wirklich einen Studenten mit der ID 8 haben?
-- Nicht spicken!


-- Erst Eintrag in 'students' anlegen:
INSERT INTO students
VALUES (8, 'Futurro', 'Alberto');

SELECT *
FROM students;

-- Jetzt müsste Alberto auch Feedback abgeben dürfen!
INSERT INTO feedback
VALUES ('2024-12-12', 8, 15);

SELECT *
FROM feedback;

-- Lasst uns die weiteren Foreign Keys setzen!

-- Foreign Key in 'student_courses' aus 'students' (student_id)
ALTER TABLE students_courses
	ADD FOREIGN KEY (student_id)
		REFERENCES students (student_id);

SELECT *
FROM students_courses;

-- Foreign Key in 'student_courses' aus 'courses' (kurs_id)
ALTER TABLE students_courses
	ADD FOREIGN KEY (kurs_id)
		REFERENCES courses (kurs_id);

SELECT *
FROM students_courses;

-- Foreign Key in 'feedback' aus 'cities' (city_id)
ALTER TABLE courses
	ADD FOREIGN KEY (city_id)
		REFERENCES city (city_id);

SELECT *
FROM courses;

-- Foreign Key in 'feedback' aus 'modules' (modul_id)
ALTER TABLE feedback
	ADD FOREIGN KEY (modul_id)
		REFERENCES modules (modul_id);

SELECT *
FROM feedback;

-- Und jetzt lasst uns das Meisterwerk als ERD betrachten! :)
DROP TABLE IF EXISTS unnormalized_students;
DROP TABLE IF EXISTS students_1nf;

----------------------

ALTER TABLE feedback
	DROP CONSTRAINT feedback_student_id_fkey;

ALTER TABLE feedback
	ADD FOREIGN KEY (student_id)
		REFERENCES students (student_id)
		ON DELETE CASCADE;

ALTER TABLE students_courses
	DROP CONSTRAINT students_courses_student_id_fkey;

ALTER TABLE students_courses
	ADD FOREIGN KEY (student_id)
		REFERENCES students (student_id)
		ON DELETE CASCADE;


DELETE
FROM students
WHERE student_id = 8;

UPDATE students
SET nachname = 'Rose'
WHERE student_id = 1;