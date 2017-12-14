SELECT 
	*,
	ISNULL([����� ������],0) - ISNULL([����� ���],0) AS diff
FROM (
SELECT 
	c1.[� ����] AS [� ���� ARM],
	c.[� ����],
	c1.[����� ������],
	c.[����� ���]
FROM Cameral1 AS c1
LEFT JOIN Cameral2 AS c ON c1.[� ����] = c.[� ����]
WHERE 
c1.[� ����] IS NOT NULL AND	isnull(c1.[����� ������],0)!=isnull(c.[����� ���],0)

union

SELECT 
	c1.[� ����],
	c.[� ����],
	c1.[����� ������],
	c.[����� ���]
FROM Cameral2 AS c
LEFT JOIN Cameral1 AS c1 ON c1.[� ����] = c.[� ����] AND c1.[� ����] IS NOT NULL
WHERE 
	c.[� ����] IS NOT NULL and isnull(c1.[����� ������],0)!=isnull(c.[����� ���],0)
)a

SELECT 
(SELECT SUM([����� ������]) FROM Cameral1 WHERE [� ����] IS NOT NULL),
(SELECT SUM([����� ���]) FROM Cameral2 WHERE [� ����] IS NOT NULL) ,
(
	(SELECT SUM([����� ������]) FROM Cameral1 WHERE [� ����] IS NOT NULL) - 
	(SELECT SUM([����� ���]) FROM Cameral2 WHERE [� ����] IS NOT NULL)
)