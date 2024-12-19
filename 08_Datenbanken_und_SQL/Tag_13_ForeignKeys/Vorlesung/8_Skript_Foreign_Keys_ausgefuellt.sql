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
SELECT *
FROM students;

-- Einfügen funktioniert ohne Probleme:
SELECT *
FROM feedback;

INSERT INTO feedback
VALUES ('2024-12-18', 8, 5);

-- ID 8 ist am Start:
SELECT *
FROM feedback;

SELECT *
FROM students;

-- Was passiert nun beim Joinen?
SELECT *
FROM feedback
         LEFT JOIN students USING (student_id);

-- Wir sind in der unwünschenswerten Lage, dass wir "Unbekannte" in unserer Datenbank haben!
-- Lösung: Mit Foreign Keys solche Dinge im Vorfeld gar nicht erst möglich machen!

-- Wir entfernen wieder die "Problemzeile":
DELETE
FROM feedback
WHERE student_id = 8;

SELECT *
FROM feedback;

-- Mit ALTER TABLE fügt man auch FOREIGN KEYs (FK) hinzu:
-- Wir wollen in Feedback in der Spalte 'student_id'
-- nur IDs aus der Tabelle 'students' zulassen!
-- Neben der Fremdschlüssel-Spalte muss angegeben werden,
-- auf welchen Primärschlüssel einer anderen Tabelle der FK verweist (referenziert).
ALTER TABLE feedback
    ADD FOREIGN KEY (student_id)
        REFERENCES students (student_id);

-- Klappt das auch jetzt noch?
INSERT INTO feedback
VALUES ('2024-12-18', 8, 5);

-- Sehr schön! :)

-- Ein Blick auf das ERD sollte auch etwas Neues zeigen
-- Rechtsklick auf public > Diagrams > Show Diagram oder auf public Str+Alt+Shift+U drücken

-- Aber wie verfahren wir, wenn wir plötzlich wirklich einen Studenten mit der ID 8 haben?

-- Erst Eintrag in 'students' anlegen:
INSERT INTO students (student_id, nachname, vorname)
VALUES (8, 'Hansen', 'Ole');

SELECT *
FROM students;

-- Jetzt müsste Ole auch Feedback abgeben dürfen!
INSERT INTO feedback
VALUES ('2024-12-18', 8, 5);

SELECT *
FROM feedback;

-- Lasst uns die weiteren Foreign Keys setzen!
-- Foreign Key in 'feedback' aus 'modules' (modul_id)
ALTER TABLE feedback
    ADD FOREIGN KEY (modul_id)
        REFERENCES modules (modul_id);

SELECT *
FROM courses;

-- Foreign Key in 'courses' aus 'cities' (city_id)
ALTER TABLE courses
    ADD FOREIGN KEY (city_id)
        REFERENCES city (city_id);

-- Foreign Key in 'student_courses' aus 'courses' (kurs_id)
ALTER TABLE students_courses
    ADD FOREIGN KEY (kurs_id)
        REFERENCES courses (kurs_id);

-- Foreign Key in 'student_courses' aus 'students' (student_id)
ALTER TABLE students_courses
    ADD FOREIGN KEY (student_id)
        REFERENCES students (student_id);

-- Und jetzt lasst uns das Meisterwerk als ERD betrachten! :)

DROP TABLE IF EXISTS unnormalized_students;
DROP TABLE IF EXISTS students_1nf;

-- Hier kommt was hin

SELECT *
FROM students;

SELECT *
FROM feedback;

-- Was passiert mit den Einträgen von Peter Habenicht (ID 4)?
DELETE
FROM students
WHERE student_id = 4;
-- Es würden "verwaiste Zellen" entstehen.

-- Wir können ihn nicht löschen, solange er in der Feedback-Tabelle vorkommt.
-- Lösung 1: Erst alles mit ID 4 aus Feedback löschen, dann den Eintrag aus
DELETE
FROM feedback
WHERE student_id = 4;

SELECT *
FROM feedback;

DELETE
FROM students_courses
WHERE student_id = 4;

DELETE
FROM students
WHERE student_id = 4;

SELECT *
FROM students;

-- Sehr umständlich.

-- Version 2: Einen Foreign Key so hinzufügen, dass beim Entfernen alles mit
-- der zugehörigen ID verschwindet.

-- Erst Constraint entfernen:
ALTER TABLE feedback
    DROP CONSTRAINT feedback_student_id_fkey;

-- Dann veränderten Constraint hinzufügen:
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

SELECT *
FROM students;

-- Ole (ID 8) rausschmeißen:
DELETE
FROM students
WHERE student_id = 8;

-- Ole fehlt in students:
SELECT *
FROM students;

-- Oles Feedback fehlt in feedback:
SELECT *
FROM feedback;

-- Auch hier (students_courses) ist kein Ole mehr in einen Kurs eingeschrieben:
SELECT *
FROM students_courses;

-- Studenten austauschen mit Update:
SELECT *
FROM students;

UPDATE students
SET nachname = 'Rose'
WHERE student_id = 1;

SELECT *
FROM students;
