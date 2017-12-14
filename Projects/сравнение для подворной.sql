DECLARE @year INT, @month INT
SELECT @year = 2015, @month = 02


SELECT 
	swi.scoreNo,
	swi.waybillNumber,
	c.CustomerName,
	isnull(swi.km,0),
	isnull(ww.km,0),
	swi.mh,
	ISNULL(ww.mh,0) mh,
	swi.hourWork
FROM _serviceWaybillsInfo swi 
LEFT JOIN (
	SELECT MIN(c.CustomerId) CustomerId,c.ReplicationId FROM Customer c WHERE c.ReplicationId IS NOT null GROUP BY c.ReplicationId	
)cc ON swi.customerId = cc.ReplicationId
LEFT JOIN Customer c ON cc.CustomerId = c.CustomerId
LEFT JOIN (
	SELECT 
	w.WaybillId,
	c.ReplicationId,
	SUM(CASE WHEN wt2.WorkUnitId = 1 THEN isnull(wt.WorkAmount,0) ELSE 0 end) km,
	SUM(CASE WHEN wt2.WorkUnitId IN(2,3) THEN isnull(wt.WorkAmount,0) ELSE 0 end) mh
	FROM Waybill w
	INNER JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId
	INNER JOIN Customer c ON c.CustomerId = wt.CustomerId
	INNER JOIN _Norm n ON wt.NormConsumptionId = n.NormId
	INNER JOIN WorkType wt2 ON wt2.WorkTypeId = n.WorkTypeId
	WHERE year(returnDate) = @year AND MONTH(returnDate) = @month AND w.WaybillState>1
	GROUP BY w.WaybillId,c.ReplicationId
) ww ON ww.WaybillId = swi.waybillNumber AND ww.ReplicationId = cc.ReplicationId
WHERE swi.serviceYear = @year AND swi.serviceMonth = @month
ORDER BY swi.waybillNumber


