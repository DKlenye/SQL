
DECLARE  @month int, @year int,@accountingId INT
SELECT @month=1,@year=2014,@accountingId = 0

declare @ownerId int
SELECT @ownerId = 1

IF @accountingId = 0 SET @accountingId=null

INSERT INTO _TempVehicleInfo
SELECT 
	fuelId,
	round(Mh,2) Mh,
	round(Km,2) Km,
	Cons,
	Cost,
	@month accmonth,
	@year accyear
FROM (
	SELECT
	b.fuelId,
	SUM(isnull(AccConsumption,0)) Cons,
	SUM(isnull(AccCost,0)) Cost,
	SUM(isnull(km,0)) Km,
	SUM(isnull(mh,0)) Mh
	FROM (
		SELECT 
			i.*	
		FROM dbo.ft_AccWaybillWorkInfo(@month, @year,@ownerId, @accountingId) i
		INNER JOIN Vehicle v ON v.VehicleId = i.VehicleId AND v.RefuellingGroupId IN (2,9,10,11)
	)b
	GROUP BY b.fuelId
)c

DELETE FROM  _TempVehicleInfo WHERE accyear = 2014


SELECT 	
	t.accYear,	
	m.MonthName,
	f.FuelName,
	t.Cons,
	t.Cost
FROM _TempVehicleInfo t
LEFT JOIN fuel f ON f.FuelId = t.fuelId
LEFT JOIN Monthes m ON m.Id = t.accmonth
ORDER BY t.accYear,m.id,f.fuelName