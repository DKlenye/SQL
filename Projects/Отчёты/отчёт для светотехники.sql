
DECLARE @start date, @end date, @garageNumber INT
SELECT @start = '13.12.2013', @end = '13.01.2014', @garageNumber = 20238


DECLARE @date date
SET @date = @start

DECLARE @Consumption TABLE (TargetDate Date, FuelId INT, Consumption DECIMAL(18,2) ,Km DECIMAL(18,3))
DECLARE @Refuelling TABLE (RefuellingDate Date, FuelId INT, Quantity DECIMAL(18,2))
DECLARE @PreRezult TABLE(TargetDate date, WaybillState INT, WaybillId INT, FuelId INT, StartRemain DECIMAL(18,2), RefuellingQuantity DECIMAL(18,2), Consumption DECIMAL(18,2), EndRemain DECIMAL(18,2), Km DECIMAL(18,2))
DECLARE @Rezult TABLE(TargetDate date, WaybillState INT, WaybillId INT, FuelId INT, StartRemain DECIMAL(18,2), RefuellingQuantity DECIMAL(18,2), Consumption DECIMAL(18,2), EndRemain DECIMAL(18,2), Km DECIMAL(18,2))

INSERT INTO @Consumption
SELECT 
	targetDate,
	fuelId,
	SUM(Consumption) Consumption,
	SUM(km) km
FROM (
SELECT 
	case WHEN wt.TaskDepartureDate<CAST(w.DepartureDate AS Date) OR wt.TaskDepartureDate>w.ReturnDate THEN CAST(w.DepartureDate AS date) ELSE  CAST(wt.TaskDepartureDate AS Date) END TargetDate,
	wt.FuelId,
	wt.Consumption,
	case when n.WorkTypeId=5 then isnull(wt.WorkAmount,0) ELSE 0 END km
FROM Waybill w
INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId AND v.GarageNumber = @garageNumber
INNER JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId
INNER JOIN NormConsumption nc ON nc.RecId = wt.NormConsumptionId
INNER JOIN Norm n ON n.NormId = nc.NormId
WHERE
w.DepartureDate>=@start AND w.ReturnDate<=DATEADD(day,1,@end)
)a
GROUP BY TargetDate, fuelId


INSERT INTO @Refuelling
SELECT 
	refuellingDate,
	FuelId,
	sum(Quantity) Quantity
FROM (
SELECT 
	cast(vr.RefuellingDate AS Date) refuellingDate,
	vr.FuelId,
	vr.Quantity
FROM VehicleRefuelling vr
INNER JOIN Waybill w ON w.WaybillId = vr.WaybillId
INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId AND v.GarageNumber = @garageNumber
WHERE vr.RefuellingDate>=@start AND vr.RefuellingDate<DATEADD(day,1,@end)
)a
GROUP BY refuellingDate,FuelId


WHILE @date<=@end

BEGIN


INSERT INTO @PreRezult
SELECT
	
	a.TargetDate,
	m.WaybillState,
	m.WaybillId,
	isnull(isnull(m.FuelId,c.FuelId),r.FuelId) FuelId,
	m.DepartureRemain,
	r.Quantity,	
	c.Consumption,
	0,
	c.Km
	
FROM (
SELECT @date AS TargetDate
)a
LEFT JOIN(
		SELECT 
		@date AS WaybillDate,
		a.WaybillId,
		WaybillState,
		wfr.FuelId,
		wfr.DepartureRemain,
		wfr.ReturnRemain
	FROM (
		SELECT 
			TOP 1 
			w.WaybillState,
			w.WaybillId
		FROM waybill w
		INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId AND v.GarageNumber = @garageNumber
		WHERE  w.ReturnDate>@date and cast(w.DepartureDate AS Date) = @date
		ORDER BY w.DepartureDate ASC
	)a
	LEFT JOIN WaybillFuelRemain wfr ON wfr.WaybillId = a.WaybillId
)m ON m.WaybillDate = a.TargetDate 
LEFT JOIN @Consumption c ON c.TargetDate = a.TargetDate AND c.FuelId = isnull(m.FuelId,c.FuelId)
LEFT JOIN @Refuelling r ON r.RefuellingDate = a.TargetDate AND r.FuelId = isnull(m.FuelId,c.FuelId)

if(SELECT TOP 1 FuelId FROM @PreRezult) IS NULL

BEGIN
	
	DELETE FROM @PreRezult
	INSERT INTO @PreRezult(TargetDate,FuelId,waybillState,StartRemain)
	SELECT @date,fuelId,r.WaybillState,EndRemain FROM @Rezult r WHERE r.TargetDate = DATEADD(DAY,-1,@date)	
	
END


--если это не путёвка, то нужно взять остаток из последних показаний
IF (SELECT TOP 1 WaybillState FROM @PreRezult) IS NULL

BEGIN
		
	UPDATE @PreRezult
		
	SET 
		WaybillState = r.WaybillState ,
		StartRemain = r.EndRemain
	FROM @PreRezult p
	LEFT JOIN @Rezult r ON p.FuelId = r.FuelId
	 WHERE r.TargetDate = DATEADD(DAY,-1,@date)	
	
END


UPDATE @PreRezult SET EndRemain = StartRemain + isnull(RefuellingQuantity,0) - isnull(Consumption,0)
		



INSERT INTO @Rezult
SELECT * FROM @PreRezult

DELETE FROM @PreRezult


SET @date = DATEADD(DAY,1,@date)

END


DELETE FROM @Rezult WHERE StartRemain IS NULL AND  refuellingQuantity IS NULL AND Consumption IS NULL AND km IS null
DELETE FROM @Rezult WHERE refuellingQuantity IS NULL AND Consumption IS NULL AND km IS null

SELECT r.*,f.FuelName FROM @Rezult r
LEFT JOIN Fuel f  ON f.FuelId = r.FuelId