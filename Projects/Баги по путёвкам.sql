

select v.GarageNumber,b.* from (
select VehicleId,COUNT(WaybillId) cnt from (
	select v.VehicleId,v.GarageNumber,w.WaybillId from Waybill w 
	inner join Vehicle v on v.VehicleId = w.Vehicleid
	where WaybillId in (
	select distinct WaybillId from WaybillTask where NormConsumptionId is null and Consumption is not null
	)
)a group by VehicleId
)b 
left join Vehicle v on v.VehicleId = b.VehicleId
order by cnt desc


select Consumption/WorkAmount*100,* from WaybillTask where NormConsumptionId is null and WaybillId in (select WaybillId from Waybill where VehicleId = 1228 and DepartureDate<'01.01.2013' ) and WorkAmount<>0

/*
update WaybillTask set NormConsumptionId=2766 where NormConsumptionId is null and WaybillId in (select WaybillId from Waybill where VehicleId = 1228 and DepartureDate<'01.03.2013' ) and WorkAmount<>0
and Consumption/WorkAmount*100 =54
*/

select * from Vehicle where VehicleId = 664

select * from Norm where VehicleId=415