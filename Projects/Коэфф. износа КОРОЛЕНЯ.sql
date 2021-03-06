declare  @start date , @end date
SELECT @start = '01.04.2015', @end = '01.05.2015'


DECLARE @dayCount int
SELECT @dayCount = count(dat) from dbo.Calendar(@start,@end) WHERE isWorkDay = 1 AND isHoliday = 0

DECLARE @allDayCount int
SELECT @allDayCount = count(dat) from dbo.Calendar(@start,@end)



/*SELECT 
	isnull(GroupRequestName,'Нет группы') GroupRequestName,
	COUNT(VehicleId) VCount,	
	SUM(FondMinutes) FondMinutes,
	SUM(FactMinutes) FactMinutes,
	AVG(K) K
FROM (*/
SELECT 
	aa.*,
	isnull(gr.GroupRequestName,vog.VehicleOilGroupName) GroupRequestName,
	aa._DayCount*aa.WorkHours*60.00 FondMinutes,
	aa.FactMinutes*1.00/(aa._DayCount*aa.WorkHours*60.00) K
FROM (
SELECT 
	v.GarageNumber,
	v.ScheduleId,
	v.VehicleId,
	ISNULL(a.FactMinutes,0) FactMinutes,
	CASE WHEN isnull(v.NotUsedDate,v.WriteOffDate) IS NULL OR isnull(v.NotUsedDate,v.WriteOffDate) NOT BETWEEN @start AND @end 
		THEN 
				CASE WHEN v.ScheduleId IN (3,4,5) OR v.GarageNumber NOT IN (1062,1063) THEN
					@dayCount
					ELSE 
					@allDayCount
					end 
		else
		CASE WHEN v.ScheduleId IN (3,4,5) OR v.GarageNumber NOT IN (1062,1063) THEN 
			(select count(dat) from dbo.Calendar(@start,isnull(v.NotUsedDate,v.WriteOffDate)))
			 ELSE  
			 (select count(dat) from dbo.Calendar(@start,isnull(v.NotUsedDate,v.WriteOffDate)) WHERE isWorkDay = 1 AND isHoliday = 0)
		end 
	end AS _DayCount,
	CASE v.GarageNumber
		WHEN 1062 THEN 16
		WHEN 1063 THEN 8
		else
	CASE v.ScheduleId 
		WHEN 3 THEN 11 
		WHEN 4 THEN 22
		WHEN 5 THEN 24
		ELSE 8
	END  
	END WorkHours
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
)aa

LEFT JOIN Vehicle v ON v.VehicleId = aa.VehicleId
LEFT JOIN GroupRequest gr ON gr.GroupRequestId = v.GroupRequestId
LEFT JOIN VehicleOilGroup vog ON vog.VehicleOilGroupId = v.VehicleOilGroupId
WHERE isnull(gr.GroupRequestName,vog.VehicleOilGroupName) LIKE '%легк%'
/*)b
GROUP BY GroupRequestName
*/