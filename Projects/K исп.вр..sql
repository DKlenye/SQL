DECLARE @start date , @end date
SELECT @start = '01.01.2015', @end = '01.03.2015'

DECLARE @dayCount int
SELECT @dayCount = count(dat) from dbo.Calendar(@start,@end) WHERE isWorkDay = 1 AND isHoliday = 0

SELECT 
	v.VehicleId,
	a.FactMinutes,
	CASE WHEN isnull(v.NotUsedDate,v.WriteOffDate) IS NULL OR isnull(v.NotUsedDate,v.WriteOffDate) NOT BETWEEN @start AND @end then @dayCount ELSE (select count(dat) from dbo.Calendar(@start,isnull(v.NotUsedDate,v.WriteOffDate)) WHERE isWorkDay = 1 AND isHoliday = 0) END _DayCount	
FROM Vehicle v 
LEFT JOIN (
SELECT 
	w.VehicleId,
	sum(ww.Minutes) FactMinutes
FROM WaybillWorkingTime ww
INNER JOIN Waybill w ON w.WaybillId = ww.WaybillId
WHERE ww.TargetDate BETWEEN @start AND @end
GROUP BY w.VehicleId
)a ON a.VehicleId = v.VehicleId
WHERE 
	v.OwnerId = 1 AND dsc =1 and
	(v.WriteOffDate IS NULL OR v.WriteOffDate>@start) AND 
	(v.NotUsedDate IS NULL OR v.NotUsedDate>@start)