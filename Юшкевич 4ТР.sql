
SELECT 
	groupAccName,
	Q,
	sum(km) km,
	sum(mass) mass,
	sum(massRace)massRace,
	sum(passengers) passengers,
	sum(passKm) passKm
FROM (
SELECT 
	w.waybillNumber,
	departureDate,
		case when MONTH(departureDate) IN (1,2,3) THEN 1 WHEN MONTH(departureDate) IN (4,5,6) THEN 2 when MONTH(departureDate) IN (7,8,9) THEN 3 when MONTH(departureDate) IN (10,11,12) THEN 4 END  AS Q,
	wt.waybillTaskId,
	wt.km,
	wt.mass,
	wt.massRace*mass massRace,
	wt.passengers,
	wt.passengers*wt.km AS passKm,
	g.groupAccName
FROM waybills w 
INNER JOIN waybillsTasks AS wt ON wt.ownerId = w.ownerId AND wt.waybillNumber = w.waybillNumber AND wt.garageNumber = w.garageNumber
INNER JOIN transportFacilities AS tf ON tf.ownerId = w.ownerId AND tf.garagenumber = w.garageNumber
INNER JOIN groupAcc g ON g.groupAccId = tf.groupAccId 
WHERE YEAR(departureDate) = 2016 AND w.ownerId = 3
)a
group by groupAccName,	Q
ORDER BY 1,2