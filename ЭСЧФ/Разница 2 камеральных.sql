

SELECT 
	c.[� ����],
	c2.[� ����],
	isnull(c.[��������� � ���],0)-isnull(c2.[��������� � ���],0)
FROM Cameral3 AS c
LEFT JOIN Cameral2 AS c2 ON c2.[� ����] = c.[� ����]
ORDER BY 3

SELECT COUNT(*) FROM Cameral2 AS c
SELECT COUNT(*) FROM Cameral3 AS c


SELECT SUM(isnull(c.[��������� � ���],0)) FROM Cameral3 AS c
SELECT SUM(isnull(c.[��������� � ���],0)) FROM Cameral2 AS c