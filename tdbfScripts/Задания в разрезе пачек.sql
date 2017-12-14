--SELECT * FROM waybillsPackages wp
--WHERE wp.waybillPackageNumber IN (SELECT DISTINCT waybillPackageNumber  FROM Waybills WHERE accyear = 2012 AND accmonth = 8)


SELECT * FROM waybillsPackages

--SELECT DISTINCT waybillPackageNumber  FROM Waybills WHERE accyear = 2012 AND accmonth = 8


alter PROC afa_WaybillTaskByPackageNumber @packageNumber INT
as

DECLARE @ownerId INT
SELECT @ownerId=1


SELECT b.*,f.fuelName FROM (
SELECT 

a.*,
afc.normConsumption accConsumption

FROM (
	SELECT 
	w.ownerId,
	w.waybillNumber,
	w.formNumber,
	w.garageNumber,
	w.waybillPackageNumber,
	w.departureDate,
	w.returnDate,
	
	wfr.fuelId,
	wfr.departureRemain,
	wfr.returnRemain,
	sum(isnull(wr.quantity,0)) quantity,
	
	'' customerName
	
	FROM waybills w 
	LEFT JOIN waybillsFuelRemains wfr ON wfr.ownerId = w.ownerId AND wfr.waybillNumber = w.waybillNumber AND wfr.garageNumber = w.garageNumber
	LEFT JOIN waybillsRefuelling wr ON wr.ownerId = w.ownerId AND wr.waybillNumber = w.waybillNumber AND wr.garageNumber = w.garageNumber AND wfr.fuelId=wr.fuelId
	WHERE w.waybillPackageNumber = @packageNumber
	GROUP BY w.ownerId,w.waybillNumber,w.formNumber,w.garageNumber,w.waybillPackageNumber,w.departureDate,w.returnDate,wfr.fuelId,wfr.departureRemain,wfr.returnRemain
)a
LEFT JOIN AccFuelConsumption afc ON afc.ownerId = a.ownerId AND afc.waybillNumber = a.waybillNumber AND afc.garageNumber = a.garageNumber AND afc.fuelId = a.fuelId
--WHERE a.waybillPackageNumber=100010727

UNION ALL

SELECT 
	w.ownerId,
	w.waybillNumber,
	w.formNumber,
	w.garageNumber,
	w.waybillPackageNumber,
	wt.taskBeginDate,
	wt.taskBeginDate,
	
	fn.fuelId,
	NULL departureRemain,
	NULL returnRemain,
	NULL quantity,
	
	c.customerName,
	wt.accConsumption
	
FROM
Waybills w 
LEFT JOIN waybillsTasks wt ON wt.ownerId = w.ownerId AND wt.waybillNumber = w.waybillNumber AND wt.garageNumber = w.garageNumber
LEFT JOIN _customers c ON c.customerId = wt.customerId
LEFT JOIN fuelNorms fn ON fn.fuelNormId = wt.fuelNormId
WHERE w.waybillPackageNumber = @packageNumber
)b
inner JOIN vf_fuel f ON f.fuelId= b.fuelId 
ORDER BY b.waybillPackageNumber,b.garageNumber,b.waybillNumber,b.fuelId,b.customerName









afa_WaybillTaskByPackageNumber 2012,08










SELECT 
	w.waybillPackageNumber,
	w.garageNumber,
	w.waybillNumber,
	w.departureDate,
	w.returnDate,
	wfr.fuelId,
	wfr.departureRemain,
	isnull(r.quantity,0) quantity,
	wfr.returnRemain
	
	--c.customerName,
	--wt.accConsumption
	
FROM waybills w 
--LEFT JOIN waybillsTasks wt ON w.ownerId = wt.ownerId AND w.waybillNumber = wt.waybillnumber AND w.garageNumber = wt.garageNumber
--LEFT JOIN customers c ON c.customerId = wt.customerId
LEFT JOIN waybillsFuelRemains wfr ON wfr.ownerId = w.ownerId AND wfr.waybillNumber = w.waybillNumber AND wfr.garageNumber = w.garageNumber
LEFT JOIN (SELECT ownerId,waybillNumber,garageNumber,fuelId,sum(quantity) quantity FROM waybillsrefuelling GROUP BY ownerId,waybillNumber,garageNumber,fuelId) r ON r.ownerId = w.ownerId AND r.waybillNumber = w.waybillNumber AND w.garageNumber = r.garageNumber AND r.fuelId= wfr.fuelId
WHERE w.accYear = @accyear AND w.accMonth = @accmonth AND w.ownerId = @ownerId
ORDER BY w.waybillPackageNumber,w.garageNumber,w.waybillNumber


GRANT EXECUTE ON afa_WaybillTaskByPackageNumber TO transp_2










afa_WaybillTaskByPackageNumber 2012,8