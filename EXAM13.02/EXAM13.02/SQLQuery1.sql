--CREATING
--CREATE DATABASE Bitbucket
--GO

USE Bitbucket

CREATE TABLE Users
(
Id INT PRIMARY KEY IDENTITY,
Username VARCHAR(30) NOT NULL,
[Password] VARCHAR(30) NOT NULL,
Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
Id INT PRIMARY KEY IDENTITY ,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
RepositoryId INT NOT NULL REFERENCES Repositories(Id),
ContributorId INT NOT NULL REFERENCES Users(Id)

CONSTRAINT PK_RepoContributor PRIMARY KEY (RepositoryId,ContributorId) 
)

CREATE TABLE Issues
(
Id INT PRIMARY KEY IDENTITY ,
Title VARCHAR(255) NOT NULL,
IssueStatus VARCHAR(6) NOT NULL,
RepositoryId INT NOT NULL REFERENCES Repositories(Id),
AssigneeId INT NOT NULL REFERENCES Users(Id)
)

CREATE TABLE Commits 
(
Id INT PRIMARY KEY IDENTITY ,
[Message] VARCHAR(255) NOT NULL,
IssueId INT REFERENCES Issues(Id),
RepositoryId INT NOT NULL REFERENCES Repositories(Id),
ContributorId INT NOT NULL REFERENCES Users(Id)
)

CREATE TABLE Files 
(
Id INT PRIMARY KEY IDENTITY ,
[Name] VARCHAR(100) NOT NULL,
Size DECIMAL(18,2) NOT NULL,
ParentId INT REFERENCES Files(Id),
CommitId INT NOT NULL REFERENCES Commits(Id)
)

--2.
INSERT INTO Files (Name,Size,ParentId,CommitId) VALUES 
('Trade.idk',2598.0,1,1),
('menu.net',9238.31,2,2),
('Administrate.soshy',1246.93,3,3),
('Controller.php',7353.15,4,4),
('Find.java',9957.86,5,5),
('Controller.json',14034.87,3,6),
('Operate.xix',7662.92,7,7)

INSERT INTO Issues (Title,IssueStatus,RepositoryId,AssigneeId) VALUES
('Critical Problem with HomeController.cs file','open',1,4),
('Typo fix in Judge.html','open',4,3),
('Implement documentation for UsersService.cs','closed',8,2),
('Unreachable code in Index.cs','open',9,8)



--3.
UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6



--4.
DELETE RepositoriesContributors
WHERE RepositoryId = 3

DELETE Issues 
WHERE RepositoryId = 3 



--5.
SELECT c.Id , c.Message, c.RepositoryId, c.ContributorId
FROM Commits AS c
ORDER BY c.Id, c.Message, c.RepositoryId, c.ContributorId


--6.
SELECT f.Id, f.Name, f.Size
FROM Files AS f
WHERE f.Name LIKE '%html%' AND 
f.Size > 1000	
	ORDER BY f.Size DESC, f.Id ASC, f.Name ASC
	

--7.
SELECT i.Id,u.Username + ' : ' + i.Title AS IssueAsignee
FROM Issues i
JOIN Users u  ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, i.AssigneeId ASC

--8.
SELECT f1.Id,
       f1.Name,
       CAST(f1.Size AS VARCHAR(100)) + 'KB'
    FROM Files AS f
             RIGHT JOIN Files AS f1
                        ON f.ParentId = f1.Id
    WHERE f.ParentId IS NULL
    ORDER BY f.Id,
             f.Name,
             f.Size DESC

SELECT * 
FROM Files

--9.

SELECT TOP(5) r.Id,r.Name ,COUNT(*) AS CommitsCount
FROM RepositoriesContributors rc
JOIN Repositories r ON rc.RepositoryId = r.Id
JOIN Commits c ON c.RepositoryId = r.Id
GROUP BY r.Id, r.Name
ORDER BY CommitsCount DESC, r.Id ASC , r.Name ASC


--10.

SELECT u.Username, AVG(f.Size) AS Size
FROM 
Users u
JOIN Commits c ON c.ContributorId = u.Id
JOIN Files f ON c.Id = f.CommitId
GROUP BY u.Username 
ORDER BY Size DESC , u.Username ASC


--11.
GO

CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
AS
BEGIN 
DECLARE @result INT 
SET @result = (SELECT COUNT(*)
						FROM Users AS u
				JOIN Commits c ON c.ContributorId = u.Id
				WHERE u.Username = @username
				GROUP BY u.Username 
				)
				IF(@result IS NULL)
				SET @result = 0;
RETURN @result
END

SELECT dbo.udf_AllUserCommits('UnderSinduxrein')




--12.
CREATE PROCEDURE usp_SearchForFiles(@fileExtension VARCHAR(30))
AS 
BEGIN
	SELECT f.Id, f.Name, CAST(f.Size AS varchar) + 'KB' AS Size
					FROM Files  AS f
					WHERE f.Name LIKE '%' + @fileExtension + '%'
					ORDER BY f.Id, f.Name, f.Size DESC
END

EXEC usp_SearchForFiles 'txt'