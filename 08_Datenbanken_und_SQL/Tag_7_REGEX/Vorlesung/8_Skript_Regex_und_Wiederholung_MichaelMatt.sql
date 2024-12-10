/* Reguläre Ausdrücke in SQLite

   -- Dokumentation: https://www.sqlite.org/lang_expr.html

   In SQLite gibt es relativ gute Möglichkeiten,
   mit regulären Ausdrücken zu arbeiten.

   Das einfachste Mittel ist LIKE mit den Wildcards '%' und '_'.
   LIKE ist allerdings beachtet allerdings nicht Groß-/Kleinschreibung.

   GLOB achtet auf Groß-/Kleinschreibung und bietet auch sonst ein paar
   Vorteile wie Zeichenräume (etwa [A-Za-z]), aber ist in den Mitteln doch
   deutlich hinter Pythons re.

   Die Spitze in der Regex-Hierarchie (ohne Installation von Erweiterungen)
   bilden REGEXP. Hier können wir Pattern schreiben, wie wir sie auch mit
   re geschrieben haben. Allerdings ist es nicht ohne Weiteres möglich, Gruppen
   zu extrahieren.

   Für erweiterte Regex-Funktionalitäten lohnt sich später bei der Arbeit
   mit PostgreSQL ein Blick auf die dortigen Regex-Funktionen.
   Regex in PostgreSQL: https://www.postgresql.org/docs/current/functions-matching.html
 */

SELECT *
FROM Customer;

SELECT *
FROM Customer
WHERE Address LIKE '%straße%';

SELECT *
FROM Customer
WHERE Email LIKE '%.de%';

SELECT *
FROM Customer
WHERE Phone LIKE '%030%';

SELECT *
FROM Customer;

-- Alle Vorkommnisse von 'rue' finden
SELECT *
FROM Customer
WHERE Address LIKE '%rue%';

-- Aber Wie findet man alle Vorkommnisse von 'Rue'?

/* GLOB zu Hilfe!
   Glob ist case-sensitive (beachtet Groß- und Kleinschreibung)
   und hier verwendet man die uns bereits gekannten Operatoren '*' und '?'.
   '*': Beliebig lange Folge beliebiger Zeichen
   '?': Genau ein beliebiges Zeichen.
   Achtung: Innerhalb von Glob reicht einfach ein '*'/'?' für die obige Bedeutung
   und nicht etwa z.B. '.*'/, '\w*' oder [A-Za-z]* wie in Python.
 */
-- Rue in Großschreibung irgendwo innerhalb von Address:
SELECT *
FROM Customer
WHERE Address GLOB '*Rue*';

-- Alle Nachnamen, die ein kleines 'B' enthalten:
SELECT *
FROM Customer
WHERE LastName GLOB '*z*';

-- Alle Nachnamen, die ein 'ch' enthalten und auf 'er' endet:
SELECT *
FROM Customer
WHERE LastName GLOB '*ch*er';

-- Übung: Suche alle Adressen, die das Wort 'de' enthalten
-- ('de' darf KEIN Wortbestandteil sein, sondern ist ein eigenes Wort).
SELECT FirstName || ' ' || LastName AS Name,
       Address
FROM Customer
WHERE Address GLOB '* de *';

-- Problem: Alle Adressen, die aus exakt zwei Teilen bestehen, die durch ein
-- Leerzeichen getrennt sind:
SELECT *
FROM Customer
WHERE Address GLOB '[A-Za-z0-9]* [A-Za-z]*';
-- * kann nicht als Match-Operator an einen Zeichenraum (Character space)
-- angefügt werden... :(

/* REGEXP zu Hilfe!
   REGEXP bietet uns den kompletten Regex-Luxus, den wir auch in Python
   im Modul re genossen hatten! Zeichenräume mit '*', aber auch Zeichen wie
   \w oder \d etc. sind damit wieder an Bord!
 */
-- Es werde Licht:
SELECT *
FROM Customer
WHERE Address REGEXP '[A-Za-z0-9]* [A-Za-z0-9]*';

-- Mit \w geht es natürlich noch leichter:
SELECT *
FROM Customer
WHERE Address REGEXP '\w* \w*';

-- Übung: 1. Suche alle Adressen heraus, die genau aus drei Teilen bestehen!
--        2. Suche alle Adressen heraus, die auf eine beliebig lange
--           Zahlenfolge anfangen.
--        3. Suche alle Adressen heraus, die auf eine beliebig lange
--           Zahlenfolge enden.
SELECT *
FROM Customer
WHERE Address REGEXP '\w* \w* \w*';

SELECT *
FROM Customer
WHERE Address GLOB '* * *';

--
SELECT *
FROM Customer
WHERE Address REGEXP '\d+.*';

SELECT *
FROM Customer
WHERE Address GLOB '[0-9]* *';

--
SELECT *
FROM Customer
WHERE Address REGEXP '.*\d+';

SELECT *
FROM Customer
WHERE Address GLOB '* [0-9]*';

-- Alle Nachnamen, die aus mindestens zwei Teilen bestehen!
SELECT *
FROM Customer
WHERE LastName REGEXP '(\S* )+\S*';

SELECT *
FROM Customer
WHERE LastName REGEXP '(\w* )+\w*';
-- Alle Telefonnummern mit einer Vorwahl in Klammern:
SELECT LastName,
       Phone
FROM Customer
WHERE Phone REGEXP '.*\(\d*\).*';

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