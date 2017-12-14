DECLARE @month int, @year int, @accountingId INT
SELECT @month = 08, @year = 2013, @accountingId = 1


--1. Рассчёт стоимости заправленного топлива

SELECT 
	*
FROM (
	SELECT 
		r.FuelId,
		r.RefuellingPlaceId,
		tc.AccountingId,
		SUM(r.Quantity) Quantity
	FROM VehicleRefuelling r
	INNER JOIN Waybill w ON w.WaybillId = r.WaybillId
	INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId
	INNER JOIN TransportColumn tc ON tc.ColumnId = isnull(v.ColumnId,5)
	INNER JOIN Accounting a ON a.AccountingId = tc.AccountingId
	where 
			(month(r.RefuellingDate)=@month and year(r.RefuellingDate)=@year AND r.AccPeriod is null)
			or r.AccPeriod = @year*100+@month
	GROUP BY r.FuelId,	r.RefuellingPlaceId, tc.AccountingId
)a
LEFT JOIN FuelFilledCost ffc ON ffc.FuelId = a.FuelId AND ffc.RefuellingPlaceId = a.RefuellingPlaceId AND ffc.AccountingId = a.AccountingId AND ffc.AccPeriod = @year*100+@month