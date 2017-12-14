DECLARE @month INT, @year INT
SELECT @month = 01, @year = 2017


DECLARE @t TABLE(m INT, Summ DECIMAL(18,2), Car DECIMAL(18,2), Crane DECIMAL(18,2))

WHILE @month<11
BEGIN

INSERT INTO @t
	SELECT 
	@month,
	SUM(AccCost) AccCost,
	SUM(Car) Car,
	SUM(Crane) Crane
FROM (
SELECT
	a.AccCost,
	CASE WHEN v.RefuellingGroupId IN (51,9,10,11) THEN a.AccCost ELSE 0 END AS Car,
	CASE WHEN v.RefuellingGroupId IN (5) THEN a.AccCost ELSE 0 END AS Crane
FROM
	dbo.ft_AccWaybillWorkInfo(@month,@year,1,1) a
	LEFT JOIN Vehicle AS v ON v.VehicleId = a.VehicleId
)a

SET @month = @month+1

END


SELECT * FROM @t
	
