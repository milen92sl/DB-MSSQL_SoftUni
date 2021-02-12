USE TripService

GO

CREATE TABLE Cities
(
Id INT PRIMARY KEY  IDENTITY NOT NULL,
Name NVARCHAR(20) NOT NULL,
CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels
(
Id INT PRIMARY KEY  IDENTITY NOT NULL,
Name NVARCHAR(30) NOT NULL,
CityId INT NOT NULL REFERENCES Cities(Id),
EmployeeCount INT NOT NULL,
BaseRate DECIMAL (18,2)
)

CREATE TABLE Rooms 
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Price DECIMAL(18,2) NOT NULL,
	Type NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT NOT NULL REFERENCES Hotels(Id)
)

CREATE TABLE Trips
(
	Id INT NOT NULL PRIMARY KEY IDENTITY ,
	RoomId  INT NOT NULL REFERENCES Rooms(Id) ,
	BookDate DATE NOT NULL,
	ArrivalDate DATE NOT NULL,
	ReturnDate DATE NOT NULL,
	CancelDate DATE,
	CHECK(BookDate < ArrivalDate),
	CHECK(ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts
(
	Id INT NOT NULL PRIMARY KEY IDENTITY ,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT NOT NULL REFERENCES Cities(Id),
	BirthDate DATE NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips 
(
	AccountId INT NOT NULL REFERENCES Accounts(Id),
	TripId INT NOT NULL REFERENCES Trips(Id),
	Luggage INT NOT NULL,
	PRIMARY KEY (AccountId, TripId),
	CHECK(Luggage >= 0)
)



--2. INSERT
INSERT INTO Accounts(FirstName,MiddleName,LastName, CityId,BirthDate, Email) VALUES
('John','Smith','Smith',34,	'1975-07-21','j_smith@gmail.com'),
('Gosho',NULL,'Petrov',11, '1978-05-16','g_petrov@gmail.com'),
('Ivan','Petrovich','Pavlov',59,'1849-09-26','i_pavlov@softuni.bg'),
('Friedrich','Wilhelm','Nietzsche',2,'1844-10-15','f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId,BookDate,ArrivalDate,ReturnDate,CancelDate) VALUES 
(101,'2015-04-12','2015-04-14','2015-04-20','2015-02-02'),
(102,'2015-07-07','2015-07-15','2015-07-22','2015-04-29'),
(103,'2013-07-17','2013-07-23','2013-07-24',NULL),
(104,'2012-03-17','2012-03-31','2012-04-01','2012-01-10'),
(109,'2017-08-07','2017-08-28','2017-08-29',NULL)

--3. UPDATE
SELECT * FROM Rooms WHERE HotelId IN (5,7,9)

UPDATE Rooms 
SET Price = Price * 1.14
WHERE HotelId IN (5,7,9)


--4. DELETE 
SELECT * FROM AccountsTrips
WHERE AccountId = 47 

DELETE FROM AccountsTrips
WHERE AccountId = 47

--5. EEE-Mails
--Select accounts whose emails start with the letter “e”. Select their first and last name, their birthdate in the format "MM-dd-yyyy", their city name, and their Email.
--Order them by city name (ascending)

SELECT FirstName,LastName,FORMAT(BirthDate,'MM-dd-yyyy'), c.Name AS HomeTown,Email
FROM Accounts AS a 
JOIN Cities AS c ON c.Id = a.CityId
WHERE a.Email LIKE 'e%'
ORDER BY c.Name ASC



--6. City Statistics
--Select all cities with the count of hotels in them. Order them by the hotel count (descending), then by city name. Do not include cities, which have no hotels in them.

SELECT c.Name AS City , COUNT(*)  AS Hotels
FROM Hotels h
JOIN Cities c ON h.CityId = c.Id
GROUP BY c.Name
ORDER BY Hotels DESC, c.Name ASC



--7. Longest and Shortest Trips
--Find the longest and shortest trip for each account, in days. Filter the results to accounts with no middle name and trips, which are not cancelled (CancelDate is null).
--Order the results by Longest Trip days (descending), then by Shortest Trip (ascending).

SELECT AccountId,FirstName + ' ' + LastName AS FullName,
MAX(DATEDIFF(DAY,ArrivalDate,ReturnDate)) AS LongestTrip,
MIN(DATEDIFF(DAY,ArrivalDate,ReturnDate)) AS ShortestTrip
FROM AccountsTrips at
JOIN Accounts a ON at.AccountId = a.Id
JOIN Trips t On at.TripId = t.Id
WHERE MiddleName IS NULL AND CancelDate IS  NULL
GROUP BY AccountId, FirstName, LastName
ORDER BY LongestTrip DESC , ShortestTrip ASC


--8. Metropolis
--Find the top 10 cities, which have the most registered accounts in them. Order them by the count of accounts (descending).

SELECT TOP (10) c.Id ,c.Name,c.CountryCode,COUNT(c.Id) AS Accounts
FROM Cities c
JOIN Accounts a ON a.CityId = c.Id
GROUP BY c.Id,c.Name, c.CountryCode
ORDER BY Accounts DESC



--9. Romantic Getaways
--Find all accounts, which have had one or more trips to a hotel in their hometown.
--Order them by the trips count (descending), then by Account ID.

SELECT AccountId, Email, ac.Name, COUNT(*) AS Trips
FROM AccountsTrips at
JOIN Accounts a ON at.AccountId = a.id
JOIN Cities ac ON a.CityId = ac.Id
JOIN Trips t ON at.TripId = t.Id
JOIN Rooms r ON t.RoomId = r.Id
JOIN Hotels h ON r.HotelId = h.Id
JOIN Cities hc ON h.CityId = hc.Id
WHERE hc.Id = ac.Id
GROUP BY  AccountId, Email, ac.Name
ORDER BY Trips DESC, AccountId ASC



--10. GDPR Violation
--Retrieve the following information about each trip:
--•	Trip ID
--•	Account Full Name
--•	From – Account hometown
--•	To – Hotel city
--•	Duration – the duration between the arrival date and return date in days. If a trip is cancelled, the value is “Canceled”
--Order the results by full name, then by Trip ID.

SELECT TripId AS Id,
FirstName + ' ' + ISNULL(MiddleName + ' ','') + LastName AS FullName,
ac.Name AS [From],
hc.Name AS [To],
CASE 
WHEN  CancelDate IS NULL THEN CONVERT(NVARCHAR,DATEDIFF(DAY, ArrivalDate, ReturnDate)) + ' ' + 'days'
ELSE CONVERT(NVARCHAR(MAX),'Canceled') END
FROM AccountsTrips at
JOIN Accounts a ON at.AccountId = a.Id
JOIN Cities AS ac ON a.CityId = ac.Id
JOIN Trips t ON at.TripId = t.Id
JOIN Rooms r ON t.RoomId = r.Id
JOIN Hotels h ON r.HotelId = h.Id
JOIN Cities hc ON h.CityId = hc.Id
ORDER BY FullName, TripId



--Section 4. Programmability (14 pts)
--11. Available Room
--Create a user defined function, named udf_GetAvailableRoom(@HotelId, @Date, @People), that receives a hotel ID, a desired date, and the count of people that are going to be signing up.
--The total price of the room can be calculated by using this formula:
--•	(HotelBaseRate + RoomPrice) * PeopleCount
--The function should find a suitable room in the provided hotel, based on these conditions:
--•	The room must not be already occupied. A room is occupied if the date the customers want to book is between the arrival and return dates of a trip to that room and the trip is not canceled.
--•	The room must be in the provided hotel.
--•	The room must have enough beds for all the people.
--If any rooms in the desired hotel satisfy the customers’ conditions, find the highest priced room (by total price) of all of them and provide them with that room.
--The function must return a message in the format:
--•	“Room {Room Id}: {Room Type} ({Beds} beds) - ${Total Price}”
--If no room could be found, the function should return “No rooms available”.
GO
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE , @People INT)
RETURNS NVARCHAR(MAX) 
BEGIN
DECLARE @RoomInfo VARCHAR(MAX) = (SELECT TOP(1) 'Room ' + CONVERT(VARCHAR,r.Id) + ': ' +  r.Type + ' (' + CONVERT(VARCHAR,r.Beds) + ' beds) - $' + CONVERT(VARCHAR,(BaseRate + Price) * @People),
(BaseRate+ Price) * @People AS FinalPrice
FROM Rooms r
JOIN Hotels h ON r.HotelId = h.Id
WHERE Beds >= @People AND HotelId = @HotelId AND 
NOT EXISTS (SELECT * FROM Trips t WHERE t.RoomId = r.Id 
	AND CancelDate IS NULL 
	AND @Date BETWEEN ArrivalDate AND ReturnDate)
ORDER BY (BaseRate+ Price) * @People DESC)


IF (@RoomInfo IS NULL)
BEGIN 
RETURN 'No rooms available';
END

RETURN @RoomInfo
END
GO

SELECT dbo.udf_GetAvailableRoom (112,'2011-12-17',2)


--12. Switch Room
--Create a user defined stored procedure, named usp_SwitchRoom(@TripId, @TargetRoomId), that receives a trip and a target room, and attempts to move the trip to the target room. A room will only be switched if all of these conditions are true:
--•	If the target room ID is in a different hotel, than the trip is in, raise an exception with the message “Target room is in another hotel!”.
--•	If the target room doesn’t have enough beds for all the trip’s accounts, raise an exception with the message “Not enough beds in target room!”.
--If all the above conditions pass, change the trip’s room ID to the target room ID.
GO

CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT) 
AS
DECLARE @TripHotelId INT = (SELECT r.HotelId FROM Trips t JOIN Rooms r ON t.RoomId = r.Id WHERE t.Id = @TripId)
DECLARE @TargetRoomHotelId INT = (SELECT HotelId FROM Rooms WHERE Id = @TargetRoomId)
	IF (@TripHotelId != @TargetRoomHotelId)
	 THROW 50001, 'Target room is in another hotel!',1 
DECLARE @TripAccounts  INT = (SELECT COUNT(*) FROM AccountsTrips WHERE TripId = @TripId)
DECLARE @TargetRoomBeds INT = (SELECT Beds FROM Rooms WHERE Id = @TargetRoomId)
	IF (@TripAccounts > @TargetRoomBeds)
	 THROW 50002, 'Not enough beds in target room!',1
UPDATE Trips SET RoomId = @TargetRoomId WHERE Id = @TripId

GO

EXEC usp_SwitchRoom 10, 11 
SELECT RoomId FROM Trips WHERE Id =10
EXEC usp_SwitchRoom 10,7
