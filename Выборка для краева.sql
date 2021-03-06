DECLARE  @start date, @end DATE

SELECT @start = '01.01.2016', @end = '01.12.2016'


--Выбираем первую дату по путевым листам
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
WHERE dateBegin IS NOT NULL AND datebegin<@end AND dateEnd>@start 



DECLARE @maintenance TABLE(VehicleId int, MaintenanceDayCount INT)
INSERT INTO @maintenance
SELECT 
	VehicleId,
	SUM(dayCount) MaintenanceDayCount
FROM (
	SELECT 
		b1.VehicleId,
		startDate,
		endDate, 
		case when s.IsWeekendWork = 1
			THEN DATEDIFF(DAY,startDate,endDate)+ 1
			ELSE DATEDIFF(DAY,startDate,endDate)+ 1 - (SELECT COUNT(dat) FROM dbo.Calendar(startDate,endDate)WHERE isWorkDay = 0 OR isHoliday = 1) 
			END	dayCount
	FROM (
	SELECT 
		VehicleId,
		CASE WHEN RequestDate < @start THEN @start ELSE RequestDate END startDate,
		CASE WHEN isnull(EndRequest,@end)>@end THEN @end ELSE isnull(EndRequest,@end) END endDate
	FROM MaintenanceRequest  
	WHERE 
		(RequestDate < @end  AND (
		EndRequest IS NULL OR 
		EndRequest > @start) )
		AND RequestDate IS NOT null
	)b1
	LEFT JOIN Vehicle v ON v.VehicleId = b1.VehicleId
	LEFT JOIN Schedule s ON s.ScheduleId = isnull(v.ScheduleId,1)
)b2 GROUP BY VehicleId


DECLARE @factDay TABLE(VehicleId INT, dayCount INT, WorkMinutes INT)
INSERT INTO @factDay
SELECT 
	VehicleId,
	COUNT(TargetDate) AS dayCount,
	SUM(WorkMinutes) WorkMinutes
FROM (
	SELECT	
		w.VehicleId,
		t.TargetDate,
		SUM(t.Minutes) AS WorkMinutes
	FROM WaybillWorkingTime t
	LEFT JOIN Waybill w ON w.WaybillId = t.WaybillId
	WHERE t.TargetDate BETWEEN @start AND @end
	GROUP BY w.VehicleId, t.TargetDate
) a
GROUP BY VehicleId


DECLARE @WaybillCustomerTime TABLE(VehicleId int, Minutes INT)
INSERT INTO @WaybillCustomerTime
SELECT w.VehicleId, SUM(t.Minutes) Minutes  FROM WaybillCustomerWorkingTime t
INNER JOIN Waybill w ON w.WaybillId = t.WaybillId
WHERE w.WaybillState > 1 AND cast (w.ReturnDate AS Date) BETWEEN @start AND @end
GROUP BY w.VehicleId


DECLARE @fondStart TABLE( inventory VARCHAR(20), ballanceCost DECIMAL(18,3), RemainCost decimal(18,3),Proclznos DECIMAL(18,3))

DECLARE @m INT, @y INT
SELECT @m = MONTH(@end), @y = YEAR(@end)

--insert INTO @fondStart
--EXEC db1.fond.dbo.spu_transport @y,@m


SELECT 
	isnull(bpg.BusinessPlanGroupName,rg.RefuellingGroupName),
	v.Model,
	1 AS Quantity,
	v.RegistrationNumber ,
	v.MakeYear,
	s.Proclznos,
	cast (round(case when FOND = 0 then 0 else ISNULL(dayCount,0)*1.00/FOND END,2) AS DECIMAL(18,2)) KVL,
	CASE WHEN tc.ColumnId IN (6,7,8,9,10,11,12,13) THEN 'УП "Нафтан-Спецтранс"' ELSE 'ОАО "Нафтан"' END s,
	d.DepartmentName
FROM (
SELECT 
	v.*,
	w.km,
	w.WeightKm,
	w.[WEIGHT],
	w.CapacityTonns,
	w.Passengers,
	w.CapacityPassengers,
	m.MaintenanceDayCount,
	f.dayCount,
	CASE WHEN dayCount > FondDayCount THEN dayCount ELSE FondDayCount END FOND,
	t.Minutes,
	CASE WHEN dayCount >= FondDayCount THEN f.WorkMinutes ELSE f.WorkMinutes + ((FondDayCount - dayCount)*v.ScheduleMinutes) END AS WorkMinutes
FROM @vehicles v
LEFT JOIN dbo.ft_VehicleWork(@start, @end) as w ON v.VehicleId = w.VehicleId
LEFT JOIN @maintenance m ON m.VehicleId = v.VehicleId
LEFT JOIN @factDay f ON f.VehicleId = v.VehicleId
LEFT JOIN @WaybillCustomerTime t ON t.VehicleId = v.VehicleId
)a
INNER JOIN Vehicle v ON v.VehicleId = a.VehicleId AND (v.WriteOffDate IS NULL OR v.WriteOffDate>= @end)
LEFT JOIN TransportColumn AS tc ON tc.ColumnId = v.ColumnId
LEFT JOIN BusinessPlanGroup AS bpg ON bpg.BusinessPlanGroupId = v.BusinessPlanGroupId
LEFT JOIN RefuellingGroup AS rg ON rg.RefuellingGroupId = v.RefuellingGroupId
LEFT JOIN @fondStart s ON s.inventory = v.InventoryNumber
LEFT JOIN Department AS d ON d.DepartmentId = v.DepartmentId
ORDER BY 8,1,2 
