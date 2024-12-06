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
SELECT 9.0 / 2.0 AS Result;
SELECT 5 * (2 - 10) / 3 AS Rechenergebnis;

-- Prinzipiell reicht auch ein Float, damit das Ergebnis Float wird
SELECT 4.5 / 2 AS Result;
SELECT 5 * (2 - 10) / 3.0 AS Rechenergebnis;

-- Können auch einfach Zahlen/Text dargestellt werden
SELECT 5.2;
SELECT 'Hello, World!' AS Greeting;

-- Typenumwandlung - Englisch: Type Casting
-- Umwandeln von Floats in Integers mit:
-- CAST(ZAHL AS DATENTYP)
SELECT CAST(5.23 AS INTEGER);
-- Ergebnis identisch mit:
SELECT 5;

-- Ergebnis der Umwandlung kann weiterverarbeitet werden
SELECT *
FROM Invoice;

SELECT CAST(Total AS INTEGER) + 100 AS komische_Rechnung
FROM Invoice;

-- Runden von Zahlen mit
-- ROUND(ZAHL, DEZIMALSTELLEN)
SELECT ROUND(5.3451432141, 2);

-- Übrigens gibt es in SQLite keinen Datentyp Boolean, sondern in dem Fall
-- nur die 0 und die 1. Mehr: https://www.sqlite.org/datatype3.html

/* Übung: 
 * Rechne die Spalte Total aus der Tabelle Invoice
 * aus Dollar in Euro um. Nenne die resultierende
 * Spalte "Gesamtbetrag €" und lasse dir alles auf zwei
 * Nachkommastellen genau ausgeben
 */
SELECT ROUND(Total * 0.93, 2) AS "Gesamtbetrag €",
       Total                  AS "Gesamtbetrag $"
FROM Invoice;

/* 2. DISTINCT - EINZIGARTIGE WERTE */
-- Alle einzigartigen Vornamen der Customer anzeigen lassen.
SELECT *
FROM Customer;
-- 59 rows

-- Alle eindeutigen Kundenvoranamen:
SELECT DISTINCT FirstName
FROM Customer; -- 57 rows

SELECT *
FROM Customer
ORDER BY Country;
-- 59

-- Alle eindeutigen Ländernamen:
SELECT DISTINCT Country
FROM Customer
ORDER BY Country;
-- 24

-- Wie viele als Zahl:
SELECT COUNT(DISTINCT Country) AS Countries_Count
FROM Customer
ORDER BY Country;

-- Selbiges für FirstName:
SELECT COUNT(DISTINCT FirstName)
FROM Customer;

-- Alle einzigartigen Kundennummern aus Invoice ausgeben lassen:
SELECT *
FROM Invoice
ORDER BY CustomerId;

SELECT DISTINCT CustomerId
FROM Invoice;

-- Bei mehreren Spalten sucht DISTINCT nach
-- einzigartigen Kombinationen
SELECT DISTINCT FirstName, LastName
FROM Customer; -- 59 Zeilen (> keine Duplikate!)

SELECT DISTINCT FirstName
FROM Customer; -- gab es Duplikate (57 Zeilen)

SELECT DISTINCT LastName
FROM Customer;
-- keine Duplikate

-- Dasselbe mit Ländern und Städten:
SELECT *
FROM Invoice;

-- Eindeutige Städte:
SELECT DISTINCT BillingCity
FROM Invoice
ORDER BY BillingCity;

-- Eindeutige Länder:
SELECT DISTINCT BillingCountry
FROM Invoice
ORDER BY BillingCountry;

-- Eindeutige Kombinationen aus Stadt - Land:
SELECT DISTINCT BillingCity, BillingCountry
FROM Invoice
ORDER BY BillingCountry, BillingCity;

-- Syntax-Error bei zwei DISTINCT-Abfragen
SELECT DISTINCT FirstName, DISTINCT LastName
FROM Customer;

-- Wichtiges Detail: Wir können nach Spalten sortieren,
-- die wir uns dann nicht ausgeben lassen!
SELECT BillingCity, BillingCountry
FROM Invoice
ORDER BY Total;

-- Alias-Namen für Spalten können im selben Statement
-- stellvertretend für die Spalte genutzt werden
SELECT FirstName AS Vorname
FROM Customer
ORDER BY Vorname;

-- Wäre sehr nervig:
SELECT ROUND((Total * 0.95) * 0.19, 2) AS MWSt
FROM Invoice
ORDER BY ROUND((Total * 0.95) * 0.19, 2) ASC;

-- Zum Glück geht das so:
SELECT ROUND((Total * 0.95) * 0.19, 2) AS MWSt
FROM Invoice
ORDER BY MWSt;

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

-- Back to Strings: Alle Künstler, die kein Leerzeichen enthalten.
SELECT Name AS Bandname
FROM Artist
WHERE Name NOT LIKE '% %';

-- Was passiert, wenn wir so etwas wie "Künstler/Bandname"
-- für den Spaltennamen nutzen?
SELECT Name AS "Künstler/Bandname"
FROM Artist
WHERE Name NOT LIKE '% %';

SELECT Name AS "Künstler oder Bandname"
FROM Artist
WHERE Name NOT LIKE '% %';

-- >>> Mit doppelten Anführungszeichen lassen sich Spalten mit
-- Zeichen erstellen, die in SQL sonst Syntax-Bedeutung haben.
-- Gängige Spaltennamen: CustomerId, customer_id, CustomerID
SELECT *
FROM Customer;

/* 3. STRING-BEARBEITUNG */
-- Länge eines Strings mit:
-- LENGTH(SPALTE)
SELECT *
FROM Customer;

SELECT length(FirstName)
FROM Customer;
-- Dasselbe in Schöner (Namen daneben zum Vergleich):
SELECT FirstName         AS Vorname,
       length(FirstName) AS Länge
FROM Customer;

-- Die längsten 10 Vornamen und deren Länge
-- ausgeben lassen
SELECT FirstName         AS Vorname,
       length(FirstName) AS Länge
FROM Customer
ORDER BY Länge DESC
LIMIT 10;

-- Strings verketten mit "||"
SELECT FirstName || ' ' || LastName AS FullName
FROM Customer;


SELECT LastName || ', ' || FirstName AS FullName
FROM Customer;

-- Substrings extrahieren mit:
-- SUBSTR(SPALTE, STARTPOSITION, ZEICHENANZAHL)

-- Erste beiden Buchstaben (Index beginnt bei 1!)
SELECT SUBSTR(FirstName, 1, 2)
FROM Customer;

SELECT SUBSTR(FirstName, 1, 2) AS FirstTwo,
       FirstName
FROM Customer;

-- Letzte beiden Buchstaben (Klassisch mit negativem Index bei Start!)
SELECT SUBSTR(FirstName, -2, 2) AS LastTwo,
       FirstName
FROM Customer;

-- Drei Zeichen ab zweitem Buchstaben:
SELECT substr(FirstName, 2, 3)
FROM Customer;

-- Zur Unterhaltung (hier gibt es leere Strings):
SELECT substr(FirstName, 4, 3)
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
SELECT FirstName || ' ' || LastName AS employee,
       SUBSTR(FirstName, 1, 1) || '.' || SUBSTR(LastName, 1, 1) ||
       '.'                          AS initials
FROM Employee;

-- Groß- Kleinschreibung mit:
-- UPPER(SPALTE)
SELECT UPPER(LastName)
FROM Employee;
-- LOWER(SPALTE)
SELECT LOWER(FirstName)
FROM Employee;

/* 4. BEDINGUNGEN */
-- Mehrfachbedingungen

-- Alle Kunden auswählen, die aus den USA kommen
-- und deren PLZ entweder mit einer 8 beginnt oder ein '-' enthält.
SELECT Country,
       PostalCode
FROM Customer
WHERE Country = 'USA'
  AND (PostalCode LIKE '8%' OR PostalCode LIKE '%-%');

-- Achtung, die Klammern sind wichtig. Was kriegt man, wenn man sie weglässt?
SELECT Country,
       PostalCode
FROM Customer
WHERE Country = 'USA' AND PostalCode LIKE '8%'
   OR PostalCode LIKE '%-%';

-- Klammerlogik hier wäre:
SELECT Country,
       PostalCode
FROM Customer
WHERE (Country = 'USA' AND PostalCode LIKE '8%')
   OR PostalCode LIKE '%-%';

-- Zahlenbereiche als Bedingung mit:
-- BETWEEN ... AND ...
SELECT EmployeeId,
       FirstName,
       LastName
FROM Employee
WHERE EmployeeId BETWEEN 1 AND 4;

-- Auswahl an Möglichkeiten als Bedingung mit:
-- IN ()
SELECT *
FROM Employee
WHERE EmployeeId IN (1, 3, 7);

SELECT *
FROM Customer
WHERE Country = 'Germany';

-- Schritt 1: Nur Kundennummern:
SELECT CustomerId
FROM Customer
WHERE Country = 'Germany';

-- Ziel: Invoice mit den deutschen CustomerIds von oben filtern:
SELECT *
FROM Invoice;

-- Lösung mit Subquery:
SELECT *
FROM Invoice
WHERE CustomerId IN (SELECT CustomerId
                     FROM Customer
                     WHERE Country = 'Germany');

-- Bonusaufgabe: Beschäftige dich mit Subqueries!

/* Übung:
 * Wähle alle Tracks aus Alben der IDs 1-100 aus, die 
 * entweder Genre 2, 5, 8 oder 10 angehören.
 */

SELECT *
FROM Track
WHERE GenreId IN (2, 5, 8, 10)
AND AlbumId BETWEEN 1 AND 100;
