
declare @month int, @year int, @refuellingPlaceId int
select @month = 10, @year = 2015, @refuellingPlaceId = 1


declare @startDate date, @endDate date, @period int

select @startDate = dbo.StrToDate('01.'+CAST(@month as varchar(2)) + '.'+ CAST(@year as varchar(4)))
select @endDate = DATEADD(MONTH,1,@startDate)
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
					case when f.UnitId = 1 then vr.Quantity ELSE case when s.Density = 0 then NULL ELSE vr.Quantity/s.Density end end Liter,
					case when f.UnitId = 2 then vr.Quantity else vr.Quantity*s.Density end Kg
				from VehicleReoilling vr
				inner join RefuellingSheet s on s.SheetId = vr.SheetId and s.RefuellingDate >= @startDate AND s.RefuellingDate < @endDate
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




DELETE FROM __AzsAccReport
insert into __AzsAccReport
select 
	b.*,
	StartSummRemain+ISNULL(IncomeCost,0)+ISNULL(Excise,0)-ISNULL(refuellingCost,0) EndSummRemain
	
from (
		select 
		a.FuelName,
		StartRemainLiter,
		StartRemainKg,
		StartSummRemain,

		IncomeVolume,
		IncomeMass,
		IncomeCost,
		e.Excise,
		
		p.PriceLiter,
		p.PriceKg,

		RefuellingQuantity,
		RefuellingMass,
		case when isnull(f.OilGroupId,0) in (0,2,3) then round(RefuellingQuantity*p.PriceLiter,0) else ROUND(RefuellingMass*p.PriceKg,0) end refuellingCost,

		endRemainLiter,
		endRemainMass
		
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
					a.FuelId,
					SUM(Volume) IncomeVolume,
					CASE WHEN f.PetrolGroupId IS NOT NULL then SUM(round(Volume * Density,0)) ELSE SUM(round(Volume * Density,1)) end IncomeMass,
					CASE WHEN f.PetrolGroupId IS NOT NULL then SUM(round(round(Volume * isnull(Density,1),0) * Price,0)) ELSE SUM(round(round(Volume * isnull(Density,1),1) * Price,0)) END IncomeCost
				from AzsFuelIncome a 
				LEFT JOIN Fuel f ON f.FuelId = a.FuelId
				where a.IncomeDate between @startDate and @endDate
				group by a.FuelId, f.PetrolGroupId
			)i on i.FuelId = r.FuelId
			left join Fuel f on f.FuelId = r.FuelId
			where r.AccPeriod  = @period
		)a
		left join Fuel f on f.FuelId = a.FuelId
		left join AZSFuelIncomeExcise e on e.FuelId = a.FuelId and e.AzsId = 1 and e.AccPeriod = @period
		left join AzsFuelPrice p on p.AzsId = 1 and p.AccPeriod = @period and p.FuelId = a.FuelId
)b


SELECT * FROM __AzsAccReport aar



