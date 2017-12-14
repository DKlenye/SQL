DECLARE @accPeriod INT
SET @accPeriod = 201405
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

/*
UPDATE AccFuelRemain
	SET AccountingId = m.AccVehice
FROM AccFuelRemain r
INNER JOIN AccVehicleMoving m ON m.AccPeriod = r.AccPeriod AND r.VehicleId = m.VehicleId AND r.FuelId = m.FuelId  
WHERE r.accPeriod = @accPeriod
*/


/*
select * from AccFuelRemain WHERE AccPeriod = 201402 AND FuelId = 1 order by Cost desc


UPDATE AccFuelRemain SET Cost = Cost-41918-47671 WHERE VehicleId = 28 AND AccPeriod = 201401
UPDATE AccFuelRemain SET Cost = Cost+41918+47671 WHERE VehicleId = 1692 AND AccPeriod = 201401

UPDATE AccFuelRemain SET Cost = Cost+1120118 WHERE VehicleId = 1069 AND AccPeriod = 201402 and FuelId = 1
UPDATE AccFuelRemain SET Cost = Cost-1120118 WHERE VehicleId = 1204 AND AccPeriod = 201402 and FuelId = 1


UPDATE AccFuelRemain SET Cost = Cost-4915085.305 WHERE VehicleId = 1080 AND AccPeriod = 201405 and FuelId = 3
UPDATE AccFuelRemain SET Cost = Cost+4915085.305 WHERE VehicleId = 6 AND AccPeriod = 201405 and FuelId = 3

UPDATE AccFuelRemain SET Cost = Cost+59302.310 WHERE VehicleId = 826 AND AccPeriod = 201405 and FuelId = 3
UPDATE AccFuelRemain SET Cost = Cost-59302.310 WHERE VehicleId = 3 AND AccPeriod = 201405 and FuelId = 3

*/

SELECT * FROM AccFuelRemain WHERE Accperiod = 201405 AND VehicleId = 826
SELECT * FROM AccFuelRemain WHERE Accperiod = 201405 AND AccountingId = 1 AND FuelId = 3 AND VehicleId = 3


SELECT * FROM AccVehicleMoving











