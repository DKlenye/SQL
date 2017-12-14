DECLARE @month int,@year int 
SELECT @month = 01, @year = 2016

declare @start date
declare @end date
declare @daycount int
	
select 
	@start = CONVERT(date,'01.'+CAST(@month as varchar(2))+'.'+cast(@year as varchar(4)) ,104),
	@end = DATEADD(DAY,-1,DATEADD(MONTH,1,@start)),
	@daycount = DATEDIFF(Day,@start,@end)+1

DECLARE @SpecTransCustomers table (CustomerId int)
INSERT INTO @SpecTransCustomers
SELECT 1128 UNION SELECT 1438


DECLARE @Vehicles table(VehicleId int)
INSERT INTO @Vehicles
SELECT 
	v.VehicleId	
FROM Vehicle v 
WHERE 
	v.ColumnId IN (6,7,8) 
	AND v.DSC = 1
	AND v.RefuellingGroupId IN (1,31,3)
	AND isnull(v.BodyTypeId,0) not in (select BodyTypeId from BodyType where (BodyTypeName like 'грузовой специальный%' and BodyTypeId not in (14,36)) OR v.BodyTypeId IN (7,74) ) 
	AND v.WriteOffDate IS null

DECLARE @Maintenance TABLE (VehicleId int, DayCount int)
INSERT INTO @Maintenance
SELECT VehicleId, SUM(dayCount) AS DayCount FROM (
SELECT
	m.VehicleId,
	DATEDIFF(DAY,
	CASE WHEN m.RequestDate<@start THEN @start ELSE m.RequestDate END,
	CASE WHEN isnull(m.EndRequest,GETDATE())>@end THEN @end ELSE isnull(m.EndRequest,GETDATE()) END) +1
	as dayCount
FROM 
MaintenanceRequest m
WHERE m.RequestDate < @end AND isnull(m.EndRequest,GETDATE())>=@start
)a
GROUP BY VehicleId

DECLARE @rezult TABLE(VehicleId INT, RegistrationNumber VARCHAR(50), Model VARCHAR(100),GarageNumber INT, CapacityTonns DECIMAL(18,3),CapacityPassengers int,SpecTransMinutes INT, Minutes INT, SpecTransWorkDay INT, WorkDay INT, MaintenanceDayCount INT, DayCount INT, tonnDayCount decimal(18,3), passDayCount DECIMAL (18,3))
INSERT INTO @rezult
SELECT 
e.*,
@daycount dayCount,
isnull(CapacityTonns,0) * @daycount as tonnDayCount,
ISNULL(CapacityPassengers,0) * @daycount as passDayCount
FROM (
	SELECT 
		d.VehicleId,
		vv.RegistrationNumber,
		vv.Model,
		vv.GarageNumber,
		case when vv.BodyTypeId = 37 THEN 20 else vv.CapacityTonns END CapacityTonns,
		vv.CapacityPassengers,	
		SpecTransMinutes,
		isnull(Minutes,0) Minutes,
		isnull(SpecTransWorkDay,0) SpecTransWorkDay,
		isnull(case when WorkDay>@daycount THEN WorkDay/2 ELSE WorkDay END,0) AS WorkDay,
		isnull(m.DayCount,0) as MaintenanceDayCount		
	FROM (
		SELECT 
			VehicleId,
			SUM(CASE WHEN SpecTrans = 1 THEN Minutes ELSE 0 END) AS SpecTransMinutes,
			SUM(CASE WHEN SpecTrans = 0 THEN Minutes ELSE 0 END) AS Minutes,
			SUM(CASE WHEN SpecTrans = 1 THEN WorkDayCount ELSE 0 END) AS SpecTransWorkDay,
			SUM(CASE WHEN SpecTrans = 0 THEN WorkDayCount ELSE 0 END) AS WorkDay
		FROM (
			SELECT 
				b.WaybillId,
				b.VehicleId,
				b.Minutes,
				b.SpecTrans,
				COUNT(ww.WorkDate) WorkDayCount
			FROM (
				SELECT 
					WaybillId,
					VehicleId,
					SUM(Minutes) Minutes,
					MAX(SpecTrans) SpecTrans
				FROM (
				SELECT
					wcwt.Minutes,
					w.WaybillId,
					w.VehicleId, 
					CASE WHEN wcwt.CustomerId IN (SELECT CustomerId FROM  @SpecTransCustomers) THEN 1 ELSE 0 END AS SpecTrans
				FROM Waybill w
				LEFT JOIN WaybillCustomerWorkingTime wcwt ON wcwt.WaybillId = w.WaybillId 
				WHERE w.ReturnDate > @start AND w.ReturnDate < @end AND  w.WaybillState>1
				)a
				GROUP BY WaybillId, VehicleId
			)b
			LEFT JOIN WaybillWork ww ON ww.WaybillId = b.WaybillId
			GROUP BY b.WaybillId, b.VehicleId, b.Minutes, b.SpecTrans
		)c
		GROUP BY VehicleId
	)d
	LEFT JOIN @Vehicles v ON v.VehicleId = d.VehicleId
	LEFT JOIN @Maintenance m ON m.VehicleId = v.VehicleId
	LEFT JOIN Vehicle vv ON vv.VehicleId = v.VehicleId
)e

DELETE FROM @rezult WHERE GarageNumber IS NULL

SELECT 
r.*,
g.RefuellingGroupName
FROM @rezult r
INNER JOIN Vehicle v ON v.VehicleId = r.VehicleId
inner join RefuellingGroup g on g.RefuellingGroupId = (case when v.RefuellingGroupId = 31 THEN 1 ELSE v.RefuellingGroupId END) and g.RefuellingGroupId in (1,3)
ORDER BY g.RefuellingGroupName,r.GarageNumber
