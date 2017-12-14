ALTER PROC ssrs_BNC @start date, @end DATE, @isSpectrans bit
 as
--SELECT @start = '01.01.2016', @end = '31.12.2016', @isSpectrans = 1


DECLARE @firstDate table(VehicleId INT, FirstDate Date)
INSERT INTO @firstDate
SELECT 
	w.VehicleId,
	cast (w.DepartureDate AS Date)	
FROM (
	SELECT 
		VehicleId,
		MIN(Position) Position
	FROM Waybill 
	GROUP BY VehicleId
	)a
LEFT JOIN Waybill w ON w.VehicleId = a.VehicleId AND w.Position = a.Position


DECLARE @vehicles TABLE(VehicleId int, dateBegin date, dateEnd date, FondDayCount INT, ScheduleMinutes INT)
INSERT INTO @vehicles
SELECT 
	b.VehicleId,
	b.dateBegin,
	b.dateEnd,
	CASE WHEN s.IsWeekendWork = 1
		THEN (select count(dat) from dbo.Calendar(b.dateBegin,b.dateEnd))
		ELSE (select count(dat) from dbo.Calendar(b.dateBegin,b.dateEnd) WHERE isWorkDay = 1 AND isHoliday = 0) 
		END AS FondDayCount,
	s.WorkMinutes
FROM (
	SELECT 
		VehicleId,
		CASE WHEN dateBegin <@start THEN @start ELSE dateBegin END dateBegin,
		CASE WHEN ISNULL(dateEnd,GETDATE())>@end THEN @end ELSE ISNULL(dateEnd,GETDATE()) end dateEnd
	FROM (
	SELECT 
		v.VehicleId,
		isnull(v.NotUsedDate,v.WriteOffDate) dateEnd,
		isnull(d.FirstDate,v.InputDate) dateBegin 
	FROM Vehicle v
	LEFT JOIN @firstDate d ON d.VehicleId = v.VehicleId
	WHERE 
		v.OwnerId = 1 AND
		v.DSC = 1
	)a
)b
LEFT JOIN Vehicle v ON v.VehicleId = b.VehicleId
LEFT JOIN Schedule s ON s.ScheduleId = isnull(v.ScheduleId,1)
WHERE dateBegin IS NOT NULL AND dateEnd>=@start 


/*
INSERT INTO TempBNC
SELECT 
		a.VehicleId,
		a.TaskDepartureDate,
		a.CustomerId,
		a.km,
		isnull(ISNULL(swi.hourWork,(wcwt.Minutes*1.0/60)),8) AS workHours,
		swi.mhour+swi.mkm AS summ,
		CASE WHEN w.ScheduleId = 6 THEN 'Коммандировка '+w.Way ELSE 'Обычный.Внутренние линии' END Way
	FROM (
		SELECT 
			w.WaybillId,
			w.VehicleId,
			cast(wt.TaskDepartureDate AS DATE) TaskDepartureDate,
			wt.CustomerId,
			sum(isnull(CASE WHEN wt2.WorkUnitId=1 THEN isnull(wt.WorkAmount,0) ELSE 0 END,0)) km
		FROM Waybill AS w
		LEFT JOIN WaybillTask AS wt ON wt.WaybillId = w.WaybillId
		LEFT JOIN _Norm n ON n.NormId = wt.NormConsumptionId
		LEFT JOIN WorkType wt2 ON wt2.WorkTypeId = n.WorkTypeId
		WHERE
		w.WaybillState>1 AND 
		CAST(w.ReturnDate AS DATE) BETWEEN @start AND @end
		GROUP BY w.WaybillId, w.VehicleId, cast(wt.TaskDeparturedate AS Date),wt.CustomerId
	)a
	LEFT JOIN WaybillCustomerWorkingTime AS wcwt ON wcwt.WaybillId = a.WaybillId AND wcwt.CustomerId = a.CustomerId
	LEFT JOIN ServiceWaybillsInfo AS swi ON swi.CustomerId = wcwt.CustomerId AND swi.waybillNumber = a.WaybillId
	LEFT JOIN waybill w ON w.WaybillId = a.WaybillId
	LEFT JOIN Schedule e ON e.ScheduleId = w.ScheduleId
	WHERE a.TaskDepartureDate IS NOT NULL

	*/


DECLARE @dates TABLE(Dat DATE, VehicleId int)
INSERT INTO @dates
SELECT c.dat, v.VehicleId  FROM dbo.Calendar(@start, @end) AS c
LEFT JOIN @vehicles v ON 1=1



DECLARE @columns TABLE (ColumnId INT)

IF(@isSpectrans = 0 )
INSERT INTO @columns 
SELECT ColumnId FROM TransportColumn WHERE AccountingId IN (1,2)
ELSE
INSERT INTO @columns 
SELECT ColumnId FROM TransportColumn WHERE AccountingId IN (3)

SELECT
	v.VehicleId,
	v.GarageNumber,
	v.Model,
	v.RegistrationNumber,
	d.Dat,
	MONTH(d.Dat) [Month],
	m.MonthName,
	DAY(d.Dat) [Day],
	c.CustomerName,
	t.workHours,
	t.km,
	t.summ,
	t.Way,
	CASE WHEN t.Way IS NULL THEN NULL ELSE 'Производственная необходимость' END Purpose,
	CASE WHEN t.TaskDepartureDate IS NULL THEN 0 ELSE 1 END  K
FROM @dates d
LEFT JOIN  TempBNC t ON t.VehicleId = d.VehicleId AND t.TaskDepartureDate = d.Dat
INNER JOIN Vehicle v ON v.VehicleId = d.VehicleId AND v.ColumnId IN (SELECT ColumnId FROM @columns)
LEFT JOIN Customer c ON c.CustomerId = t.CustomerId
LEFT JOIN Monthes AS m ON m.Id = MONTH(d.Dat)
ORDER BY v.VehicleId, d.Dat