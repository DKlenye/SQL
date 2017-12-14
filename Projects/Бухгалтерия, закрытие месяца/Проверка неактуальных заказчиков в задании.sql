DECLARE @month INT, @year INT , @accountingId INT
SELECT @month = 09, @year = 2014 , @accountingId = 1


SELECT v.GarageNumber, c.CustomerName, c.CustomerId, c.CostCode, w.* FROM Waybill w 
INNER JOIN WaybillTask wt on wt.WaybillId = w.WaybillId
LEFT JOIN Customer c ON c.CustomerId = wt.CustomerId
LEFT JOIN Vehicle v ON v.VehicleId = w.VehicleId
WHERE w.returnDate>'01.09.2014' AND w.AccPeriod IS null
AND c.notActual = 1
ORDER BY c.CustomerId

/*
UPDATE WaybillTask
SET
	CustomerId = 710
	
WHERE TaskId IN (
SELECT wt.TaskId FROM Waybill w 
INNER JOIN WaybillTask wt on wt.WaybillId = w.WaybillId
LEFT JOIN Customer c ON c.CustomerId = wt.CustomerId
LEFT JOIN Vehicle v ON v.VehicleId = w.VehicleId
WHERE w.returnDate>'01.03.2013' AND w.AccPeriod IS null
AND c.notActual = 1 AND c.CustomerId = 558
)
*/

/*
SELECT c.CustomerId,c.CustomerName,v.GarageNumber FROM Vehicle v 
INNER JOIN Customer c ON c.CustomerId = v.CustomerId AND c.notActual = 1 
WHERE v.OwnerId = 1

update Vehicle SET CustomerId = WHERE VehicleId IN (SELECT VehicleId FROM Vehicle v 
INNER JOIN Customer c ON c.CustomerId = v.CustomerId AND c.notActual = 1 AND v.CustomerId = 13)
*/