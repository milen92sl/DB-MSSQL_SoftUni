SELECT TOP (5) e.EmployeeID, e.JobTitle, a.[AddressID], AddressText
FROM Employees AS e
JOIN Addresses AS a ON a.AddressID = e.AddressID
ORDER BY AddressID ASC

SELECT TOP (50) e.FirstName, e.LastName,t.Name AS Town,a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON a.AddressID = e.AddressID 
JOIN Towns AS t ON t.TownID = a.TownID
ORDER BY e.FirstName ,e.LastName

SELECT e.EmployeeID, e.FirstName, e.LastName, d.Name
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY e.EmployeeID ASC

SELECT TOP (5) e.EmployeeID, e.FirstName, e.Salary, d.Name
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID ASC

SELECT TOP(3) e.EmployeeID,e.FirstName
FROM Employees AS e 
LEFT JOIN EmployeesProjects AS ep ON ep.EmployeeID = e.EmployeeID
WHERE ep.EmployeeID IS NULL
ORDER BY e.EmployeeID

SELECT e.FirstName, e.LastName, e.HireDate, d.Name AS [DeptName]
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1999-01-01'
AND 
d.Name IN ('Sales' ,'Finance')
ORDER BY e.HireDate ASC


SELECT TOP (5) e.EmployeeID, e.FirstName, p.Name AS ProjectName
FROM Employees e
JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects p ON p.ProjectID = ep.ProjectID
WHERE p.StartDate > '2002-08-13' AND 
p.EndDate IS NULL
ORDER BY e.EmployeeID ASC

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

SELECT TOP (50)
emp.EmployeeID, emp.FirstName + ' ' + emp.LastName AS EmployeeName,mng.FirstName + ' ' + mng.LastName AS ManagerName,d.Name AS DepartmentName
FROM Employees AS emp
JOIN Employees AS mng ON mng.EmployeeID = emp.ManagerID
JOIN Departments AS d ON emp.DepartmentID = d.DepartmentID
ORDER BY emp.EmployeeID

SELECT TOP (1) AVG(e.Salary) AS MinAverageSalary
FROM Employees e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
GROUP BY e.DepartmentID
ORDER BY MinAverageSalary 

USE Geography

SELECT  c.CountryCode, m.MountainRange, p.PeakName, p.Elevation
FROM Countries AS c
JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
JOIN Mountains AS m ON m.Id = mc.MountainId
JOIN Peaks AS p ON p.MountainId = m.Id
WHERE  c.CountryCode = 'BG' AND
p.Elevation > 2835
ORDER BY p.Elevation DESC

SELECT  c.CountryCode, COUNT(*) AS MountainRanges
FROM Countries AS c
JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
WHERE c.CountryCode IN ('US', 'RU', 'BG')
GROUP BY c.CountryCode

SELECT  TOP (5) 
c.CountryName,r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
WHERE c.ContinentCode = 'AF' 
ORDER BY c.CountryName

SELECT ContinentCode, CurrencyCode, CurrencyUsage FROM (
SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage,
DENSE_RANK () OVER (PARTITION BY ContinentCode ORDER BY COUNT (CurrencyCode) DESC) AS Ranked
FROM Countries  
GROUP BY ContinentCode, CurrencyCode) AS k
WHERE Ranked = 1 AND CurrencyUsage > 1 
ORDER BY ContinentCode

SELECT COUNT(*) AS [Count]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
WHERE mc.MountainId IS NULL

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
