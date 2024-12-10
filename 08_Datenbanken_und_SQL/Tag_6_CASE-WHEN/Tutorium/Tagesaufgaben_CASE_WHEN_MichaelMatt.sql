/* Tagesaufgaben: Case When, Datetime in SQLite
 * ------------------
 */

-- Verbinde dich zu der 'kursdaten.sqlite'
-- Datenbank und schaue auf das ER Diagramm.
-- Verwende wieder möglichst erklärende
-- Spaltenbezeichnungen in deinen Lösungen.


/* ---------
 * TEIL 1 - CASE, WHEN
 * ---------
 */

/* ---------
 * a) 	Teile die Schüler in zwei Gruppen ein.
 * 		Lasse dir dazu die Namen der Teilnehmer
 * 		und eine neue Spalte anzeigen, welche
 * 		die Gruppe des Schülers zeigt.
 *    	In Gruppe 1 sollen alle fallen, deren
 * 		Name mit A bis F beginnt. In Gruppe 2
 * 		fallen alle Schüler mit einem anderen
 * 		Anfangsbuchstaben.
 */
SELECT name,
       CASE
	       WHEN name BETWEEN 'A' AND 'F'
		       THEN 'Group1'
	       ELSE 'Group2'
	       END AS 'StudentGroups'
FROM student;


/* b) 	Zeige das Alter der Studenten an,
 * 		sowie eine neue Spalte, welche das
 * 		Alter folgendermaßen kategorisiert:
 * 			< 30:  "young adult"
 * 			30 - 50:  "adult"
 * 			> 50:  "golden ager"
 */
SELECT name,
       age,
       CASE
	       WHEN age < 30
		       THEN 'young adult'
	       WHEN age BETWEEN 30 AND 50
		       THEN 'adult'
	       WHEN age > 50
		       THEN 'golden ager'
	       END AS 'AgeGroups'
FROM student;

/* c) 	Berechne zwei Spalten zum Bestehen
 * 		der Prüfungen:
 *    1.Wenn in der Note im Monat 1 eine
 * 		Punktzahl über 20 erreicht wurde,
 *      dann soll 'bestanden' eingetragen
 * 		werden. Wenn nicht, dann 'nicht bestanden'.
 *    2.Bei der Note im Monat 6 soll die
 * 		Prüfung ab einer Punktzahl über 50
 * 		als bestanden gelten und dieselben
 * 		Texte wie bei 1. eingetragen werden.
 *
 *      Optional: Erstelle eine Spalte, die anzeigt
 * 		ob eine Person entweder nie bestanden,
 *      nur im 1. Monat bestanden, nur nach
 * 		6 Monaten bestanden, oder immer bestanden hat.
 */
SELECT name         AS StudentName,
       note_monat_1 AS GradeMonth1,
       note_monat_6 AS GradeMonth6,
       CASE
	       WHEN note_monat_1 > 20
		       THEN 'passed'
	       ELSE 'failed'
	       END      AS 'ResultMonth1',
       CASE
	       WHEN note_monat_6 > 50
		       THEN 'passed'
	       ELSE 'failed'
	       END      AS 'ResultsMonth6',
       CASE
	       WHEN note_monat_1 > 20 AND note_monat_6 > 50
		       THEN 'passed everytime'
	       WHEN note_monat_1 > 20 AND note_monat_6 <= 50
		       THEN 'passed only in 1. Month'
	       WHEN note_monat_1 <= 20 AND note_monat_6 > 50
		       THEN 'passed only in 6. Month'
	       ELSE 'failed everytime'
	       END      AS 'ExaminationStatus'
FROM student;

/* d) 	OPTIONAL: Zeige den Namen der Studenten
 * 		an, sowie zwei neue Spalten. In diesen
 * 		Spalten soll für die Prüfung in Monat 1
 * 		und Monat 6 jeweils 'unter Durchschnitt',
 * 		'Durschschnitt', oder 'über Durchschnitt'
 * 		angezeigt werden, indem du die Note der
 * 		Schüler mit der Durchschnittsnote des
 * 		Kurses für die jeweilige Prüfung
 * 		vergleichst.
 * 
 * 	  	Versuche auch, den berechneten
 * 		Notendurchschnitt zu runden. Ändert
 * 		sich das Ergebnis?
 */
SELECT ROUND(AVG(note_monat_1), 2) AS AverageMonth1,
       ROUND(AVG(note_monat_6), 2) AS AverageMonth6
FROM student;
--
SELECT name    AS StudentName,
       CASE
	       WHEN note_monat_1 < 31
		       THEN 'below average'
	       WHEN note_monat_1 = 31
		       THEN 'averag'
	       ELSE 'above averag'
	       END AS 'StatusMonth1',
       CASE
	       WHEN note_monat_6 < 41
		       THEN 'below average'
	       WHEN note_monat_6 = 41
		       THEN 'averag'
	       ELSE 'above averag'
	       END AS 'StatusMonth6'
FROM student;

-- Antwort:  


/* ---------
* Aufgabe 2 - Datetime
* ---------
* Manches hier lässt sich auch ohne Datetime lösen.
* Mehr Datetime Funktionen kommen in Postgres.
*/

/* a) Lass dir das heutige Datum anzeigen.
 * 
 */
SELECT DATE('now') AS Today;

/* b) Lass dir das Datum vor 1 Jahr und
 * 	  2 Monaten ausgeben;
 */
SELECT DATE('now', '-1 year', '-2 months') AS SpecificDate;

/* c) Lass dir das Alter der Studenten
 * 	  und ihr Geburtsjahr anzeigen.
 *    Sortiere nach Geburtsjahr.
 */
SELECT name,
       age,
       DATE('now') - age AS YearOfBirth
FROM student
ORDER BY YearOfBirth;

/* d) Zeige den Namen der Studenten
 * 	  an sowie eine weitere Spalte,
 * 	  welche die Generation basierend
 * 	  auf dem Geburtsjahr anzeigt:
 * 
 * 	   bis 1964: 'Baby Boomer'
 * 	   1965 - 1980: 'Gen X'
 * 	   1981 - 1996: 'Millennial'
 *     1997 - 2012: 'Gen Z'
 * 
 *    Hier kannst du auf deine 
 * 	  Gebburtsjahr-Berechnung aus 
 *    Aufgabe 2a) aufbauen. 
 */
SELECT name,
       DATE('now') - age AS YearOfBirth,
       CASE
	       WHEN DATE('now') - age <= 1964
		       THEN 'Baby Boomer'
	       WHEN DATE('now') - age BETWEEN 1965 AND 1980
		       THEN 'Gen X'
	       WHEN DATE('now') - age BETWEEN 1981 AND 1996
		       THEN 'Millennial'
	       ELSE 'Gen Z'
	       END           AS Generation
FROM student;

/* ---------
 * Optional
 * ---------
 * 
 * 	  Schaue dir schon mal die Website von
 * 	  postgres (https://www.postgresql.org/)
 *    an und klicke dich eventuell durch 
 *    die Dokumentation. 
 */
😅👍

