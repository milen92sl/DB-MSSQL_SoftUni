--1.	Database Design
--Submit all of yours create statements to the Judge system.


--CREATE DATABASE ColonialJourney
CREATE TABLE Planets
(
	Id INT IDENTITY NOT NULL PRIMARY KEY,
	Name VARCHAR(30) NOT NULL
)
 
CREATE TABLE Spaceports
(
	Id INT IDENTITY NOT NULL PRIMARY KEY,
	Name VARCHAR(50) NOT NULL,
	PlanetId INT NOT NULL REFERENCES Planets(Id)
)
 
CREATE TABLE Spaceships
(
	Id INT IDENTITY NOT NULL PRIMARY KEY,
	Name VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)
 
CREATE TABLE Colonists
(
	Id INT IDENTITY NOT NULL PRIMARY KEY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) NOT NULL UNIQUE,
	BirthDate DATE NOT NULL
)
 
CREATE TABLE Journeys
(
	Id INT IDENTITY NOT NULL PRIMARY KEY,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) NULL CHECK(Purpose IN ('Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId INT NOT NULL REFERENCES Spaceports(Id),
	SpaceshipId INT NOT NULL REFERENCES Spaceships(Id)
)
 
CREATE TABLE TravelCards
(
	Id INT IDENTITY NOT NULL PRIMARY KEY,
	CardNumber VARCHAR(10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) NULL CHECK (JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	ColonistId INT NOT NULL REFERENCES Colonists(Id),
	JourneyId INT NOT NULL REFERENCES Journeys(Id),
)

--DML
--Before you start, you must import “DataSet-ColonialJourney.sql”. If you have created the structure correctly, the data should be successfully inserted without any errors.
--In this section, you have to do some data manipulations:
--2.	Insert
--Insert sample data into the database. Write a query to add the following records into the corresponding tables. All Ids should be auto-generated.
INSERT INTO Planets VALUES 
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships VALUES 
('Golf','VW',3),
('WakaWaka','Wakanda',4 ),
('Falcon9','SpaceX',1 ),
('Bed','Vidolov',6)


--3.	Update
--Update all spaceships light speed rate with 1 where the Id is between 8 and 12.

UPDATE Spaceships 
SET LightSpeedRate = LightSpeedRate + 1 
WHERE Id BETWEEN 8 AND 12

--4.	Delete
--Delete first three inserted Journeys (be careful with the relationships).

DELETE TravelCards
WHERE JourneyId between 1 and 3

DELETE Journeys
WHERE Id between 1 and 3


--5.	Select all military journeys
--Extract from the database, all Military journeys in the format "dd-MM-yyyy". Sort the results ascending by journey start.
--Required Columns
--•	Id
--•	JourneyStart
--•	JourneyEnd

SELECT Id, FORMAT(JourneyStart, 'dd/MM/yyyy'), FORMAT(JourneyEnd, 'dd/MM/yyyy')
FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart

--6.	Select all pilots
--Extract from the database all colonists, which have a pilot job. Sort the result by id, ascending.

SELECT c.Id, FirstName+ ' ' + LastName AS full_name
FROM TravelCards tc
JOIN Colonists AS c ON tc.ColonistId = c.Id
WHERE JobDuringJourney = 'Pilot'
ORDER BY c.Id ASC


--7.	Count colonists
--Count all colonists that are on technical journey. 

SELECT COUNT(*) AS [count]
FROM Colonists AS C
JOIN TravelCards TC on C.Id = TC.ColonistId
JOIN Journeys J on J.Id = TC.JourneyId
WHERE J.Purpose='Technical'


--8.	Select spaceships with pilots younger than 30 years
--Extract from the database those spaceships, which have pilots, younger than 30 years old. In other words, 30 years from 01/01/2019. Sort the results alphabetically by spaceship name.
--Required Columns
--•	Name
--•	Manufacturer

SELECT S.Name, S.Manufacturer
FROM Spaceships AS S
JOIN Journeys J on S.Id = J.SpaceshipId
JOIN TravelCards TC on J.Id = TC.JourneyId AND TC.JobDuringJourney = 'Pilot'
JOIN Colonists C on C.Id = TC.ColonistId AND DATEDIFF(YEAR,C.BirthDate, '01/01/2019')<30
ORDER BY S.Name


--9.	Select all planets and their journey count
--Extract from the database all planets’ names and their journeys count. Order the results by journeys count, descending and by planet name ascending.
--Required Columns
--•	PlanetName
--•	JourneysCount

SELECT p.Name, COUNT(j.Id) AS JourneysCount
FROM Planets p
JOIN Spaceports sp ON p.Id = sp.PlanetId
JOIN Journeys j ON sp.Id = j.DestinationSpaceportId
GROUP BY p.Name
Order by JourneysCount DESC, p.Name



--10.	Select Second Oldest Important Colonist
--Find all colonists and their job during journey with rank 2. Keep in mind that all the selected colonists with rank 2 must be the oldest ones. You can use ranking over their job during their journey.
--Required Columns
--•	JobDuringJourney
--•	FullName
--•	JobRank

SELECT JobDuringJourney,FULLNAME, RANKQUERY.RANK
     FROM (SELECT TC.JobDuringJourney AS JobDuringJourney,
       C.FirstName+' '+C.LastName AS FULLNAME,
      ( DENSE_RANK() over (PARTITION BY TC.JobDuringJourney ORDER BY C.BirthDate)) AS RANK
FROM Colonists AS C
JOIN TravelCards TC on C.Id = TC.ColonistId) AS RANKQUERY
WHERE RANK=2



--11.	Get Colonists Count
--Create a user defined function with the name dbo.udf_GetColonistsCount(PlanetName VARCHAR (30)) that receives planet name and returns the count of all colonists sent to that planet.

CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS VARCHAR(30)
BEGIN 

DECLARE @CountInfo VARCHAR(30) = (SELECT COUNT(p.Name)
FROM TravelCards t 
JOIN Journeys j ON t.JourneyId = j.Id
JOIN Spaceports sp ON sp.Id = j.DestinationSpaceportId
JOIN Planets p ON p.Id = sp.PlanetId
WHERE p.Name = @PlanetName) 

RETURN @CountInfo
END

SELECT dbo.udf_GetColonistsCount('Otroyphus')



--12.	Change Journey Purpose
--Create a user defined stored procedure, named usp_ChangeJourneyPurpose(@JourneyId, @NewPurpose), that receives an journey id and purpose, and attempts to change the purpose of that journey. An purpose will only be changed if all of these conditions pass:
--•	If the journey id doesn’t exists, then it cannot be changed. Raise an error with the message “The journey does not exist!”
--•	If the journey has already that purpose, raise an error with the message “You cannot change the purpose!”
--If all the above conditions pass, change the purpose of that journey.
CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT,
                                          @NewPurpose VARCHAR(11))
AS
BEGIN
    IF (@JourneyId NOT IN (SELECT Id
                           FROM Journeys))
        THROW 50001, 'The journey does not exist!',1
    IF ((SELECT COUNT(*)
         FROM Journeys
         WHERE Id = @JourneyId
           AND Purpose = @NewPurpose) != 0)
        THROW 50002,'You cannot change the purpose!',1

    UPDATE Journeys
    SET Purpose=@NewPurpose
    WHERE Id = @JourneyId

END

EXEC usp_ChangeJourneyPurpose 196, 'Technical'