


UPDATE WaybillTask 
SET CustomerId = cc.CustomerId	
FROM waybillTask wt
INNER JOIN Waybill w ON wt.WaybillId = w.WaybillId
INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId
INNER JOIN Customer c ON c.CustomerId = wt.CustomerId AND c.CustomerId IN (SELECT CustomerId FROM Customer WHERE CostCode LIKE '78%')
LEFT JOIN customer cc ON cc.ReplicationId = c.CustomerId AND cc.ReplicationSource=0
WHERE w.AccPeriod IS NULL
