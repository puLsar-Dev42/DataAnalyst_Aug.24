/* Tagesaufgaben PostgreSQL und Datetime
 * ------------------------------------------------------
 */

-- Falls noch nicht geschehen, übertrage
-- die Chinook Datenbank in Postgres.
-- Verbinde dich mit der PostgreSQL Chinook Datenbank.
SELECT *
FROM "Customer";


/* 1.
 * ----
 * Extrahiere die ersten drei Buchstaben
 * des Album-Namens.
 */

/* 2.
 * ----
 * Zeige die "Title" Spalte der Album
 * Tabelle an, umgewandelt in einen
 * varchar(3) Datentyp. Was fällt auf?
 */


/* 3.
 * ----
 * Lass dir die einzigartigen
 * Bestellanzahlen aus der Tabelle
 * InvoiceLine anzeigen.
 */


/* 4.
 * ----
 * Nun, da du weißt, dass jeder Artikel
 * in jeder Bestellung nur einmal vorkommt,
 * errechne den Gesamtrechnungsbetrag
 * jeder Rechnung basierend auf der InvoiceLine
 * Tabelle. Zeige ihn zusammen mit der
 * Rechnungs-ID an.
 * 
 */


/* 5.
 * ----
 * Du willst deine Rechnungsbeträge
 * runden und stellst einen Vergleich an:
 *  Berechne wieder den Gesamtpreis pro
 * 	Rechnung und zeige ihn neben der
 * 	Rechnungs-ID an. In einer dritten
 * 	Spalte, wandle die Werte vor der
 * 	Summierung in integer um. In einer
 * 	vierten Spalte runde die Werte
 * 	stattdessen vor der Summierung.
 *  In der fünften Spalte stelle die
 * 	Differenz der beiden Methoden dar.
 * 
 */


/* 6.
 * ----
 * Lass dir die Spalte InvoiceDate
 * aus der Tabelle Invoice anzeigen.
 */


/* 7. Optional
 * ----
 * Lass dir nur den Monat und den
 * Tag der Rechnung anzeigen.
 */


/* 8.
 * ----
 * Lass dir alle Infos zu Rechnungen
 * aus Februar bis (einschließlich) August
 * des Jahres 2009 anzeigen.
 */


/* 9. 
 * ----
 * Gruppiere die Invoice Tabelle nach
 * dem Jahr des Rechnungsdatum und zeige
 * das jeweilige Jahr als Text, sowie
 * den Gesamtumsatz und Durchschnittsumsatz
 * pro Rechnung des Jahres an.
 */


/* 10. Optional
 * ----
 * Lass dir pro Rechnungs-ID eine
 * Liste aller gekauften TrackIds anzeigen.
 *
 */

