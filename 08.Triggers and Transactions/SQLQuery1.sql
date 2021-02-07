--1.Create Table Logs
--Create a table – Logs (LogId, AccountId, OldSum, NewSum). Add a trigger to the Accounts table that enters a new entry into the Logs table every time the sum on an account changes. Submit only the query that creates the trigger.

CREATE TABLE Logs 
(
LogId INT PRIMARY KEY IDENTITY,
AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
OldSum DECIMAL(15,2),
NewSum DECIMAL(15,2)
)

CREATE TRIGGER tr_InsertAccountInfo 
ON Accounts FOR UPDATE
AS 
DECLARE @newSum DECIMAL(15,2) = (SELECT Balance From inserted)
DECLARE @oldSum DECIMAL(15,2) = (SELECT Balance From deleted)
DECLARE @accountId  INT = (SELECT Id FROM inserted)

INSERT INTO Logs(AccountId, NewSum, OldSum) VALUES 
(@accountId, @newSum, @oldSum)

UPDATE Accounts 
SET Balance += 10 
WHERE Id = 1

SELECT * FROM Logs

--2.	Create Table Emails
--Create another table – NotificationEmails(Id, Recipient, Subject, Body). Add a trigger to logs table and create new email whenever new record is inserted in logs table. The following data is required to be filled for each email:
--•	Recipient – AccountId
--•	Subject – "Balance change for account: {AccountId}"
--•	Body - "On {date} your balance was changed from {old} to {new}."
--Submit your query only for the trigger action.

CREATE TABLE NotificationEmails 
(
Id INT PRIMARY KEY IDENTITY ,
Recipient INT FOREIGN KEY REFERENCES Accounts(Id),
Subject VARCHAR(50),
Body VARCHAR(MAX)
)

CREATE TRIGGER tr_LogEmail ON Logs FOR INSERT 
AS 
DECLARE @accountId INT = (SELECT TOP(1) AccountId FROM inserted)
DECLARE @oldSum DECIMAL(15,2) = (SELECT TOP(1) OldSum FROM inserted)
DECLARE @newSum DECIMAL(15,2) = (SELECT TOP(1) NewSum FROM inserted)

INSERT INTO NotificationEmails (Recipient,Subject, Body) VALUES
(
@accountId,
'Balance change for account: ' + CAST(@accountId AS varchar(20)),
'On ' + CONVERT(varchar(30),GETDATE(),103) + ' your balance was changed from '
+ CAST(@oldSum AS varchar(20)) + ' to ' + CAST(@newSum AS varchar(20)))

UPDATE Accounts
SET Balance += 100 
WHERE Id = 1;

SELECT * FROM Accounts WHERE Id = 1;

--3.	Deposit Money
--Add stored procedure usp_DepositMoney (AccountId, MoneyAmount) that deposits money to an existing account. Make sure to guarantee valid positive MoneyAmount with precision up to fourth sign after decimal point. The procedure should produce exact results working with the specified precision.

CREATE PROCEDURE usp_DepositMoney
(
                 @accountId   INT,
                 @moneyAmount MONEY
)
AS
     BEGIN
         IF(@moneyAmount < 0)
             BEGIN
                 RAISERROR('Cannot deposit negative value', 16, 1);
         END;
             ELSE
             BEGIN
                 IF(@accountId IS NULL
                    OR @moneyAmount IS NULL)
                     BEGIN
                         RAISERROR('Missing value', 16, 1);
                 END;
         END;
         BEGIN TRANSACTION;
         UPDATE Accounts
           SET
               Balance+=@moneyAmount
         WHERE Id = @accountId;
         IF(@@ROWCOUNT < 1)
             BEGIN
                 ROLLBACK;
                 RAISERROR('Account doesn''t exists', 16, 1);
         END;
         COMMIT;
     END;

--	 4.	Withdraw Money
--Add stored procedure usp_WithdrawMoney (AccountId, MoneyAmount) that withdraws money from an existing account. Make sure to guarantee valid positive MoneyAmount with precision up to fourth sign after decimal point. The procedure should produce exact results working with the specified precision.

CREATE PROCEDURE usp_WithdrawMoney
(
                 @accountId   INT,
                 @moneyAmount MONEY
)
AS
     BEGIN
         IF(@moneyAmount < 0)
             BEGIN
                 RAISERROR('Cannot withdraw negative value', 16, 1);
         END;
             ELSE
             BEGIN
                 IF(@accountId IS NULL
                    OR @moneyAmount IS NULL)
                     BEGIN
                         RAISERROR('Missing value', 16, 1);
                 END;
         END;
         BEGIN TRANSACTION;
         UPDATE Accounts
           SET
               Balance-=@moneyAmount
         WHERE Id = @accountId;
         IF(@@ROWCOUNT < 1)
             BEGIN
                 ROLLBACK;
                 RAISERROR('Account doesn''t exists', 16, 1);
         END;
             ELSE
             BEGIN
                 IF(0 >
                   (
                       SELECT Balance
                       FROM Accounts
                       WHERE Id = @accountId
                   ))
                     BEGIN
                         ROLLBACK;
                         RAISERROR('Balance not enough', 16, 1);
                 END;
         END;
         COMMIT;
     END;
   

--5.	Money Transfer
--Write stored procedure usp_TransferMoney(SenderId, ReceiverId, Amount) that transfers money from one account to another. Make sure to guarantee valid positive MoneyAmount with precision up to fourth sign after decimal point. Make sure that the whole procedure passes without errors and if error occurs make no change in the database. You can use both: "usp_DepositMoney", "usp_WithdrawMoney" (look at previous two problems about those procedures). 
CREATE PROCEDURE usp_TransferMoney
(
                 @senderId   INT,
                 @receiverId INT,
                 @amount     MONEY
)
AS
     BEGIN
         IF(@amount < 0)
             BEGIN
                 RAISERROR('Cannot transfer negative amount', 16, 1);
         END;
             ELSE
             BEGIN
                 IF(@senderId IS NULL
                    OR @receiverId IS NULL
                    OR @amount IS NULL)
                     BEGIN
                         RAISERROR('Missing value', 16, 1);
                 END;
         END;

-- Withdraw from the sender
         BEGIN TRANSACTION;
         UPDATE Accounts
           SET
               Balance-=@amount
         WHERE Id = @senderId;
         IF(@@ROWCOUNT < 1)
             BEGIN
                 ROLLBACK;
                 RAISERROR('Sender''s account doesn''t exists', 16, 1);
         END;

-- Check sender's current balance
         IF(0 >
           (
               SELECT Balance
               FROM Accounts
               WHERE ID = @senderId
           ))
             BEGIN
                 ROLLBACK;
                 RAISERROR('Not enough funds', 16, 1);
         END;

-- Add money to the receiver
         UPDATE Accounts
           SET
               Balance+=@amount
         WHERE ID = @receiverId;
         IF(@@ROWCOUNT < 1)
             BEGIN
                 ROLLBACK;
                 RAISERROR('Receiver''s account doesn''t exists', 16, 1);
         END;
         COMMIT;
     END;

--Queries for Diablo Database
--You are given a database "Diablo" holding users, games, items, characters and statistics available as SQL script. Your task is to write some stored procedures, views and other server-side database objects and write some SQL queries for displaying data from the database.
--Important: start with a clean copy of the "Diablo" database on each problem. Just execute the SQL script again.

--6.	Trigger
--1. Users should not be allowed to buy items with higher level than their level. Create a trigger that restricts that. The trigger should prevent inserting items that are above specified level while allowing all others to be inserted.
--2. Add bonus cash of 50000 to users: baleremuda, loosenoise, inguinalself, buildingdeltoid, monoxidecos in the game "Bali".
--3. There are two groups of items that you must buy for the above users. The first are items with id between 251 and 299 including. Second group are items with id between 501 and 539 including.
--Take off cash from each user for the bought items.
--4. Select all users in the current game ("Bali") with their items. Display username, game name, cash and item name. Sort the result by username alphabetically, then by item name alphabetically. 

CREATE TRIGGER tr_RestrictItems ON UserGameItems INSTEAD OF INSERT
AS
DECLARE @itemId INT = (SELECT ItemId FROM inserted)
DECLARE @userGameId INT = (SELECT UserGameId FROM inserted)

DECLARE @itemLevel INT = (SELECT MinLevel FROM Items WHERE Id = @itemId)
DECLARE @userGameLevel INT = (SELECT Level FROM UsersGames WHERE Id = @userGameId)

IF(@userGameLevel >= @itemLevel)
BEGIN 
	INSERT INTO UserGameItems (ItemId, UserGameId) VALUES 
	(@itemId, @userGameId)
END


SELECT * 
FROM Users AS u
JOIN UsersGames  AS ug ON ug.UserId = u.Id
WHERE ug.Id = 38

SELECT * 
FROM Items 
WHERE Id = 2 

SELECT * 
FROM UserGameItems 
WHERE UserGameId = 38 AND ItemId = 14

INSERT INTO UserGameItems (ItemId, UserGameId) VALUES 
(14,38)
-- here we insert 

SELECT * FROM Users AS u
JOIN UsersGames AS ug ON ug.UserId = u.Id
JOIN Games AS g ON g.Id = ug.GameId
WHERE g.Name = 'Bali' AND u.Username IN 
('baleremuda','loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')

UPDATE UsersGames 
SET Cash += 50000
WHERE GameId = (SELECT * FROM Games Where Name = 'Bali') AND
UserId IN (SELECT Id FROM Users WHERE Username IN ('baleremuda','loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))


---3.

SELECT * FROM Users WHERE Username IN ('baleremuda','loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')

DECLARE @itemId INT = 251;

WHILE (@itemId <= 299)
BEGIN
	
	EXEC usp_BuyItem 22, @itemId, 212
	EXEC usp_BuyItem 37, @itemId, 212
	EXEC usp_BuyItem 52, @itemId, 212
	EXEC usp_BuyItem 61, @itemId, 212
	
	SET @itemId += 1;
END

DECLARE @counter INT = 501;

WHILE (@counter  <= 539)
BEGIN
	
	EXEC usp_BuyItem 22, @counter, 212
	EXEC usp_BuyItem 37, @counter, 212
	EXEC usp_BuyItem 52, @counter, 212
	EXEC usp_BuyItem 61, @counter, 212
	
	SET @itemId += 1;
END


CREATE PROC usp_BuyItem @userId INT , @itemId INT, @gameId INT
AS
BEGIN TRANSACTION
DECLARE @user INT = (SELECT Id FROM Users WHERE Id = @userId)
DECLARE @item INT = (SELECT Id FROM Items WHERE Id = @itemId)

IF(@user IS NULL OR @item IS NULL)
BEGIN
	ROLLBACK
	RAISERROR('Invalid user or item Id!', 16,1)
	RETURN
END 
DECLARE @userCash DECIMAL(15,2) = (SELECT Cash FROM UsersGames WHERE UserId = @userId
AND GameId = @gameId)
DECLARE @itemPrice DECIMAL(15,2) = (SELECT Price FROM Items WHERE Id = @itemId)

IF (@userCash - @itemPrice < 0 )
BEGIN 
	ROLLBACK
	RAISERROR('Insufficient funds!', 16,2)
END

UPDATE UsersGames 
SET Cash -= @itemPrice 
WHERE UserId = @userId AND GameId = @gameId

DECLARE @userGameId DECIMAL(15,2) = (SELECT id FROM UsersGames WHERE UserId = @userId
AND GameId = @gameId)

INSERT INTO UserGameItems (ItemId, UserGameId) VALUES (@itemId, @userGameId)

COMMIT

--4. 
SELECT u.Username, g.Name, ug.Cash, i.Name
FROM Users  AS u
JOIN UsersGames AS ug ON ug.UserId = u.Id
JOIN Games AS g ON g.Id = ug.GameId
JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
JOIN Items AS i ON i.Id = ugi.ItemId
WHERE g.Name = 'Bali'
ORDER BY u.Username, i.Name

--7.	*Massive Shopping
--1.	User Stamat in Safflower game wants to buy some items. He likes all items from Level 11 to 12 as well as all items from Level 19 to 21. As it is a bulk operation you have to use transactions. 
--2.	A transaction is the operation of taking out the cash from the user in the current game as well as adding up the items. 
--3.	Write transactions for each level range. If anything goes wrong turn back the changes inside of the transaction.
--4.	Extract all of Stamat’s item names in the given game sorted by name alphabetically

--Stamat id 9
--Safflower id 87

DECLARE @UserName VARCHAR(50) = 'Stamat'
DECLARE @GameName VARCHAR(50) = 'Safflower'
DECLARE @UserID int = (SELECT Id FROM Users WHERE Username = @UserName)
DECLARE @GameID int = (SELECT Id FROM Games WHERE Name = @GameName)
DECLARE @UserMoney money = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
DECLARE @ItemsTotalPrice money
DECLARE @UserGameID int = (SELECT Id FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)

BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 11 AND 12)

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 19 AND 21)

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END

SELECT Name AS [Item Name]
FROM Items
WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @userGameID)
ORDER BY [Item Name]

--Queries for SoftUni Database
--8.	Employees with Three Projects
--Create a procedure usp_AssignProject(@emloyeeId, @projectID) that assigns projects to employee. If the employee has more than 3 project throw exception and rollback the changes. The exception message must be: "The employee has too many projects!" with Severity = 16, State = 1.
CREATE PROC usp_AssignProject (@employeeId INT, @projectId INT)
AS
BEGIN TRANSACTION
DECLARE @employee INT = (SELECT EmployeeID FROM Employees WHERE EmployeeID = @employeeId)
DECLARE @project INT = (SELECT ProjectID FROM Projects WHERE ProjectID = @projectId)

IF (@employee IS NULL OR @project IS NULL)
BEGIN 
 ROLLBACK
  RAISERROR('Invalid employee id or project id!',16,1)
 RETURN 
END

DECLARE @employeeProjects INT = (SELECT COUNT(*) FROM EmployeesProjects WHERE
EmployeeID = @employeeId)

IF(@employeeProjects >= 3)
BEGIN 
	ROLLBACK
	RAISERROR('The employee has too many projects!',16,2)
	RETURN
END

INSERT INTO EmployeesProjects (EmployeeId,ProjectId) VALUES (@employeeId,@projectId)
COMMIT

EXEC usp_AssignProject 2, 1
--9.	Delete Employees
--Create a table Deleted_Employees(EmployeeId PK, FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary) that will hold information about fired (deleted) employees from the Employees table. Add a trigger to Employees table that inserts the corresponding information about the deleted records in Deleted_Employees.

CREATE TABLE Deleted_Employees 
(
EmployeeId INT PRIMARY KEY IDENTITY ,
FirstName VARCHAR(50),
LastName VARCHAR(50),
MiddleName VARCHAR(50),
JobTitle VARCHAR(50),
DepartmentId INT,
Salary DECIMAL (15,2)
)
GO
CREATE TRIGGER tr_DeletedEmployees ON Employees FOR DELETE
AS 
INSERT INTO Deleted_Employees (FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
SELECT  FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary FROM deleted