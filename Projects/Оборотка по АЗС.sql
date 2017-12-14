

create Proc ssrs_AzsFuelMoving
as

declare @month int, @year int, @refuellingPlaceId int
select @month = 06, @year = 2013, @refuellingPlaceId = 1


declare @startDate date, @endDate date, @period int

select @startDate = dbo.StrToDate('01.'+CAST(@month as varchar(2)) + '.'+ CAST(@year as varchar(4)))
select @endDate = DATEADD(DAY,-1,DATEADD(MONTH,1,@startDate))
select @period = @year*100+@month

declare @refuelling table(fuelId int,  RefuellingQuantity decimal(18,6),RefuellingMass decimal(18,6))



insert into @refuelling
select 
	FuelId,
	SUM(Liter) Liter,
	SUM(Kg) Kg
from (

	select 
		FuelId,
		round(SUM(Liter),6) Liter,
		round(SUM(Kg),6) Kg
	from (
			select 
				FuelId,
				SheetId,
				SUM(Liter) Liter,
				SUM(Kg) Kg
			from (
				select 
					vr.FuelId,
					vr.SheetId,
					case when f.UnitId = 1 then vr.Quantity else Quantity/s.Density end Liter,
					case when f.UnitId = 2 then vr.Quantity else Quantity*s.Density end Kg
				from VehicleReoilling vr
				inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.RefuellingDate between @startDate and @endDate
				inner join Fuel f on f.FuelId = s.FuelId
				where vr.RefuellingPlaceId = @refuellingPlaceId 
			)a
			group by FuelId,SheetId
	)b
	group by FuelId

	union all

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

	union all
	
	Select 
		FuelId,
		SUM(Quantity) OtherQuantity,
		round(SUM(Quantity * isnull(Density,0)),2) OtherMass
	from RefuellingOther r
	where r.RefuellingDate between @startDate and @endDate
	group by FuelId 

)a
group by FuelId



select 
a.FuelName,
StartRemainLiter,
StartRemainKg,
case when a.UnitId = 1 then StartRemainLiter else StartRemainKg end AllStartRemain,

IncomeVolume,
IncomeMass,
case when a.UnitId = 1 then IncomeVolume else IncomeMass end AllIncome,

RefuellingQuantity,
RefuellingMass,
case when a.UnitId = 1 then RefuellingQuantity else RefuellingMass end AllRefuelling,

endRemainLiter,
endRemainMass,
case when a.UnitId = 1 then endRemainLiter else endRemainMass end AllEndRemain,


case when a.UnitId = 1 then 'Î.' else 'Í„.' end Unit
from (

	select 
		f.FuelName,
		f.fuelId,
		f.UnitId,
		round(r.StartRemainLiter,6) StartRemainLiter,
		round(r.StartRemainKg,6) StartRemainKg,
		r.StartSummRemain,	
		i.IncomeVolume,
		i.IncomeMass,
		i.IncomeCost,	
		ref.RefuellingQuantity,
		ref.RefuellingMass,
		round(r.StartRemainLiter+isnull(i.IncomeVolume,0)-isnull(ref.RefuellingQuantity,0),6) endRemainLiter,
		round(r.StartRemainKg+isnull(i.IncomeMass,0)-isnull(ref.RefuellingMass,0),6) endRemainMass
					
	from 
		AzsFuelRemain r 
	left join @refuelling ref on ref.fuelId = r.FuelId
	left join (
			select 
			FuelId,
			SUM(Volume) IncomeVolume,
			SUM(round(Volume * Density,0)) IncomeMass,
			SUM(round(round(Volume * isnull(Density,1),0) * Price,0)) IncomeCost
		from AzsFuelIncome a where a.IncomeDate between @startDate and @endDate
		group by FuelId
	)i on i.FuelId = r.FuelId
	left join Fuel f on f.FuelId = r.FuelId
	where r.AccPeriod  = @period
)a
left join Fuel f on f.FuelId = a.FuelId
order by f.OilGroupId