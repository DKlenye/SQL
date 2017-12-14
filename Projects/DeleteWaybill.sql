declare @waybillId int
select @waybillId = 754714

DELETE FROM DistributionListWaybills WHERE WaybillId = @waybillId


delete from WaybillTaskIncrease where TaskId in (select TaskId from WaybillTask where WaybillId = @waybillId)
delete from WaybillTask where WaybillId = @waybillId
delete from VehicleRefuelling where WaybillId = @waybillId
delete from WaybillFuelRemain where WaybillId = @waybillId
delete from WaybillDriver where WaybillId = @waybillId
delete from WaybillCounter where WaybillId = @waybillId
delete from Waybill where WaybillId = @waybillId