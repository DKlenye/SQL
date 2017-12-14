

SELECT 
	'if (select count(*) from WaybillCustomerWorkingTime where WaybillId = '+Cast(WaybillId AS VARCHAR(100))+' ) = 1 update WaybillCustomerWorkingTime set CustomerId = '+Cast(CustomerId AS VARCHAR(100))+' WHERE WaybillId = '+ Cast(WaybillId AS VARCHAR(100))
FROM (
SELECT a.WaybillId,a.CustomerId FROM (
SELECT 
	DISTINCT 
	w.WaybillId,
	wt.CustomerId
FROM Waybill w
LEFT JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId
INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId
WHERE w.AccPeriod IS NULL AND w.WaybillState> 1
)a
LEFT JOIN WaybillCustomerWorkingTime ww ON ww.WaybillId = a.WaybillId AND ww.CustomerId = a.CustomerId
WHERE ww.WaybillId IS NULL AND a.CustomerId IS NOT NULL
)b



SELECT WaybillId m FROM WaybillCustomerWorkingTime GROUP BY WaybillId,CustomerId HAVING count(Minutes)>1

delete FROM WaybillCustomerWorkingTime WHERE Minutes = 0 AND waybillId IN (
SELECT WaybillId FROM WaybillCustomerWorkingTime GROUP BY WaybillId,CustomerId HAVING count(Minutes)>1)