DECLARE @start date, @end date

/*	
	коэффициент выхода транспорта на линию (КВЛ)
	K = Кол-во дней отработанных автомобилем / фонд рабочего времени
	
	коэффициент использования пробега (КИП)
	K = Пробег с грузом / Пробег общий
	
	коэффициент технической готовности (КТГ)
	К = фонд рабочего времени - дней в ремонте / фонд рабочего времени
	
	коэффициент использования рабочего времени (КИВ)
	К = 
	
	коэффициент использования грузоподъёмности (КИГ)
	K = масса перевезённого груза / грузоподъёмность
	
*/	

SELECT @start = '01.01.2015', @end = '01.05.2015'


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



--выбираем список машин и расчитываем фонд рабочего времени
SELECT 
	VehicleId,
	dateBegin,
	deteEnd,
	
FROM (
SELECT 
	VehicleId,
	CASE WHEN dateBegin <@start THEN @start ELSE dateBegin END dateBegin,
	CASE WHEN ISNULL(dateEnd,GETDATE())>@end THEN @end ELSE ISNULL(dateEnd,GETDATE()) end dateEnd 
FROM (
SELECT 
	v.VehicleId,
	isnull(v.NotUsedDate,CASE WHEN f.Inventory IS NULL THEN v.WriteOffDate ELSE f.dateEnd END) dateEnd, --если нет даты вывода из экспл, то берём дату списания по фондам, если нет по фондам то берём по нашему справочнику
	isnull(isnull(f.dateBegin,d.FirstDate),v.InputDate) dateBegin --если по фондам нет связи, то берём по путевому листу, если нету путёвок, то в справочнке дата ввода
FROM Vehicle v
left join db1.fond.dbo.vw_Fond0AvtoAll f ON f.Inventory = v.InventoryNumber AND f.idArm = 0
LEFT JOIN @firstDate d ON d.VehicleId = v.VehicleId
WHERE 
	v.OwnerId = 1 AND
	v.DSC = 1
)a
)a1 
	WHERE dateBegin IS NOT NULL AND dateEnd>@start 


SELECT 
	*
FROM (
	SELECT 
		VehicleId,
		SUM(km) km,
		SUM(WeightKm) WeightKm,
		SUM(Weight) WEIGHT,
		SUM(CapacityTonns) CapacityTonns
	FROM (
		SELECT 
			w.WaybillId,
			w.VehicleId,
			isnull(wt.WeightKm,0) WeightKm,
			ISNULL(wt.[Weight],0) [Weight],
			ISNULL(v.CapacityTonns,0) CapacityTonns,
			ISNULL(v.CapacityPassengers,0) CapacityPassengers,
			CASE WHEN wt2.WorkUnitId=1 THEN isnull(wt.WorkAmount,0) ELSE 0 END km
		FROM Waybill w
		INNER JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId
		INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId
		LEFT JOIN _Norm n ON n.NormId = wt.NormConsumptionId
		LEFT JOIN WorkType wt2 ON wt2.WorkTypeId = n.WorkTypeId
		WHERE w.WaybillState > 1 AND cast (w.ReturnDate AS Date) BETWEEN @start AND @end
	)a
	GROUP BY VehicleId
)b

SELECT 
	VehicleId,
	SUM(dayCount) MaintenanceDayCount
FROM (
	SELECT 
		VehicleId,
		startDate,
		endDate, 
		DATEDIFF(DAY,startDate,endDate)+ 1 dayCount
	FROM (
	SELECT 
		VehicleId,
		CASE WHEN RequestDate < @start THEN @start ELSE RequestDate END startDate,
		CASE WHEN isnull(EndRequest,GETDATE())>@end THEN @end ELSE isnull(EndRequest,GETDATE()) END endDate
	FROM MaintenanceRequest  
	WHERE 
		(RequestDate BETWEEN @start AND @end  OR
		EndRequest IS NULL OR 
		EndRequest BETWEEN @start AND @end) 
		AND RequestDate IS NOT null
	)b1
)b2 GROUP BY VehicleId


SELECT 
	VehicleId, COUNT(TargetDate) dayCount
FROM (
SELECT 
	DISTINCT
	w.VehicleId,
	wwt.TargetDate
FROM WaybillWorkingTime wwt
LEFT JOIN Waybill w ON w.WaybillId = wwt.WaybillId
WHERE wwt.TargetDate BETWEEN @start AND @end
)c1
GROUP BY VehicleId