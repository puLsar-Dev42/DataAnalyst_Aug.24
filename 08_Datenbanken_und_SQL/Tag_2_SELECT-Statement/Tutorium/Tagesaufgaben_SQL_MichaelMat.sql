
SELECT *
FROM Customer;

SELECT *
FROM Customer
LIMIT 15;

SELECT Firstname AS Vorname,
       Lastname AS Nachname,
       Country AS Land
FROM Customer;

SELECT DISTINCT Country
FROM Customer
ORDER BY Country ASC;

SELECT Firstname AS Vorname,
       Lastname AS Nachname,
       City AS Stadt
FROM Customer
WHERE Country LIKE 'Germany';

/*
SELECT Firstname AS Vorname,
       Lastname AS Nachname,
       Email AS Emailaddresse
FROM Customer
WHERE (country = 'USA'
           or country = 'United Kingdom')
AND LastName != 'Stevens';
*/

SELECT Firstname AS Vorname,
       Email AS Emailaddresse
FROM Customer
WHERE (country = 'USA'
           or country = 'United Kingdom')
AND Lastname != 'Stevens';

SELECT Name
FROM Genre
WHERE Name LIKE 'R%'
AND Name NOT LIKE '%ck';

SELECT Name
FROM Genre
WHERE Name NOT LIKE '%Rock%'
ORDER BY Name DESC;
