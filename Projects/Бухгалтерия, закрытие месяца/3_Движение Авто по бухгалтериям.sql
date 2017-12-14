DECLARE @accPeriod INT
SET @accPeriod = 201710

declare @IgnoreVehicles table (VehicleId int)
insert into @IgnoreVehicles
select Data from dbo.Split('1142,30,614,1239,1284,1295',',')

--delete from AccVehicleMoving where accPeriod = @accPeriod
--INSERT INTO AccVehicleMoving
SELECT 
	DISTINCT
	@accPeriod AccPeriod,
	v.VehicleId,
	r.AccountingId AccRemain,
	tc.AccountingId AccVehice,
	v.ColumnId,
	r.FuelId,
	r.Quantity,
	cast(round(r.Cost,0) AS INT) Cost,
	cast(r.DiffCost AS INT) DiffCost
FROM AccFuelRemain r
LEFT JOIN Vehicle v ON v.VehicleId = r.VehicleId
LEFT JOIN TransportColumn tc ON tc.ColumnId = ISNULL(v.ColumnId,5)
LEFT JOIN Accounting a ON a.AccountingId = tc.AccountingId
WHERE r.AccPeriod = @accPeriod AND r.AccountingId<>a.AccountingId
 and r.VehicleId not in (select VehicleId from @IgnoreVehicles)


UPDATE AccFuelRemain
	SET AccountingId = m.AccVehice
FROM AccFuelRemain r
INNER JOIN AccVehicleMoving m ON m.AccPeriod = r.AccPeriod AND r.VehicleId = m.VehicleId AND r.FuelId = m.FuelId  
WHERE r.accPeriod = @accPeriod

SELECT 
	v.GarageNumber AS [Гар.№],
	f.FuelName AS [Топливо],
	m.Quantity AS [Кол-во, л],
	m.Cost+m.DiffCost AS [Стоимость, руб],
	--m.AccRemain,
	m.ColumnId [В колонну]
FROM AccVehicleMoving m
INNER JOIN Vehicle v ON v.VehicleId = m.VehicleId
INNER JOIN Fuel f ON f.FuelId = m.FuelId
WHERE AccPeriod = @accPeriod AND m.Quantity<>0 
ORDER BY 2,1

SELECT * FROM AccFuelRemain WHERE AccPeriod = 201602 AND VehicleId = 1295
delete FROM AccFuelRemain WHERE AccPeriod = 201602 AND VehicleId = 1142 AND AccountingId = 2
