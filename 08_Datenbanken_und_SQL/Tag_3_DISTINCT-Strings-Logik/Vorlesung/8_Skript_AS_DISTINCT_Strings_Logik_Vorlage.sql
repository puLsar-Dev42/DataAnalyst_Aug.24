/* Rechnen; DISTINCT; AS; Strings; Mehrfachbedingungen
 * 
 * 
 */

/* 1. RECHNEN IN QUERIES */
-- Datenbankabfrage ohne FROM

-- Typen: Es wird immer der "einfachste" Typ verwendet
-- Input: Zahlen, die sich als Integers darstellen lassen
-- Output: Integers (Nachkommastellen werden entfernt)
-- Erinnerung: Bei Python würden hier immer Floats entstehen
SELECT 9 / 2;

-- Bei Floats als Input kommen auch Floats raus
SELECT 9.0 / 2.0;

-- Spaltenname des Ergebnisses ändern mit AS
SELECT 5 * (2 - 10) / 3 AS Rechenergebnis;

SELECT 5.0 * (2.0 - 10.0) / 3.0 AS Rechenergebnis;

-- Prinzipiell reicht auch ein Float, damit das Ergebnis Float wird
SELECT 5.0 * (2 - 10) / 3 AS Rechenergebnis;

-- Können auch einfach Zahlen/Text dargestellt werden
SELECT 5.23;
SELECT 'Hallo';

-- Typenumwandlung - Englisch: Type Casting
-- Umwandeln von Floats in Integers mit:
-- CAST(ZAHL AS DATENTYP)
SELECT CAST(5.23 AS integer);
-- Ergebnis identisch mit:
SELECT 5;

-- Ergebnis der Umwandlung kann weiterverarbeitet werden
SELECT CAST(Total AS integer) - 1.1
FROM Invoice;

-- Runden von Zahlen mit
-- ROUND(ZAHL, DEZIMALSTELLEN)
SELECT ROUND(5.23, 1);

-- Übrigens gibt es in SQLite keinen Datentyp Boolean, sondern in dem Fall
-- nur die 0 und die 1. Mehr: https://www.sqlite.org/datatype3.html

/* Übung: 
 * Rechne die Spalte Total aus der Tabelle Invoice
 * aus Dollar in Euro um. Nenne die resultierende
 * Spalte "Gesamtbetrag €" und lasse dir alles auf zwei
 * Nachkommastellen genau ausgeben
 */
SELECT Total AS Gesamtbetrag_$,
       ROUND(Total * 0.95, 2) AS Gesamtbetrag_€
FROM Invoice;

/* 2. DISTINCT - EINZIGARTIGE WERTE */
-- Alle einzigartigen Vornamen der Customer anzeigen lassen.
SELECT DISTINCT FirstName
FROM Customer
ORDER BY FirstName;

-- Kurzer Check (müsst ihr aktuell noch nicht verstehen!):
SELECT COUNT(DISTINCT(FirstName))
FROM Customer;

SELECT COUNT(FirstName)
FROM Customer;

-- Alle einzigartigen Kundennummern aus Invoice ausgeben lassen:
SELECT *
FROM Invoice; -- 412 Zeilen

SELECT DISTINCT CustomerId
FROM Invoice; -- 59 Zeilen

-- Bei mehreren Spalten sucht DISTINCT nach
-- einzigartigen Kombinationen
SELECT DISTINCT FirstName, LastName
FROM Customer
ORDER BY FirstName;

SELECT *
FROM Invoice;  -- 412 Zeilen

SELECT DISTINCT CustomerId, Total
FROM Invoice;  -- 360 Zeilen

-- Syntax-Error bei zwei DISTINCT-Abfragen
SELECT DISTINCT FirstName, DISTINCT LastName
FROM Customer
ORDER BY FirstName;

-- Wichtiges Detail: Wir können nach Spalten sortieren,
-- die wir uns dann nicht ausgeben lassen!
SELECT DISTINCT FirstName
FROM Customer
ORDER BY LastName;

-- Alias-Namen für Spalten können im selben Statement
-- stellvertretend für die Spalte genutzt werden
SELECT DISTINCT FirstName AS vorname
FROM Customer
WHERE vorname != 'Marc'
ORDER BY vorname;

-- Schreibweise ohne Alias in der Where-Bedingung:
SELECT DISTINCT FirstName AS vorname
FROM Customer
WHERE FirstName != 'Marc'
ORDER BY FirstName;

/* Übungen:
 * 1. Lasse dir alle einzigartigen AlbumIDs aus der Tabelle Track ausgeben.
 * 2. Löse mit den neuen Mitteln: Aus welchen Städten kommen unsere Mitarbeiter?
 * 3. Unsere Kunden kommen aus einigen Ländern. Welches sind die fünf ersten
 * Länder, wenn wir uns die verschiedenen Länder in umgekehrter alphabetischer
 * Reihenfolge ausgeben lassen?
 */

SELECT DISTINCT AlbumId
FROM Track;

SELECT DISTINCT City
FROM Employee;

SELECT DISTINCT Country
FROM Customer
ORDER BY Country DESC
LIMIT 5;

/*

-- KEIN GUTER SQL CODE!!!

->>VERGESSEN!!!<<-

SELECT DISTINCT Customer.Country
ORDER BY Country DESC
LIMIT 5;

*/

-- Back to Strings: Alle Künstler, die kein Leerzeichen enthalten.
SELECT Name AS Bandname
FROM Artist
WHERE Name NOT LIKE '% %';

-- Was passiert, wenn wir so etwas wie "Künstler/Bandname"
-- für den Spaltennamen nutzen?
SELECT Name AS "Künstler/Bandname"
FROM Artist
WHERE Name NOT LIKE '% %';

SELECT Name AS "Künstler oder Band"
FROM Artist
WHERE Name NOT LIKE '% %';

-- >>> Mit doppelten Anführungszeichen lassen sich Spalten mit
-- Zeichen erstellen, die in SQL sonst Syntax-Bedeutung haben.

/* 3. STRING-BEARBEITUNG */
-- Länge eines Strings mit:
-- LENGTH(SPALTE)
SELECT LENGTH(FirstName)
FROM Customer;

-- Dasselbe in Schöner (Namen daneben zum Vergleich):
SELECT FirstName AS Vorname,
       LENGTH(FirstName) AS Laenge
FROM Customer;

-- Die 10 längsten Vornamen ausgeben lassen ohne Zusatzspalte mit Längen:
SELECT FirstName AS vorname
FROM Customer
ORDER BY LENGTH(vorname) DESC
LIMIT 10;

-- Die längsten 10 Vornamen und deren Länge
-- ausgeben lassen
SELECT
	FirstName AS vorname,
	LENGTH(FirstName) AS vornamenlaenge
FROM Customer
ORDER BY LENGTH(vorname) DESC
LIMIT 10;

-- Strings verketten mit "||"
SELECT FirstName ||' '|| LastName
FROM Customer;

-- Substrings extrahieren mit:
-- SUBSTR(SPALTE, STARTPOSITION, ZEICHENANZAHL)

-- Erste beiden Buchstaben (Index beginnt bei 1!)
SELECT SUBSTR(FirstName, 1, 2),
       FirstName -- Zum Vergleich
FROM Customer;

-- Letzte beiden Buchstaben (Klassisch mit negativem Index bei Start!)
SELECT SUBSTR(FirstName, -2, 2),
       FirstName -- Zum Vergleich
FROM Customer;

-- Drei Zeichen ab zweitem Buchstaben:
SELECT SUBSTR(FirstName, 2, 3)
FROM Customer;

-- Excel: LINKS, RECHTS, TEIL
-- Python: string[1:5]

-- Indizieren Python: Start bei 0, Intervalle halboffen 
--                    -> Ende nicht mehr mit drin
--               SQL: Start bei 1, Intervalle geschlossen 
--                    -> Letzter Wert wird eingeschlossen      

/* Übung: 
 * Erstelle eine Spalte mit den Initialen aller Mitarbeiter.
 * Verwende dazu die Employee Tabelle.
 * "Andrew Adams" soll zu "A.A." werden.
 */

SELECT FirstName || ',' || LastName AS CompleteName,
    SUBSTR(FirstName, 1, 1)
        || '.' ||
    SUBSTR(LastName, 1, 1)
        || '.' AS Initials
FROM Employee;

-- Groß- Kleinschreibung mit:
-- UPPER(SPALTE)
SELECT UPPER(FirstName) 
FROM Employee;
-- LOWER(SPALTE)
SELECT LOWER(FirstName)
FROM Employee;

/* 4. BEDINGUNGEN */
-- Mehrfachbedingungen

-- Alle Kunden auswählen, die aus den USA kommen
-- und deren PLZ entweder mit einer 8 beginnt oder ein '-' enthält.
SELECT *
FROM Customer
WHERE Country = 'USA'
AND (PostalCode LIKE '8%' OR PostalCode LIKE '%-%');

-- Achtung, die Klammern sind wichtig. Was kriegt man, wenn man sie weglässt?
SELECT *
FROM Customer
WHERE Country = 'USA'
AND PostalCode LIKE '8%' OR PostalCode LIKE '%-%';

-- Zahlenbereiche als Bedingung mit:
-- BETWEEN ... AND ...
SELECT EmployeeId
FROM Employee
WHERE EmployeeId BETWEEN 1 AND 4;

-- Auswahl an Möglichkeiten als Bedingung mit:
-- IN ()
SELECT *
FROM Employee
WHERE EmployeeId IN (2, 4, 6, 8);

/* Übung:
 * Wähle alle Tracks aus Alben der IDs 1-100 aus, die 
 * entweder Genre 2, 5, 8 oder 10 angehören.
 */

SELECT *
FROM Track
WHERE AlbumId BETWEEN 1 AND 100
AND GenreId IN (2, 5, 8, 10);
