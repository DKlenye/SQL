DECLARE @date DATE, @Owner int
SELECT @date = '01.11.2013',@Owner=1

declare @remains table(
	WaybillId int,
	VehicleId int,
	FuelId int, 
	Remain decimal(18,2),
	Trip varchar(5)
)

insert into @remains
select 
w.WaybillId,
w.VehicleId,
FuelId,
DepartureRemain + Refuelling as Remain,
case when w.ReturnDate>@date then 'ком' else null end
from(
	select 
		w.WaybillId,
		w.VehicleId,
		fr.FuelId,
		fr.DepartureRemain,
		SUM(isnull(r.Quantity,0)) Refuelling
	from (
		select 
			w.VehicleId,
			min(w.Position) Position
		from Waybill w 
		inner join Vehicle v on v.VehicleId = w.VehicleId
		where 
			w.WaybillState=1 and w.DepartureDate < @date
		group by w.VehicleId
	)a
	inner join Waybill w on w.VehicleId = a.VehicleId and w.Position = a.Position
	left join WaybillFuelRemain fr on fr.WaybillId = w.WaybillId
	left join Waybill ww on ww.VehicleId = w.VehicleId and ww.Position>=w.Position
	left join VehicleRefuelling r on fr.FuelId = r.FuelId and r.RefuellingDate>=w.DepartureDate and r.RefuellingDate < @date and r.WaybillId = ww.WaybillId
	group by w.WaybillId, w.VehicleId, fr.FuelId, fr.DepartureRemain
)b
inner join Waybill w on w.WaybillId = b.WaybillId

insert into @remains
select 
		w.WaybillId,
		w.VehicleId,
		fr.FuelId,
		fr.ReturnRemain,
		case when w.ReturnDate>@date then 'п' else null end
	from (
		select 
			w.VehicleId,
			max(w.Position) Position
		from Waybill w 
		INNER JOIN Vehicle v on v.VehicleId = w.VehicleId
		LEFT JOIN @remains r ON r.VehicleId = v.VehicleId
		where 
			r.VehicleId IS NULL and
			w.DepartureDate < @date AND w.WaybillState > 1
		group by w.VehicleId
	)a
	inner join Waybill w on w.VehicleId = a.VehicleId and w.Position = a.Position
	INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId 
	left join WaybillFuelRemain fr on fr.WaybillId = w.WaybillId
	group by w.WaybillId, w.VehicleId,w.ReturnDate, fr.FuelId, fr.ReturnRemain



delete r from @remains as r
left join norm n on n.VehicleId = r.VehicleId
left join NormFuels nf on nf.NormId = n.NormId and nf.FuelId = r.FuelId
where isnull(Remain,0) = 0 and nf.FuelId is NULL


SELECT 
	r.WaybillId,
	r.VehicleId,
	v.GarageNumber,
	r.FuelId,
	isnull(r.Remain,0) Remain,
	isnull(ISNULL(we.EmployeeId,ve.EmployeeId),wed.EmployeeId) EmployeeId
	
FROM @remains r
INNER JOIN Waybill w ON r.WaybillId = w.WaybillId
INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId AND v.WriteOffDate IS null
LEFT JOIN Driver Wd ON Wd.DriverId = w.DriverId
LEFT JOIN Employee We ON We.EmployeeId = Wd.EmployeeId AND We.DismissDate IS NULL
LEFT JOIN Employee WeD ON WeD.EmployeeId = Wd.EmployeeId
LEFT JOIN Driver Vd ON Vd.DriverId = v.DriverId
LEFT JOIN Employee Ve ON Ve.EmployeeId = Vd.EmployeeId AND Ve.DismissDate IS NULL
ORDER BY 6
