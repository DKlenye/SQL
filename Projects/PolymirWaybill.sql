-- 
--select * from _PolymirWaybillTask
--select * from Waybill where VehicleId = 100

--select * from Vehicle where ReplicationSource = 2 and DSC = 1

declare @GarageNumber int
select @GarageNumber =254 


declare @WorkUnitId int
declare @normId int
declare @FuelId int


select 
	top 1 @normId = n.NormId,@WorkUnitId=t.WorkUnitId
from Vehicle v
left join _Norm n on n.VehicleId = v.VehicleId and n.isMain = 1
left join WorkType t on t.WorkTypeId = n.WorkTypeId
where v.OwnerId = 1 and GarageNumber = 20000+@GarageNumber

select top 1 @FuelId=FuelId from NormFuels where NormId = @normId

declare @npl int
declare @Id varchar(15)
declare Cur_Wb cursor 
for 
	select npl,npl+'_'+fr from _PolymirWaybill where gar_n = @GarageNumber
				
open Cur_Wb

fetch next from Cur_Wb into @npl,@Id

while @@fetch_status=0
begin
	
	declare @WaybillId int
	select @WaybillId=WaybillId from Waybill where ReplicationSource = 2 and ReplicationId = @Id
	
	declare @CustomerId int
	select top 1 @CustomerId=CustomerId from Customer where SHZ = (select top 1 SHZ from _PolymirWaybillTask where npl+'_'+fr = @Id )
	
	
	if @WorkUnitId = 1	
	begin
	
		--select top 1 * from WaybillTask
		
		if not exists(select * from WaybillTask where ReplicationId = @npl and ReplicationSource = 2)
		
		insert into WaybillTask(WaybillId,CustomerId,NormConsumptionId,TaskDepartureDate,FuelId,WorkAmount,Consumption,ReplicationSource,ReplicationId)
		select 
			@WaybillId,
			@CustomerId,
			@normId,
			d_vy,
			@FuelId,
			prob,
			rgn,
			2,
			npl
		from _PolymirWaybill where npl+'_'+fr = @Id
		
	
	end
	
	else begin
	
		if not exists(select * from WaybillTask where ReplicationId = @npl and ReplicationSource = 2)
	
		insert into WaybillTask(WaybillId,CustomerId,NormConsumptionId,TaskDepartureDate,FuelId,WorkAmount,Consumption,ReplicationSource,ReplicationId)
		select 
			@WaybillId,
			@CustomerId,
			@normId,
			d_vy,
			@FuelId,
			chas,
			rgn,
			2,
			npl
		from _PolymirWaybill where npl+'_'+fr = @Id
	
	end
	
	
	
fetch next from Cur_Wb into @npl,@Id
end
close Cur_Wb 
deallocate Cur_Wb


