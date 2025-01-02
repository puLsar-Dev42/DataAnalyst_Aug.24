/*
 * Tagesaufgaben: Fensterfunktionen
 * 
 * Verwende die dvdrental Datenbank in postgres!
 * 
 * Verwende für jede der Aufgaben das OVER Statement!
 */

-- Aufgabe 1: Wie hoch ist die durchschnittliche 
-- Verleihdauer für jede inventory_id in der Tabelle
-- rental? Lass dir die inventory_id, die customer_id
-- und die durchschnittliche Verleihdauer für jeden
-- Eintrag der Tabelle rental ausgeben und sortiere
-- nach inventory_id.

SELECT inventory_id,
	   customer_id,
	   avg(
	   extract(
			   DAY FROM (return_date - rental_date)
	   )
		  )
	   OVER (
		   PARTITION BY rental_id
		   ORDER BY inventory_id
		   ) AS avg_rental_duration
FROM rental;



-- Aufgabe 2:
-- a) Berechne die Summe der amount Spalte für
-- die aktuelle payment_id addiert mit dem amount aller 
-- vorherigen payment_id. Lass dir die payment_id, die
-- amount-Spalte und das Ergebnis der Berechnung anzeigen.
-- Nutze die Tabelle payment.

SELECT payment_id,
	   amount,
	   round(
					   sum(amount)
					   OVER (
						   ROWS BETWEEN UNBOUNDED PRECEDING
							   AND CURRENT ROW
						   ),
					   2
	   ) AS cumulative_amount_sum
FROM payment;

-- b) Erstelle nun für jeden Kunden eine anwachsende Summe.
-- Folgende Spalten sind von Interesse:
-- payment_id, customer_id, amount, cum_customer_sum

SELECT payment_id,
	   customer_id,
	   amount,
	   round(
					   sum(amount)
					   OVER (
						   PARTITION BY customer_id
						   ROWS BETWEEN UNBOUNDED PRECEDING
							   AND CURRENT ROW
						   ),
					   2
	   ) AS cumulative_amount_sum
FROM payment
ORDER BY payment_id;

-- Aufgabe 3: Berechne einen gleitenden Mittelwert für amount.
-- Dieser soll immer gebildet werden aus dem Betrag der vorhergehenden,
-- der gegenwärtigen sowie der nachfolgenden Zeile (3-Tage-Durchschnitt)
-- Lass dir die payment_id, die amount-Spalte und das Ergebnis
-- der Berechnung anzeigen (three_day_avg).
-- Nutze die Tabelle payment.

SELECT payment_id,
	   amount,
	   round(
					   sum(amount)
					   OVER (
						   ROWS BETWEEN 1 PRECEDING
							   AND 1 FOLLOWING
						   ),
					   2
	   ) AS cumulative_amount_sum
FROM payment;



-- Aufgabe 4: Wie hoch sind die gesamten Ausgaben
-- für jeden Kunden in der Tabelle payment?
-- Lass dir customer_id, amount, payment_date und die
-- gesamten Ausgaben ausgeben.


SELECT customer_id,
	   amount,
	   payment_date,
	   sum(amount)
	   OVER (
		   PARTITION BY customer_id
		   ) AS total_paid,
	   round(
			   (amount * 100) / sum(amount)
								OVER (
									PARTITION BY customer_id
									),
			   2
	   )     AS percentage_share_of_total_paid
FROM payment
ORDER BY customer_id,
		 payment_date;

-- Aufgabe 5 (Bonus):
-- Erweitere die Ausgabe von Aufgabe 4 so, dass dort neben amount
-- der Anteil des Betrags in Prozent an der Gesamtsumme pro Kunden vorkommt.


-- Aufgabe 6 (Bonus):
-- Bilde für die Kunden mit ihren Klarnamen Summen.
-- Vergib diesen Kundensummen Ränge.

-- WAAAAAASSSSS??? 🤨

