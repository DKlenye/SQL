declare @month int, @year int
SELECT @month=3,@year=2013


--DELETE FROM WaybillWork
INSERT INTO WaybillWork
SELECT 
	a.WaybillId,
	w.ReturnDate,
	sum(CASE WHEN wrk.WorkUnitId=1 THEN isnull(wt.workAmount,0) else 0 END) km,	
	SUM(CASE wrk.WorkUnitId  
			WHEN 2 THEN cast( round (isnull(wt.workAmount,0)/isnull(n.MotoToMachineKoef,1),2) AS DECIMAL(18,2))
			WHEN 3 THEN cast( round (isnull(wt.workAmount,0)/isnull(n.MotoToMachineKoef,1),2) AS DECIMAL(18,2))		
			else 0 
		END) mh,
	SUM(CASE wrk.WorkUnitId  
			WHEN 2 THEN CASE WHEN isnull(n.MotoToMachineKoef,1)<>1 THEN isnull(wt.workAmount,0) ELSE  cast( round (isnull(wt.workAmount,0) * 0.7,1) AS DECIMAL(18,2)) END
			WHEN 3 THEN CASE WHEN isnull(n.MotoToMachineKoef,1)<>1 THEN isnull(wt.workAmount,0) ELSE  cast( round (isnull(wt.workAmount,0) * 0.7,1) AS DECIMAL(18,2)) END
			else 0 
		END) moto,
		a.Norm,
		a.Fact,	
		w.VehicleId
FROM (
SELECT 
	WaybillId,
	SUM(Fact) Fact,
	SUM(Norm) Norm
from ft_AccWaybillFactNorm(@month,@year,1,null)
GROUP BY (WaybillId)
)a
inner JOIN WaybillTask wt ON wt.WaybillId = a.WaybillId
inner JOIN _Norm n ON n.NormId = wt.NormConsumptionId 
inner JOIN WorkType wrk ON wrk.WorkTypeId = n.WorkTypeId
inner JOIN Waybill w ON w.WaybillId = a.WaybillId
GROUP BY a.WaybillId,a.Fact,a.Norm,w.VehicleId,	w.ReturnDate

/*
INSERT INTO WaybillWork
SELECT 
	w.WaybillId,
	w.ReturnDate,
	sum(CASE WHEN wrk.WorkUnitId=1 THEN isnull(wt.workAmount,0) else 0 END) km,	
	0,
	0,
	0,
	0,
	wt.TrailerId
FROM Waybill w
INNER JOIN WaybillTask wt on wt.WaybillId = w.WaybillId
inner JOIN _Norm n ON n.NormId = wt.NormConsumptionId 
inner JOIN WorkType wrk ON wrk.WorkTypeId = n.WorkTypeId
WHERE w.WaybillState = 2 AND (w.AccPeriod>=201303 OR w.AccPeriod IS null) AND wt.TrailerId IS NOT NULL
GROUP BY w.WaybillId,	w.ReturnDate,wt.TrailerId
*/



