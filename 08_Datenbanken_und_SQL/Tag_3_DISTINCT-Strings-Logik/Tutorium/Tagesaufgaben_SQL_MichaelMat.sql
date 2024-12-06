-- 1.

-- a.) Verbindung hergestellt!

-- b.)
SELECT DISTINCT country
FROM circuits;

-- c.)
SELECT forename || ',' || surname
AS completename
FROM drivers;

-- d.)
SELECT name, year
FROM races
WHERE year = 2015;

-- e.)
SELECT *
FROM results
WHERE (driverId = 3 AND position = '');

-- f.)
SELECT *
FROM drivers
WHERE (nationality = 'German' AND code != '');


-- 2.

-- a.)
SELECT name AS TrackName,
       LENGTH(name) AS LetterCount
FROM circuits
ORDER BY LetterCount DESC
LIMIT 2;

-- b.)
SELECT forename || ' ' || surname
    AS CompleteName,
LENGTH
(forename || ' ' || surname)
    AS NameLength
FROM drivers
ORDER BY NameLength DESC
LIMIT 1;

-- c.)
SELECT UPPER(SUBSTR(surname,1, 3))
AS DriversCode
FROM drivers;

-- d.)
SELECT *
FROM drivers
WHERE surname GLOB '[A-F]*';