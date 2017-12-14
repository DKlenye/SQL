select 
	w.VehicleId,
	g.*
from VehicleRefuelling g 
left join Waybill w  on w.WaybillId = g.WaybillId
where RefuellingPlaceId = 11 and RefuellingDate between '01.12.2015' and '31.12.2015 23:59'
order by w.VehicleId
