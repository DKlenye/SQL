declare @AzsId int, @month int, @year int

select @AzsId = 01, @month = 10, @year = 2015

declare @startDate date, @endDate date, @period int
select @startDate = dbo.StrToDate('01.'+CAST(@month as varchar(2)) + '.'+ CAST(@year as varchar(4)))
select @endDate =DATEADD(MONTH,1,@startDate)
select @period = @year*100+@month

SELECT @startDate,@endDate

select 
	f.FuelName,
	FuelCostCode,CostCode,
	cast(sum(Quantity) AS INT) Q,
	cast(round(SUM(Summ),0) AS INT)	
from (
	select 
		vr.FuelId,
		tc.ColumnName,
		a.FuelCostCode,
		z.CostCode,
		SUM(vr.Quantity) Quantity,
		SUM(vr.Quantity * p.PriceLiter)Summ
	from VehicleRefuelling vr
	inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.AzsId = @AzsId
	inner join Waybill w on w.WaybillId = vr.WaybillId
	inner join Vehicle v on v.VehicleId = w.VehicleId
	inner join TransportColumn tc on tc.ColumnId = ISNULL(v.ColumnId,5)
	left join Accounting a on a.AccountingId = tc.AccountingId
	left join Azs z on z.AzsId = s.AzsId
	left join AzsFuelPrice p on p.FuelId = vr.FuelId and p.AccPeriod = @period and p.AzsId = @AzsId
	where  vr.RefuellingDate >= @startDate and vr.RefuellingDate <= @endDate
	group by vr.FuelId,tc.ColumnName,a.FuelCostCode,z.CostCode
)a
left join Fuel f on f.FuelId = a.FuelId
group by f.FuelName,FuelCostCode,CostCode


select 
	b.OilCostCode,
	b.CostCode,
	cast(SUM(round(b.Summ,0)) as int) Summ
from (
	select 
		a.*,
		a.Vol*isnull(p.PriceLiter,p.PriceKg) Summ
	from (
		select 
			a.OilCostCode,
			z.CostCode,
			og.OilGroupName,
			vr.FuelId,
			f.FuelName,
			tc.ColumnName,
			sum(round(vr.Quantity / isnull(s.Density,1),4)) Vol 
		from VehicleReoilling vr
		inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.AzsId = @AzsId and s.RefuellingDate >= @startDate and s.RefuellingDate < @endDate
		inner join Vehicle v on v.VehicleId = vr.VehicleId
		left join TransportColumn tc on tc.ColumnId = v.ColumnId
		left join Accounting a on a.AccountingId = tc.AccountingId
		left join Azs z on z.AzsId = s.AzsId
		left join Fuel f on f.FuelId = vr.FuelId
		left join OilGroup og on og.OilGroupId = f.OilGroupId
		group by a.OilCostCode,z.CostCode,og.OilGroupName, vr.FuelId, f.FuelName,tc.ColumnName
	)a
	left join AzsFuelPrice p on p.FuelId = a.FuelId and p.AzsId = @AzsId and p.AccPeriod = @period
)b
group by  b.OilCostCode,	b.CostCode



select 
	b.ColumnName,
	b.FuelName,
	b.OilCostCode,
	b.CostCode,
	SUM(b.Vol) Vol,
	Cast(SUM(round(b.Summ,0)) as int)Summ
from (
	select 
		a.*,
		a.Vol*isnull(p.PriceLiter,p.PriceKg) Summ
	from (
		select 
			a.OilCostCode,
			z.CostCode,
			og.OilGroupName,
			vr.FuelId,
			f.FuelName,
			tc.ColumnName,
			sum(round(vr.Quantity / isnull(s.Density,1),4)) Vol 
		from VehicleReoilling vr
		inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.AzsId = @AzsId and s.RefuellingDate >=@startDate and s.RefuellingDate <@endDate
		inner join Vehicle v on v.VehicleId = vr.VehicleId
		left join TransportColumn tc on tc.ColumnId = v.ColumnId
		left join Accounting a on a.AccountingId = tc.AccountingId
		left join Azs z on z.AzsId = s.AzsId
		left join Fuel f on f.FuelId = vr.FuelId
		left join OilGroup og on og.OilGroupId = f.OilGroupId
		group by a.OilCostCode,z.CostCode,og.OilGroupName, vr.FuelId, f.FuelName,tc.ColumnName
	)a
	left join AzsFuelPrice p on p.FuelId = a.FuelId and p.AzsId = @AzsId and p.AccPeriod = @period
)b
group by  b.ColumnName,	b.FuelName,b.OilCostCode,	b.CostCode


select 
	b.AccGroupName,
	b.GroupCostCode,
	b.oilCostCode,
	cast(SUM(round(b.Summ,0)) as int) Summ
from (
	select 
		a.*,
		a.Vol*isnull(p.PriceLiter,p.PriceKg) Summ
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
			sum(round(vr.Quantity / isnull(s.Density,1),4)) Vol 
		from VehicleReoilling vr
		inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.AzsId = @AzsId and s.RefuellingDate >= @startDate AND s.RefuellingDate< @endDate
		inner join Vehicle v on v.VehicleId = vr.VehicleId
		left join AccGroup ag on ag.AccGroupId = v.AccGroupId
		left join TransportColumn tc on tc.ColumnId = v.ColumnId
		left join Accounting a on a.AccountingId = tc.AccountingId
		left join Azs z on z.AzsId = s.AzsId
		left join Fuel f on f.FuelId = vr.FuelId
		left join OilGroup og on og.OilGroupId = f.OilGroupId
		group by ag.AccGroupName,ag.CostCode,a.OilCostCode,z.CostCode,og.OilGroupName, vr.FuelId, f.FuelName,tc.ColumnName
	)a
	left join AzsFuelPrice p on p.FuelId = a.FuelId and p.AzsId = @AzsId and p.AccPeriod = @period
)b
group by  b.AccGroupName,		b.GroupCostCode,		b.oilCostCode

	
	
select 
Debet,
Credit,
cast(SUM(round(Quantity*p.PriceLiter,0)) AS INT) Summ
from (
	select 
		r.CostCode Debet,
		'10034000' Credit,
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
		where ro.RefuellingDate >= @startDate and  ro.RefuellingDate <@endDate
	)a
	left join FuelRecipient r on r.FuelRecipientId = a.FuelRecipientId
	group by r.CostCode,a.FuelId
)b
left join AzsFuelPrice p on p.FuelId = b.FuelId and p.AzsId = @AzsId and p.AccPeriod = @period
group by Debet,Credit




select 

FuelRecipientName,
Debet,
Credit,
FuelName,
sum(Quantity) Quantity,
SUM(round(Quantity*p.PriceLiter,0)) Summ
from (
	select 
		f.FuelName,
		r.FuelRecipientName,
		r.CostCode Debet,
		'10034000' Credit,
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
		where ro.RefuellingDate >=@startDate AND ro.RefuellingDate< @endDate
	)a
	left join FuelRecipient r on r.FuelRecipientId = a.FuelRecipientId
	left join Fuel f on f.FuelId = a.FuelId
	group by f.FuelName, r.FuelRecipientName,r.CostCode,a.FuelId
)b
left join AzsFuelPrice p on p.FuelId = b.FuelId and p.AzsId = @AzsId and p.AccPeriod = @period
group by FuelRecipientName,Debet,Credit,FuelName







	select 
		a.*,
		a.Vol*isnull(p.PriceLiter,p.PriceKg) Summ
	from (
		select 
			vr.VehicleId,
			ag.AccGroupName,
			ag.CostCode GroupCostCode,
			a.OilCostCode,
			z.CostCode,
			og.OilGroupName,
			vr.FuelId,
			f.FuelName,
			tc.ColumnName,
			sum(round(vr.Quantity / isnull(s.Density,1),4)) Vol 
		from VehicleReoilling vr
		inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.AzsId = @AzsId and s.RefuellingDate >= @startDate AND s.RefuellingDate< @endDate
		inner join Vehicle v on v.VehicleId = vr.VehicleId
		left join AccGroup ag on ag.AccGroupId = v.AccGroupId
		left join TransportColumn tc on tc.ColumnId = v.ColumnId
		left join Accounting a on a.AccountingId = tc.AccountingId
		left join Azs z on z.AzsId = s.AzsId
		left join Fuel f on f.FuelId = vr.FuelId
		left join OilGroup og on og.OilGroupId = f.OilGroupId
		group BY vr.VehicleId, ag.AccGroupName,ag.CostCode,a.OilCostCode,z.CostCode,og.OilGroupName, vr.FuelId, f.FuelName,tc.ColumnName
	)a
	left join AzsFuelPrice p on p.FuelId = a.FuelId and p.AzsId = @AzsId and p.AccPeriod = @period