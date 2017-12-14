declare @AzsId int, @month int, @year int

select @AzsId = 1, @month = 05, @year = 2013

declare @startDate date, @endDate date, @period int
select @startDate = dbo.StrToDate('01.'+CAST(@month as varchar(2)) + '.'+ CAST(@year as varchar(4)))
select @endDate = DATEADD(MONTH,1,@startDate)
select @period = @year*100+@month


declare @FuelPrice table(FuelId int, Price int)

insert into @FuelPrice
select 1,4569
union all
select 2,5093
union all
select 3,4416
union all
select 4,4794
union all

select 6,1731
union all
select 8,1785
union all
select 9,4003
union all
select 10,3280
union all
select 11,27010
union all
select 12,5603
union all
select 13,9648
union all
select 14,14000
union all
select 16,4550
union all
select 18,18501
union all
select 19,15963
union all
select 20,24957
union all
select 21,33416


select 
	f.FuelName,
	FuelCostCode,CostCode,round(SUM(Summ),0)
from (
	select 
		vr.FuelId,
		tc.ColumnName,
		a.FuelCostCode,
		z.CostCode,
		SUM(vr.Quantity) Quantity,
		SUM(vr.Quantity * p.Price)Summ
	from VehicleRefuelling vr
	inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.AzsId = @AzsId
	inner join Waybill w on w.WaybillId = vr.WaybillId
	inner join Vehicle v on v.VehicleId = w.VehicleId
	inner join TransportColumn tc on tc.ColumnId = ISNULL(v.ColumnId,5)
	left join Accounting a on a.AccountingId = tc.AccountingId
	left join Azs z on z.AzsId = s.AzsId
	left join @FuelPrice p on p.FuelId = vr.FuelId
	where  vr.RefuellingDate between @startDate and @endDate
	group by vr.FuelId,tc.ColumnName,a.FuelCostCode,z.CostCode
)a
left join Fuel f on f.FuelId = a.FuelId
group by f.FuelName,FuelCostCode,CostCode


select 
	b.OilCostCode,
	b.CostCode,
	SUM(round(b.Summ,0))Summ
from (
	select 
		a.*,
		a.Vol*p.Price Summ
	from (
		select 
			a.OilCostCode,
			z.CostCode,
			og.OilGroupName,
			vr.FuelId,
			f.FuelName,
			tc.ColumnName,
			sum(round(vr.Quantity / isnull(s.Density,1),1)) Vol 
		from VehicleReoilling vr
		inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.AzsId = @AzsId and s.RefuellingDate between @startDate and @endDate
		inner join Vehicle v on v.VehicleId = vr.VehicleId
		left join TransportColumn tc on tc.ColumnId = v.ColumnId
		left join Accounting a on a.AccountingId = tc.AccountingId
		left join Azs z on z.AzsId = s.AzsId
		left join Fuel f on f.FuelId = vr.FuelId
		left join OilGroup og on og.OilGroupId = f.OilGroupId
		group by a.OilCostCode,z.CostCode,og.OilGroupName, vr.FuelId, f.FuelName,tc.ColumnName
	)a
	left join @FuelPrice p on p.FuelId = a.FuelId
)b
group by  b.OilCostCode,	b.CostCode











	select 
		a.AccGroupName,
		a.GroupCostCode,
		a.oilCostCode,
		sum(round(a.Vol*p.Price,0)) Summ
	from (
		select 
			ag.AccGroupName,
			ag.CostCode GroupCostCode,
			a.OilCostCode,
			z.CostCode,
			og.OilGroupName,
			vr.FuelId,
			f.FuelName,
			tc.ColumnName,
			sum(round(vr.Quantity / isnull(s.Density,1),1)) Vol 
		from VehicleReoilling vr
		inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.AzsId = @AzsId and s.RefuellingDate between @startDate and @endDate
		inner join Vehicle v on v.VehicleId = vr.VehicleId
		inner join AccGroup ag on ag.AccGroupId = v.AccGroupId
		left join TransportColumn tc on tc.ColumnId = v.ColumnId
		left join Accounting a on a.AccountingId = tc.AccountingId
		left join Azs z on z.AzsId = s.AzsId
		left join Fuel f on f.FuelId = vr.FuelId
		left join OilGroup og on og.OilGroupId = f.OilGroupId
		group by ag.AccGroupName,ag.CostCode,a.OilCostCode,z.CostCode,og.OilGroupName, vr.FuelId, f.FuelName,tc.ColumnName
	)a
	left join @FuelPrice p on p.FuelId = a.FuelId
	group by a.AccGroupName,		a.GroupCostCode,		a.oilCostCode













select 
Debet,
Credit,
SUM(round(Quantity*p.Price,0)) Summ
from (
	select 
		r.Debet,
		r.Credit,
		a.FuelId,
		SUM(Quantity) Quantity
	from (
		select 
			FuelId,
			Quantity,
			ISNULL(i.FuelRecipientId,t.FuelRecipientId) FuelRecipientId
		from RefuellingOther ro
		left join RefuellingInvoice i on i.InvoiceId = ro.InvoiceId
		left join RefuellingTTN t on t.TTNId = ro.TTNId
		where ro.RefuellingDate between @startDate and @endDate
	)a
	left join FuelRecipient r on r.FuelRecipientId = a.FuelRecipientId
	group by r.Debet,r.Credit,a.FuelId
)b
left join @FuelPrice p on p.FuelId = b.FuelId
group by Debet,Credit

