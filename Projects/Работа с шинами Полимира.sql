
--INSERT INTO  TireWork 
SELECT 
	tm.TireMovingId,
	s.rep,
	s.probmes,
	1
FROM SHINPER s 
INNER JOIN Vehicle v ON v.GarageNumber = s.gar_n+20000
inner JOIN Tire t ON t.FactoryNumber=s.zawnom
LEFT JOIN TireMoving tm ON tm.TireId = t.TireId AND tm.VehicleId = v.VehicleId
LEFT JOIN TireWork tw ON tw.TireMovingId = tm.TireMovingId AND tw.Period = s.rep
WHERE s.rep>1 AND s.zawnom NOT LIKE '%á/í%' AND tw.TireMovingId IS NULL
AND s.zawnom NOT IN (
		SELECT  DISTINCT zawnom FROM (
			SELECT zawnom,rep,COUNT(probmes) b FROM SHINPER 
			WHERE zawnom NOT LIKE '%á/í%'
			GROUP BY zawnom,rep
		HAVING COUNT(probmes)>1 AND rep>1
		)	
)


SELECT * FROM Shin WHERE zawnom IN (
SELECT  DISTINCT zawnom FROM (
SELECT zawnom,rep,COUNT(probmes) b FROM SHINPER 
WHERE zawnom NOT LIKE '%á/í%'
GROUP BY zawnom,rep
HAVING COUNT(probmes)>1 AND rep>1
)b
) ORDER BY zawnom

SELECT * FROM TireWork tw WHERE tw.IsAutomatic = 1
SELECT * FROM TireMoving tm WHERE tm.TireMovingId IN (81)

SELECT * FROM shin WHERE zawnom LIKE '%á/í%' ORDER BY gar_n