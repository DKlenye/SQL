
DECLARE @month INT, @year INT
SELECT @month = 08, @year = 2015

SELECT 
	g.groupAccName,
	tf.ColumnId,
	tf.garageNumber,
	tf.registrationNumber,
	tf.model,	
	ft.BS,
	ft.SBS,
	f.fuelName,
	quantity,
	cast (r.quantity*fiw.worth AS INT) summ
FROM _reoilOther r
LEFT JOIN transportFacilities tf ON tf.ownerId = r.ownerId AND tf.garageNumber = r.garageNumber
LEFT JOIN GroupAcc g ON g.groupAccId = tf.groupAccId
LEFT JOIN ForTran ft ON ft.GroupAccid = g.groupAccId
LEFT JOIN FuelIncomeWorth fiw ON fiw.ownerId = r.ownerId AND fiw.fuelId = r.fuelId AND fiw.accYear = @year AND fiw.accMonth = @month
LEFT JOIN fuel f ON f.fuelId = r.fuelId
WHERE 
	r.ownerId = 1 AND
	MONTH(r.reoilDate)=@month AND
	YEAR(r.reoilDate)=@year AND
	r.placeId = 1
	AND tf.ColumnId NOT IN (2,4)
	AND r.fuelId NOT IN (44,46,49)
	
	

 
 
 
 