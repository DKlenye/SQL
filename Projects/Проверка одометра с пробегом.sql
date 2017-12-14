

DECLARE @position INT,@waybillId INT, @departure INT, @return INT, @VehicleId INT
SELECT @VehicleId = 20251


DECLARE @saveCounter INT
SET @saveCounter = null


declare ConsCur cursor 
for 
	
SELECT 
	isnull(ww.Position,w.Position) Position,
	isnull(ww.WaybillId,w.WaybillId) WaybillId,
	--a.km,
	isnull(wc.DepartureCount,wc2.DepartureCount) dc,
	isnull(wc.ReturnCount,wc2.ReturnCount) rc
	--isnull(wc.ReturnCount- wc.DepartureCount,wc2.ReturnCount - wc2.DepartureCount) diff,
	--isnull(wc.ReturnCount- wc.DepartureCount,wc2.ReturnCount - wc2.DepartureCount) - a.km diff2
FROM (
SELECT 
WaybillId, 
SUM(km) km
FROM WaybillWork ww
INNER JOIN Vehicle v ON v.VehicleId = ww.VehicleId and v.GarageNumber = @VehicleId AND v.OwnerId = 1
GROUP BY WaybillId
)a
LEFT JOIN WaybillCounter wc ON wc.WaybillId = a.WaybillId AND wc.CounterId = 1
LEFT JOIN Waybill w ON w.ReplicationSource = 1 AND w.WaybillNumber = a.WaybillId
LEFT JOIN WaybillCounter wc2 ON wc2.WaybillId = w.WaybillId AND wc2.CounterId = 1
LEFT JOIN waybill ww ON ww.WaybillId = a.WaybillId
ORDER BY 1


open ConsCur
fetch next from ConsCur into @position ,@waybillId , @departure , @return 

while @@fetch_status=0
begin

IF(@departure<>@saveCounter) SELECT @waybillId ,@position,@departure,@return, @saveCounter
SET @saveCounter = @return


fetch next from ConsCur into @position ,@waybillId , @departure , @return 
end
close ConsCur 
deallocate ConsCur