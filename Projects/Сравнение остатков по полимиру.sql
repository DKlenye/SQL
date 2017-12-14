

select 
c.*,
v.GarageNumber
from (
select 

b.VehicleId,
b.FuelId,
b.DepartureRemain,
afc.Quantity,
b.DepartureRemain-afc.Quantity Diff

from (
	select 
		w.VehicleId,
		wfr.FuelId,
		isnull(wfr.DepartureRemain,0) DepartureRemain
	from (
	select w.VehicleId,MIN(w.Position) Position from Waybill w  
	inner join Vehicle v on v.VehicleId = w.VehicleId and v.ReplicationSource = 2
	where
	w.AccPeriod = 201303
	group by w.VehicleId
	)a
	inner join Waybill w on w.Position = a.Position and w.VehicleId = a.VehicleId
	left join WaybillFuelRemain wfr on wfr.WaybillId = w.WaybillId
)b
left join AccFuelRemain afc on afc.AccPeriod = 201303 and afc.VehicleId = b.VehicleId and b.FuelId = afc.FuelId
)c 

left join Vehicle v on v.VehicleId = c.VehicleId
where Diff<>0
order by Diff