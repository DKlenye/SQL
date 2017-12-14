SELECT * FROM Waybill WHERE
waybillId IN (796265,796316,796319,796322,796333,796284,796300,796272,796275,796431,796289,796293,796307,796268,796310,796313)
OR waybillId in(SELECT WaybillId FROM Waybill WHERE VehicleId = 1284 AND AccPeriod IS NULL AND WaybillState>1 AND DepartureDate < '07.12.2015')
OR waybillId in(SELECT WaybillId FROM Waybill WHERE VehicleId = 1295 AND AccPeriod IS NULL AND WaybillState>1 AND DepartureDate < '08.12.2015')


SELECT * FROM Waybill WHERE VehicleId = 1284 AND AccPeriod IS NULL AND WaybillState>1 AND DepartureDate < '07.12.2015'
SELECT * FROM Waybill WHERE VehicleId = 1295 AND AccPeriod IS NULL AND WaybillState>1 AND DepartureDate < '08.12.2015'


UPDATE Waybill
	SET 
		AccPeriod = 201512,
		AccountingId = 1,
		ColumnId = 5
WHERE WaybillId IN (
SELECT WaybillId FROM Waybill WHERE
waybillId IN (796265,796316,796319,796322,796333,796284,796300,796272,796275,796431,796289,796293,796307,796268,796310,796313)
OR waybillId in(SELECT WaybillId FROM Waybill WHERE VehicleId = 1284 AND AccPeriod IS NULL AND WaybillState>1 AND DepartureDate < '07.12.2015')
OR waybillId in(SELECT WaybillId FROM Waybill WHERE VehicleId = 1295 AND AccPeriod IS NULL AND WaybillState>1 AND DepartureDate < '08.12.2015')
)