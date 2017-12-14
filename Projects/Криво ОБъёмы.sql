

SELECT 
	AccGroupName,
	CostCode,
	Y,
	SUM(km) km,
	SUM(hourWork) hourWork,
	SUM(summ) summ
FROM (
SELECT 
	YEAR(w.ReturnDate) Y,
	ga.AccGroupName,
	w.ReturnDate,
	c.CustomerName,
	c.CostCode,
	b.WaybillId,
	b.CustomerId,
	wcwt.Minutes,
	isnull(isnull(isnull(swi.km,so.km),b.km),0) km,
	isnull(isnull(swi.hourWork,so.hourWork),0) hourWork,
	isnull(isnull(swi.mkm+swi.mhour+ swi.mmass,so.allSumm),0) summ
FROM (
SELECT 
	WaybillId,
	CustomerId,
	SUM(km) km
FROM (
SELECT 
	w.WaybillId,
	wt.TaskId,
	wt.CustomerId,
	c.CostCode,
	CASE WHEN wt2.WorkUnitId = 1 THEN isnull(wt.WorkAmount,0) ELSE 0 END km
FROM Waybill w
LEFT JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId
LEFT JOIN Customer c ON c.CustomerId = wt.CustomerId
LEFT JOIN _Norm n ON n.NormId = wt.NormConsumptionId
LEFT JOIN WorkType wt2 ON wt2.WorkTypeId = n.WorkTypeId
WHERE 
	YEAR(returnDate) IN (2012,2013,2014)
	AND c.CostCode LIKE '90%'
)a group by WaybillId,CustomerId
)b
LEFT JOIN WaybillCustomerWorkingTime wcwt ON wcwt.WaybillId = b.WaybillId AND wcwt.CustomerId = b.CustomerId
LEFT JOIN Waybill w ON w.WaybillId = b.WaybillId
LEFT JOIN Vehicle v ON v.VehicleId = w.VehicleId
LEFT JOIN AccGroup ga ON ga.AccGroupId  = v.AccGroupId
LEFT JOIN _serviceWaybillsInfo swi ON swi.waybillNumber =  (CASE WHEN w.ReplicationId IS NOT NULL THEN w.WaybillNumber ELSE w.WaybillId end)
LEFT JOIN _ServiceOrders so ON so.WaybillNumber = (CASE WHEN w.ReplicationId IS NOT NULL THEN w.WaybillNumber ELSE w.WaybillId end)
LEFT JOIN Customer c ON c.CustomerId = b.CustomerId
)c
group by Y,AccGroupName,CostCode
ORDER BY AccGroupName,c.CostCode,y


