/* ----------------------------------------
 * Tagesaufgaben CREATE, DROP, TABLE
 * ----------------------------------------
 */


/* --------------------
 * TABELLEN
 * --------------------
 */


/* 1.
 * ----
 * Erstelle eine Datenbank my_shop und verbinde das Skript mit dieser!
 * PS: Denk an die Auswahl des Schemas vor dem Verbinden.
 */
CREATE DATABASE my_shop;

/* 2.
 * ---- 
 * Erstelle eine Tabelle orders, welche
 * über folgende Spalten verfügt:
 * order_id: Primärschlüssel, IDs Werte werden automatisch seriell erzeugt
 * order_date: Datum / Zeitstempel der Bestellung, darf nicht NULL sein!
 * customer_id: Ganzzahlen für Kundennummern*
 * product_name: Name des Produkts, VARCHAR(30) (Bildschirm, Maus, Tastatur, Tisch)
 * price: Preis des Produkts, FLOAT (249.99, 6.99, 12.49, 299.99)
 */

DROP TABLE orders;
CREATE TABLE orders
(
	order_id     SERIAL PRIMARY KEY,
	order_date   TIMESTAMP(0) NOT NULL,
	customer_id  INT,
	product_name VARCHAR(30),
	price        FLOAT
);

/* 3.
 * ---- 
 * Benutze nun ein INSERT-Statement, um folgende Einträge hinzuzufügen:
 * Datum: 28.02.2024 12:43:12, Kunde Nr.: 1, Produkt: Tisch, Preis: 299.99
 * Datum: 28.02.2024 17:07:43, Kunde Nr.: 2, Produkt: Maus, Preis: 6.99
 * Datum: 04.03.2024 09:31:10, Kunde Nr.: 1, Produkt: Bildschirm, Preis: 249.99
 * Datum: 06.03.2024 11:56:57, Kunde Nr.: 3, Produkt: Bildschirm, Preis: 249.99
 * Datum: 07.03.2024 12:22:21, Kunde Nr.: 2, Produkt: Tastatur, Preis: 12.49
 * Lass dir die Tabelle danach wieder anzeigen.
 */
INSERT INTO orders (order_date, customer_id, product_name, price)
VALUES ('2024-02-28 12:43:12', 1, 'Tisch', 299.99),
       ('2024-02-28 17:07:43', 2, 'Maus', 6.99),
       ('2024-03-04 09:31:10', 1, 'Bildschirm', 249.99),
       ('2024-03-06 11:56:57', 3, 'Bildschirm', 249.99),
       ('2024-03-07 12:22:21', 2, 'Tastatur', 12.49);

SELECT *
FROM orders;
/* 4.
 * ----
   Erstelle nun eine Tabelle customer mit folgenden Spalten:
   customer_id: Primärschlüssel, seriell
   lastname: VARCHAR(32)
   firstname: VARCHAR(32)
   address: VARCHAR(255)
 */
DROP TABLE customer;

CREATE TABLE customer
(
	customer_id SERIAL PRIMARY KEY,
	lastname    VARCHAR(32)  NOT NULL,
	firstname   VARCHAR(32)  NOT NULL,
	address     VARCHAR(255) NOT NULL
);
/* 5.
 * ----
   Füge folgende Informationen der Tabelle hinzu:
   Kunde 1 soll Peter Schmidt, wohnhaft im Holzpfad 42, sein.
   Kunde 2 soll Alina Klein, wohnhaft in der Traumallee 6, sein.
   Kunde 3 soll Bernhard Anders, wohnhaft in der Höllengasse 7, sein.
   Prüfe, ob alles geklappt hat.
 */
INSERT INTO customer(lastname, firstname, address)
VALUES ('Schmidt', 'Peter', 'im Holzpfad 42'),
       ('Klein', 'Alina', 'in der Traumallee 6'),
       ('Anders', 'Bernhard', 'in der Höllengasse 7');

SELECT *
FROM customer;
/* 6.
 * ----
   Entferne in customer die Spalte 'address'.
   Entferne die Tabelle orders.
   Entferne die komplette Datenbank.
 */
ALTER TABLE customer
	DROP address;

DROP TABLE orders;

DROP DATABASE my_shop;
-- * customer_id in orders ist ein klassisches Beispiel für einen
-- Fremdschlüssel, wobei der Primärschlüssel sich in customers befindet.
-- Aber dazu mehr in der Vorlesung zu Fremdschlüsseln!