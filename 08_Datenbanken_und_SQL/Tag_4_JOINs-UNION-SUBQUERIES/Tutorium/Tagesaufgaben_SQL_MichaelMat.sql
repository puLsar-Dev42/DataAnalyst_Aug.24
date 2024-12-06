-- 1.

-- a.)
-- Erstelle eine Abfrage, die raceID, driverRef, positionText und points aller deutschen Fahrer ausgibt.
-- Verbinde dazu die Tabellen driver und results.

SELECT dr.driverRef AS DriverRef,
       re.raceId AS RaceID,
       re.positionText AS PositionText,
       re.points AS Points
FROM drivers AS dr
JOIN results AS re
ON dr.driverId = re.driverId
WHERE nationality = 'German';


-- b)
-- Gib Renndatum, Streckenname, PositionText, Punkte und driverRef
-- aller Rennen aus 2015 aus, bei denen die Fahrer mindestens 8 Punkte gemacht haben.
-- Sortiere nach Renndatum und Punkten

SELECT dr.driverRef AS DriverRef,
       re.positionText AS PositionText,
       re.points AS Points,
       ra.date AS RaceDate,
       ra.name AS CircuitName
FROM results AS re
JOIN races AS ra
    ON re.raceId = ra.raceId
JOIN circuits AS ci
ON ra.circuitId = ci.circuitId
JOIN drivers AS dr
ON re.driverId = dr.driverId
WHERE ra.year = 2015
AND re.points >= 8
ORDER BY ra.date ASC,
         re.points DESC;



-- c)
-- Welcher Fahrer hat im 3. Rennen (Feld round) des Jahres 2015 den ersten Platz gemacht?

SELECT dr.forename || ' ' || dr.surname AS DriverName,
       ra.year AS Year,
       ra.round AS Round,
       re.position AS Position
FROM races AS ra
JOIN results AS re
ON ra.raceId = re.raceId
JOIN drivers AS dr
ON re.driverId = dr.driverId
WHERE ra.year = 2015
AND ra.round = 3
AND re.position = 1;



-- d)
-- Welcher Fahrer hatte im 4. Rennen 2015 die schnellste Rundenzeit?

SELECT dr.forename || ' ' || dr.surname AS DriverName,
       ra.year AS Year,
       ra.round AS Round,
       re.fastestLapTime AS FastestLapTime
FROM races AS ra
JOIN results AS re
ON ra.raceId = re.raceId
JOIN drivers AS dr
ON re.driverId = dr.driverId
WHERE ra.year = 2015
AND ra.round = 4
AND re.fastestLapTime != ''
ORDER BY re.fastestLapTime ASC
LIMIT 1;