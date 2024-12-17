-- Skript Normalisierung

/*
   In den vergangenen Wochen haben wir Datenbanken kennengelernt und dort auch ID-Spalten kennengelernt.
   Diese ID-Spalten waren nötig, um einzelne Einträge (z.B. Bestellungen) voneinander eindeutig
   unterscheiden zu können.

   Aber die Datenbanken bestanden i.d.R. nicht aus einer einzigen Tabelle mit einer einzigen ID-Spalte,
   sondern aus einer Reihe Tabellen, die sich mittels Joins zusammenführen ließen.
   Wir haben das so "hingenommen".
   Aber wieso liegen die Daten in Datenbanken eigentlich so voneinander getrennt?
 */
-- Bitte kurz überlegen und nicht weiterlesen!


/*
   Die Hintergründe für Aufteilung von Daten in Fakten- und Dimensionstabellen sind: Performance und Konsistenz.
   Durch die Auslagerung von nicht immer benötigten Daten werden viele redundante Daten (Duplikate) entfernt, wodurch
   Tabelleninhalte grundsätzlich schneller geladen werden können.
   Durch die Auslagerung der meisten Informationen zu z.B. Kunden einer Firma sowie das Setzen von Primär- und Fremd-
   schlüsseln wird das Anlegen solcher Einträge weniger anfällig für Fehler und somit die Konsistenz der Daten gesteigert.

   In den 70er-Jahren wurde eine Reihe von Regeln definiert, die das Datenbank-Design geprägt haben.
   Diese Regeln können (A) gleich am Anfang implementiert werden, wenn die Datenbank überhaupt erst entworfen wird und
   noch keine Daten vorliegen. (wünschenswertes Szenario)
   Diese Regeln können aber auch (B) nachträglich auf Tabellen angewendet werden, die nicht den Ansprüchen entsprechen.
   Dann wird eine "chaotische" Tabelle genommen und "normalisiert". Am Ende steht idealerweise ein Verbund aus
   kleineren Tabellen, die zusammen ein funktionierendes Schema bilden.

   Im Folgenden wird der Normalisierungsprozess anhand eines Beispiels erläutert.
   Die Ausgangsrelation beschreibt, welche Studenten von DataCraft in welchem Kurs welche
   Lieblingsmodule haben.
 */

/*
   Schritt 1: Import der nicht-normalisierten Daten in eine Tabelle
   aus einer CSV-Datei mittels COPY
 */

-- Neue Datenbank erstellen:
DROP DATABASE IF EXISTS datacraft;

-- CREATE DATABASE datacraft;

-- Mit dieser Datenbank verbinden.

-- Neue Tabelle erstellen:
DROP TABLE IF EXISTS unnormalized_students;

CREATE TABLE IF NOT EXISTS unnormalized_students
(
	feedback_date   DATE,
	student_name    VARCHAR(120),
	kurs            VARCHAR(30),
	dozent          VARCHAR(55),
	stadt           VARCHAR(30),
	vorwahl         VARCHAR(10),
	lieblingsmodule VARCHAR(55),
	beschreibungen  VARCHAR(255),
	anzahl_tage     VARCHAR(30)
);

-- Check:
SELECT *
FROM unnormalized_students;

-- Daten in die Tabelle importieren:
COPY unnormalized_students
	FROM 'C:\Users\Admin\OneDrive\Dokumente\DataCraft\DataAnalyst_Aug.24\08_Datenbanken_und_SQL\Tag_12_Normalisierung\Vorlesung\datacraft_students.csv'
	DELIMITER ';'
	CSV HEADER;
-- Falls Zugriff verweigert wird:
-- https://www.commandprompt.com/education/how-to-fix-permission-denied-error-while-importing-a-csv-file-in-postgresql/
-- Hinweis: 'Jeder' statt 'Everyone' eintragen.

-- Check:
SELECT *
FROM unnormalized_students;

/* Schritt 2:
Umwandlung zu 1. Normalform (1NF)!
Eine Relation befindet sich in der ersten Normalform,
wenn alle Attribute nur einfache Attributwerte aufweisen (Bezeichnung: atomar).
Das trifft auf unsere Tabelle an mehreren Stellen nicht zu!
Die Spalte Lieblingsmodule ist nicht atomar, da dort mal ein, mal mehrere Module in einem Feld vorkommen.
Findet ihr eine weitere Spalte, wo ein ähnliches Problem besteht?
ACHTUNG!
Sobald wir die erste Normalform herstellen, entstehen automatisch viele doppelte Werte, die Redundanz nimmt zu.
Das ist nicht tragisch, da wir damit noch nicht am Ende unserer Zerlegung sind!
*/

-- Einträge, die durch einen Trenner wie ein Komma voneinander getrennt sind,
-- lassen sich in Arrays zerteilen:
SELECT student_name,
       regexp_split_to_array(lieblingsmodule, ', ') AS module_array
FROM unnormalized_students;

SELECT student_name,
       UNNEST(regexp_split_to_array(lieblingsmodule, ', ')) AS modules
FROM unnormalized_students;

-- Zusammen mit UNNEST lassen sich diese Arrays auf Zeilen entpacken
-- dadurch entstehen redundante Daten (Duplikate) z.B. in den IDs:
SELECT student_name,
       UNNEST(regexp_split_to_array(lieblingsmodule, ', ')) AS lieblingsmodul,
       UNNEST(regexp_split_to_array(beschreibungen, ', '))  AS beschreibung,
       UNNEST(regexp_split_to_array(anzahl_tage, ', '))     AS anzahl_tage
FROM unnormalized_students;

-- So würde eine Tabelle in der ersten Normalform aussehen:
SELECT feedback_date,
       SPLIT_PART(student_name, ',', 1)                          AS nachname,
       SPLIT_PART(student_name, ',', 2)                          AS vorname,
       kurs,
       dozent,
       stadt,
       vorwahl,
       UNNEST(regexp_split_to_array(lieblingsmodule, ', '))::INT AS lieblingsmodul,
       UNNEST(regexp_split_to_array(beschreibungen, ', '))       AS beschreibung,
       UNNEST(regexp_split_to_array(anzahl_tage, ', '))::INT     AS anzahl_tage
FROM unnormalized_students;

-- Jetzt neu: Tabelle erstellen aus einem SELECT mit CREATE TABLE AS:
DROP TABLE IF EXISTS students_1nf;

CREATE TABLE students_1nf AS
SELECT feedback_date,
       SPLIT_PART(student_name, ',', 1)                          AS nachname,
       SPLIT_PART(student_name, ',', 2)                          AS vorname,
       kurs,
       dozent,
       stadt,
       vorwahl,
       UNNEST(regexp_split_to_array(lieblingsmodule, ', '))::INT AS lieblingsmodul,
       UNNEST(regexp_split_to_array(beschreibungen, ', '))       AS beschreibung,
       UNNEST(regexp_split_to_array(anzahl_tage, ', '))::INT     AS anzahl_tage
FROM unnormalized_students;

SELECT *
FROM students_1nf;

-- Wir sehen, dass es hier viele Doppelungen gibt
-- Es wiederholen sich z.B. zu einzelnen Studenten Vor- und Nachnamen
-- Das ist unnötige Redundanz.
-- Quizfrage: Wie viele Tabellen lassen sich aus der vorliegenden Tabelle herstellen?


/*
Umwandlung zur 2. Normalform (2NF)!

Eine Relation erreicht die zweite Normalform, wenn:
- sie bereits in der ersten Normalform ist und
- jedes Nicht-Schlüssel-Attribut funktional vollständig vom Primärschlüssel abhängt.

Bsp.: In einer Tabelle Bestellungen ist Primärschlüssel die order_id.
Kunden, die Bestellungen getätigt haben, erscheinen in der orders-Tabelle mit customer_id.
Zusätzliche Informationen wie Nachname, Vorname, Adresse des Kunden werden NICHT durch
den Primärschlüssel der Tabelle (order_id) bestimmt.
Da diese Merkmale von der customer_id abhängen, die in der customer-Tabelle Primärschlüssel ist,
gehören diese Attribute nicht in orders, sondern in customers!

Um die zweite Bedingung zu überprüfen: Wenn Attribute eindeutig von einem Teil des
Schlüssels identifiziert werden können, ist die Relation nicht in der zweiten Normalform!

Vorgehensweise zur Erreichung der zweiten Normalform:
- Festlegung des Primärschlüssels der gegebenen Relation; wenn dieser nur aus einem Attribut besteht, ist die Relation bereits in der 2NF.
- Überprüfung, ob bereits weitere Attribute aus Teilschlüsselattributen folgen. Wenn nicht, liegt bereits die 2NF vor. Wenn Abhängigkeiten gefunden werden, dann
- Neue Relation erstellen, die das Teilschlüsselattribut und alle davon abhängigen Nichtschlüsselattribute enthält. Das Teilschlüsselattribut wird zum Primärschlüssel der neuen Relation.
- Entfernen der ausgelagerten Nichtschlüsselattribute aus der Ausgangsrelation.
- Diesen Vorgang ab Punkt 2 wiederholen, bis alle Nichtschlüsselattribute funktional vom gesamten Schlüssel abhängig sind.
*/

SELECT *
FROM students_1nf;

-- Tabelle 1: students

DROP TABLE IF EXISTS students;

-- So sollte die Studenten-Tabelle aussehen:
SELECT DISTINCT nachname, vorname, kurs
FROM students_1nf;

-- Tabelle erstellen:
CREATE TABLE students
(
	student_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	nachname   TEXT,
	vorname    TEXT,
	kurs       TEXT
);

-- Daten einfügen:
INSERT INTO students (nachname, vorname, kurs)
SELECT DISTINCT nachname, vorname, kurs
FROM students_1nf;

-- Reinschauen:
SELECT *
FROM students;

-- Statt Kurs könnte man aus der nachfolgenden Tabelle auch Kurs-IDs holen.

-- Tabelle 2: courses
SELECT *
FROM students_1nf;

SELECT DISTINCT kurs, dozent, stadt, vorwahl
FROM students_1nf;
-- wäre schon gut, aber mit IDs noch besser.

DROP TABLE IF EXISTS courses;

CREATE TABLE courses
(
	kurs_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	kurs    TEXT,
	dozent  TEXT,
	stadt   TEXT,
	vorwahl TEXT
);

INSERT INTO courses (kurs, dozent, stadt, vorwahl)
SELECT DISTINCT kurs, dozent, stadt, vorwahl
FROM students_1nf;

SELECT *
FROM courses;

-- Fügen wir die Kurs-ID zu Students hinzu:
CREATE TABLE students_temp AS (SELECT student_id,
                                      nachname,
                                      vorname,
                                      kurs_id
                               FROM students
	                                    JOIN courses
	                                         USING (kurs));

DROP TABLE students;

ALTER TABLE students_temp
	RENAME TO students;

ALTER TABLE students
	ADD PRIMARY KEY (student_id);

SELECT *
FROM students;

SELECT *
FROM courses;

-- Aber es sind in 'courses' weitere Abhängigkeiten drin! Mehrere Leute haben gleiche Stadt UND gleiche Vorwahl.
-- Die Vorwahl hängt direkt von der Stadt ab. Das ist ein Fall von der 3. Normalform.
-- Das lässt sich durch eine weitere Tabelle also noch weiter zerlegen!

CREATE TABLE city
(
	city_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	stadt   TEXT,
	vorwahl TEXT
);

INSERT INTO city (stadt, vorwahl)
SELECT DISTINCT stadt, vorwahl
FROM courses;

SELECT *
FROM city;

SELECT kurs_id, kurs, dozent, city_id
FROM courses
	     JOIN city USING (stadt, vorwahl);

CREATE TABLE courses_temp
AS
	(SELECT kurs_id, kurs, dozent, city_id
	 FROM courses
		      JOIN city USING (stadt, vorwahl));

DROP TABLE courses;

ALTER TABLE courses_temp
	RENAME TO courses;

ALTER TABLE courses
	ADD PRIMARY KEY (kurs_id);

SELECT *
FROM courses;

SELECT *
FROM city;

-- Aufgabe: Erstelle die dritte Tabelle 'modules'


-- Die letzte Tabelle nicht vergessen: Faktentabelle
-- Sehr viele überflüssige Informationen können nun entfernt werden
SELECT *
FROM students_1nf;

-- So sieht die gewünschte Tabelle aus:
SELECT feedback_date,
       student_id,
       lieblingsmodul
FROM students_1nf s
	     JOIN modules m
	          ON s.lieblingsmodul = m.modul_id
	     JOIN courses k USING (kurs)
	     JOIN students USING (nachname, vorname);

-- Die Faktentabelle erstellen:
CREATE TABLE feedback AS
	(SELECT feedback_date,
	        student_id,
	        m.modul_id
	 FROM students_1nf s
		      JOIN modules m
		           ON s.lieblingsmodul = m.modul_id
		      JOIN courses k USING (kurs)
		      JOIN students USING (nachname, vorname));

ALTER TABLE feedback
	ADD COLUMN feedback_id INT PRIMARY KEY
		GENERATED BY DEFAULT AS IDENTITY;

SELECT *
FROM feedback;

-- Angenommen, Studenten können auch in mehreren Kursen sein und dort Feedback abgeben.
-- Dann braucht es eine Zwischentabelle für Studenten und Kurse!

SELECT *
FROM students;

CREATE TABLE students_courses AS
SELECT DISTINCT student_id, kurs_id
FROM students;

SELECT *
FROM students_courses;

-- Nun braucht 'students' nicht mehr die Spalte 'kurs_id'

ALTER TABLE students
	DROP COLUMN kurs_id;

SELECT *
FROM students;

-- Jetzt sind wir bereit für den nächsten Teil!