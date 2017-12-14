

SELECT 
	c.[№ ЭСЧФ],
	c2.[№ ЭСЧФ],
	isnull(c.[Стоимость с НДС],0)-isnull(c2.[Стоимость с НДС],0)
FROM Cameral3 AS c
LEFT JOIN Cameral2 AS c2 ON c2.[№ ЭСЧФ] = c.[№ ЭСЧФ]
ORDER BY 3

SELECT COUNT(*) FROM Cameral2 AS c
SELECT COUNT(*) FROM Cameral3 AS c


SELECT SUM(isnull(c.[Стоимость с НДС],0)) FROM Cameral3 AS c
SELECT SUM(isnull(c.[Стоимость с НДС],0)) FROM Cameral2 AS c