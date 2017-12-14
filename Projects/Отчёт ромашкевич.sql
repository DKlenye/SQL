Alter PROC ssrs_VehicleInfo1 @date date
as

DECLARE @year INT
SET @year=YEAR(@date)

DECLARE @writeOffDate date
SET @writeOffDate = '01.01.'+CAST(@year AS VARCHAR(4))

DECLARE @VehicleFuel TABLE(VehicleId INT, FuelId INT)
INSERT INTO @VehicleFuel
SELECT distinct v.VehicleId, nf.FuelId FROM Vehicle v
LEFT JOIN Norm n ON n.VehicleId = v.VehicleId AND isnull(n.isMain,0)=1
LEFT JOIN NormFuels nf ON nf.NormId = n.NormId
WHERE v.OwnerId = 1 

DELETE FROM @VehicleFuel WHERE FuelId IS null

DELETE FROM @VehicleFuel WHERE VehicleId IN (
SELECT VehicleId FROM @VehicleFuel WHERE FuelId IN (1,2)
GROUP BY VehicleId
HAVING COUNT(FuelId)>1
) AND FuelId = 1

DELETE FROM @VehicleFuel WHERE VehicleId IN (
SELECT VehicleId FROM @VehicleFuel WHERE FuelId IN (3,7)
GROUP BY VehicleId
HAVING COUNT(FuelId)>1
) AND FuelId = 7



DECLARE @Consumption TABLE(VehicleId INT, accPeriod INT, FuelId INT, Refuelling DECIMAL(18,3), Consumption DECIMAL(18,3))
INSERT INTO @Consumption
SELECT 
			VehicleId,
			AccPeriod,
			FuelId,
			Sum(ISNULL(Refuelling,0)) Refuelling,
			SUM(ISNULL(DepartureRemain,0)+ISNULL(Refuelling,0)-ISNULL(ReturnRemain,0)) Consumption
		FROM (
		SELECT 
			w.WaybillId,
			w.AccPeriod,
			w.VehicleId,
			wfr.DepartureRemain,
			wfr.ReturnRemain,
			wfr.FuelId ,
			sum(vr.Quantity) Refuelling
		FROM Waybill w
		INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId AND v.OwnerId = 1
		LEFT JOIN WaybillFuelRemain wfr ON wfr.WaybillId = w.WaybillId
		LEFT JOIN VehicleRefuelling vr ON vr.WaybillId = w.WaybillId AND vr.FuelId = wfr.FuelId
		WHERE w.AccPeriod >=(@year-1)*100+01 AND w.AccPeriod<=@year*100+01
		GROUP BY w.WaybillId,w.AccPeriod,w.VehicleId, wfr.DepartureRemain, wfr.ReturnRemain, wfr.FuelId
	)b
	WHERE b.FuelId IS NOT null
	GROUP BY VehicleId,	AccPeriod,	FuelId





DECLARE @Wate TABLE(VehicleId INT, FuelId INT, Waste DECIMAL(18,3))

INSERT INTO @Wate
SELECT VehicleId,
	FuelId,
	SUM(Waste) waste
	
from	(
SELECT 
	VehicleId,
	FuelId,
	Fact-Norm Waste
FROM (
SELECT 
	w.VehicleId,
	b.FuelId,
	ISNULL(DepartureRemain,0)+ISNULL(Refuelling,0)-ISNULL(ReturnRemain,0) Fact,
	b.NormConsumption Norm
FROM (
	SELECT 
		a.WaybillId,
		wfr.DepartureRemain,
		wfr.ReturnRemain,
		wfr.FuelId ,
		sum(vr.Quantity) Refuelling,
		a.NormConsumption
	FROM (
		SELECT 
			w.WaybillId,
			wt.FuelId,
			Sum(wt.Consumption) NormConsumption
		FROM Waybill w
		INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId AND v.OwnerId = 1
		INNER JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId
		WHERE w.AccPeriod >=(@year-1)*100+03 AND w.AccPeriod<=@year*100+01
		GROUP BY w.WaybillId,wt.FuelId
	)a
	LEFT JOIN WaybillFuelRemain wfr ON wfr.WaybillId = a.WaybillId AND wfr.FuelId = a.FuelId
	LEFT JOIN VehicleRefuelling vr ON vr.WaybillId = a.WaybillId AND vr.FuelId = wfr.FuelId
	GROUP BY a.WaybillId, wfr.DepartureRemain, wfr.ReturnRemain, wfr.FuelId ,	a.NormConsumption
)b
INNER JOIN waybill w ON w.WaybillId = b.WaybillId
)c
WHERE Fact-Norm >0
)d
GROUP BY d.VehicleId,d.FuelId

IF (@year = 2014)
BEGIN
	
	DELETE FROM @Consumption WHERE accPeriod IN (201301,201302) AND VehicleId IN (
		SELECT vehicleId FROM Vehicle WHERE ReplicationSource = 2	
	)
	
	INSERT INTO @Consumption
	SELECT 
		v.VehicleId,
		rep,
		vf.FuelId,
		Refuelling,
		Consumption
	FROM (
		SELECT 
		sum(rgf) Consumption,
		SUM(ISNULL(pol_oao,0)+ISNULL(pol_azs1,0)+ISNULL(pol_nr,0)+ISNULL(pol_azs2,0))Refuelling,
		gar_n+20000 GarageNumber,
		rep
		FROM _PolymirWaybill WHERE rep IN (201301,201302)
		and gar_n<>0
		GROUP BY gar_n,rep
	)a
	LEFT JOIN Vehicle v ON v.GarageNumber=a.GarageNumber AND v.OwnerId = 1
	LEFT JOIN @VehicleFuel vf ON vf.VehicleId = v.VehicleId		
END


DECLARE @work TABLE (VehicleId INT, km DECIMAL(18,3), mh DECIMAL(18,3), Passengers INT, tkm DECIMAL(18,3))

INSERT INTO @work
SELECT 
	w.VehicleId,
	SUM (CASE WHEN wrk.WorkUnitId=1 THEN isnull(wt.workAmount,0) else 0 end) km,
							SUM (CASE wrk.WorkUnitId  
									WHEN 2 THEN cast( round (wt.workAmount/isnull(n.MotoToMachineKoef,1),2) AS DECIMAL(18,2))
									WHEN 3 THEN cast( round (wt.workAmount/isnull(n.MotoToMachineKoef,1),2) AS DECIMAL(18,2))		
									else 0 
								end) mh,
		SUM(ISNULL(Passengers,0))Passengers,
		sum(isnull(WeightKm,0)*isnull(Weight,0)) Tkm	
FROM waybill w
INNER JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId
LEFT JOIN NormConsumption nc ON nc.RecId = wt.NormConsumptionId 
LEFT JOIN Norm n ON n.NormId = nc.NormId
LEFT JOIN WorkType wrk ON wrk.WorkTypeId = n.WorkTypeId
WHERE w.AccPeriod >=(@year-1)*100+01 AND w.AccPeriod<=@year*100+01
GROUP BY w.VehicleId
			
		
		
		
		
				
SELECT 
a.*,
w.km,
w.mh,
w.Passengers,
w.tkm,
wt.Waste,
v.GarageNumber,
v.Model,
bt.BodyTypeName,
v.MakeYear,
v.CapacityTonns,
v.CapacityPassengers,
f.FuelName
FROM Vehicle v 
LEFT JOIN (
	SELECT 
		SUM(isnull(Consumption,0)) Consumption,
		sum(ISNULL(Refuelling,0)) Refuelling ,
		c.FuelId,
		c.VehicleId
	FROM @Consumption c
	INNER JOIN @VehicleFuel vf ON vf.VehicleId = c.VehicleId AND c.FuelId = vf.FuelId
	GROUP BY c.fuelId,c.VehicleId
)a ON a.VehicleId = v.VehicleId
LEFT JOIN @work w ON w.VehicleId = v.VehicleId
LEFT JOIN @Wate wt ON wt.VehicleId = v.VehicleId AND wt.FuelId = a.fuelId
LEFT JOIN BodyType bt ON bt.BodyTypeId = v.BodyTypeId
LEFT JOIN Fuel f ON f.FuelId = a.fuelId
WHERE v.OwnerId = 1 AND (v.WriteOffDate IS NULL OR v.WriteOffDate>'01.01.2014') AND v.DSC = 1
AND a.FuelId IS NOT NULL
ORDER BY v.GarageNumber