

UPDATE waybilltask 
	SET waybilltask.TaskDepartureDate = w.DepartureDate 
select * FROM waybilltask wt 
INNER JOIN Waybill w ON w.WaybillId = wt.WaybillId AND ( wt.TaskDepartureDate<CAST(w.DepartureDate AS Date) OR wt.TaskDepartureDate>w.ReturnDate)
WHERE w.ReturnDate > '01.02.2014' AND w.WaybillState = 2