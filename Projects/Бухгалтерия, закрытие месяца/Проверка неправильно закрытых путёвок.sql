

SELECT * FROM (
	SELECT 
		w.VehicleId,
		MAX(Position)  Position
	FROM  Waybill w
	INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId AND v.OwnerId = 1
	WHERE w.AccPeriod IS NOT null
	GROUP BY w.VehicleId
)a
LEFT JOIN Waybill w ON w.VehicleId = a.VehicleId AND w.Position <= a.Position AND w.AccPeriod IS NULL
WHERE w.WaybillId IS NOT NULL