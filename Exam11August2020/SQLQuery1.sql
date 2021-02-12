--create database Bakery

USE Bakery

CREATE TABLE Countries
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
[Name] NVARCHAR(50) UNIQUE NOT NULL
)


CREATE TABLE Customers
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
FirstName NVARCHAR(25),
LastName NVARCHAR(25),
Gender CHAR(1)
CHECK(Gender IN ('M','F')),
Age INT,
PhoneNumber VARCHAR(10)
CHECK(LEN(PhoneNumber) = 10),
CountryId INT NOT NULL REFERENCES Countries(Id)
)

CREATE TABLE Products
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
[Name] NVARCHAR(25) UNIQUE NOT NULL,
[Description] NVARCHAR(250),
Recipe NVARCHAR(MAX),
Price DECIMAL(18,2)
CHECK(Price >= 0)
)

CREATE TABLE Feedbacks 
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
[Description] NVARCHAR(255),
Rate DECIMAL(2,2)
CHECK(Rate BETWEEN 0 AND 10),
ProductId INT NOT NULL REFERENCES Products(Id),
CustomerId INT NOT NULL REFERENCES Customers(Id)
)

CREATE TABLE Distributors 
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
Name NVARCHAR(25) UNIQUE NOT NULL,
AddressText NVARCHAR(30),
Summary NVARCHAR(200),
CountryId INT NOT NULL REFERENCES Countries(Id)
)

CREATE TABLE Ingredients 
(
Id INT IDENTITY PRIMARY KEY NOT NULL,
[Name] NVARCHAR(30),
[Description] NVARCHAR(200),
OriginCountryId INT NOT NULL REFERENCES Countries(Id),
DistributorId INT NOT NULL REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients
(
ProductId INT NOT NULL REFERENCES Products(Id),
IngredientId INT  NOT NULL REFERENCES Ingredients(Id)

CONSTRAINT PK_ProductsIngredients PRIMARY KEY (ProductId,IngredientId)
)



--2.	Insert
--Let’s insert some sample data into the database. Write a query to add the following records into the corresponding tables. All Id’s should be auto-generated.

INSERT INTO Distributors (Name,CountryId,AddressText,Summary) VALUES 
('Deloitte & Touche',2,'6 Arch St #9757','Customizable neutral traveling'),
('Congress Title',13,'58 Hancock St','Customer loyalty'),
('Kitchen People',1,'3 E 31st St #77','Triple-buffered stable delivery'),
('General Color Co Inc',21,'6185 Bohn St #72','Focus group'),
('Beck Corporation',23,'21 E 64th Ave','Quality-focused 4th generation hardware')


INSERT INTO Customers (FirstName,LastName,Age,Gender,PhoneNumber,CountryId) VALUES 
('Francoise', 'Rautenstrauch',15,'M','0195698399',5),
('Kendra','Loud',22,'F','0063631526',11),
('Lourdes','Bauswell',50,'M','0139037043',8),
('Hannah','Edmison',18,'F','0043343686',1),
('Tom','Loeza',	31,'M',	'0144876096',23),
('Queenie','Kramarczyk',30,'F','0064215793',29),
('Hiu','Portaro',25,'M','0068277755',16),
('Josefa','Opitz',43,'F','0197887645',17)


--3.	Update
--We’ve decided to switch some of our ingredients to a local distributor. Update the table Ingredients and change the DistributorId of "Bay Leaf", "Paprika" and "Poppy" to 35. Change the OriginCountryId to 14 of all ingredients with OriginCountryId equal to 8.

UPDATE Ingredients
SET DistributorId = 35
WHERE Name IN ('Bay Leaf','Paprika', 'Poppy')

UPDATE Ingredients 
SET OriginCountryId = 14
WHERE OriginCountryId  = 8

--4.	Delete
--Delete all Feedbacks which relate to Customer with Id 14 or to Product with Id 5.

DELETE Feedbacks 
WHERE CustomerId = 14 OR ProductId = 5


--Section 3. Querying 
--You need to start with a fresh dataset, so recreate your DB and import the sample data again.
--For this section put your queries in judge and use: “SQL Server prepare DB and run queries”.
--5.	Products by Price
--Select all products ordered by price (descending) then by name (ascending). 
--Required columns:
--•	Name
--•	Price
--•	Description

SELECT p.Name, p.Price, p.Description
FROM Products p
ORDER BY p.Price DESC, p.Name ASC


--6.	Negative Feedback
--Select all feedbacks alongside with the customers which gave them. Filter only feedbacks which have rate below 5.0. Order results by ProductId (descending) then by Rate (ascending).
--Required columns:
--•	ProductId
--•	Rate
--•	Description
--•	CustomerId
--•	Age
--•	Gender

SELECT f.ProductId, f.Rate, f.Description, f.CustomerId, c.Age, c.Gender
FROM Feedbacks f
JOIN Customers c ON c.Id = f.CustomerId
WHERE Rate < 5.0
ORDER BY ProductId DESC, Rate ASC

--7.	Customers without Feedback
--Select all customers without feedbacks. Order them by customer id (ascending).
--Required columns:
--•	CustomerName – customer’s first and last name, concatenated with space
--•	PhoneNumber
--•	Gender

SELECT c.FirstName + ' ' + c.LastName AS CustomerName, c.PhoneNumber, c.Gender
FROM Customers c
LEFT JOIN Feedbacks f ON f.CustomerId = c.Id
WHERE f.Id IS NULL
ORDER BY c.Id


--8.	Customers by Criteria
--Select customers that are either at least 21 old and contain “an” in their first name or their phone number ends with “38” and are not from Greece. Order by first name (ascending), then by age(descending).
--Required columns:
--•	FirstName
--•	Age
--•	PhoneNumber

SELECT c.FirstName, c.Age, c.PhoneNumber
FROM Customers c
WHERE (c.Age >= 21 AND FirstName = '%an%') 
		OR (c.PhoneNumber = '%38'AND c.CountryId != (SELECT c.Id
         FROM Countries cs
         WHERE cs.Name = 'Greece'))

ORDER BY c.FirstName ASC, Age DESC


--9.	Middle Range Distributors
--Select all distributors which distribute ingredients used in the making process of all products having average rate between 5 and 8 (inclusive). Order by distributor name, ingredient name and product name all ascending.
--Required columns:
--•	DistributorName
--•	IngredientName
--•	ProductName
--•	AverageRate


SELECT DistributorName, IngredientName, ProductName, AVG
FROM (SELECT D.Name AS DistributorName,
       I.Name AS IngredientName,
        P.Name AS ProductName,
        AVG(F.Rate) AS AVG
FROM Distributors AS D
JOIN Ingredients I on D.Id = I.DistributorId
JOIN ProductsIngredients PI on I.Id = PI.IngredientId
JOIN Products P on P.Id = PI.ProductId
JOIN Feedbacks F on P.Id = F.ProductId
GROUP BY D.Name, I.Name, P.Name) AS RANK
WHERE AVG BETWEEN 5.0 AND 8.0
ORDER BY DistributorName, IngredientName,ProductName


--10.	Country Representative
--Select all countries with their most active distributor (the one with the greatest number of ingredients). If there are several distributors with most ingredients delivered, list them all. Order by country name then by distributor name.
--Required columns:
--•	CountryName
--•	DistributorName

SELECT rankQuery.Name, rankQuery.DistributorName
FROM (
SELECT c.Name, d.Name as DistributorName,
       DENSE_RANK() OVER (PARTITION BY c.Name ORDER BY COUNT(i.Id) DESC) as rank
FROM Countries AS c
      join  Distributors D ON c.Id = D.CountryId
     left join Ingredients I ON D.Id = I.DistributorId
GROUP BY  c.Name, d.Name
) AS rankQuery
WHERE rankQuery.rank=1
 ORDER BY rankQuery.Name, rankQuery.DistributorName

-- Section 4. Programmability 
--For this section put your queries in judge and use: “SQL Server run skeleton, run queries and check DB”.
--11.	Customers with Countries
--Create a view named v_UserWithCountries which selects all customers with their countries.
--Required columns:
--•	CustomerName – first name plus last name, with space between them
--•	Age
--•	Gender
--•	CountryName

CREATE VIEW v_UserWithCountries AS
(
SELECT CONCAT(C.FirstName, ' ', c.LastName) AS CustomerName,
             C.Age AS Age,
       C.Gender AS Gender,
       C2.Name AS CountryName
FROM Customers AS C
         join Countries C2 ON C2.Id = C.CountryId)

SELECT TOP 5 *
  FROM v_UserWithCountries
 ORDER BY Age



-- 12.	Delete Products
--Create a trigger that deletes all of the relations of a product upon its deletion. 

 CREATE TABLE DeletedProducts
(
     Id          INT IDENTITY
        PRIMARY KEY,
    Name        NVARCHAR(25)   not null
        UNIQUE,
    Description NVARCHAR(250),
    Recipe      NVARCHAR(max)  not null,
    Price       DECIMAL(15, 2) not null
        CHECK ([Price] >= 0)
)

CREATE TRIGGER dbo.ProductsToDelete
    on Products
    INSTEAD OF DELETE
    AS
BEGIN
    DECLARE
        @deletedProductId INT = (SELECT p.Id
                                 FROM Products AS p
                                          JOIN deleted AS d ON d.Id = p.Id)
    DELETE
    FROM ProductsIngredients
    WHERE ProductId = @deletedProductId
    DELETE
    FROM Feedbacks
    WHERE ProductId = @deletedProductId
    DELETE
    FROM Products
    WHERE Id = @deletedProductId
END

GO