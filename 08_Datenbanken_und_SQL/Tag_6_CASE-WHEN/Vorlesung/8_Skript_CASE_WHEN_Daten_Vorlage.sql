/* CASE WHEN & Datumsformate
 * -----------------------
 */

-- Wir arbeiten weiter mit Chinook

/* -----------------------
 * 1: CASE WHEN
 * -----------------------
 *
 * - CASE WHEN hatten wir bereits in Python kennengelernt
 * - Es ähnelt if-else-Bedingungen,
 * - aber die Variabel wird festgehalten und mit gewissen Fällen verglichen
 * 
 * - Wenn eine Bedingung im CASE WHEN zutrifft,
 *   wird der entsprechende Block ausgeführt.
 *   Die weiteren Bedingungen werden in dem Fall
 *   nicht überprüft.
 * 
 * - Falls keine der Bedingungen im CASE WHEN
 *   zutrifft, wird der ELSE-Block ausgeführt,
 *   falls ein Else vorhanden ist.
 * 
 * - CASE WHEN eignet sich hervorragend, um z.B.
 *   numerische Daten zu kategorisieren oder auch bei String-Matching.7
 *   Der Aufbau ist: CASE ...
                          WHEN ... THEN ...
                          WHEN ... THEN ...
                          ... (beliege viele WHEN-THEN-Blöcke)
                          ELSE ... (optional)
                          END AS MeinSpaltenName
 */

-- Beispiel: Song-Längen kategorisieren.
--           Zunächst ganze Tabelle auswählen
SELECT *
FROM Track;

-- Mit CASE WHEN alle möglichen Werte abdecken
-- Grenzwert: 300000 - drunter: kurz, drüber: lang
SELECT Name,
       Milliseconds,
       CASE
	       WHEN Milliseconds > 300000
		       THEN 'long'
	       ELSE 'short'
	       END AS TrackLength
FROM Track;

-- Ohne ELSE
SELECT Name,
       Milliseconds,
       CASE
	       WHEN Milliseconds > 400000
		       THEN 'long'
	       WHEN Milliseconds <= 400000
		       THEN 'short'
	       END AS TrackLength
FROM Track;

-- Was, wenn durch CASE WHEN nicht der gesamte Wertebereich abgedeckt wird
SELECT Name,
       Milliseconds,
       CASE
	       WHEN Milliseconds > 400000
		       THEN 'long'
	       END AS TrackLength
FROM Track;
-- Keine gute Idee, es sei denn, man steht auf NULLs.

-- Mehrere Kategorien bilden:
-- Songs unter 3 Minuten,
-- zwischen 3 und 6 Minuten,
-- zwischen 6 und 9 Minuten,
-- über 9 Minuten.
SELECT Milliseconds / 60000.0 AS Minutes
FROM Track;

SELECT Name,
       CASE
	       WHEN Milliseconds / 60000.0 < 3
		       THEN 'sehr kurz'
	       WHEN Milliseconds / 60000.0 BETWEEN 3 AND 6
		       THEN 'kurz'
	       WHEN Milliseconds / 60000.0 BETWEEN 6 AND 9
		       THEN 'lang'
	       ELSE 'sehr lang'
	       END AS Tracklänge
FROM Track;

-- Wunsch: Milliseconds durch 60000 nicht immer wiederholen
-- Problem: Neu erstellte Spalten sind im SELECT noch nicht nutzbar
-- SQL Error
SELECT Milliseconds / 60000.0 AS Minutes,
       CASE
	       WHEN Minutes < 3
		       THEN 'sehr kurz'
	       WHEN Minutes <= 6
		       THEN 'kurz'
	       ELSE 'lang'
	       END                AS Tracklänge
FROM Track;

-- Über Subquery können wir doch auf Minuten zugreifen
SELECT Name,
       CASE
	       WHEN Minutes < 3
		       THEN 'sehr kurz'
	       WHEN Minutes <= 6
		       THEN 'kurz'
	       WHEN Minutes <= 9
		       THEN 'lang'
	       ELSE 'sehr lang'
	       END AS Tracklänge
FROM (SELECT Name,
             Milliseconds / 60000.0 AS Minutes
      FROM Track);

-- CASE WHEN kombinierbar mit weiteren bereits
-- gelernten Bedingungen

SELECT City,
       CASE
	       WHEN LENGTH(City) > 10
		       THEN 'long'
	       ELSE 'short'
	       END AS NameLength
FROM Customer;

-- Zwischenübung: Erweitere obigen Code, sodass gezählt wird, wie viele lange
-- und kurze Städtenamen es gibt.


-- Soll eine Spalte ganz bestimmte Werte erhalten,
-- dann kann die Spalte direkt neben CASE stehen.
-- Auf diese Weise muss man sie nicht jedes Mal aufs Neue schreiben.

SELECT *
FROM Employee;

SELECT City,
       CASE City
	       WHEN 'Edmonton'
		       THEN 'Friend'
	       WHEN 'Lethbridge'
		       THEN 'Foe'
	       WHEN 'Calgary'
		       THEN 'Who''s this?' -- das erste ' hebelt die Bedeutung von ' aus
	       END AS CityPrejudices
FROM Employee;

-- Es dürfen beliebig viele Case when in einer Query vorkommen
-- STRFTIME = String-Format-Time (STR.ing-F.ormat-TIME)
SELECT LastName                 AS Nachname,
       STRFTIME('%Y', HireDate) AS Anstellungsjahr,
       CASE STRFTIME('%Y', HireDate)
	       WHEN '2002'
		       THEN 'Altes Eisen'
	       WHEN '2003'
		       THEN 'Erfahren'
	       WHEN '2004'
		       THEN 'Neu und naiv'
	       END                  AS Arbeitserfahrung,
       Title                    AS Jobtitel,
       CASE Title
	       WHEN 'General Manager'
		       THEN 'Keine Ahnung vom Laden'
	       WHEN 'Sales Manager'
		       THEN 'Keine Ahnung von den Kunden'
	       WHEN 'Sales Support Manager'
		       THEN 'Keine Zeit zu denken'
	       WHEN 'Sales Support Agent'
		       THEN 'Keine Zeit zu atmen'
	       WHEN 'IT Manager'
		       THEN 'Nicht genug Ahnung vom Detail'
	       WHEN 'IT Staff'
		       THEN 'Keine Chance'
	       END                  AS Überblick
FROM Employee;

/* ÜBUNGSAUFGABE 1 
 * -----------------------
 * Du möchtest für dein Unternehmen Kundensegmente
 * erstellen. Hierzu möchtest du deiner Ausgabe 
 * der Gesamttabelle Invoice folgende Information
 * in einer neuen Spalte hinzufügen:
 * 	Wenn der Kunde aus der Hauptstadt seines Landes
 * 	kommt, soll in der neuen Spalte "Hauptstadt-Kunde"
 * 	angezeigt werden. Kommt der Kunde nicht aus
 * 	der Hauptstadt seines Landes, soll in der neuen
 * 	Spalte "Nicht-Hauptstadt-Kunde" angezeigt werden.
 * 
 * Liste der Hauptstädte:
 * 		'Oslo', 'Prague', 'Vienne',
 *      'Brussels', 'Copenhagen', 'Brasília',
 *      'Lisbon', 'Berlin', 'Paris', 'Helsinki',
 *      'Rome', 'Warsaw', 'Amsterdam', 'Budapest',
 *      'London', 'Stockholm', 'Delhi', 'Madrid'
 */

SELECT *,
       CASE
	       WHEN BillingCity IN ('Oslo', 'Prague', 'Vienne',
	                            'Brussels', 'Copenhagen', 'Brasília',
	                            'Lisbon', 'Berlin', 'Paris', 'Helsinki',
	                            'Rome', 'Warsaw', 'Amsterdam', 'Budapest',
	                            'London', 'Stockholm', 'Delhi', 'Madrid')
		       THEN 'Hauptstadt-Kunde'
	       ELSE 'Nicht-Hauptstadt-Kunde'
	       END AS Kunden_Art
FROM Invoice;


-- CASE WHEN als Bedingung beim Suchen
-- Bei Beträgen unter 10, deutsche Rechnungen suchen.
-- Bei Beträgen ab 10, Rechnungen aus den USA suchen.
SELECT InvoiceId,
       Total,
       BillingCountry
FROM Invoice
WHERE CASE
	      WHEN Total < 10
		      THEN BillingCountry = 'Germany'
	      WHEN Total >= 10
		      THEN BillingCountry = 'USA'
	      END;

-- Alternativ mit Where:
SELECT Total, BillingCountry
FROM Invoice
WHERE BillingCountry = 'Germany' AND Total < 10
   OR BillingCountry = 'USA' AND Total >= 10;

/* ÜBUNGSAUFGABE 2
 * -----------------------
   Den folgenden Code solltest du kennen. Passe ihn so an,
   dass du nur die Gesamtsumme pro Land in einer Spalte stehen hast.
   Füge dann eine Spalte hinzu, in der folgende Werte vorkommen können:
       über 300 Dollar: 'hohe Einnahmen'
       ab 100 bis 300 Dollar: 'moderate Einnahmen'
       unter 100: 'niedrige Einnahmen'
   Nenne die zusätzliche Spalte 'RevenueCategory'.
 */
SELECT BillingCountry,
       TotalRevenue,
       CASE
	       WHEN TotalRevenue < 100
		       THEN 'niedrige Einnahmen'
	       WHEN TotalRevenue BETWEEN 100 AND 300
		       THEN 'moderate Einnahmen'
	       WHEN TotalRevenue >= 300
		       THEN 'hohe Einnahmen'
	       END AS RevenueCategory
FROM (SELECT BillingCountry,
             SUM(Total) AS TotalRevenue
      FROM Invoice
      GROUP BY BillingCountry
      ORDER BY TotalRevenue DESC);

/* ---------------
 * 2. Zeitdaten in SQLite
 * Dokumentation: https://www.sqlite.org/lang_datefunc.html
 * ---------------
 * Achtung: In PostgreSQL wird es andere Datentypen geben
 * ---------------
 * DATE, TIME, DATETIME, JULIANDAY/UNIXEPOCH, TIMEDIFF, STRFTIME
 */

-- Warm werden
-- Aktuellen Zeitpunkt als Zeitstempel erhalten
-- (Achtung: Standard-Zeitzone UTC):
SELECT DATETIME('now') AS Now;

-- Zeitzone anpassen:
SELECT DATETIME('now', 'localtime') AS Now;

-- Zeitstempel selbst erstellen:
SELECT DATETIME('1989-11-09T18:53') AS Mauerfall;

-- Aktuelles Datum erhalten:
SELECT DATE('now') AS Today;

-- Datum erstellen
SELECT DATE('2020-03-22') AS ErsterLockdown;

-- Zu guter Letzt auch ausschließlich aktuelle Zeit
SELECT TIME('now', 'localtime') AS CurrentTime;

-- Datumsangaben modifizieren
SELECT DATE('now', '+10 years') AS Harmageddon;
SELECT DATE('now', '+73 days') AS Sommerferien;
SELECT DATE('now', '+3 years', '+2 months', '+10 days') AS SpecificDate;

-- Wenn mit INT gerechnet wird, kommt auch INT als Ergebnis wieder raus.
-- Die Ganzzahl entspricht dem Jahr:
SELECT DATE('now') - 1;
SELECT DATETIME('now') - 1;

-- Bei Time entspricht die Ganzzahl der Stunde:
SELECT TIME('now', 'localtime') - 1;
-- Achtung: Die Ergebnisse sind wirklich Integers und haben keine Eigenschaften
-- von Date-Objekten!
-- Wollen wir um ein Jahr zurückgehen und weiterhin mit einem Datum arbeiten
-- dann ist das die bessere Variante:
SELECT DATE('now', '-1 year');

SELECT HireDate,
       DATE(HireDate, '-1 year'),
       HireDate - 1
FROM Employee;

-- Zurück zu Chinook mit unserem neuen Wissen!
-- Folgende Spalten interessieren uns:
SELECT BirthDate, HireDate
FROM Employee;

-- Datentypen (und mehr) der gesamten Tabelle einsehen:
PRAGMA TABLE_INFO(Employee);
-- Mehr zu PRAGMA: https://www.sqlite.org/pragma.html#:~:text=The%20PRAGMA%20statement%20is%20an,(non%2Dtable)%20data.

-- Oder nur den Bereich auswählen, der uns interessiert:
SELECT name,
       type
FROM PRAGMA_TABLE_INFO('Employee')
WHERE name IN ('BirthDate', 'HireDate');

-- An welchem Datum gehen unsere Mitarbeiter in Rente (ab 70, natürlich)?
-- Sortiert, damit die, die als erste gehen, oben erscheinen.
SELECT DATE(BirthDate, '+70 years') AS GoodbyeDate
FROM Employee
ORDER BY GoodbyeDate;

-- Die Rechnung mit Spalten + Zahl gibt Jahres-Integers zurück
-- und nicht, was wir wollten
SELECT BirthDate + 70 AS GoodbyeDate
FROM Employee
ORDER BY GoodbyeDate;

-- Zwei Datetime-Spalten verrechnen (Datumsarithmetik)
-- Hier ist es praktisch, den Unterschied in Jahren zurückzuerhalten!
SELECT BirthDate,
       HireDate,
       HireDate - Birthdate
FROM Employee;

-- Gruppenübung: Erweitert die obere Rententabelle so, dass neben der
-- GoodbyeSpalte eine YearsToGo-Spalte (Jahre bis zur Rente) erscheint.
-- Mega-Bonus: Werde die -7 los und ersetze sie durch eine gemütliche Null.
-- Noch besser: Lasse dort "retired" stehen.
SELECT FirstName,
       LastName,
       DATE(BirthDate, '+70 years')
	       AS GoodbyYear,
       DATE(BirthDate, '+70 years') - DATE('now')
	       AS YearsToGo
FROM Employee;


-- Wenn die -7 aus der vorherigen Tabelle in ein 'retired' umgewandelt werden soll! 
SELECT FirstName,
       LastName,
       DATE(BirthDate, '+70 years')
	           AS GoodbyYear,
       CASE
	       WHEN DATE(BirthDate, '+70 years') - DATE('now') <= 0
		       THEN 'retired'
	       ELSE DATE(BirthDate, '+70 years') - DATE('now')
	       END AS YearsToGo
FROM Employee;

-- Differenz in Tagen: Wert erst in Zahl umwandeln
-- JULIANDAY berechnet Tage ab 24.11.4714 v.Chr.
SELECT JULIANDAY(HireDate) - JULIANDAY(BirthDate)
FROM Employee;

-- Der Beweis ;)
SELECT DATE(JULIANDAY(0));

-- Übung: Wie viel Tage sind seit dem 24.11.4714 v.Chr.
-- bis zu deinem Geburtstag vergangen?


-- UNIXEPOCH gibt uns dagegen die Anzahl von Sekunden aus:
SELECT UNIXEPOCH(HireDate) - UNIXEPOCH(BirthDate) AS ExistenceSeconds
FROM Employee;

-- Außerdem startet UNIXEPOCH "klassisch" am 01.01.1970 um 00:00:00
-- Der Beweis:
SELECT DATETIME(0, 'UNIXEPOCH');

-- Mit Timediff kriegen wir heraus, wie viele Jahre, Monate, Tage usw.
-- auf das rechte Datum draufgeschlagen werden müssen, um das linke zu erhalten
-- Mag lesbarer wirken, ist aber weniger präzise als die anderen Ausgaben
SELECT TIMEDIFF(HireDate, BirthDate) AS ReadableDifference
FROM Employee;

-- Übung: Lasse dir die Zeit der Anstellung von Angestellten bis zum heutigen
-- Tag a) in Jahren und b) in Tagen in einer Tabelle ausgeben.
-- Nenne die Spalten YearsWorked und DaysWorked
-- Bei den Tagen wird es viele störende Nachkommastellen geben, löse durch
-- Typenumwandlung in Ganzzahlen (wir brauchen keine halben Tage)
SELECT DATE('now') - HireDate                              AS YearsWorked,
       CAST(JULIANDAY('now') - JULIANDAY(HireDate) AS INT) AS DaysWorked
FROM Employee;
-- Datum als String ausdrücken
SELECT STRFTIME('%d.%m', BirthDate) AS Birthday
FROM Employee;

SELECT STRFTIME('%m', BirthDate) AS MonthOfBirth
FROM Employee;

-- Etwas komplexer:
SELECT STRFTIME('%Y', DATE(BirthDate, '+100 years')) AS Centennial
FROM Employee;

-- Übung: In welchem Jahr werden unser Mitarbeiter ihr 25-Jahre-Jubiläum haben?
-- Sortiere aufsteigend.
-- Es sollten Nachname, Vorname und das Jubiläumsjahr nebeneinander stehen
SELECT FirstName || ' ' || LastName                AS Name,
       STRFTIME('%Y', HireDate)                    AS HireDate,
       STRFTIME('%Y', DATE(HireDate, '+25 years')) AS TwentyFifthAnniversary
FROM Employee;


