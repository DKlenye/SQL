
DECLARE @date date
SET @date='01.01.2014'

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
) AND FuelId = 2

DELETE FROM @VehicleFuel WHERE VehicleId IN (
SELECT VehicleId FROM @VehicleFuel WHERE FuelId IN (3,7)
GROUP BY VehicleId
HAVING COUNT(FuelId)>1
) AND FuelId = 7



DECLARE @Consumption TABLE(VehicleId INT, accPeriod INT, FuelId INT, Consumption DECIMAL(18,3))
INSERT INTO @Consumption
SELECT 
			VehicleId,
			AccPeriod,
			FuelId,
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
		INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId AND v.OwnerId = 1 AND isnull(v.ColumnId,5)<>5
		LEFT JOIN WaybillFuelRemain wfr ON wfr.WaybillId = w.WaybillId
		LEFT JOIN VehicleRefuelling vr ON vr.WaybillId = w.WaybillId AND vr.FuelId = wfr.FuelId
		WHERE w.AccPeriod >=(@year-1)*100+01 AND w.AccPeriod<=@year*100+01
		GROUP BY w.WaybillId,w.AccPeriod,w.VehicleId, wfr.DepartureRemain, wfr.ReturnRemain, wfr.FuelId
	)b
	WHERE b.FuelId IS NOT null
	GROUP BY VehicleId,	AccPeriod,	FuelId


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
		Consumption
	FROM (
		SELECT 
		sum(rgf) Consumption,
		gar_n+20000 GarageNumber,
		rep
		FROM _PolymirWaybill WHERE rep IN (201301,201302)
		and gar_n<>0
		GROUP BY gar_n,rep
	)a
	LEFT JOIN Vehicle v ON v.ReplicationSource = 2 AND v.GarageNumber+20000=a.GarageNumber
	LEFT JOIN @VehicleFuel vf ON vf.VehicleId = v.VehicleId
	
		
END





SELECT 
	isnull(g.E0,0) E0,
	isnull(g.E1,0) E1,
	isnull(g.E2,0) E2,
	isnull(g.E3,0) E3,
	isnull(g.E4,0) E4,
	isnull(g.E5,0) E5,
	isnull(c.AllCount,0) AllCount,
	isnull(c.Y11,0) Y11,
	isnull(c.Y10,0) Y10,
	isnull(c.Y7,0) Y7,
	isnull(c.Y3,0) Y3,
	d.*,
	f.FuelName,
	f.WeightCoeff,
	d.Consumption*f.WeightCoeff AS Tonn,
	case when rg.RefuellingGroupId=4 THEN 'Строительная техника' ELSE  rg.RefuellingGroupName END RefuellingGroupName
FROM (
	SELECT 
		RefuellingGroupId,
		fuelId,
		COUNT(VehicleId) AllCount,
		SUM(Y11) Y11,
		SUM(Y10) Y10,
		SUM(Y7) Y7,
		SUM(Y3) Y3
	FROM (
	SELECT 
		a.*,	
		v.GarageNumber,
		vf.FuelId,
		case 
						when rg.RefuellingGroupId IN (9,10,11) 
							THEN 2 
							ELSE 
									case WHEN rg.RefuellingGroupId IN (4,5,19,30) 
										THEN 4 
										ELSE rg.RefuellingGroupId 
									END
					END RefuellingGroupId
	FROM (
		SELECT 11 AS YearCount ,1 as Y11,0 AS Y10, 0 AS Y7, 0 AS Y3  ,VehicleId  FROM Vehicle WHERE @year-isnull(MakeYear,2000) >=10 
		UNION ALL
		SELECT 10 AS YearCount , 0,1,0,0 ,VehicleId  FROM Vehicle WHERE @year-isnull(MakeYear,2000) >=7 AND @year-isnull(MakeYear,2000)<10
		UNION ALL
		SELECT 7 AS YearCount ,0,0,1,0,VehicleId  FROM Vehicle WHERE @year-isnull(MakeYear,2000) >=3 AND @year-isnull(MakeYear,2000)<7
		UNION ALL
		SELECT 3 AS YearCount ,0,0,0,1, VehicleId  FROM Vehicle WHERE @year-isnull(MakeYear,2000) <3 
	)a
	INNER JOIN Vehicle v ON v.VehicleId = a.VehicleId AND v.OwnerId = 1 AND (v.WriteOffDate IS NULL OR v.WriteOffDate>@writeOffDate) AND isnull(v.ColumnId,5)<>5
	INNER JOIN RefuellingGroup rg ON rg.RefuellingGroupId = v.RefuellingGroupId AND rg.RefuellingGroupId IN (1,2,3,9,10,11,31,6, 4,5,19,30)
	LEFT JOIN @VehicleFuel vf ON vf.VehicleId = a.VehicleId 
	)b
	GROUP BY RefuellingGroupId,	fuelId
)c
RIGHT JOIN (
	
		SELECT 
	RefuellingGroupId,
	FuelId,
	SUM(consumption)/1000 Consumption
FROM (
	SELECT 
				case 
						when rg.RefuellingGroupId IN (9,10,11) 
							THEN 2 
							ELSE 
									case WHEN rg.RefuellingGroupId IN (4,5,19,30) 
										THEN 4 
										ELSE rg.RefuellingGroupId 
									END
					END RefuellingGroupId,
					c.FuelId,
					c.Consumption
			FROM @Consumption c
			inner JOIN Vehicle v ON v.VehicleId = c.VehicleId AND v.OwnerId = 1 AND isnull(v.ColumnId,5)<>5
			INNER JOIN RefuellingGroup rg ON rg.RefuellingGroupId = v.RefuellingGroupId AND rg.RefuellingGroupId IN (1,2,3,9,10,11,31,6, 4,5,19,30)
	)a
	GROUP BY RefuellingGroupId, FuelId
)d ON d.RefuellingGroupId = c.RefuellingGroupId AND d.FuelId = c.FuelId

LEFT JOIN (
	SELECT 
	RefuellingGroupId,
	FuelId,
	SUM(E0) E0,
	SUM(E1) E1,
	SUM(E2) E2,
	SUM(E3) E3,
	SUM(E4) E4,
	SUM(E5) E5
FROM (
SELECT 
		case 
				when rg.RefuellingGroupId IN (9,10,11) 
					THEN 2 
						ELSE 
							case WHEN rg.RefuellingGroupId IN (4,5,19,30) 
								THEN 4 
								ELSE rg.RefuellingGroupId 
							END
					END RefuellingGroupId,
					vf.FuelId,
					 E0,
					 E1,
					 E2,
					 E3,
					 E4,
					 E5				
	FROM (
	SELECT 
		v.VehicleId,
	  case when isnull(v.EcologyClassId,1)=1 THEN 1 ELSE 0 end E0,
	  case when isnull(v.EcologyClassId,1)=2 THEN 1 else 0 end E1,
	  case when isnull(v.EcologyClassId,1)=3 THEN 1 else 0 end E2,
	  case when isnull(v.EcologyClassId,1)=4 THEN 1 else 0 end E3,
	  case when isnull(v.EcologyClassId,1)=5 THEN 1 else 0 end E4,
	  case when isnull(v.EcologyClassId,1)=6 THEN 1 else 0 end E5
	FROM Vehicle v
	)a
	INNER JOIN Vehicle v ON v.VehicleId = a.VehicleId AND v.OwnerId = 1 AND (v.WriteOffDate IS NULL OR v.WriteOffDate>@writeOffDate) AND isnull(v.ColumnId,5)<>5
	INNER JOIN RefuellingGroup rg ON rg.RefuellingGroupId = v.RefuellingGroupId AND rg.RefuellingGroupId IN (1,2,3,9,10,11,31,6, 4,5,19,30)
	LEFT JOIN @VehicleFuel vf ON vf.VehicleId = a.VehicleId 
		
	)b
	GROUP BY RefuellingGroupId, FuelId

) g ON d.RefuellingGroupId = g.RefuellingGroupId AND d.FuelId = g.FuelId
LEFT JOIN Fuel f ON f.FuelId = d.FuelId
LEFT JOIN RefuellingGroup rg ON rg.RefuellingGroupId = d.RefuellingGroupId
ORDER by rg.RefuellingGroupName,f.FuelName

				
				
				

