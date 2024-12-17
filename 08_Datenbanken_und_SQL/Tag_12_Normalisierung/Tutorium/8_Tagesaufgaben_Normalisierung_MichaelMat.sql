-- Tagesaufgabe Normalisierung

/*
   Dir liegt die Datei my_sql_shop.csv vor mit Daten in nicht-normalisierter Form.
   Führe folgende Schritte durch:
   1. Erstelle eine Datenbank 'my_shop', in die alle Daten kommen.
   2. Kopiere die Daten aus der CSV in eine Tabelle 'unnormalized_shop'.
   3. Überführe die Daten in die erste Normalform (eine große Tabelle).
   4. Überführe die Daten in die zweite Normalform und falls nötig weiter in die dritte Normalform.
   Vergiss nicht, Primärschlüssel zu setzen.

   Es ist dir überlassen, ob du die Daten in SQL oder in Excel normalisierst.
   Solltest du sie in Excel normalisieren, dann importiere im Nachgang alle Tabellen in 'my_shop'.
 */
CREATE DATABASE my_shop;

---
CREATE TABLE IF NOT EXISTS unnormalized_shop
(
	order_id         INT PRIMARY KEY,
	customer_name    VARCHAR(120),
	product_name     VARCHAR(55),
	product_price    DECIMAL(12, 2),
	order_date       DATE,
	product_category VARCHAR(55),
	customer_mail    VARCHAR(120),
	address          VARCHAR(255),
	employee_name    VARCHAR(120),
	employee_phone   VARCHAR(30)
);

COPY unnormalized_shop
	FROM 'C:\Users\Admin\OneDrive\Dokumente\DataCraft\DataAnalyst_Aug.24\08_Datenbanken_und_SQL\Tag_12_Normalisierung\Tutorium\my_sql_shop.csv'
	DELIMITER ';'
	CSV HEADER;

---

CREATE TABLE my_shop_nf1
(
	order_id         SERIAL PRIMARY KEY,
	customer_name    VARCHAR(120),
	product_name     VARCHAR(55),
	product_price    DECIMAL(12, 2),
	order_date       DATE,
	product_category VARCHAR(55),
	customer_mail    VARCHAR(120),
	address          VARCHAR(255),
	employee_name    VARCHAR(120),
	employee_phone   VARCHAR(30)
);

INSERT INTO my_shop_nf1 (order_id,
                         customer_name,
                         product_name,
                         product_price,
                         order_date,
                         product_category,
                         customer_mail,
                         address,
                         employee_name,
                         employee_phone)
SELECT DISTINCT order_id,
                customer_name,
                product_name,
                product_price,
                order_date,
                product_category,
                customer_mail,
                address,
                employee_name,
                employee_phone
FROM unnormalized_shop;

---
-- DROP TABLE customers;

CREATE TABLE customers
(
	customer_id   SERIAL PRIMARY KEY,
	customer_name TEXT,
	address       TEXT,
	customer_mail TEXT
);

INSERT INTO customers (customer_name, address, customer_mail)
SELECT DISTINCT customer_name, address, customer_mail
FROM my_shop_nf1;

---
-- DROP TABLE products;

CREATE TABLE products
(
	product_id       SERIAL PRIMARY KEY,
	product_category TEXT,
	product_name     TEXT,
	product_price    DECIMAL(12, 2)

);

INSERT INTO products (product_category, product_name, product_price)
SELECT DISTINCT product_category, product_name, product_price
FROM my_shop_nf1;

---
-- DROP TABLE employees;

CREATE TABLE employees
(
	employee_id    SERIAL PRIMARY KEY,
	employee_name  TEXT,
	employee_phone TEXT
);

INSERT INTO employees (employee_name, employee_phone)
SELECT DISTINCT employee_name, employee_phone
FROM my_shop_nf1;

---
-- DROP TABLE orders;

CREATE TABLE orders
(
	order_id      INT PRIMARY KEY,
	product_id    INT,
	customer_id   INT,
	employee_id   INT,
	order_date    DATE,
	product_price DECIMAL(12, 2)
);

INSERT INTO orders (order_id, product_id, customer_id, employee_id, order_date, product_price)
SELECT ms.order_id,
       p.product_id,
       c.customer_id,
       e.employee_id,
       ms.order_date,
       ms.product_price
FROM my_shop_nf1 AS ms
	     JOIN products AS p ON ms.product_name = p.product_name
	     JOIN customers AS c ON ms.customer_name = c.customer_name
	     JOIN employees AS e ON ms.employee_name = e.employee_name;

---

