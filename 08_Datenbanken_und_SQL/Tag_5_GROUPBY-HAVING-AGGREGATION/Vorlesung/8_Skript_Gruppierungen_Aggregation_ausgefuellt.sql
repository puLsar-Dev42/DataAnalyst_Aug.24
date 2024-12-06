/* Skript: Gruppierung und Aggregation in SQLite */
-- Wir verbinden uns mit Chinook --

/* AGGREGATIONSFUNKTIONEN
 * COUNT, MIN, MAX, AVG, SUM
 */
-- Beispiel: Teuerste Rechnung
SELECT *
FROM Invoice;

SELECT MAX(Total)
FROM Invoice;

-- Mit anständigem Spaltennamen
SELECT MAX(Total) AS HighestTotal
FROM Invoice;

-- Einige Aggregationen gleichzeitig
SELECT MAX(UnitPrice),
       MIN(UnitPrice),
       SUM(UnitPrice), -- nicht sinnvoll!!!
       ROUND(AVG(UnitPrice), 2),
       COUNT(UnitPrice)
FROM Track;

-- Mit schöneren Namen und formatierten Zahlen:
SELECT MAX(UnitPrice)           AS MaxUnitPrice,
       MIN(UnitPrice)           AS MinUnitPrice,
       SUM(UnitPrice)           AS SummedUnitPrices, -- fragwürdige Metrik
       ROUND(AVG(UnitPrice), 2) AS AverageUnitPrice,
       COUNT(UnitPrice)         AS NumUnitPrices
FROM Track;

-- COUNT() - Werte zählen
----------------------------

SELECT *
FROM Invoice;
-- Ohne Spalte zählt es die Anzahl der Zeilen einer Tabelle
SELECT COUNT()
FROM Invoice;

-- 412 Zeilen insgesamt
SELECT COUNT(*)
FROM Invoice;

-- COUNT(SPALTE) zählt alle Nicht-Null-Einträge

-- 210 Nicht-Null-Values
SELECT COUNT(BillingState)
FROM Invoice;

-- 202 Null Values
SELECT COUNT() BillingStateMissing
FROM Invoice
WHERE BillingState IS NULL;

-- Übung: Wie viele Einträge hat die Tabelle Track?
-- Bei wie vielen ist ein Komponist angegeben?
-- Bonus: Ermittle mit den bekannten Mitteln in einem Select-Statement,
-- wie hoch die Anzahl der Einträge ist, bei denen KEIN Komponist
-- angegeben wird.
SELECT COUNT() AS AllEntries
FROM Track;

SELECT COUNT(Composer) AS EntriesWithComposers
FROM Track;

SELECT COUNT() AS NoComposerAdded
FROM Track
WHERE Composer IS NULL;

-- COUNT(DISTINCT SPALTE) zählt nur einmalige Nicht-Null-Werte
SELECT DISTINCT BillingState
FROM Invoice;

SELECT COUNT(DISTINCT BillingState) AS NumStates
FROM Invoice;

-- Eine Liste aller einzigartigen Vornamen
SELECT DISTINCT FirstName
FROM Customer;

-- Die Anzahl dieser einzigartigen Vornamen als Zahl
SELECT COUNT(DISTINCT FirstName) AS UniqueFirstNames
FROM Customer;

-- Quizfrage: Wie lässt sich die vorige Komponistenquery um die Anzahl der
-- Komponisten OHNE Doppelungen ergänzen?
SELECT COUNT()                  AS AllEntries,
       COUNT(Composer)          AS EntriesWithComposers,
       COUNT(DISTINCT Composer) AS UniqueComposers
FROM Track;

-- Alternativ zu spaltenlosem COUNT() >
-- Spalte mit ausschließlich einzigartigen Werten zählen (Unique identifier):
SELECT COUNT(TrackId)
FROM Track;

/* Großes Thema: Gruppierung mit GROUP BY
 * Daten basierend auf einer oder mehreren Spalten gruppieren
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
FROM Invoice;

-- Quizfrage 2: Ist das jetzt aber die Lösung?
SELECT BillingCountry,
       Total
FROM Invoice
GROUP BY BillingCountry;

-- Das ist jetzt die Lösung:
SELECT BillingCountry,
       SUM(Total) AS TotalSum
FROM Invoice
GROUP BY BillingCountry;

-- Mehrere Spalten aggregieren (Top 5 Länder an den Gesamteinnahmen)
SELECT BillingCountry,
       SUM(Total)           AS TotalRevenue,
       COUNT()              AS OrdersCount,
       ROUND(AVG(Total), 2) AS AverageOrder
FROM Invoice
GROUP BY BillingCountry
ORDER BY TotalRevenue DESC
LIMIT 5;

-- Quizfrage: Wie kriegen wir die top fünf Länder nach
-- durchschnittlichem Bestellpreis?
SELECT BillingCountry,
       SUM(Total)           AS TotalRevenue,
       COUNT()              AS OrdersCount,
       ROUND(AVG(Total), 2) AS AverageOrder
FROM Invoice
GROUP BY BillingCountry
ORDER BY AverageOrder DESC
LIMIT 5;

-- Ohne Aggregation: Aus welchem Land kommt die teuerste Bestellung
SELECT BillingCountry,
       MAX(Total) AS HighestOrder
FROM Invoice;

-- Check 1:
SELECT BillingCountry,
       MAX(Total) AS HighestOrder
FROM Invoice
GROUP BY BillingCountry
ORDER BY HighestOrder DESC;

-- Check 2, ob die Zeile auch wirklich passt (mit einer Subquery!)
SELECT *
FROM Invoice
WHERE Total = (SELECT MAX(Total)
               FROM Invoice);

-- Maximum bei Textspalten (alphabetisch statt numerisch auf-/absteigend):
SELECT MIN(BillingCountry) AS FirstCountry,
       MAX(BillingCountry) AS LastCountry
FROM Invoice;

-- Was ist die alphabetisch letzte Stadt zum jeweiligen Land?
-- Query zum Umschauen:
SELECT DISTINCT BillingCountry, BillingCity
FROM Invoice
ORDER BY BillingCountry, BillingCity DESC;

SELECT BillingCountry,
       MAX(BillingCity) AS LastCity
FROM Invoice
GROUP BY BillingCountry;

-- Auf Martins Wunsch:
SELECT BillingCountry   AS Country,
       MIN(BillingCity) AS FirstCity,
       MAX(BillingCity) AS LastCity
FROM Invoice
GROUP BY BillingCountry
ORDER BY UPPER(Country);

-- Check an ein paar Beispielen, ob der Output oben drüber okay ist
SELECT DISTINCT BillingCity, BillingCountry
FROM Invoice
WHERE BillingCountry IN ('Argentina', 'Brazil', 'USA', 'Canada')
ORDER BY BillingCountry, BillingCity;

-- Alle einzigartigen Städte in den USA, die beliefert wurden
SELECT DISTINCT BillingCity
FROM Invoice
WHERE BillingCountry = 'USA'
ORDER BY BillingCity;

/*
  Mögliche Fehler
  Alle Spalten, die ich aggregieren will, müssen auch
  eine Aggregationsfunktion haben.
  Nur Weglassen bei Spalten, nach denen gruppiert wird.
  Aggregationsfunktionen müssen zum Datentyp passen.
  Wenn man die Aggregationsfunktion mal vergisst, gibt es trotzdem Output,
  aber der ist meist nicht gerade sinnvoll (siehe Appendix).
 */

-- Mehrere Spalten in GROUP BY
-- Beispiel: Wie viele Kunden haben wir pro Land sowie Stadt (als Kombination):
SELECT Country,
       City,
       COUNT() AS NumCustomers
FROM Customer
GROUP BY Country, City
ORDER BY NumCustomers DESC;

-- Wir haben nicht gerade viele Kunden ;)

-- Gruppenverknüpfung mit group_concat
-- Werte aller Zeilen einer Gruppe in einem Feld zusammenführen
-- Beispiel: Welche Städte gibt es in jeweils einem Land?
SELECT Country,
       GROUP_CONCAT(DISTINCT City)
FROM Customer
GROUP BY Country;

-- Beispiel: Alle Kundennachnamen pro Land auflisten:
SELECT Country,
       GROUP_CONCAT(DISTINCT LastName)
FROM Customer
GROUP BY Country;

-- Check für Brasilien:
-- Gonçalves,Martins,Rocha,Almeida,Ramos
SELECT LastName,
       Country
FROM Customer
WHERE Country = 'Brazil';

/* Übungsaufgabe 1: 
*  Du arbeitest mit der Tabelle Album und möchtest herausfinden,
*  welche Artists (Künstler-ID reicht, aber als Bonus gern mit Künstlernamen!)
*  am häufigsten mit Alben vertreten sind.
*  Führe den passenden Befehl (mit group by + order by) hierfür
*  durch und überprüfe manuell, welches die Top 3 Künstler sind
*  und wie oft Alben von ihnen in der Tabelle vorkommen.
*/
SELECT ArtistId,
       COUNT(ArtistId) AS AlbumCount
FROM Album
GROUP BY ArtistId
ORDER BY AlbumCount DESC
LIMIT 3;

SELECT ArtistId,
       Name,
       COUNT(ArtistId) AS AlbumCount
FROM Album
         JOIN Artist USING (ArtistId)
GROUP BY ArtistId
ORDER BY AlbumCount DESC
LIMIT 3;

-------------
-- Alternativweg mit Liste und Subquery statt Join
SELECT Name, ArtistId
FROM Artist
WHERE ArtistId IN (90, 22, 58);

SELECT Name,
       ArtistId
FROM Artist
WHERE ArtistId IN (SELECT ArtistId
                   FROM Album
                   GROUP BY ArtistId
                   ORDER BY COUNT(ArtistId) DESC
                   LIMIT 3);

/* Übungsaufgabe 2:
* Du arbeitest mit der Tabelle Customer. 
* Erstelle eine Auszählung der Spalte Country und überprüfe,
* welches Land wie häufig vorkommt.
* Ordne absteigend und beantworte die Frage, woher die meisten Kunden kommen.
*/

SELECT Country, COUNT(Country) CustomerCount
FROM Customer
GROUP BY Country
ORDER BY CustomerCount DESC;

/* Übungsaufgabe 3:
* Du arbeitest mit der Tabelle Invoice.
* Finde heraus, wie viel Umsatz pro Kunde gemacht wurde und lasse dir die
* top 5 Kunden mit ihren IDs und der jeweiligen Gesamtsumme ausgeben.
* Wenn die Zeit reicht: Du willst die top 5 Kunden per E-Mail kontaktieren
* und sie mit einer Gratis-CD belohnen. Hole Nachnamen, Vornamen und Mails
* dieser Kunden mit in die Ausgabe hinzu!
*/
SELECT *
FROM Invoice;

SELECT CustomerId,
       LastName,
       FirstName,
       Email,
       SUM(Total) SumSpent
FROM Invoice
         JOIN Customer
              USING (CustomerId)
GROUP BY CustomerId
ORDER BY SumSpent DESC
LIMIT 5;

/* HAVING
 * Bedingungen zur Aufnahme einer Gruppe ins Endergebnis
 */
-- Beispiel: Anzahl der Bestellungen pro Land; 
--           Aber nur Länder mit mehr als 10 Bestellungen anzeigen
SELECT BillingCountry,
       COUNT() AS OrdersCount
FROM Invoice
-- WHERE OrdersCount >= 10 > Nur für Ausgangsdaten vor Aggregation
GROUP BY BillingCountry
HAVING OrdersCount >= 10  -- Für aggregierte Daten
ORDER BY OrdersCount DESC;

/* Übungsaufgabe 4:
* Modifiziere deine Abfrage aus Übungsaufgabe 4 so, dass du dir statt die Top 5
* nun alle Kunde mit Gesamtausgaben ab 40 Dollar ausgeben lässt.
 */
SELECT CustomerId,
       LastName,
       FirstName,
       Email,
       SUM(Total) SumSpent
FROM Invoice
         JOIN Customer
              USING (CustomerId)
GROUP BY CustomerId
HAVING SumSpent >= 40
ORDER BY SumSpent DESC;


/* Übungsaufgabe 5:
* Du möchtest die durchschnittliche Länge von Tracks (Millisekunden) pro
* Genre erfahren. Wie gehst du vor und was sind die Top 5 Genres?
* Bonus: Du möchtest gern die Zahlen formatieren mit Punkt für Dezimalstellen
* und mit Komma als Tausendertrennzeichen.
 */
SELECT g.Name,
       AVG(Milliseconds) AS AverageDuration
FROM Genre g
         JOIN Track t
              USING (GenreId)
GROUP BY g.Name
ORDER BY AverageDuration DESC;

SELECT Genre,
       PRINTF('%,.2f', time) AS AverageDuration
FROM (SELECT g.Name            AS Genre,
             AVG(Milliseconds) AS time
      FROM Genre g
               JOIN Track t
                    USING (GenreId)
      GROUP BY g.Name
      ORDER BY AVG(Milliseconds) DESC);

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
