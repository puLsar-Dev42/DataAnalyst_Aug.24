-- RAUM FÜR WIEDERHOLUNGEN!

/*1. Wähle die Spalten mit Namensangaben, Telefon und Mail-Adressen aus
   Customer. Ordne aufsteigend nach dem Nachnamen. Benenn die Spalten um
   in passende deutsche Entsprechungen.
 */
SELECT FirstName AS Vorname,
       LastName  AS Nachname,
       Email     AS EmailAddresse
FROM Customer
ORDER BY LastName;

/* 2. Dich interessieren die Kunden mit den Kunden-IDs 20-30.
   Erweitere deine obige Abfrage, sodass du nur noch Informationen zu diesen
   Kunden erhältst. Ergänze außerdem um eine Spalte Kunden-ID.
   Die Kunden sollen nicht mehr nach Nachname,
   sondern nach Kunden-ID geordnet sein.
 */
SELECT FirstName  AS Vorname,
       LastName   AS Nachname,
       Email      AS Emailaddresse,
       CustomerId AS KundenID
FROM Customer
WHERE KundenID BETWEEN 20 AND 30
ORDER BY KundenID;

-- 3. Lasse dir dieselben Spalten ausgeben, aber diesmal für Kunden,
-- deren Nummer mit +49 beginnt.
SELECT FirstName AS Vorname,
       LastName  AS Nachname,
       Email     AS Emailaddresse,
       Phone     AS Telefonnummer
FROM Customer
WHERE Telefonnummer LIKE '+49%'
ORDER BY Nachname;

-- 4. Was sind die alphabetisch ersten fünf Städte in Customer?
SELECT City AS Stadt
FROM Customer
ORDER BY City
LIMIT 5;
-- oder so?
SELECT DISTINCT City AS Stadt
FROM Customer
ORDER BY City
LIMIT 5;

-- 5. Wie viele einzigartige Länder gibt es in Invoice?
-- Löse mittels Aggregation!
-- Nenne den Spaltennamen über der Anzahl 'CountriesCount'-
SELECT COUNT(DISTINCT BillingCountry) AS CountriesCount
FROM Invoice;

/* 6. Du möchtest die Gesamtsummen an Umsätzen für folgende Länder:
   Deutschland, Frankreich, USA, Indien, United Kingdom, China.
   Löse in einer einzigen Query.
   Tabellenanforderung: eine Spalte mit Landesnamen und eine mit Gesamtsummen
   Gibt es Kunden/Rechnungen aus allen obigen Ländern?
 */
SELECT BillingCountry AS Land,
       SUM(Total)     AS Gesamtsumme
FROM Invoice
WHERE BillingCountry IN ('Germany',
                         'France',
                         'USA',
                         'India',
                         'United Kingdom',
                         'China')
GROUP BY BillingCountry
ORDER BY BillingCountry;

--
SELECT DISTINCT BillingCountry
FROM Invoice
WHERE BillingCountry IN ('Germany',
                         'France',
                         'USA',
                         'India',
                         'United Kingdom',
                         'China');

-- 7. Gehe in Customer und zähle die Kunden für obige Länder.
-- Ordne absteigend nach Kundenzahl.
SELECT C.Country                               AS Land,
       COUNT(C.FirstName || ' ' || C.LastName) AS Kundenzahl
FROM Customer AS C
WHERE C.Country IN ('Germany',
                    'France',
                    'USA',
                    'India',
                    'United Kingdom',
                    'China')
GROUP BY C.Country
ORDER BY Kundenzahl DESC;

-- 8. Welcher Kunde hat die höchste Bestellung gemacht?
SELECT C.CustomerId AS KundenID,
       I.Total      AS Bestellung,
       MAX(I.Total) AS MaxBestellung
FROM Invoice AS I
	     JOIN Customer AS C ON C.CustomerId = I.CustomerId;

-- 9. Wie heißt der Kunde mit Namen (und Adresse)?
SELECT C.CustomerId                     AS KundenID,
       C.FirstName || ' ' || C.LastName AS Name,
       C.Address                        AS Addresse,
       I.Total                          AS Bestellung,
       MAX(I.Total)                     AS MaxBestellung
FROM Invoice AS I
	     JOIN Customer AS C ON C.CustomerId = I.CustomerId;

/* 10. In Invoice gibt es diverse Bestellungen.
   Die Beträge dort setzen sich oft aus mehreren gekauften Tracks zusammen.
   In InvoiceLine sind die Einkäufe aufgeschlüsselt, allerdings fehlen da
   Tracknamen. Diese befinden sich in der Tabelle Track.
   Deine Aufgabe: Verbinde die drei Tabellen so, dass du zu allen Käufen
   Invoice-ID, den Tracknamen und den Preis des jeweiligen Tracks siehst.
 */
SELECT I.InvoiceId  AS InvoiceID,
       T.Name       AS Trackname,
       IL.UnitPrice AS Preis
FROM Track AS T
	     JOIN InvoiceLine AS IL ON T.TrackId = IL.TrackId
	     JOIN Invoice AS I ON IL.InvoiceId = I.InvoiceId;

/* 11. Erweitere deine Query so, dass du den Kunden mit Nach- und Vornamen
   zu diesen Käufen siehst (Nach InvoiceID zwei Spalten: Lastname, Firstname)
 */
SELECT I.InvoiceId  AS InvoiceID,
       C.LastName   AS Nachname,
       C.FirstName  AS Vorname,
       T.Name       AS Trackname,
       IL.UnitPrice AS Preis
FROM Track AS T
	     JOIN InvoiceLine AS IL ON T.TrackId = IL.TrackId
	     JOIN Invoice AS I ON IL.InvoiceId = I.InvoiceId
	     Join Customer AS C ON I.CustomerId = C.CustomerId;

-- 12. Filtere den obigen Code ein, um nur Käufe aus Deutschland zu sehen.
SELECT I.InvoiceId  AS InvoiceID,
       C.LastName   AS Nachname,
       C.FirstName  AS Vorname,
       T.Name       AS Trackname,
       IL.UnitPrice AS Preis
FROM Track AS T
	     JOIN InvoiceLine AS IL ON T.TrackId = IL.TrackId
	     JOIN Invoice AS I ON IL.InvoiceId = I.InvoiceId
	     Join Customer AS C ON I.CustomerId = C.CustomerId
WHERE I.BillingCountry = 'Germany'
ORDER BY Nachname;

-- 13. Finde alle Albumtitel in Album, die aus genau zwei Worten bestehen.
SELECT A.Title AS Title
FROM Album AS A
WHERE Title REGEXP '\w+ \w+';

-- 14. Extrahiere in der Tabelle Invoice den Datumsteil mit Jahr und Monat.
SELECT STRFTIME('%Y.%m.', I.InvoiceDate) AS Datum
FROM Invoice AS I;

-- 15. Forme die Gesamtsumme für die einzelnen Monate.
-- Lasse dir die top 10 Monate nach der Gesamtsumme ausgeben.
SELECT STRFTIME('%Y.%m.', I.InvoiceDate) AS Monat,
       SUM(I.Total)                      AS Gesamtsumme
FROM Invoice AS I
GROUP BY STRFTIME('%Y.%m.', I.InvoiceDate)
ORDER BY Gesamtsumme DESC
LIMIT 10;