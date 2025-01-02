/*
Lernkontrolle 3 (PostgreSQL, Datenbankdesign)
Die möglichen Punkte stehen bei der jeweiligen Aufgabe dabei.

-- Benutze zunächst die Datenbank northwind.

-- Achtung: Nicht alle Spalten, die hier genannt werden, existieren auch
-- in Tabellen. Manche müsst ihr auch ausrechnen!

*/


/*
 1. Betrachte die Tabelle orderdetails und die Tabelle products.
 Lasse dir eine Tabelle ausgeben, die folgende Spalten enthält:
 orderid, productid, productname, unit_price, quantity, total_price.
 20 Pkt.
*/

SELECT od.orderid,
	   od.productid,
	   p.productname,
	   p.price               AS unit_price,
	   od.quantity,
	   od.quantity * p.price AS total_price
FROM products AS p
		 JOIN orderdetails AS od ON p.productid = od.productid
ORDER BY od.orderid;


/*
2. Schreibe eine Funktion, die als Parameter eine Produkt-ID entgegennimmt
   und den Namen des betreffenden Produkts zurückgibt.
   Denke daran, deine Funktion zu testen! 20 Pkt.
*/

CREATE OR REPLACE FUNCTION search_prod_by_id(product_id INT)
	RETURNS TEXT AS
$$
DECLARE
	product_name TEXT;
BEGIN
	SELECT productname
	INTO product_name
	FROM products
	WHERE productid = product_id;
	
	RETURN product_name;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 'NO PRODUCT FOUND';
END;
$$
	LANGUAGE plpgsql;

SELECT search_prod_by_id(69);

/*
3. Schreibe eine Funktion, die die Tabelle products mittels regulärem Ausdruck
   nach Produktnamen filtert und Produkt-ID, den Namen sowie Preis des Produkts
   zurückgibt. Suche nach Produkten, die 'cho' in beliebiger Schreibung im Namen
   enthalten und führe ein paar weitere eigene Tests durch.
   20 Pkt.
*/

-- DROP FUNCTION search_prod_by_name;

CREATE OR REPLACE FUNCTION search_prod_by_name(searched_prod TEXT)
	RETURNS TABLE
			(
				product_id   INT,
				product_name VARCHAR(50),
				price        NUMERIC
			)
AS
$$
BEGIN
	RETURN QUERY
		SELECT p.productid, p.productname, p.price
		FROM products AS p
		WHERE p.productname ILIKE '%' || searched_prod || '%';
END;
$$
	LANGUAGE plpgsql;

SELECT *
FROM search_prod_by_name('cho');

SELECT *
FROM search_prod_by_name('cof');

SELECT *
FROM search_prod_by_name('gummi');

/*
4. Erstelle einen View für deine Mitarbeiter, in dem diese mit ID, Nachnamen,
Vornamen und der Anzahl Bestellungen (orders_count), die sie abgewickelt haben, vorkommen.
Der View soll absteigend nach orders_count sortiert sein und nur die top 10 Verkäufer umfassen.
Nenne den View top_ten_employees.
Teste den View.
15 Pkt.
*/

CREATE OR REPLACE VIEW top_ten_employees AS
SELECT e.employeeid,
	   e.lastname,
	   e.firstname,
	   COUNT(o.orderid) AS orders_count
FROM employees AS e
		 JOIN orders AS o ON e.employeeid = o.employeeid
GROUP BY e.employeeid, e.lastname, e.firstname
ORDER BY orders_count DESC
LIMIT 10;

SELECT *
FROM top_ten_employees;
/*
5. Erstelle eine Datenbank wochenende und verbinde dich mit dieser.
   Beschreibe, wie du dich mit dieser verbunden hast und wieso das wichtig ist,
   bevor du Tabellen erstellst.
   5 Pkt.
*/

CREATE DATABASE wochenende;

-- Antwort: wenn ich die db erstellt habe bzw. nachdem ich den befehl mit enter bestätigt habe, wähle ich
-- bei data_source postgresql@localhost und wähle dann das public_schema wochenende.<schema>
-- das ist wichtig damit wir unsere relations auch an der richtigen stellen erstellen!!!

/*
6. Erstelle in der Datenbank eine Tabelle namens planung mit folgenden Spalten:
   ID (automatisch ansteigende Ganzzahlen, Primärschlüssel)
   Tag (Textdaten), darf keine fehlenden Werte enthalten
   Tagesabschnitt (Textdaten)
   Unternehmung (Textdaten)
   10 Pkt.
*/

CREATE TABLE planung
(
	id             SERIAL PRIMARY KEY,
	tag            VARCHAR(50) NOT NULL,
	tagesabschnitt VARCHAR(50),
	unternehmung   VARCHAR(50)
);

/*
7. Befülle die Tabelle mit folgenden Informationen:
   Samstag - Vormittag - spazieren
   Samstag - Nachmittag - ein Buch lesen
   Samstag - Abend - tanzen
   Sonntag - Vormittag - Sport
   Sonntag - Nachmittag - meditieren
   Sonntag - Abend - Kino
   Prüfe, ob alles geklappt hat!
   5 Pkt.
*/

INSERT INTO planung(tag, tagesabschnitt, unternehmung)
VALUES ('Samstag', 'Vormittag', 'spazieren');

INSERT INTO planung(tag, tagesabschnitt, unternehmung)
VALUES ('Samstag', 'Nachmittag', 'ein Buch lesen');

INSERT INTO planung(tag, tagesabschnitt, unternehmung)
VALUES ('Samstag', 'Abend', 'tanzen');

INSERT INTO planung(tag, tagesabschnitt, unternehmung)
VALUES ('Sonntag', 'Vormittag', 'Sport');

INSERT INTO planung(tag, tagesabschnitt, unternehmung)
VALUES ('Sonntag', 'Nachmittag', 'meditieren');

INSERT INTO planung(tag, tagesabschnitt, unternehmung)
VALUES ('Sonntag', 'Abend', 'Kino');

SELECT *
FROM planung;

/*
8. Du hast beschlossen, dein Wochenende flexibler zu gestalten und dich
    doch gegen die Tabelle entschieden.
    Entferne zuerst die Tabelle.
    Entferne danach die Datenbank.
    Beschreibe kurz, wie du vorgehen musstest, um die Datenbank löschen zu können.
    5 Pkt.
*/

DROP TABLE planung;

-- jetzt muss ich das schema auf postgresql ändern da ich sonst die db nicht löschen kann!!!

DROP DATABASE wochenende;
