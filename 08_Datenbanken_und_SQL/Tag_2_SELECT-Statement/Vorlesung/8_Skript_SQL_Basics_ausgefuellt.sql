/* Skript: SQL Einführung
 * 
 * 
 * Block-Kommentare mit "/* ... STERN/"
 * Kommentar über mehrere Zeilen
 */


-- Zeilen-Kommentar mit "--": wird nicht ausgeführt

-- Komplette Tabelle abfragen (alle Spalten -> '*'):
SELECT *
FROM Album;

-- Kleinschreibung und alles in eine Zeile ist zwar kein Problem, aber unschön!
select *
from Album;

-- Mehrere Spalten selektieren
SELECT AlbumId, Title
FROM Album;

-- Übung mit Customer:
SELECT *
FROM Customer;

SELECT Firstname,
       Lastname,
       Country,
       Address
FROM Customer;

-- Spalten umbenennen mit einem Alias (AS):
SELECT AlbumId AS Albumnummer,
       Title   AS Albumtitel
FROM Album;

/* Die Spalten müssen NICHT in der Reihenfolge selektiert werden,
   in der sie in der Tabelle vorliegen */
SELECT Email,
       LastName,
       Country
FROM Customer;

/* Aufgabe:
   1. Lass dir mit einem Select-Statement alle Einträge
   von Customer ausgeben + Employee.
   2. Lass dir in einem Select-Statement Vor-, Nachname und Firma von Kunden
   ausgeben.
   3. Lass dir Nachname, Vorname und Mail aus Customer ausgeben
   Nutze für die Spaltennamen die deutschen Entsprechungen!
 */
SELECT *
FROM Customer;

SELECT FirstName,
       LastName,
       Company
FROM Customer;

SELECT LastName  AS Nachname,
       FirstName AS Vorname,
       Email
FROM Customer;

-- Sortieren nach: ORDER BY
SELECT *
FROM Album
ORDER BY Title;

SELECT *
FROM Album
ORDER BY ArtistId;

-- Aufsteigend oder absteigend sortieren:
-- DESC: Descending - absteigend
-- ASC: Ascending - aufsteigend
SELECT *
FROM Album
ORDER BY Title DESC;

SELECT *
FROM Album
ORDER BY Title ASC;

-- Ausgabe begrenzen
-- LIMIT (INTEGER)

-- Die 10 Alben auswählen, die im Alphabet 
-- zuerst kommen

SELECT Title,
       AlbumId
FROM Album
ORDER BY Title
LIMIT 10;


/* Aufgabe:
   1. Lass dir alle Kunden nach dem Land, in dem sie wohnen, geordnet ausgeben.
   2. Ordne die Kunden alphabetisch absteigend nach Nachnamen und lasse dir
   die obersten fünf dieser Kunden mit Nachnamen, Vornamen und Mail ausgeben.
 * */
SELECT *
FROM Customer
ORDER BY Country;

SELECT LastName, FirstName, Email
FROM Customer
ORDER BY LastName DESC
LIMIT 5;

-- Beispiel für Order mit zwei Spalten:
SELECT FirstName,
       LastName,
       Country
FROM Customer
ORDER BY Country, LastName;

-- Order geht mit beliebig vielen Spalten.

/* ZEILEN FILTERN ÜBER BEDINGUNGEN
 * WHERE Schlüsselwort + Bedingung
 * Einfaches "=" Zeichen genügt.
 * */
SELECT *
FROM Album
WHERE AlbumId = 94;

SELECT *
FROM Album
WHERE Title = 'A Matter of Life and Death';

-- Texteinträge in Tabelle mit einfachen Anführungszeichen
-- Tabellen- und Spaltennamen mit doppelten Anführungszeichen

-- Ungefährer Vergleich / Teilvergleich: LIKE
-- %: Wildcard: Beliebig viele beliebige Buchstaben 0-unendlich
-- LIKE ist case-insensitive
SELECT *
FROM Album
WHERE Title LIKE 'a%';

-- Alle Alben, die mit "r" aufhören
SELECT *
FROM Album
WHERE Title LIKE '%r';

-- Alle Alben, die ein "r" enthalten
SELECT *
FROM Album
WHERE Title LIKE '%r%'
ORDER BY Title DESC;

-- AND: Beide Bedingungen müssen gleichzeitig wahr sein
-- Alle Alben, die ein "a" und ein "r" 
-- im Titel enthalten (Reihenfolge egal)
SELECT *
FROM Album
WHERE Title LIKE '%a%'
  AND Title LIKE '%r%';

-- "_": Ein beliebiger Buchstabe
SELECT *
FROM Album
WHERE Title LIKE 'Fireba__';

-- Albentitel, die r enthalten, aber weder damit anfangen, noch damit enden:
-- Geht dann leichter mit GLOB, keine Sorge!
SELECT *
FROM Album
WHERE Title LIKE '%r%'
  AND Title NOT LIKE 'r%'
  AND Title NOT LIKE '%r'
ORDER BY Title DESC;

-- Beide Alben mit "A Real .... One" Auswählen
SELECT *
FROM Album
WHERE Title LIKE 'A Real ____ One';

-- Bringt selbes Ergebnis, aber ist prinzipiell weiter gefasst:
SELECT *
FROM Album
WHERE Title LIKE 'A Real % One';
-- Würde z.B. auch "A Real Hungry Crazy One" mitnehmen.

-- OR: Mindestens eine Bedingung muss wahr sein
SELECT *
FROM Album
WHERE AlbumId = 87
   OR AlbumId = 12;

-- Bonus: Version mit Liste und mehreren IDs:
SELECT *
FROM Album
WHERE AlbumId IN (87, 12, 22, 47, 45);

SELECT *
FROM Album
WHERE Title LIKE 'r%'
   OR Title LIKE '%r';

/* Aufgabe:
   1. Lass dir alle Kundendaten von Kunden ausgeben, die auf ein G anfangen.
   2. Lass dir alle Daten von Kunden ausgeben, deren Adressen als vorletzten
   Buchstaben ein e haben.
 */
SELECT *
FROM Customer
WHERE LastName LIKE 'g%';

-- Version, bei der e auch am Ende stehen darf
SELECT *
FROM Customer
WHERE Address LIKE '%e_';

-- Version, bei der e nicht auch am Ende stehen darf
SELECT *
FROM Customer
WHERE Address LIKE '%e_'
  AND NOT Address LIKE '%e';

-- Logische Operatoren
/* Ist gleich "="
 * Kleiner als "<"
 * Größer als ">"
 * kleiner gleich "<="
 * größer gleich ">="
 * ungleich "!=" "<>"
 */
SELECT *
FROM Album
WHERE AlbumId > 10;

SELECT *
FROM Album
WHERE AlbumId <= 20;

SELECT *
FROM Album
WHERE ArtistId != 90;

-- Etwas umständlich:
SELECT *
FROM Album
WHERE AlbumId >= 10
  AND AlbumId < 30;

-- Geht auch mit Strings!
SELECT *
FROM Album
WHERE Title > 'V'
ORDER BY Title;

-- Between ist inklusiv: Unterster und oberster Wert sind mit an Bord!
SELECT *
FROM Album
WHERE AlbumId BETWEEN 10 AND 29;

/* Aufgabe:
   1. Lass dir alle Daten von Kunden mit der SupportRepId 3 ausgeben.
   2. Lass dir alle Daten zu Kunden-IDs zwischen 10 und 30 ausgeben.
 */

SELECT *
FROM Customer
WHERE SupportRepId = 3;

SELECT *
FROM Customer
WHERE CustomerId BETWEEN 10 AND 30;

-- Resas + Mathias Research:
SELECT *
FROM Artist
WHERE Name LIKE 'Billy%';

-- Welche Alben hat Billy produziert?
SELECT *
FROM Album
WHERE ArtistId = 10;

-- Wie heißen die Tracks auf dem Album?
SELECT TrackId,
       Name,
       Composer
FROM Track
WHERE AlbumId = 13
ORDER BY Name;

-- Bonus: The Best of Billy Cobham anhören und in George Duke reinhören ;)
-- Bei Fragen Mathias fragen
