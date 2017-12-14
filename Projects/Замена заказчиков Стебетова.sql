
INSERT INTO Customer
SELECT 
	--CustomerId,
	CustomerName,
	25210000 CostCode,
	OwnerId,
	ReplicationId,
	ReplicationSource,
	CustomerName1,
	notActual,
	SHZ,
 	252470 PolymirCostCode,
	CustomerId tmpId,
	isPolymir,
	PolymirId
	
FROM Customer WHERE CostCode LIKE '2386%' AND notActual = 0

UPDATE  Customer SET notActual = 1 WHERE CostCode LIKE '2386%' AND notActual = 0

SELECT CustomerId FROM Customer WHERE CustomerId > 1062 AND tmpId IS NOT NULL

UPDATE Vehicle
	SET CustomerId = c.CustomerId
FROM Vehicle v 
INNER JOIN (
	SELECT CustomerId,tmpId FROM Customer WHERE CustomerId > 1062 AND tmpId IS NOT NULL
)c ON c.tmpId = v.CustomerId


UPDATE WaybillTask 
	SET CustomerId = c.CustomerId 
FROM WaybillTask wt
INNER JOIN Waybill w ON w.WaybillId = wt.WaybillId
INNER JOIN (
	SELECT CustomerId,tmpId FROM Customer WHERE CustomerId > 1062 AND tmpId IS NOT NULL
	)c ON c.tmpId = wt.CustomerId
WHERE w.AccPeriod IS null