SELECT 
	*,
	ISNULL([Сумма вычета],0) - ISNULL([Сумма НДС],0) AS diff
FROM (
SELECT 
	c1.[№ ЭСЧФ] AS [№ ЭСЧФ ARM],
	c.[№ ЭСЧФ],
	c1.[Сумма вычета],
	c.[Сумма НДС]
FROM Cameral1 AS c1
LEFT JOIN Cameral2 AS c ON c1.[№ ЭСЧФ] = c.[№ ЭСЧФ]
WHERE 
c1.[№ ЭСЧФ] IS NOT NULL AND	isnull(c1.[Сумма вычета],0)!=isnull(c.[Сумма НДС],0)

union

SELECT 
	c1.[№ ЭСЧФ],
	c.[№ ЭСЧФ],
	c1.[Сумма вычета],
	c.[Сумма НДС]
FROM Cameral2 AS c
LEFT JOIN Cameral1 AS c1 ON c1.[№ ЭСЧФ] = c.[№ ЭСЧФ] AND c1.[№ ЭСЧФ] IS NOT NULL
WHERE 
	c.[№ ЭСЧФ] IS NOT NULL and isnull(c1.[Сумма вычета],0)!=isnull(c.[Сумма НДС],0)
)a

SELECT 
(SELECT SUM([Сумма вычета]) FROM Cameral1 WHERE [№ ЭСЧФ] IS NOT NULL),
(SELECT SUM([Сумма НДС]) FROM Cameral2 WHERE [№ ЭСЧФ] IS NOT NULL) ,
(
	(SELECT SUM([Сумма вычета]) FROM Cameral1 WHERE [№ ЭСЧФ] IS NOT NULL) - 
	(SELECT SUM([Сумма НДС]) FROM Cameral2 WHERE [№ ЭСЧФ] IS NOT NULL)
)