DECLARE @start date , @end date
SELECT @start = '01.01.2015', @end = '01.03.2015'


DECLARE @dayCount int
SELECT @dayCount = count(dat) from dbo.Calendar(@start,@end) WHERE isWorkDay = 1 AND isHoliday = 0



SELECT 
	isnull(GroupRequestName,'Нет группы'),
	COUNT(VehicleId) VCount,
	SUM(_DayCount) _DayCount,
	SUM(MaintenanceDay) MaintenanceDay,
	AVG(K) K
FROM (
SELECT 
	isnull(gr.GroupRequestName,vog.VehicleOilGroupName) GroupRequestName ,
	v.GarageNumber,
	v.VehicleId,
	_DayCount,
	MaintenanceDay,
	CASE WHEN _DayCount-MaintenanceDay<0 THEN 0 else (_DayCount*1.00-MaintenanceDay*1.00)/_DayCount*1.00 end K
FROM (
SELECT 
	v.VehicleId,
	isnull(m.DayCount,0) MaintenanceDay,
	CASE WHEN isnull(v.NotUsedDate,v.WriteOffDate) IS NULL OR isnull(v.NotUsedDate,v.WriteOffDate) NOT BETWEEN @start AND @end then @dayCount ELSE (select count(dat) from dbo.Calendar(@start,isnull(v.NotUsedDate,v.WriteOffDate)) WHERE isWorkDay = 1 AND isHoliday = 0) END _DayCount	
FROM Vehicle v 
LEFT JOIN (
	SELECT 
		VehicleId,
		SUM(DayCount) DayCount
	FROM (
	SELECT 
		VehicleId,
		(SELECT COUNT(*) FROM dbo.Calendar(StartDate,EndDate) WHERE isWorkDay = 1 AND isHoliday = 0) DayCount
	FROM (
	SELECT 
		v.VehicleId,
		case when mr.RequestDate<@start THEN @start ELSE mr.RequestDate END StartDate,
		case when isnull(mr.EndRequest,@end)>@end THEN @end ELSE isnull(mr.EndRequest,@end) END EndDate
	FROM MaintenanceRequest mr 
	INNER JOIN Vehicle v ON v.VehicleId = mr.VehicleId AND v.OwnerId = 1 AND (v.WriteOffDate IS NULL OR v.WriteOffDate>@start) AND	(v.NotUsedDate IS NULL OR v.NotUsedDate>@start)
	WHERE RequestDate BETWEEN @start AND @end
	OR	(RequestDate<@start AND isnull(EndRequest,@end) >=@start)
	)a
	)b
	GROUP BY VehicleId
)m ON m.VehicleId = v.VehicleId

WHERE 
	v.OwnerId = 1 AND dsc =1 and
	(v.WriteOffDate IS NULL OR v.WriteOffDate>@start) AND 
	(v.NotUsedDate IS NULL OR v.NotUsedDate>@start)
)a
LEFT JOIN Vehicle v ON v.VehicleId = a.VehicleId
LEFT JOIN GroupRequest gr ON gr.GroupRequestId = v.GroupRequestId
LEFT JOIN VehicleOilGroup vog ON vog.VehicleOilGroupId = v.VehicleOilGroupId
)b
WHERE GroupRequestName IS NOT null
GROUP BY GroupRequestName

