
declare  @refuellingPlaceId int, @month int, @year int
select @month = 08, @year = 2015, @refuellingPlaceId = 1


declare @startDate date, @endDate date, @period int

select @startDate = dbo.StrToDate('01.'+CAST(@month as varchar(2)) + '.'+ CAST(@year as varchar(4)))
select @endDate = DATEADD(MONTH,1,@startDate)
select @period = @year*100+@month

insert into FuelFilledCost

select 
	a.FuelId,
	1,
	null,
	Quantity*p.PriceLiter Cost,
	0,
	@year*100+@month,
	AccountingId
from (
	select 
		tc.AccountingId,
		r.FuelId,
		SUM(Quantity) Quantity
	from VehicleRefuelling r
	left join Waybill w on w.WaybillId = r.WaybillId
	left join Vehicle v on v.VehicleId = w.VehicleId
	left join TransportColumn tc on ISNULL(v.ColumnId,5) = tc.ColumnId
	where r.RefuellingDate between @startDate and @endDate and RefuellingPlaceId = 1
	group by tc.AccountingId,r.FuelId
)a
left join AzsFuelPrice p on p.FuelId = a.FuelId and p.AzsId = 1 and p.AccPeriod = @year*100+@month


/*
select 
			b.FuelId,
			SUM(b.Quantity) RefuellingQuantity,
			SUM(b.Mass) RefuellingMass
		from (
			select 
				s.SheetId,
				a.FuelId,
				a.Quantity,
				round(a.Quantity*s.Density,1)Mass
			from (
				select 
					vr.FuelId,
					vr.SheetId,
					sum(vr.Quantity) Quantity
				from 
				VehicleRefuelling vr
				where vr.RefuellingPlaceId = @refuellingPlaceId and vr.RefuellingDate between @startDate and @endDate
				group by vr.FuelId, vr.SheetId
			)a
			left join RefuellingSheet s on s.SheetId = a.SheetId
		)b
	group by b.FuelId
*/

