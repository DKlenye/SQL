alter PROC ssrs_BNC   @start datetime, @end DATETIME, @isSpectrans bit
AS 
--SELECT @start = '01.01.2016', @end = '31.12.2016'

DECLARE @dates TABLE(Dat DATETIME, GarageNumber int)
INSERT INTO @dates
SELECT c.dat,tf.garageNumber FROM dbo.Calendar(@start,@end) AS c
INNER JOIN transportFacilities AS tf ON 1=1
WHERE tf.ownerId =3 AND (tf.writeOff IS NULL OR tf.writeOff>@start) AND tf.groupAccId NOT IN (7,24,25,26,28,29)

--SELECT * FROM transportFacilities AS tf WHERE tf.ownerId = 3

--SELECT * FROM groupAcc AS ga
/*
INSERT INTO TempBnc
		SELECT 
			b.garageNumber,
			taskDate Dat,
			'Бурец В.И.' CustomerName,
			diff workHours,
			km,
			0 summ,
			Way,
			'Производственная необходимость' Purpose
		FROM (
			SELECT 
				garageNumber,
				diff,
				Way,
				taskDate,
				sum(km) km
			FROM (
			SELECT 
				w.waybillNumber,
				w.garageNumber,
				CASE WHEN DATEDIFF(minute,w.departureDate,w.returnDate)*1.0/60>24 THEN 8.75 ELSE DATEDIFF(minute,w.departureDate,w.returnDate)*1.0/60 END  diff,
				CASE WHEN s.scheduleId = 5 THEN 'Коммандировка '+w.way ELSE 'Обычный. Внутренние линии' END Way,
				dbo.StrToDate(dbo.dateToStr(wt.taskBeginDate)) taskDate,
				wt.km
			FROM Waybills w 
			LEFT JOIN waybillsTasks AS wt ON wt.waybillNumber = w.waybillNumber
			LEFT JOIN schedule AS s ON s.scheduleId = w.scheduleId
			WHERE w.waybillState = 2 AND  w.departureDate >@start AND w.departureDate<@end AND w.ownerId = 3 AND wt.customerId IS  NOT NULL
			)a
			GROUP BY garageNumber,diff,Way,taskDate
		)b
*/


SELECT
	tf.GarageNumber VehicleId,
	tf.GarageNumber,
	tf.Model,
	tf.RegistrationNumber,
	d.Dat,
	MONTH(d.Dat) [Month],
	m.monthName,
	DAY(d.Dat) [Day],
	CustomerName,
	workHours,
	km,
	c.summ,
	Way,
	c.Purpose,
	CASE WHEN c.Purpose IS NULL THEN 0 ELSE 1 END K
FROM @dates d
LEFT JOIN TempBnc c ON c.Dat = d.Dat AND c.GarageNumber = d.GarageNumber
LEFT JOIN monthes AS m ON m.monthId = MONTH(d.Dat)
LEFT JOIN transportFacilities AS tf ON tf.ownerId = 3 AND tf.garageNumber = d.garageNumber
WHERE len(tf.model)>1
ORDER BY tf.garageNumber, d.Dat

