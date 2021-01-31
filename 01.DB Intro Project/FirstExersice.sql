CREATE DATABASE Hotel

USE Hotel

--ï	Employees (Id, FirstName, LastName, Title, Notes)
CREATE TABLE Employees 
(
Id INT PRIMARY KEY, 
FirstName VARCHAR(90),
LastName VARCHAR(90),
Title VARCHAR(50),
Notes VARCHAR(MAX)
)

INSERT INTO Employees (Id, FirstName, LastName, Title, Notes) VALUES 
(1,'Gosho', 'Goshev', 'CEO', NULL),
(2,'Petar', 'Petrov', 'CEO', 'random note'),
(3,'Petrov', 'Goshev', 'CTO', NULL)

--ï	Customers (AccountNumber, FirstName, LastName, PhoneNumber, EmergencyName, EmergencyNumber, Notes)
CREATE TABLE Customers 
(
AcountNumber INT PRIMARY KEY,
FirstName VARCHAR(90)  NOT NULL, 
LastName VARCHAR(90)  NOT NULL,
PhoneNumber CHAR(10) NOT NULL,
EmergencyName VARCHAR(90)  NOT NULL,
EmergencyNumber CHAR(10) NOT NULL,
Notes VARCHAR(MAX)
)

INSERT INTO Customers VALUES 
(120,'G', 'P', '1234567890', 'T','1234567890', NULL),
(121,'F', 'C', '1234567890', 'T','1234567890', NULL),
(122,'T', 'K', '1234567890', 'T','1234567890', NULL)


CREATE TABLE RoomStatus 
(
RoomStatus VARCHAR(20) NOT NULL,
Notes VARCHAR(MAX)
)

INSERT INTO RoomStatus VALUES
('Cleaning', NULL),
('Free',NULL),
('NotFree',NULL)

CREATE TABLE RoomTypes 
(
RoomStatus VARCHAR(20),
Notes VARCHAR(MAX)
)
INSERT INTO RoomTypes VALUES
('Apartment', NULL),
('One Bedroom',NULL),
('Studio',NULL)


CREATE TABLE BedTypes 
(
BedType VARCHAR(20) NOT NULL,
Notes VARCHAR(MAX)
)
INSERT INTO BedTypes VALUES
('Single', NULL),
('Double',NULL),
('Child Bed', NULL)



--ï	Rooms (RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes)
CREATE TABLE Rooms
(
RoomNumber INT PRIMARY KEY ,
RoomType VARCHAR(20) NOT NULL,
BedType VARCHAR(20) NOT NULL,
Rate INT, 
RoomStatus VARCHAR(20) NOT NULL, 
Notes VARCHAR(MAX)
)

INSERT INTO Rooms VALUES 
(120, 'Apartment','Single', 10, 'Free', NULL),
(121, 'Studio','Double', 15, 'Not Free', NULL),
(122, 'Apartment','Child Bed', 18, 'Free', NULL)

--ï	Payments (Id, EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, TotalDays, AmountCharged, TaxRate, TaxAmount, PaymentTotal, Notes)
CREATE TABLE Payments
(
Id INT PRIMARY KEY ,
EmployeeId INT NOT NULL,
PaymentDate DATETIME NOT NULL,
AccountNumber INT NOT NULL, 
FirstDateOccupied DATETIME NOT NULL, 
LastDateOccupied DATETIME NOT NULL, 
TotalDays INT NOT NULL, 
AmountCharged DECIMAL(15,2) NOT NULL,
TaxRate INT, 
TaxAmount INT,
PaymentTotal DECIMAL (15,2), 
Notes VARCHAR(MAX)
)
INSERT INTO Payments VALUES 
(1,1,GETDATE(),120,'5/5/2012', '5/8/2012',3,450.23, NULL, NULL, 450.23,NULL),
(2,1,GETDATE(),120,'2/5/2012', '5/8/2012',3,44.23, NULL, NULL, 450.23,NULL),
(3,1,GETDATE(),120,'1/7/2012', '5/8/2012',3,214.23, NULL, NULL, 44.23,NULL)


--ï	Occupancies (Id, EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge, Notes)
CREATE TABLE Occupancies 
(
Id INT PRIMARY KEY ,
EmployeeId INT NOT NULL,
DateOccupied DATETIME NOT NULL,
AccountNumber INT NOT NULL, 
RoomNumber INT NOT NULL, 
RateApplied INT , 
PhoneCharge DECIMAL(15,2),
Notes VARCHAR(MAX)
)
INSERT INTO Occupancies VALUES 
(1,120,GETDATE(),120,120,0,0,NULL),
(2,432,GETDATE(),123,122,0,0,NULL),
(3,231,GETDATE(),13,54,0,0,NULL)



CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories 
(
Id INT PRIMARY KEY NOT NULL,
CategoryName VARCHAR(90) NOT NULL,
DailyRate INT, 
WeeklyRate INT,
MonthlyRate INT,
WeekendRate INT
)

INSERT INTO Categories VALUES 
(1,'Sport', 10, 8, 7, 6),
(2,'Travelling', 2, 3, 1, 4),
(3,'OffRoad', 4, 4, 5, 6)

CREATE TABLE Cars 
(
Id INT PRIMARY KEY NOT NULL,
PlateNumber VARCHAR(20) NOT NULL,
Manufacturer VARCHAR(20) NOT NULL, 
Model VARCHAR(20) NOT NULL,
CarYear VARCHAR(20) NOT NULL,
CategoryId INT NOT NULL,
Doors SMALLINT NOT NULL,
Picture VARCHAR(MAX),
Condition VARCHAR(20),
Available BIT NOT NULL,
)
INSERT INTO Cars VALUES 
(1,'CÕ0553¿¿','AUDI','A6','2006',1,4,'LINK-sdasdasd','diesel',0),
(2,'CÕ0563¿¿','BMW','M3','2008',1,4,'LINK-sdasdasd','benzin',0),
(3,'CÕ0253¿¿','Mercedes','CLS','2009',1,4,'LINK-sdasdasd','diesel',0)
CREATE TABLE Employees 
(
Id INT PRIMARY KEY NOT NULL, 
FirstName VARCHAR(90) NOT NULL,
LastName VARCHAR(90) NOT NULL,
Title VARCHAR(50) NOT NULL,
Notes VARCHAR(MAX)
)

INSERT INTO Employees (Id, FirstName, LastName, Title, Notes) VALUES 
(1,'Gosho', 'Goshev', 'CEO', NULL),
(2,'Petar', 'Petrov', 'CEO', 'random note'),
(3,'Petrov', 'Goshev', 'CTO', NULL)


CREATE TABLE Customers 
(
Id INT PRIMARY KEY NOT NULL, 
DriverLicenceNumber VARCHAR(90) NOT NULL,
FullName VARCHAR(120) NOT NULL,
Adress VARCHAR(300) NOT NULL,
City VARCHAR(30) NOT NULL,
ZIPCode INT,
Notes VARCHAR(MAX)
)

INSERT INTO Customers VALUES
(1,'4231353','Milen Ivanov','Sliven, Druzhba 21','Sliven',8800,'asdasda'),
(2,'4324311','Gosho Ivanov','Sliven, Druzhba 3','Sliven',8800,'asdasda'),
(3,'563454131','Ivan Ivanov','Sliven, Druzhba 23','Sliven',8800,'asdasda')

CREATE TABLE RentalOrders 
(
Id INT PRIMARY KEY NOT NULL,
EmployeeId INT NOT NULL,
CustomerId INT NOT NULL,
CarId INT NOT NULL,
TankLevel VARCHAR(20),
KilometrageStart INT NOT NULL,
KilometrageEnd INT NOT NULL,
TotalKilometrage INT NOT NULL,
StartDate DATETIME NOT NULL,
EndDate DATETIME NOT NULL,
TotalDays INT NOT NULL,
RateApplied INT,
TaxRate INT,
OrderStatus VARCHAR(20) NOT NULL,
Notes VARCHAR(MAX)
)

INSERT INTO RentalOrders VALUES 
(1,1,3,5,'Half', 100, 150, 50, GETDATE(),GETDATE(),5,5,NULL,'Good', NULL),
(2,2,4,6,'Full', 100, 150, 50, GETDATE(),GETDATE(),5,5,NULL,'Good', NULL),
(3,5,6,7,'Empty', 100, 150, 50, GETDATE(),GETDATE(),5,5,NULL,'Good', NULL)

SELECT Name FROM Towns
ORDER BY Name
SELECT Name FROM Departments 
ORDER BY Name
SELECT FirstName,LastName, JobTitle, Salary 
FROM Employees 
ORDER BY Salary DESC

USE Hotel
DELETE FROM Occupancies
