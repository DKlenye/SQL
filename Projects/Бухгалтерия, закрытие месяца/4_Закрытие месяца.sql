
declare @accountingId int, @month int, @year int
select @accountingId = 1, @month = 10, @year = 2017

declare @d date 
select @d = dbo.StrToDate('01.'+cast(@month as varchar(2))+'.'+cast(@year as varchar(4)))
select @d = DATEADD(Month,1,@d);

--сохраняем значение АссountingId и ColumnId в путевых листах, потому что значения могут поменяться и отчёты изменятся

UPDATE Waybill
	SET 
		AccPeriod = @year*100+@month,
		AccountingId = tc.AccountingId,
		ColumnId = tc.ColumnId
FROM Waybill w
INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId 
inner join TransportColumn tc on tc.ColumnId = ISNULL(v.ColumnId,5) and tc.AccountingId = @accountingId
WHERE w.AccPeriod IS NULL and WaybillState >1 and ReturnDate < @d AND w.AccountingId IS null

UPDATE VehicleRefuelling
SET
	AccountingId = tc.AccountingId
FROM VehicleRefuelling vr
INNER JOIN Waybill w ON w.WaybillId = vr.WaybillId
INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId
inner join TransportColumn tc on tc.ColumnId = ISNULL(v.ColumnId,5) and tc.AccountingId = @accountingId
WHERE year(RefuellingDate)=@year AND MONTH(refuellingDate)=@month AND vr.AccountingId IS null

