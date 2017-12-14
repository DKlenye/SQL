DECLARE @year int
SET @year = 2013



SELECT 
	ag.AccGroupName,
	ag.CostCode,
	isPolymir,
	SUM(km) km,
	SUM(mh) mh,
	SUM(m) m
FROM (
SELECT 
	VehicleId,
	isPolymir,
	SUM(isnull(km,0)) km,
	SUM(isnull(mh,0)) mh,
	SUM(M) M
FROM (
SELECT 
	b.*,
	isnull(w.Minutes,0) M
FROM (
SELECT 
	VehicleId,
	WaybillId,
	CustomerId,
	isPolymir,
	SUM(km) km,
	SUM(mh) mh
FROM (
SELECT
	w.VehicleId, 
	w.WaybillId,
	wt.TaskId,
	isnull(c.isPolymir,0) isPolymir,
	c.CustomerId,
	CASE WHEN wrk.WorkUnitId=1 THEN wt.workAmount else null end km,
	--Если моточасы, то используем коэффициент для пересчёта в машиночасы	
		CASE wrk.WorkUnitId  
			WHEN 2 THEN  cast( round (wt.workAmount/isnull(n.MotoToMachineKoef,1),2) AS DECIMAL(18,2))
			WHEN 3 THEN cast( round (wt.workAmount/isnull(n.MotoToMachineKoef,1),2) AS DECIMAL(18,2))		
			else null
		end mh
FROM Waybill w
INNER JOIN Vehicle v ON v.OwnerId = 1 AND v.VehicleId = w.VehicleId
LEFT JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId
LEFT JOIN Customer c ON c.CustomerId = wt.CustomerId
LEFT JOIN _Norm n ON n.NormId = wt.NormConsumptionId
LEFT JOIN WorkType wrk ON wrk.WorkTypeId = n.WorkTypeId
WHERE isnull(w.ReplicationSource,0)<>2 AND w.AccPeriod BETWEEN @year*100+01 AND @year*100+12 --ReturnDate BETWEEN '01.01.2014' AND '31.12.2014'
)a 
GROUP BY VehicleId, WaybillId,	CustomerId,	isPolymir
)b
LEFT JOIN WaybillCustomerWorkingTime w ON b.CustomerId = w.CustomerId AND b.WaybillId = w.WaybillId
)c
group by VehicleId,isPolymir

UNION ALL

SELECT 
	v.VehicleId,
	1 isPolymir,
	pw.prob,
	pw.chas,
	sum(pwt.chas*60) M
FROM _PolymirWaybill pw
LEFT JOIN Vehicle v ON v.GarageNumber = 20000+pw.gar_n
LEFT JOIN _PolymirWaybillTask pwt ON pwt.npl = pw.npl
WHERE rep BETWEEN @year*100+01 AND @year*100+12
GROUP BY v.VehicleId,	pw.prob,	pw.chas
)al
LEFT JOIN Vehicle v ON v.VehicleId = al.VehicleId
LEFT JOIN AccGroup ag ON ag.AccGroupId = v.AccGroupId
group by ag.AccGroupName,ag.CostCode,isPolymir
ORDER BY ag.AccGroupName,al.isPolymir
