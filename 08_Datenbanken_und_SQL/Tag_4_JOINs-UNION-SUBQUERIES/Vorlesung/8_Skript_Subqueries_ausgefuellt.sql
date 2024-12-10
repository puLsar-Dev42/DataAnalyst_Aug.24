/* ---------------
 * 3. SUBQUERIES - Unterabfragen
 * ---------------
 *
 * Das Ergebnis einer (Unter-)Abfrage kann in
 * eine andere (Über-)Abfrage eingefügt werden.
 * Die innere Abfrage wird in dem Fall Subquery
 * oder Unterabfrage genannt und in Klammern
 * geschrieben.
 * ---------------
 */
SELECT 4 + 3 AS result;

SELECT result
FROM (SELECT 4 + 3 AS result);

-- Beispiel: 1. Innere Abfrage um Künstler mit den
--              meisten Alben herauszufinden.
--      	 2. Äußere Abfrage um Namen dieses
--              Künstlers anzeigen zu lassen.

-- Diese Query gibt uns einfach nur eine Zahl (Artist-ID) zurück:
SELECT ArtistId
FROM Album
GROUP BY ArtistId
ORDER BY COUNT() DESC
LIMIT 1;

-- Die Zahl wird in der WHERE-Bedingung genutzt:
SELECT *
FROM Artist
WHERE ArtistId = (SELECT ArtistId
                  FROM Album
                  GROUP BY ArtistId
                  ORDER BY COUNT() DESC
                  LIMIT 1);

-- Was im Hintergrund abläuft:
SELECT ArtistId,
       COUNT() AS anzahl
FROM Album
GROUP BY ArtistId
ORDER BY COUNT() DESC;

-- Beispiel: 1. Welche AlbumId enthält die meisten Tracks?
--      	 2. Gib den Titel und die KünstlerId des Albums aus.

-- 1. Die Subquery
SELECT AlbumId
FROM Track
GROUP BY AlbumId
ORDER BY COUNT() DESC
LIMIT 1;

-- 2. Die Gesamtquery:
SELECT Title,
       ArtistId
FROM Album
WHERE AlbumId = (SELECT AlbumId
                 FROM Track
                 GROUP BY AlbumId
                 ORDER BY COUNT() DESC
                 LIMIT 1);

-- Artistname mit in die Ausgabe kriegen. ;)
SELECT Title,
       Name
FROM Album
         JOIN Artist USING (ArtistId)
WHERE AlbumId = (SELECT AlbumId
                 FROM Track
                 GROUP BY AlbumId
                 ORDER BY COUNT() DESC
                 LIMIT 1);
