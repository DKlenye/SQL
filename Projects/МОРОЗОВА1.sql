
DECLARE @year int, @month INT
SELECT @year = 2013,@month = 03



SELECT 
	al2.AccPeriod/100 y,
	al2.AccPeriod - (al2.AccPeriod/100)*100 m,
	al2.*,
	f.FuelName
FROM (
SELECT 
	AccPeriod,
	FuelId,
	SUM(isnull(FactConsumption,0)) Consumption,
	SUM(ISNULL(SummConsumption,0)) Summ
FROM (
SELECT 
			c.AccPeriod,
			c.ColumnId,
			c.AccountingId,
			c.WaybillId,	
			c.FuelId,
			c.FactConsumption,
			round(c.FactConsumption*afp.Price,0) SummConsumption
		FROM (
			SELECT 
				b.*,
				b.DepartureRemain+b.RefuellingQuantity-b.ReturnRemain FactConsumption
			FROM (
				SELECT 
					a.AccPeriod,
					a.ColumnId,
					a.AccountingId,
					a.WaybillId,	
					a.FuelId,
					a.DepartureRemain,
					a.ReturnRemain,
					a.RefuellingQuantity,
					SUM(ISNULL(wt.Consumption,0)) NormConsumption
				FROM (
					SELECT 	
						w.ColumnId,
						w.AccPeriod,
						w.AccountingId,
						w.WaybillId,
						wfr.FuelId,
						isnull(wfr.DepartureRemain,0) DepartureRemain,
						isnull(wfr.ReturnRemain,0) ReturnRemain,
						SUM(isnull(vr.Quantity,0)) RefuellingQuantity	
					FROM Waybill w
					INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId AND v.OwnerId = 1 AND v.AccGroupId = 5
					INNER join Accounting a on a.AccountingId = w.AccountingId
					LEFT JOIN WaybillFuelRemain wfr on wfr.WaybillId = w.WaybillId
					LEFT JOIN VehicleRefuelling vr ON vr.WaybillId = wfr.WaybillId AND vr.FuelId = wfr.FuelId
					WHERE w.AccPeriod >= @year*100+@month
					GROUP BY w.AccPeriod,w.ColumnId,w.AccountingId,w.AccountingId,w.WaybillId,wfr.FuelId,wfr.DepartureRemain,wfr.ReturnRemain
				)a
				LEFT JOIN WaybillTask wt ON wt.WaybillId = a.WaybillId AND wt.FuelId = a.FuelId
				GROUP BY a.AccPeriod,a.ColumnId,a.AccountingId,a.WaybillId,a.FuelId,a.DepartureRemain,a.ReturnRemain,a.RefuellingQuantity
			)b
		)c
		LEFT JOIN AccFuelPrice afp ON afp.AccountingId = c.AccountingId AND afp.FuelId = c.FuelId AND afp.AccPeriod = c.AccPeriod
		)al
GROUP BY AccPeriod,	FuelId
)al2
LEFT JOIN Fuel f ON f.FuelId = al2.FuelId
WHERE al2.Consumption>0
ORDER BY 1,2