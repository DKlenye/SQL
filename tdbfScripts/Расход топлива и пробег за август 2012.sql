

alter PROC afa_econReport
AS

DECLARE @owner INT,@accyear INT, @month INT

SELECT @owner=1,@accyear = 2012,@month=8



SELECT 
	isnull(tso.subOwnerName,'не закреплено') subOwnerName,
	ga.groupAccName,
	f.fuelName,
	tf.garageNumber,
	tf.model,
	tf.registrationNumber,
	sum(isnull(w.returnKm,0)-isnull(w.departureKm,0)) km,
	sum(isnull(w.returnMh,0)-isnull(w.departureMh,0)) mh,
	sum(afc.normConsumption) normConsumption,
	sum(afc.normConsumption*fw.worth) normSumm
FROM waybills w
LEFT JOIN AccFuelConsumption afc ON afc.ownerId = w.ownerId AND afc.waybillnumber = w.waybillNumber AND afc.garagenumber = w.garageNumber
LEFT JOIN transportFacilities tf ON tf.ownerId = w.ownerId AND tf.garageNumber = w.garageNumber
LEFT JOIN TransportSubOwner tso ON tso.subOwnerId = tf.subOwnerId
LEFT JOIN fuel f ON f.fuelId = afc.fuelId
LEFT JOIN groupAcc ga ON ga.groupAccId= tf.groupAccId
LEFT JOIN fuelWorth fw ON fw.accYear = @accyear AND fw.accMonth = @month AND fw.OwnerId=@owner AND fw.fuelId = f.fuelId
WHERE w.ownerId = 1 AND w.accYear = @accyear AND w.accMonth = @month AND afc.fuelId is NOT NULL
GROUP BY tso.subOwnerName,ga.groupAccName,f.fuelName,tf.garageNumber,tf.model,tf.registrationNumber
ORDER BY 1,2,3,4


GRANT EXECUTE ON afa_econReport TO transp_2