/*  --------------- ---------------
 * Tabellen verbinden in SQL
 * Befehle: JOINs, UNION, Subqueries
 *  --------------- ---------------
 */ 


/* ---------------
 * 1. UNION - Tabellen mit denselben Spalten
 *            untereinander zusammenfügen
 * ---------------
 * 
 * Ähnlich wie concat oder append in Pandas.
 */

-- Beispiel: Neue Daten anfügen
--	         (Nur in das Ergebnis, nicht in die Datenbank)
SELECT *
FROM customers;

SELECT *
FROM more_customers;

SELECT *
FROM customers
UNION
SELECT *
FROM more_customers;
-- ACHTUNG: Keine Kontrolle der Spaltennamen!

-- Spaltenanzahl muss übereinstimmen
-- Stimmen sie nicht überein --> Error
SELECT * FROM customers;
SELECT * FROM strange_customers;

SELECT *
FROM customers
UNION
SELECT *
FROM strange_customers;

-- UNION lässt sich beliebig oft verketten
SELECT *
FROM customers
UNION
SELECT *
FROM more_customers
UNION
SELECT *
FROM even_more_customers;

-- Verkettung der gleichen Daten ist nicht möglich
-- ID-Doppelung wird verhindert
SELECT *
FROM customers
UNION
SELECT *
FROM customers;
-- Führt NICHT zu einer Tabelle mit doppelt so vielen Einträgen (Duplikaten)
-- Grund: Primärschlüssel-Spalten können keine doppelten Werte enthalten.


/* ---------------
 * 2. JOIN --> Vereinigen von Tabellen mit 
 *             verschiedenen Spalten anhand 
 *             von Schlüsselspalten
 * ---------------
 * -- INNER (Simple Join) --> Nur Inhalte, die es in beiden Tabellen gibt
 * -- FULL OUTER --> Alle Inhalte (maximal mögliche Menge an NULL-Werten)
 * -- LEFT  --> Alle Inhalte aus erster Tabelle
 * -- RIGHT  --> Alle Inhalte aus zweiter Tabelle
 * -- CROSS --> Alle Inhalte aus Tabelle1 und 2 werden kombiniert
 * ---------------
 */

-- Auswahl der übereinstimmenden Schlüsselspalte
-- a) Wenn beide ID-Variablen in beiden Tabellen gleich heißen: USING
--    Beispiel: Kunden und Bestellungen zusammenführen
--    an der gemeinsamen Spalte, die Kundennummern enthält.
--    In pandas: pd.merge(on="customerId")

SELECT *
FROM customers;
SELECT *
FROM orders;
-- Beobachtung: In beiden ist die gleichnamige "customerId" enthalten!
-- Weitere Beobachtungen:

-- Führen wir nun einen INNER JOIN von customers und orders durch:
SELECT *
FROM customers
         JOIN orders
              USING (customerId);
-- Was fällt auf?


-- b) Wenn der Name der Schlüsselspalte nicht 
--    in beiden Tabellen identisch ist, verwenden wir ON
--    Beispiel : orders und customers_diff_colnames
--    In pandas: pd.merge(left_on=..., right_on=...)

SELECT *
FROM customers_diff_colnames;
SELECT *
FROM orders;
-- Beobachtung:

-- Ohne Alias
SELECT *
FROM orders
         JOIN customers_diff_colnames
              ON customerId = customer_number;

-- Left Join Beispiel
--
SELECT *
FROM orders
         LEFT JOIN customers USING (customerId);
-- Beobachtung: Alle Bestellnummern aus linker Tabelle (orders) bleiben
-- erhalten und wenn in customer die Kunden-IDs von orders nicht existieren,
-- wird die Namensspalte mit NULL aufgefüllt.

-- Right Join
-- Es passiert dasselbe wie beim Left Join, nur spiegelverkehrt.
-- Die rechte Tabelle wird um Daten aus der linken Tabelle ergänzt.
SELECT *
FROM orders RIGHT JOIN customers
USING (customerId);

-- Beobachtung:

-- Full Outer Join
SELECT *
FROM orders FULL OUTER JOIN customers
USING (customerId);
-- Beobachtung:

-- Left Anti-Join
SELECT *
FROM orders LEFT JOIN customers
USING (customerId)
WHERE name IS NULL;

-- Natural Join -> Alle Spalten mit 
-- übereinstimmenden Namen werden abgeglichen
SELECT *
FROM customers
         NATURAL JOIN orders;

-- Cross Join (Kreuzprodukt)
-- Wenn die Schlüsselspalte weggelassen wird,
-- wird ein Cross-Join erstellt
SELECT * FROM customers
JOIN orders;

-- Beim Joinen ist es manchmal sinnvoll, den Tabellen einen Alias zu geben,
-- um sie im Statement leicht adressieren zu können:
SELECT *
FROM customers;
SELECT *
FROM orders_diff;
-- Problem: Wir haben zweimal Spalte name.
SELECT *
FROM customers
         JOIN orders_diff ON customerId = customer_number;
-- Spaltennamen mit Tabellennamen davor wie customers.name
-- Ziel sind folgende Spalten: CustomerId, OrderId; customer_name, item_name
-- Hilfsmittel: Alias für die Tabellen!
SELECT c.customerId,
       o.orderId,
       c.name AS customer_name,
       o.name AS item_name
FROM customers c
         JOIN orders_diff o ON customerId = customer_number;

-- Ab zu den Übungen! (Und eventuell zu den Subqueries)
