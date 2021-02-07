
USE WMS
--1.	Database design
--Submit all of your create statements to Judge. Do not include database creation statements.
--Look for hints in the details of your submission!

CREATE TABLE Clients 
(
ClientId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Phone CHAR(12) CHECK(LEN(Phone) = 12) NOT NULL
)

CREATE TABLE Mechanics 
(
MechanicId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL ,
Address VARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
ModelId INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs 
(
JobId INT PRIMARY KEY IDENTITY,
ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
Status VARCHAR(11) DEFAULT 'Pending' 
   CHECK(Status IN ('Pending', 'In Progress', 'Finished')) NOT NULL,
ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
IssueDate DATE NOT NULL,
FinishDate DATE
)

CREATE TABLE Orders 
(
OrderId INT PRIMARY KEY IDENTITY,
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
IssueDate DATE,
Delivered BIT DEFAULT 0
)

CREATE TABLE Vendors
(
VendorId INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts
(
PartId INT PRIMARY KEY IDENTITY,
SerialNumber VARCHAR(50) UNIQUE NOT NULL,
Description VARCHAR(255),
Price DECIMAL(15,2) CHECK (Price > 0 AND Price <= 9999.99) NOT NULL ,
VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
StockQty INT DEFAULT 0 CHECK (StockQty >= 0)
)

CREATE TABLE OrderParts
(
OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
Quantity INT DEFAULT 1 CHECK(Quantity > 0)

CONSTRAINT PK_OrdersParts PRIMARY KEY (OrderId,PartId)
)

CREATE TABLE PartsNeeded
(
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
Quantity INT DEFAULT 1 CHECK(Quantity > 0)

CONSTRAINT PK_JobsParts PRIMARY KEY (JobId, PartId)
)
-- 30 POINTS FOR CORRECT DATABASE DIAGRAM


--Section 2. DML
--Before you start you have to import Data.sql. If you have created the structure correctly the data should be successfully inserted.
--In this section, you have to do some data manipulations:
--2.	Insert
--Let’s insert some sample data into the database. Write a query to add the following records into the corresponding tables. All Id’s should be auto-generated. Replace names that relate to other tables with the appropriate ID (look them up manually, there is no need to perform table joins).

INSERT INTO Clients (FirstName,LastName,Phone) VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie', 'Knipp', '805-690-1682'),
('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts (SerialNumber,Description,Price,VendorId) VALUES 
('WP8182119' ,'Door Boot Seal' , 117.86, 2),
('W10780048' ,'Suspension Rod' , 42.81, 1),
('W10841140' ,'Silicone Adhesive ' , 6.77, 4),
('WPY055980' ,'High Temperature Adhesive' , 13.94, 3)
-- +2 POINTS


--3.	Update
--Assign all Pending jobs to the mechanic Ryan Harnos (look up his ID manually, there is no need to use table joins) and change their status to 'In Progress'.

UPDATE Jobs
SET MechanicId = 3, Status = 'In Progress'
WHERE Status = 'Pending'
-- +4 POINTS


--4.	Delete
--Cancel Order with ID 19 – delete the order from the database and all associated entries from the mapping table.

DELETE  FROM OrderParts WHERE OrderId = 19
DELETE FROM Orders WHERE OrderId = 19
-- +4 POINTS


--Section 3. Querying 
--You need to start with a fresh dataset, so run the Data.sql script again. It includes a section that will delete all records and replace them with the starting set, so you don’t need to drop your database.
--5.	Mechanic Assignments
--Select all mechanics with their jobs. Include job status and issue date. Order by mechanic Id, issue date, job Id (all ascending).
--Required columns:
--•	Mechanic Full Name
--•	Job Status
--•	Job Issue Date

SELECT FirstName + ' ' + LastName AS Mechanic, Status, IssueDate
FROM Mechanics AS m
JOIN Jobs AS j ON j.MechanicId = m.MechanicId
ORDER BY m.MechanicId ASC, j.IssueDate ASC, j.JobId ASC
-- +3 POINTS


--6.	Current Clients
--Select the names of all clients with active jobs (not Finished). Include the status of the job and how many days it’s been since it was submitted. Assume the current date is 24 April 2017. Order results by time length (descending) and by client ID (ascending).
--Required columns:
--•	Client Full Name
--•	Days going – how many days have passed since the issuing
--•	Status

SELECT c.FirstName + ' ' + c.LastName AS Client,
		DATEDIFF(DAY, j.IssueDate, '04/24/2017') AS TimeLength,
		j.Status
	FROM Jobs AS j
	JOIN Clients AS c ON c.ClientId = j.ClientId
	WHERE j.Status <> 'Finished'
	ORDER BY TimeLength DESC, j.ClientId ASC
-- +5 POINTS 


--7.	Mechanic Performance
--Select all mechanics and the average time they take to finish their assigned jobs. Calculate the average as an integer. Order results by mechanic ID (ascending).
--Required columns:
--•	Mechanic Full Name
--•	Average Days – average number of days the machanic took to finish the job

SELECT (m.FirstName + ' ' + m.LastName) AS Mechanic,
AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
	FROM Mechanics AS m
	JOIN Jobs As j ON j.MechanicId = m.MechanicId
    GROUP BY j.MechanicId,(m.FirstName + ' ' + m.LastName)
	ORDER BY j.MechanicId 
-- +6 POINTS


--8.	Available Mechanics
--Select all mechanics without active jobs (include mechanics which don’t have any job assigned or all of their jobs are finished). Order by ID (ascending).
--Required columns:
--•	Mechanic Full Name

SELECT m.FirstName + ' ' + m.LastName
FROM Mechanics AS m
LEFT JOIN Jobs AS j ON j.MechanicId = m.MechanicId
WHERE j.JobId IS NULL OR (SELECT COUNT(JobId)
		FROM Jobs
		WHERE Status <> 'Finished' AND MechanicId = m.MechanicId
 GROUP BY MechanicId, Status) IS NULL
GROUP BY m.MechanicId ,(m.FirstName + ' ' + m.LastName)
-- +7 POINTS


--9.	Past Expenses
--Select all finished jobs and the total cost of all parts that were ordered for them. Sort by total cost of parts ordered (descending) and by job ID (ascending).
--Required columns:
--•	Job ID
--•	Total Parts Cost

SELECT j.JobId, ISNULL(SUM(p.Price * op.Quantity),0) AS TotalCost
 FROM Jobs AS j
LEFT JOIN Orders AS o ON o.JobId = j.JobId
LEFT JOIN OrderParts AS op ON op.OrderId = o.OrderId
LEFT JOIN Parts AS p ON p.PartId = op.PartId
  WHERE Status = 'Finished'
 GROUP BY j.JobId
ORDER BY TotalCost DESC, j.JobId ASC
-- +7 POINTS



--10.	Missing Parts
--List all parts that are needed for active jobs (not Finished) without sufficient quantity in stock and in pending orders (the sum of parts in stock and parts ordered is less than the required quantity). Order them by part ID (ascending).
--Required columns:
--•	Part ID
--•	Description
--•	Required – number of parts required for active jobs
--•	In Stock – how many of the part are currently in stock
--•	Ordered – how many of the parts are expected to be delivered (associated with order that is not Delivered)

SELECT 
	p.PartId,
	p.Description,
	pn.Quantity AS [Required],
	p.StockQty AS [InStock],
	IIF(o.Delivered = 0, op.Quantity, 0) AS Ordered
FROM Parts AS p
	LEFT JOIN PartsNeeded AS pn ON pn.PartId = p.PartId 
	LEFT JOIN OrderParts AS op ON op.PartId = p.PartId
	LEFT JOIN Jobs AS j ON j.JobId = pn.JobId
	LEFT JOIN Orders AS o ON o.JobId = j.JobId
WHERE j.Status != 'Finished' AND p.StockQty + 
IIF(o.Delivered = 0, op.Quantity, 0) < pn.Quantity
ORDER BY PartId

-- +12 POINTS


--Section 4. Programmability
--11.	Place Order
--Your task is to create a user defined procedure (usp_PlaceOrder) which accepts job ID, part serial number and   quantity and creates an order with the specified parameters. If an order already exists for the given job that and the order is not issued (order’s issue date is NULL), add the new product to it. If the part is already listed in the order, add the quantity to the existing one.
--When a new order is created, set it’s IssueDate to NULL.
--Limitations:
--•	An order cannot be placed for a job that is Finished; error message ID 50011 "This job is not active!"
--•	The quantity cannot be zero or negative; error message ID 50012 "Part quantity must be more than zero!"
--•	The job with given ID must exist in the database; error message ID 50013 "Job not found!"
--•	The part with given serial number must exist in the database ID 50014 "Part not found!"
--If any of the requirements aren’t met, rollback any changes to the database you’ve made and throw an exception with the appropriate message and state 1. 
--Parameters:
--•	JobId
--•	Part Serial Number
--•	Quantity

CREATE PROCEDURE usp_PlaceOrder 
(
@jobId INT, 
@serialNumber VARCHAR(50),
@qty INT
)
AS

DECLARE @status VARCHAR(10) = (SELECT Status FROM Jobs WHERE
JobId = @jobId)

DECLARE @partId VARCHAR(10) = (SELECT PartId FROM Parts WHERE
SerialNumber = @serialNumber)

IF (@qty <= 0)
THROW 50012, 'Part quantity must be more than zero!', 1 
ELSE IF (@status IS NULL)
THROW 50013, 'Job not found!',1
ELSE IF(@status = 'Finished')
THROW 50011, 'This job is not active!', 1
ELSE IF (@partId IS NULL)
THROW 50014, 'Part not found!',1

DECLARE @orderId INT  = (SELECT o.OrderId 
							FROM Orders As o
						 WHERE JobId = @jobId AND o.IssueDate IS NULL)

IF(@orderId IS NULL )
BEGIN
     INSERT INTO Orders(JobId, IssueDate) VALUES
     (@jobId, NULL)
END

 SET @orderId = 
	 (SELECT o.OrderId FROM Orders AS o 
	 WHERE JobId = @jobId AND o.IssueDate IS NULL)
     
DECLARE @orderPartExists INT = (SELECT OrderId FROM OrderParts
WHERE OrderId = @orderId 
AND PartId = @partId)

IF(@orderPartExists IS NULL)
	 BEGIN 
	 INSERT INTO OrderParts (OrderId,PartId,Quantity) VALUES 
     (@orderId,@partId,@qty)
END
ELSE 
BEGIN 
  UPDATE OrderParts 
  SET Quantity += @qty
  WHERE OrderId = @orderId 
END

-- CHECK QUERY ===>

--DECLARE @err_msg AS NVARCHAR(MAX);
--BEGIN TRY
--  EXEC usp_PlaceOrder 1, 'ZeroQuantity', 0
--END TRY

--BEGIN CATCH
--  SET @err_msg = ERROR_MESSAGE();
--  SELECT @err_msg
--END CATCH

 -- + 10 POINTS 



-- 12.	Cost Of Order
--Create a user defined function (udf_GetCost) that receives a job’s ID and returns the total cost of all parts that were ordered for it. Return 0 if there are no orders.
--Parameters:
--•	JobId
--Example usage:

 CREATE FUNCTION udf_GetCost(@jobId INT)
 RETURNS DECIMAL(15,2)
 AS 
 BEGIN
 DECLARE @result DECIMAL(15,2)
 SET @result = (SELECT SUM(p.Price * op.Quantity) AS totalSum 
 FROM Jobs AS j
 JOIN Orders AS o ON o.JobId = j.JobId
 JOIN OrderParts AS op ON op.OrderId = o.OrderId
 JOIN Parts AS p ON p.PartId = op.PartId
 WHERE j.JobId = @jobId
 GROUP BY j.JobId)
 IF(@result IS NULL)
 SET @result = 0;
 RETURN @result
 END

 SELECT dbo.udf_GetCost(1)

 -- +10 POINTS