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

SELECT * FROM Customer;

-- Alle Vorkommnisse von 'rue' finden
SELECT * FROM Customer
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
SELECT * FROM Customer
WHERE Address GLOB '*Rue*';

-- Alle Nachnamen, die ein kleines 'B' enthalten:
SELECT * FROM Customer
WHERE LastName GLOB '*z*';

-- Alle Nachnamen, die ein 'ch' enthalten und auf 'er' anfangen:
SELECT * FROM Customer
WHERE LastName GLOB '*ch*er';

-- Übung: Suche alle Adressen, die das Wort 'de' enthalten
-- ('de' darf KEIN Wortbestandteil sein, sondern ist ein eigenes Wort).


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




-- Alle Nachnamen, die aus mindestens zwei Teilen bestehen!
SELECT *
FROM Customer
WHERE LastName REGEXP '(\w* )+\w*';

-- Alle Telefonnummern mit einer Vorwahl in Klammern:
SELECT * FROM Customer
WHERE Phone REGEXP '.* \(\d*\) .*';

-- RAUM FÜR WIEDERHOLUNGEN!

/*1. Wähle die Spalten mit Namensangaben, Telefon und Mail-Adressen aus
   Customer. Ordne aufsteigend nach dem Nachnamen. Benenn die Spalten um
   in passende deutsche Entsprechungen.
 */


/* 2. Dich interessieren die Kunden mit den Kunden-IDs 20-30.
   Erweitere deine obige Abfrage, sodass du nur noch Informationen zu diesen
   Kunden erhältst. Ergänze außerdem um eine Spalte Kunden-ID.
   Die Kunden sollen nicht mehr nach Nachname,
   sondern nach Kunden-ID geordnet sein.
 */


-- 3. Lasse dir dieselben Spalten ausgeben, aber diesmal für Kunden,
-- deren Nummer mit +49 beginnt.


-- 4. Was sind die alphabetisch ersten fünf Städte in Customer?


-- 5. Wie viele einzigartige Länder gibt es in Invoice?
-- Löse mittels Aggregation!
-- Nenne den Spaltennamen über der Anzahl 'CountriesCount'-


/* 6. Du möchtest die Gesamtsummen an Umsätzen für folgende Länder:
   Deutschland, Frankreich, USA, Indien, United Kingdom, China.
   Löse in einer einzigen Query.
   Tabellenanforderung: eine Spalte mit Landesnamen und eine mit Gesamtsummen
   Gibt es Kunden/Rechnungen aus allen obigen Ländern?
 */


-- 7. Gehe in Customer und zähle die Kunden für obige Länder.
-- Ordne absteigend nach Kundenzahl.


-- 8. Welcher Kunde hat die höchste Bestellung gemacht?


-- 9. Wie heißt der Kunde mit Namen (und Adresse)?


/* 10. In Invoice gibt es diverse Bestellungen.
   Die Beträge dort setzen sich oft aus mehreren gekauften Tracks zusammen.
   In InvoiceLine sind die Einkäufe aufgeschlüsselt, allerdings fehlen da
   Tracknamen. Diese befinden sich in der Tabelle Track.
   Deine Aufgabe: Verbinde die drei Tabellen so, dass du zu allen Käufen
   Invoice-ID, den Tracknamen und den Preis des jeweiligen Tracks siehst.
 */



/* 11. Erweitere deine Query so, dass du den Kunden mit Nach- und Vornamen
   zu diesen Käufen siehst (Nach InvoiceID zwei Spalten: Lastname, Firstname)
 */



-- 12. Filtere den obigen Code ein, um nur Käufe aus Deutschland zu sehen.


-- 13. Finde alle Albumtitel in Album, die aus genau zwei Worten bestehen.


-- 14. Extrahiere in der Tabelle Invoice den Datumsteil mit Jahr und Monat.


-- 15. Forme die Gesamtsumme für die einzelnen Monate.
-- Lasse dir die top 10 Monate nach der Gesamtsumme ausgeben.

