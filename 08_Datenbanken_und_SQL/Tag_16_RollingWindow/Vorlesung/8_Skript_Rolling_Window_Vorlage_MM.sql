/*
 * -------------------------------------------
 * Skript: 	Rolling Window / Moving Average
 * -------------------------------------------
 *
 */

--- Was sind "WINDOW"-Funktionen?
/*
Eine Fensterfunktion führt eine Berechnung
über eine Reihe von Tabellenzeilen durch,
die in irgendeiner Weise (die wir festlegen können)
mit der aktuellen Zeile verbunden sind.

Beispiele für solche Verbindungen:
- Gruppierung nach Abteilungsnummern/ -namen
- Zusammenfassung von Zeitdaten zu festen Einheiten wie Wochen

Das kennen wir bereits von Aggregationen.
Im Unterschied zu Aggregationsfunktionen fassen
Fensterfunktionen Daten aber nicht so zusammen,
dass pro aggregierten Wert jeweils eine Zeile übrigbleibt.
Sondern es bleiben die ursprüngliche Zeilenzahl erhalten.
Auf diese Weise können die eigentlichen Werte mit
den aggregierten Werten verglichen werden.
(Es wird hier also ein klassisches Select-Statement mit
Aggregatsfunktionen vermischt.)

Beispiele:
- Gehälter der Mitarbeiter der verschiedenen Abteilungen neben
dem Durchschnittsgehalt pro Abteilung
- Kumulative Verkaufsdaten von Produkten auf Wochenbasis o.Ä.

Das Keyword, mit dem Fensterfunktionen erstellt werden, ist OVER.
Syntax von Over:
<function> OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE ...)

Neben den klassischen Aggregationen sowie rollenden Summen u.Ä.
können mit RANK auch Rangfolgen (ganze Zahlen, aufsteigend)
für Daten vergeben werden.

*/

-- Zunächst erstellen wir eine Datenbank mit einer Tabelle für die weiteren Beispiele:
-- CREATE DATABASE rolling_united
-- Zu dieser verbinden, nicht vergessen!

CREATE DATABASE rolling_united;

CREATE TABLE empsalary
(
	depname     VARCHAR(50),
	empno       INT,
	salary      DECIMAL(10, 2),
	avg         DECIMAL(10, 2),
	enroll_date DATE
);


INSERT INTO empsalary (depname, empno, salary, avg, enroll_date)
VALUES ('develop', 11, 5200, 5020.00, '2020-01-15'),
	   ('develop', 7, 4200, 5020.00, '2021-05-20'),
	   ('develop', 9, 4500, 5020.00, '2019-07-10'),
	   ('develop', 8, 6000, 5020.00, '2022-03-12'),
	   ('develop', 10, 5200, 5020.00, '2020-08-25'),
	   ('personnel', 5, 3500, 3700.00, '2021-02-18'),
	   ('personnel', 2, 3900, 3700.00, '2019-11-05'),
	   ('sales', 3, 4800, 4866.67, '2021-06-30'),
	   ('sales', 1, 5000, 4866.67, '2022-09-14'),
	   ('sales', 4, 4800, 4866.67, '2023-01-22');

-- Blick in empsalary:
SELECT *
FROM empsalary;

-- Ziel: Einzelgehälter aller Mitarbeiter
-- und Durchschnittsgehalt der Firma nebeneinander.

SELECT avg(salary)
FROM empsalary;

SELECT depname,
	   empno,
	   salary
FROM empsalary;

-- Versuch: Auf Einzelzeilen mit Abteilungsname und Gehalt
-- sowie Summen daneben hoffen

SELECT depname,
	   empno,
	   salary,
	   avg(salary)
FROM empsalary;

-- Die Lösung: OVER verwenden!
-- Firmenübergreifendes Durchschnittsgehalt neben Gehaltsspalte:
SELECT depname,
	   empno,
	   salary,
	   round(avg(salary) OVER (), 2) AS department_avg
FROM empsalary;

-- OVER kann mehr als das!
-- PARTITION BY teilt die Daten in Gruppen ein (partitioniert sie) anhand
-- von Werten in einer Spalte (etwa IDs). Dadurch werden für diese jeweiligen
-- Gruppen (einzelne Kunden) Berechnungen angestellt.

-- Durchschnittsgehälter je Abteilung neben Gehaltsspalte:
SELECT depname,
	   empno,
	   salary,
	   round
	   (avg(salary)
		OVER (PARTITION BY depname),
		2) AS department_avg
FROM empsalary;

-- Vergabe von Rängen für Gehälter:
SELECT depname,
	   empno,
	   salary,
	   RANK()
	   OVER (PARTITION BY depname
		   ORDER BY salary DESC) AS salary_rank
FROM empsalary;
-- Beobachtungen zur Rangvergabe: ...

-- Alternative Rangvergabe mit DENSE_RANK()
SELECT depname,
	   empno,
	   salary,
	   DENSE_RANK()
	   OVER (PARTITION BY depname
		   ORDER BY salary DESC) AS salary_rank
FROM empsalary;
-- Unterschied: ...

-- Vergabe von Zeilennummern mit ROW_NUMBER()
SELECT depname,
	   empno,
	   salary,
	   ROW_NUMBER() OVER
		   (PARTITION BY depname
		   ORDER BY salary DESC) AS row_num
FROM empsalary;
-- Bemerkungen: ...

-- Exotisch: Partition bei Year
SELECT depname,
	   enroll_date                    AS date,
	   salary,
	   date_part('year', enroll_date) AS year,
	   sum(salary) OVER
		   (PARTITION BY date_part('year', enroll_date)
		   ORDER BY enroll_date)      AS year_cum_sum
FROM empsalary
ORDER BY year;

-- Übung 1: Erstelle nachfolgende Tabelle samt Daten:
CREATE TABLE sales
(
	product_name  VARCHAR(100),
	version       VARCHAR(50),
	price         DECIMAL(10, 2),
	quantity_sold INT,
	revenue       DECIMAL(10, 2),
	sales_date    DATE
);

INSERT INTO sales (product_name, version, price, quantity_sold, revenue,
				   sales_date)
VALUES ('Clinical Trial Manager', 'Basic', 1500.00, 120, 180000.00,
		'2023-02-15'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 85, 297500.00, '2023-03-10'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 50, 375000.00,
		'2023-04-05'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 60, 210000.00, '2023-05-20'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 40, 300000.00,
		'2023-06-12'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 110, 165000.00,
		'2023-07-25'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 50, 375000.00,
		'2023-08-10'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 95, 142500.00,
		'2023-09-05'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 70, 245000.00, '2023-10-18'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 130, 195000.00,
		'2023-11-03'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 100, 350000.00,
		'2023-01-10'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 75, 562500.00,
		'2023-02-01'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 90, 315000.00, '2023-03-12'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 80, 120000.00,
		'2023-04-08'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 65, 487500.00,
		'2023-05-01'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 95, 142500.00,
		'2023-06-30'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 60, 210000.00, '2023-07-14'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 40, 300000.00,
		'2023-08-22'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 75, 262500.00, '2023-09-01'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 60, 450000.00,
		'2023-10-05'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 120, 180000.00,
		'2023-10-20'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 85, 297500.00, '2023-11-10'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 55, 412500.00,
		'2023-11-15'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 80, 280000.00, '2023-12-01'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 95, 142500.00,
		'2023-12-10'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 60, 210000.00, '2023-12-15'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 110, 165000.00,
		'2023-01-20'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 70, 525000.00,
		'2023-02-25'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 60, 450000.00,
		'2023-03-05'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 100, 150000.00,
		'2023-04-22'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 65, 227500.00, '2023-05-15'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 50, 375000.00,
		'2023-06-10'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 70, 245000.00, '2023-07-05'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 75, 562500.00,
		'2023-08-18'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 125, 187500.00,
		'2023-09-12'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 90, 315000.00, '2023-10-02'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 80, 600000.00,
		'2023-10-25'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 85, 297500.00, '2023-11-28'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 95, 142500.00,
		'2023-12-05'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 70, 245000.00, '2023-01-30'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 50, 375000.00,
		'2023-02-15'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 130, 195000.00,
		'2023-03-22'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 100, 350000.00,
		'2023-04-30'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 65, 487500.00,
		'2023-06-02'),
	   ('Clinical Trial Manager', 'Basic', 1500.00, 110, 165000.00,
		'2023-07-17'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 75, 262500.00, '2023-08-03'),
	   ('Clinical Trial Manager', 'Enterprise', 7500.00, 55, 412500.00,
		'2023-09-20'),
	   ('Clinical Trial Manager', 'Pro', 3500.00, 85, 297500.00, '2023-10-12');

SELECT *
FROM sales;

-- Lasse dir Folgendes nebeneinander anzeigen:
-- Verkaufsdatum, Einnahmebetrag sowie den Durchschnitt über alle Verkäufe hinweg

SELECT sales_date,
	   revenue,
	   round
	   (avg(revenue)
		OVER (),
		2) AS avg_rev
FROM sales;

-- Lasse dir Verkaufsdatum, Software-Version sowie Einzelbetrag ausgeben,
-- gefolgt vom Durchschnitt der Einnahmen pro Version.
-- Sortiere nach Produktversion und Datum.

SELECT sales_date,
	   version,
	   price,
	   revenue,
	   round
	   (avg(revenue)
		OVER (
			PARTITION BY version
			),
		2) AS vers_avg_rev
FROM sales
ORDER BY version, sales_date;

-- Vergib Ränge innerhalb der Versionen für die Anzahlen verkaufter Produkte.
-- In der Ausgabe sollen sein: Datum, Versionsname, Anzahl sowie Rang
-- Bei der Rangvergabe sollen keine Zahlen übersprungen werden.

SELECT sales_date,
	   version,
	   quantity_sold,
	   DENSE_RANK()
	   OVER (
		   PARTITION BY version
		   ORDER BY quantity_sold DESC
		   ) AS sold_rank
FROM sales;

-- ÜBUNG ENDE

-- Kumulativ anwachsende Ausgaben:
SELECT empno,
	   enroll_date,
	   salary,
	   SUM(salary)
	   OVER (
		   ORDER BY enroll_date
		   ROWS BETWEEN UNBOUNDED PRECEDING
			   AND CURRENT ROW
		   ) AS cumulative_sum
FROM empsalary
ORDER BY enroll_date;

-- Das Ganze verbinden mit Partitionierung nach Abteilungen:
SELECT empno,
	   depname,
	   enroll_date,
	   salary,
	   SUM(salary)
	   OVER (
		   PARTITION BY depname
		   ORDER BY enroll_date
		   ROWS BETWEEN UNBOUNDED PRECEDING
			   AND CURRENT ROW
		   ) AS rolling_sum
FROM empsalary;

-- Übung 2: Erstelle eine anwachsende Summe für die verschiedenen Softwareversionen,
-- die mit steigenden Datumsangaben steigt.
-- Die Ausgabe soll umfassen: Datum, Versionsname, Einnahmebetrag, kumulative Summe.

SELECT sales_date,
	   version,
	   revenue,
	   sum(revenue)
	   OVER (
		   PARTITION BY version
		   ORDER BY sales_date
		   ROWS BETWEEN UNBOUNDED PRECEDING
			   AND CURRENT ROW
		   ) AS cumulative_version_sum
FROM sales;

-- ÜBUNG ENDE

-- Man kann auch Fenster definieren, die mitwandern
-- Beispiel: rollierender Drei-Tage-Durchschnitt

-- Daten erzeugen:
CREATE TABLE daily_data
(
	record_date DATE,
	daily_sales INT
);

INSERT INTO daily_data (record_date, daily_sales)
VALUES ('2024-01-01', 100), -- Week 1
	   ('2024-01-02', 150),
	   ('2024-01-03', 200),
	   ('2024-01-04', 120),
	   ('2024-01-05', 180),
	   ('2024-01-06', 160),
	   ('2024-01-07', 130),
	   ('2024-01-08', 170), -- Week 2
	   ('2024-01-09', 190),
	   ('2024-01-10', 220),
	   ('2024-01-11', 210),
	   ('2024-01-12', 180),
	   ('2024-01-13', 160),
	   ('2024-01-14', 150),
	   ('2024-01-15', 140), -- Week 3
	   ('2024-01-16', 130),
	   ('2024-01-17', 160),
	   ('2024-01-18', 170),
	   ('2024-01-19', 180),
	   ('2024-01-20', 190),
	   ('2024-01-21', 200);

-- 3-Tage-Mittelwert

SELECT record_date,
	   daily_sales,
	   AVG(daily_sales)
	   OVER (
		   ORDER BY record_date
		   ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
		   ) AS rolling_3_days_avg
FROM daily_data
ORDER BY record_date;

-- Beobachtungen: ...

-- Oder mit einer ganzen Woche (bis zu dem aktuellen Tag!):
SELECT record_date,
	   daily_sales,
	   ROUND(
					   AVG(daily_sales)
					   OVER (
						   ORDER BY record_date
						   ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
						   ),
					   2) AS rolling_7_days_avg
FROM daily_data
ORDER BY record_date;

-- Doku: https://www.postgresql.org/docs/current/tutorial-window.html
-- Ebenfalls interessant ist hier die Möglichkeit, benannte Fenster zu nutzen (named Windows)
-- Noch mehr Details: https://www.postgresql.org/docs/current/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS
