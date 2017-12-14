

select 
	b.FuelId,
	SUM(b.Quantity) Quantity,
	SUM(b.Mass) Mass
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
		where vr.RefuellingPlaceId = 1 and vr.RefuellingDate between '01.05.2013' and '01.06.2013'
		group by vr.FuelId, vr.SheetId
	)a
	left join RefuellingSheet s on s.SheetId = a.SheetId
)b
group by b.FuelId