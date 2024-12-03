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
select * from Album;

-- Mehrere Spalten selektieren
SELECT AlbumId,
       Title
FROM Album;

-- Spalten umbenennen mit einem Alias (AS):
SELECT AlbumId AS Album_Nr,
       Title AS Album_Titel
FROM Album;


SELECT Firstname,
       Lastname,
       Country,
       Address
FROM Customer;

/* Die Spalten müssen NICHT in der Reihenfolge selektiert werden,
   in der sie in der Tabelle vorliegen */

SELECT ArtistId,
       Title
FROM Album;

/* Aufgabe:
   1. Lass dir mit einem Select-Statement alle Einträge
   von Customer ausgeben.
   2. Lass dir in einem Select-Statement Vor-, Nachname und Firma eines Kunden
   ausgeben.
   3. Lass dir Nachname, Vorname und Mail aus Customer ausgeben
   Nutze für die Spaltennamen die deutschen Entsprechungen!
 */
SELECT *
FROM Customer;

SELECT *
FROM Employee;

SELECT Firstname,
       Lastname,
       Company
FROM Customer;

SELECT Lastname AS Nachname,
       Firstname AS Vorname,
       Email AS Emailaddresse
FROM Customer;

-- Sortieren nach: ORDER BY
SELECT AlbumId,
       Title
FROM Album
ORDER BY Title;

-- Aufsteigend oder absteigend sortieren:
-- DESC: Descending - absteigend
-- ASC: Ascending - aufsteigend
SELECT AlbumId,
       Title
FROM Album
ORDER BY Title DESC;

SELECT AlbumId,
       Title
FROM Album
ORDER BY Title ASC;

-- Ausgabe begrenzen
-- Limit ZAHL
SELECT * 
FROM Album
LIMIT 10;

-- Die 10 Alben auswählen, die im Alphabet 
-- zuerst kommen

SELECT *
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

SELECT Lastname,
       Firstname,
       Email
FROM Customer
ORDER BY Lastname DESC
LIMIT 5;


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
-- %: Wildcard: Beliebig viele beliebige Buchstaben
SELECT *
FROM Album
WHERE Title LIKE 'A%';
-- Alle Alben, die mit "r" aufhören
SELECT *
FROM Album
WHERE Title LIKE '%r';
-- Alle Alben, die ein "r" enthalten
SELECT *
FROM Album
WHERE Title LIKE '%r%';

-- AND: Beide Bedingungen müssen gleichzeitig wahr sein
-- Alle Alben, die ein "a" und ein "r" 
-- enthalten (Reihenfolge egal)
SELECT *
FROM Album
WHERE Title LIKE '%r%'
AND Title LIKE '%a%';

-- "_": Ein beliebiger Buchstabe
SELECT *
FROM Album
WHERE Title LIKE 'Fireba__';

-- Beide Alben mit "A Real ... One" Auswählen
SELECT *
FROM Album
WHERE Title LIKE 'A Real ____ One';

SELECT *
FROM Album
WHERE Title LIKE 'A Real % One';

-- OR: Mindestens eine Bedingung muss wahr sein
SELECT *
FROM Album
WHERE AlbumId = 87
OR AlbumId = 12;

/* Aufgabe:
   1. Lass dir alle Kundendaten von Kunden ausgeben, die auf ein G anfangen.
   2. Lass dir alle Daten von Kunden ausgeben, deren Adressen als vorletzten
   Buchstaben ein e haben.
 */
SELECT *
FROM Customer
WHERE LastName LIKE 'G%'
ORDER BY LastName ASC;

SELECT *
FROM Customer
WHERE Address LIKE '%e_';

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
WHERE AlbumId >= 10;

SELECT *
FROM Album
WHERE AlbumId >= 10
AND AlbumId <= 15;

-- Between ist inklusiv: Unterster und oberster Wert sind mit an Bord!

SELECT *
FROM Album
WHERE AlbumId BETWEEN 10 AND 15;

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
