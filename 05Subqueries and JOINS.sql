----Write a query that selects:
--•	EmployeeId
--•	JobTitle
--•	AddressId
--•	AddressText
--Return the first 5 rows sorted by AddressId in ascending order.

SELECT TOP (5) e.EmployeeID, e.JobTitle, a.[AddressID], AddressText
FROM Employees AS e
JOIN Addresses AS a ON a.AddressID = e.AddressID
ORDER BY AddressID ASC

--2.	Addresses with Towns
--Write a query that selects:
--•	FirstName
--•	LastName
--•	Town
--•	AddressText
--Sorted by FirstName in ascending order then by LastName. Select first 50 employees.

SELECT TOP (50) e.FirstName, e.LastName,t.Name AS Town,a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON a.AddressID = e.AddressID 
JOIN Towns AS t ON t.TownID = a.TownID
ORDER BY e.FirstName ,e.LastName

--3.	Sales Employee
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	LastName
--•	DepartmentName
--Sorted by EmployeeID in ascending order. Select only employees from "Sales" department.

SELECT e.EmployeeID, e.FirstName, e.LastName, d.Name
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY e.EmployeeID ASC

--4.	Employee Departments
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	Salary
--•	DepartmentName
--Filter only employees with salary higher than 15000. Return the first 5 rows sorted by DepartmentID in ascending order.

SELECT TOP (5) e.EmployeeID, e.FirstName, e.Salary, d.Name
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID ASC

--5.	Employees Without Project
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--Filter only employees without a project. Return the first 3 rows sorted by EmployeeID in ascending order.

SELECT TOP(3) e.EmployeeID,e.FirstName
FROM Employees AS e 
LEFT JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
WHERE ep.EmployeeID IS NULL
ORDER BY e.EmployeeID

--6.	Employees Hired After
--Write a query that selects:
--•	FirstName
--•	LastName
--•	HireDate
--•	DeptName
--Filter only employees hired after 1.1.1999 and are from either "Sales" or "Finance" departments, sorted by HireDate (ascending).

SELECT e.FirstName, e.LastName, e.HireDate, d.Name AS [DeptName]
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1999-01-01'
AND 
d.Name IN ('Sales' ,'Finance')
ORDER BY e.HireDate ASC

--7.	Employees with Project
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	ProjectName
--Filter only employees with a project which has started after 13.08.2002 and it is still ongoing (no end date). Return the first 5 rows sorted by EmployeeID in ascending order.


SELECT TOP (5) e.EmployeeID, e.FirstName, p.Name AS ProjectName
FROM Employees e
JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects p ON p.ProjectID = ep.ProjectID
WHERE p.StartDate > '2002-08-13' AND 
p.EndDate IS NULL
ORDER BY e.EmployeeID ASC

--8.	Employee 24
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	ProjectName
--Filter all the projects of employee with Id 24. If the project has started during or after 2005 the returned value should be NULL.

SELECT e.EmployeeID, e.FirstName, 
CASE 
WHEN DATEPART(YEAR, p.StartDate) >= '2005'
THEN NULL
ELSE p.Name
END AS ProjectName
FROM Employees e
JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects p ON p.ProjectID = ep.ProjectID
WHERE e.EmployeeID = 24

--9.	Employee Manager
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	ManagerID
--•	ManagerName
--Filter all employees with a manager who has ID equals to 3 or 7. Return all the rows, sorted by EmployeeID in ascending order.

SELECT emp.EmployeeID, emp.FirstName, emp.ManagerID, mng.FirstName AS ManagerName
FROM Employees AS emp
JOIN Employees AS mng ON mng.EmployeeID = emp.ManagerID
WHERE mng.EmployeeID IN (3,7)
ORDER BY emp.EmployeeID

--10. Employee Summary
--Write a query that selects:
--•	EmployeeID
--•	EmployeeName
--•	ManagerName
--•	DepartmentName
--Show first 50 employees with their managers and the departments they are in (show the departments of the employees). Order by EmployeeID.

SELECT TOP (50)
emp.EmployeeID, emp.FirstName + ' ' + emp.LastName AS EmployeeName,mng.FirstName + ' ' + mng.LastName AS ManagerName,d.Name AS DepartmentName
FROM Employees AS emp
JOIN Employees AS mng ON mng.EmployeeID = emp.ManagerID
JOIN Departments AS d ON emp.DepartmentID = d.DepartmentID
ORDER BY emp.EmployeeID

--11. Min Average Salary
--Write a query that returns the value of the lowest average salary of all departments.

SELECT TOP (1) AVG(e.Salary) AS MinAverageSalary
FROM Employees e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
GROUP BY e.DepartmentID
ORDER BY MinAverageSalary 

USE Geography

--12. Highest Peaks in Bulgaria
--Write a query that selects:
--•	CountryCode
--•	MountainRange
--•	PeakName
--•	Elevation
--Filter all peaks in Bulgaria with elevation over 2835. Return all the rows sorted by elevation in descending order.

SELECT  c.CountryCode, m.MountainRange, p.PeakName, p.Elevation
FROM Countries AS c
JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
JOIN Mountains AS m ON m.Id = mc.MountainId
JOIN Peaks AS p ON p.MountainId = m.Id
WHERE  c.CountryCode = 'BG' AND
p.Elevation > 2835
ORDER BY p.Elevation DESC

--13. Count Mountain Ranges
--Write a query that selects:
--•	CountryCode
--•	MountainRanges
--Filter the count of the mountain ranges in the United States, Russia and Bulgaria.

SELECT  c.CountryCode, COUNT(*) AS MountainRanges
FROM Countries AS c
JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
WHERE c.CountryCode IN ('US', 'RU', 'BG')
GROUP BY c.CountryCode

--14. Countries with Rivers
--Write a query that selects:
--•	CountryName
--•	RiverName
--Find the first 5 countries with or without rivers in Africa. Sort them by CountryName in ascending order.

SELECT  TOP (5) 
c.CountryName,r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
WHERE c.ContinentCode = 'AF' 
ORDER BY c.CountryName

--15. *Continents and Currencies
--Write a query that selects:
--•	ContinentCode
--•	CurrencyCode
--•	CurrencyUsage
--Find all continents and their most used currency. Filter any currency that is used in only one country. Sort your results by ContinentCode.

SELECT ContinentCode, CurrencyCode, CurrencyUsage FROM (
SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage,
DENSE_RANK () OVER (PARTITION BY ContinentCode ORDER BY COUNT (CurrencyCode) DESC) AS Ranked
FROM Countries  
GROUP BY ContinentCode, CurrencyCode) AS k
WHERE Ranked = 1 AND CurrencyUsage > 1 
ORDER BY ContinentCode

--16.Countries Without Any Mountains
--Find all the count of all countries, which don’t have a mountain.

SELECT COUNT(*) AS [Count]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
WHERE mc.MountainId IS NULL

--18. Highest Peak Name and Elevation by Country
--For each country, find the name and elevation of the highest peak, along with its mountain. When no peaks are available in some country, display elevation 0, "(no highest peak)" as peak name and "(no mountain)" as mountain name. When multiple peaks in some country have the same elevation, display all of them. Sort the results by country name alphabetically, then by highest peak name alphabetically. Limit only the first 5 rows.

SELECT TOP (5) k.CountryName, k.PeakName, k.HighestPeak, k.MountainRange
FROM (SELECT  
CountryName,
ISNULL(p.PeakName, '(no highest peak)') AS PeakName, 
ISNULL(m.MountainRange,'(no mountain)' ) AS MountainRange,
ISNULL(MAX(p.Elevation), 0) AS HighestPeak ,
DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY MAX(p.Elevation) DESC) AS Ranked
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
LEFT JOIN Mountains AS m ON m.Id = mc.MountainId 
LEFT JOIN Peaks AS p ON p.MountainId = m.Id 
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
GROUP BY CountryName, p.PeakName, m.MountainRange) AS k
WHERE Ranked = 1 
ORDER BY CountryName, PeakName
