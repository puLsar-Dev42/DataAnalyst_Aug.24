/* Skript: Gruppierung und Aggregation in SQLite */
-- Wir verbinden uns mit Chinook --

/* AGGREGATIONSFUNKTIONEN
 * COUNT, MIN, MAX, AVG, SUM
 */
-- Beispiel: Teuerste Rechnung

SELECT MAX(Total)
FROM Invoice;

-- Mit anständigem Spaltennamen
SELECT MAX(Total) AS HighestTotal
FROM Invoice;

-- Einige Aggregationen gleichzeitig
SELECT MAX(UnitPrice),
       MIN(UnitPrice),
       ROUND(SUM(UnitPrice), 2),
       AVG(UnitPrice),
       COUNT(UnitPrice)
FROM Track;

-- Mit schöneren Namen und formatierten Zahlen:
SELECT MAX(UnitPrice)                 AS MaxUnitPrice,
       MIN(UnitPrice)                 AS MinUnitPrice,
       ROUND(SUM(UnitPrice), 2)       AS SummedUnitPrices, -- fragwürdige Metrik
       PRINTF('%.2f', AVG(UnitPrice)) AS AverageUnitPrice,
       COUNT(UnitPrice)               AS NumUnitPrices
FROM Track;

-- COUNT() - Werte zählen
----------------------------

SELECT * FROM Invoice;
-- Ohne Spalte zählt es die Anzahl der Zeilen einer Tabelle
SELECT COUNT()
FROM Invoice;

-- COUNT(SPALTE) zählt alle Nicht-Null-Einträge
SELECT COUNT()             AS NumEntries,
       COUNT(Billingstate) AS Cities
FROM Invoice;

-- Übung: Wie viele Einträge hat die Tabelle Track?
-- Bei wie vielen ist ein Komponist angegeben?
-- Bonus: Ermittle mit den bekannten Mitteln in einem Select-Statement,
-- wie hoch die Anzahl der Einträge ist, bei denen KEIN Komponist
-- angegeben wird.

SELECT COUNT()
FROM Track;

SELECT COUNT(Composer)
FROM Track;

SELECT COUNT(Name)
FROM Track
WHERE Composer IS NULL;

-- COUNT(DISTINCT SPALTE) zählt nur einmalige Nicht-Null-Werte

SELECT * FROM Employee;

-- Eine Liste aller einzigartigen Nachnamen
SELECT DISTINCT LastName
FROM Employee;

-- Die Anzahl dieser einzigartigen Nachnamen als Zahl
SELECT COUNT(DISTINCT LastName) AS UniqueEmployees
FROM Employee;

-- Quizfrage: Wie lässt sich die vorige Komponistenquery um die Anzahl der
-- Komponisten OHNE Doppelungen ergänzen?

SELECT
	COUNT() AS Entries,
	COUNT(Composer) AS Composers,
	COUNT(DISTINCT Composer) AS UniqueComposers
FROM Track;

-- Alternativ zu spaltenlosem COUNT() >
-- Spalte mit ausschließlich einzigartigen Werten zählen (Unique identifier):
SELECT COUNT(TrackId)
FROM Track;

-- Fehlende Werte aus einzelnen Spalten suchen (Bonus von weiter oben)
SELECT COUNT()
FROM Track
WHERE Composer IS NULL;

/* Großes Thema: Gruppierung mit GROUP BY
 * Daten basierend auf einer oder mehreren Spalten gruppieren
 *
 */

-- Vorarbeit, bisschen Daten anschauen:
SELECT InvoiceId,
       BillingCity,
       BillingCountry,
       Total
FROM Invoice;
-- Beobachtung: In BillingCountry gibt es mehrere Länder, die sich wiederholen
-- Wie wäre es mit einem Überblick über Umsatzsummen pro Land?

-- Quizfrage: Ist das die Lösung? (Bitte nicht weiter nach unten schauen ;))
SELECT BillingCountry,
       Total
FROM Invoice
GROUP BY BillingCountry;



SELECT BillingCountry,
       SUM(Total) AS TotalSum
FROM Invoice
GROUP BY BillingCountry;

-- Mehrere Spalten aggregieren (Top 5 Länder an den Gesamteinnahmen)
SELECT BillingCountry,
       COUNT()    AS OrdersCount,
       SUM(Total) AS TotalRevenue,
       AVG(Total) AS AverageOrder
FROM Invoice
GROUP BY BillingCountry
ORDER BY TotalRevenue DESC
LIMIT 5;

-- Quizfrage: Wie kriegen wir die Top Fünf Länder nach
-- durchschnittlichem Bestellpreis?

-- Ohne Aggregation: Aus welchem Land kommt die teuerste Bestellung
SELECT
	BillingCountry AS land,
	MAX(Total) AS max_rechnung
FROM Invoice;

-- Check, ob die Zeile auch wirklich passt (mit einer Subquery!)
SELECT *
FROM Invoice
WHERE Total = (SELECT MAX(Total)
               FROM Invoice);

-- Maximum bei Textspalten (alphabetisch statt numerisch auf-/absteigend):
-- Was ist die alphabetisch letzte Stadt zum jeweiligen Land?
SELECT
	BillingCountry AS land,
	MAX(BillingCity)
FROM Invoice
GROUP BY land;

-- Check an ein paar Beispielen, ob der Output oben drüber okay ist
SELECT DISTINCT BillingCity, BillingCountry
FROM Invoice
WHERE BillingCountry IN ('Argentina', 'Brazil', 'USA', 'Canada')
ORDER BY BillingCountry, BillingCity;

-- Alle einzigartigen Städte in den USA, die beliefert wurden
SELECT DISTINCT BillingCity
FROM Invoice
WHERE BillingCountry = 'USA';

-- Mögliche Fehler
-- Alle Spalten, die ich aggregieren will, müssen auch
-- eine Aggregationsfunktion haben.
-- Nur Weglassen bei Spalten, nach denen gruppiert wird.
-- Aggregationsfunktionen müssen zum Datentyp passen.
-- Wenn man die Aggregationsfunktion mal vergisst, gibt es trotzdem Output,
-- aber der ist meist nicht gerade sinnvoll (siehe Appendix).

-- Mehrere Spalten in GROUP BY
-- Beispiel: 
SELECT
	Country,
	City,
	COUNT(CustomerId) AS CustomerNumber
FROM Customer
GROUP BY Country, City
ORDER BY CustomerNumber DESC;
-- Wir haben nicht gerade viele Kunden ;)

-- Gruppenverknüpfung mit group_concat
-- Werte aller Zeilen einer Gruppe in einem Feld zusammenführen
-- Beispiel: Alle Kunden pro Land auflisten
SELECT
	Country,
	GROUP_CONCAT(LastName, ', ') AS CustomerList
FROM Customer
GROUP BY Country;

-- Check für Kanada
SELECT LastName FROM Customer
WHERE Country = 'Canada';

/* Übungsaufgabe 1: 
*  Du arbeitest mit der Tabelle Album und möchtest herausfinden,
*  welche Artists (Künstler-ID reicht, aber als Bonus gern mit Künstlernamen!)
*  am häufigsten mit Alben vertreten sind.
*  Führe den passenden Befehl (mit group by + order by) hierfür
*  durch und überprüfe manuell, welches die Top 3 Künstler sind
*  und wie oft Alben von ihnen in der Tabelle vorkommen.
*/
SELECT ArtistId,
       COUNT(*) AS AlbumCount
FROM Album
GROUP BY ArtistId
ORDER BY AlbumCount DESC
LIMIT 3;

-- # Bonus:
SELECT al.ArtistId,
       ar.Name AS ArtistName,
       COUNT(*) AS AlbumCount
FROM Album AS al
JOIN Artist AS ar
    USING (ArtistId)
GROUP BY al.ArtistId,
         ar.Name
ORDER BY AlbumCount DESC
LIMIT 3;




/* Übungsaufgabe 2: 
* Du arbeitest mit der Tabelle Customer. 
* Erstelle eine Auszählung der Spalte Country und überprüfe,
* welches Land wie häufig vorkommt.
* Ordne absteigend und beantworte die Frage, woher die meisten Kunden kommen.
*/
SELECT Country,
       COUNT(*) AS CountryCount
FROM Customer
GROUP BY Country
ORDER BY CountryCount DESC;



/* Übungsaufgabe 3:
* Du arbeitest mit der Tabelle Invoice.
* Finde heraus, wie viel Umsatz pro Kunde gemacht wurde und lasse dir die
* Top 5 Kunden mit ihren IDs und der jeweiligen Gesamtsumme ausgeben.
* Wenn die Zeit reicht: Du willst die Top 5 Kunden per E-Mail kontaktieren
* und sie mit einer Gratis-CD belohnen. Hole Nachnamen, Vornamen und Mails
* dieser Kunden mit in die Ausgabe hinzu!
*/
SELECT CustomerId,
       SUM(Total) AS TotalRevenue
FROM Invoice
GROUP BY CustomerId
ORDER BY TotalRevenue DESC
LIMIT 5;


-- # Bonus:
WITH Top5 AS
    (SELECT CustomerId,
            SUM(Total) AS TotalRevenue
     FROM Invoice
     GROUP BY CustomerId
     ORDER BY TotalRevenue DESC
     LIMIT 5)
SELECT t5.CustomerId,
       c.LastName || ' ' || c.FirstName AS Top5Customers,
       c.Email,
       t5.TotalRevenue
FROM Top5 AS t5
JOIN Customer AS c
USING (CustomerId)
ORDER BY t5.TotalRevenue DESC;

SELECT * FROM Artist;


/* HAVING
 * Bedingungen zur Aufnahme einer Gruppe ins Endergebnis
 */
-- Beispiel: Anzahl der Bestellungen pro Land; 
--           Aber nur Länder mit mehr als 10 Bestellungen anzeigen
SELECT BillingCountry,
       COUNT() AS OrdersCount
FROM Invoice
GROUP BY BillingCountry
HAVING OrdersCount > 10
ORDER BY OrdersCount DESC;

/* Übungsaufgabe 4:
* Modifiziere deine Abfrage aus Übungsaufgabe 4 so, dass du dir statt die Top 5
* nun alle Kunde mit Gesamtausgaben ab 40 Dollar ausgeben lässt.
 */



/* Übungsaufgabe 5:
* Du möchtest die durchschnittliche Länge von Tracks (Millisekunden) pro
* Genre erfahren. Wie gehst du vor und was sind die Top 5 Genres?
* Bonus: Du möchtest gern die Zahlen formatieren mit Punkt für Dezimalstellen
* und mit Komma als Tausendertrennzeichen.
 */






-- APPENDIX*
-- Was passiert eigentlich hier?
-- Man sollte nicht einfach so die ganze Tabelle nach Land gruppieren.
SELECT *
FROM Invoice
GROUP BY BillingCountry;
-- Es gibt zwar für jede Zeile einen Wert zurück, aber was bedeuten die Werte?

SELECT *
FROM Invoice
WHERE BillingCountry = 'Argentina';
-- Id 119 > Es wird immer einfach die erste Zeile übernommen, in der der
-- einzigartige Wert (hier: Argentina) vorkommt. Ein hochgefährliches Verhalten,
-- falls man es nicht kennt.
