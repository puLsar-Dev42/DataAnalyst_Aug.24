-- Verbinde dieses Skript mit der Chinook-Datenbank!

-- Übung 1: Finde alle Kunden, die vom Mitarbeiter Margaret Park betreut werden
-- und gib ihren Vornamen, Nachnamen und ihre Telefonnummer aus.
SELECT FirstName, LastName, Phone
FROM Customer
WHERE SupportRepId = 4;




-- Übung 2:
-- Finde alle Künstler ohne Album

SELECT ar.ArtistId,
       ar.Name
FROM Artist AS ar
    LEFT JOIN Album AS al
        ON ar.ArtistId = al.ArtistId
WHERE al.AlbumId IS NULL;



/* Übung 3 JOIN:
 *  -- Zeige die Namen aller Kunden an, sowie den
 *     Mitarbeiter, der für ihren Support zuständig ist.
 *     Ordne das Ergebnis nach den Mitarbeitern, die die Kunden betreuen!
 *
 * Fortgeschrittene Übung:
 *  -- Zeige die Namen aller Mitarbeiter sowie eine Liste
 *     ihrer zugehörigen Kunden an, selbst wenn sie noch
 *     keine Kunden betreuen.
 *
 * Knifflig:
 *  -- Welche Tracks wurden von Kunden aus Kanada gekauft?
 *     Zeige den Tracknamen und den Kundennamen an.
 *     Rechtsklick auf Datenbank > Diagrams > Show Diagram
 *     >>> Zeigt Zusammenhänge zwischen Tabellen als Diagramm (ERD).
 */

SELECT C.CustomerId,
       C.FirstName || ' ' || C.LastName AS CustomerName,
       C.SupportRepId,
       E.FirstName || ' ' || E.LastName AS EmployeeName
FROM Customer AS C
    JOIN Employee AS E
        ON E.EmployeeId = C.SupportRepId
ORDER BY EmployeeName;


