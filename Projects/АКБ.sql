declare @BatteryMovingId int
set @BatteryMovingId = 11

declare @batteryId int, @InstallDate date
select @batteryId = BatteryId, @InstallDate=InstallDate from BatteryMoving where BatteryMovingId = @BatteryMovingId

declare @unitId int, @InitWork decimal(18,3)
select @unitId = WorkUnitId,@InitWork = InitWork  from Battery where BatteryId = @batteryId

declare @table table(VehicleId int, InstallDate date, RemoveDate date, m int, y int, work decimal(18,3),BatteryRemoveReasonId int )


insert into @table
select 
	VehicleId,
	InstallDate,
	RemoveDate,
	m,y,
	SUM(work),
	BatteryRemoveReasonId
from (
select
	m.BatteryRemoveReasonId,
	m.InstallDate,
	m.RemoveDate,
	w.VehicleId,
	MONTH(w.ReturnDate)m,
	YEAR(w.ReturnDate)y,
	SUM(isnull(
		CASE wrk.WorkUnitId  
			WHEN 1 THEN wt.workAmount 
			WHEN 2 THEN cast( round (wt.workAmount/isnull(n.MotoToMachineKoef,1),2) AS DECIMAL(18,2)) 
			WHEN 3 THEN cast( round (wt.workAmount/isnull(n.MotoToMachineKoef,1),2) AS DECIMAL(18,2))		
			else null 
		end 
	,0)) work	
	
from BatteryMoving m
inner join Waybill w on 
	w.VehicleId = m.VehicleId and
	w.ReturnDate between m.InstallDate and ISNULL(m.RemoveDate,getDate()) and 
	w.WaybillState>1
inner join WaybillTask wt on wt.WaybillId = w.WaybillId
inner JOIN NormConsumption nc ON nc.RecId = wt.NormConsumptionId 
inner JOIN Norm n ON n.NormId = nc.NormId 
inner JOIN WorkType wrk ON wrk.WorkTypeId = n.WorkTypeId and (case when wrk.WorkUnitId = 3 then 2 else wrk.WorkUnitId end ) = @unitId
where m.BatteryId = @batteryId
group by w.VehicleId,w.ReturnDate,m.InstallDate,m.RemoveDate,m.BatteryRemoveReasonId
)a
group  by VehicleId,m,y,InstallDate,RemoveDate,BatteryRemoveReasonId
order by InstallDate,y,m

declare @table1 table(VehicleId int, InstallDate date, RemoveDate date, work decimal(18,3))
insert into @table1
select VehicleId,InstallDate,RemoveDate, sum(work) from @table where InstallDate<@InstallDate group by VehicleId,InstallDate,RemoveDate

delete from @table where InstallDate <> @InstallDate


declare @rezult table(
	VehicleString varchar(100),	
	InstallDate date,
	RemoveDate date,
	Work decimal(18,3),
	SummaryWork decimal(18,3),
	TechState varchar(50),
	RemoveReason varchar(50)
)

declare @SummaryWork decimal(18,3)
set @SummaryWork = isnull(@InitWork,0)


while exists (select * from @table1)
begin

	insert into @rezult
	select 
		v.Model+', Гос.№'+v.RegistrationNumber+', Гар.№'+CAST(v.GarageNumber as varchar(10)),
		a.InstallDate,
		a.RemoveDate,
		a.work,
		a.work+@SummaryWork,
		case when @SummaryWork = 0 then 'новая' else 'бывшая в эксплуатации' end,
		r.BatteryRemoveReasonName
	from (
		select top 1 * from @table
	)a
	left join Vehicle v on v.VehicleId = a.VehicleId
	left join BatteryRemoveReason r on r.BatteryRemoveReasonId = a.BatteryRemoveReasonId
	
	select top 1 @SummaryWork = @SummaryWork+work from @table
	
delete top (1) from @table1
end


declare @firstFlag tinyint
select @firstFlag = 1

while exists (select * from @table)
begin
	
	declare @cnt int
	select @cnt = count(*) from @table
	
	insert into @rezult(VehicleString,InstallDate,Work,SummaryWork)
	select 
		case when @firstFlag=1 then  v.Model+', Гос.№'+v.RegistrationNumber+', Гар.№'+CAST(v.GarageNumber as varchar(10)) else null end,
		case when @firstFlag=1 then  a.InstallDate else null end,		
		a.work,
		a.work+@SummaryWork		
	from (
		select top 1 * from @table
	)a
	left join Vehicle v on v.VehicleId = a.VehicleId
	
	if(@firstFlag = 1) set @firstFlag = 0;
	
	select top 1 @SummaryWork = @SummaryWork+work from @table		
	
	if 	@cnt = 1
		insert into @rezult(RemoveDate,TechState,RemoveReason)		
		select 
			a.RemoveDate,
			case when r.isWriteOff = 1 then 'неудовлетворительное' else 'удовлетворительное' end,
			r.BatteryRemoveReasonName
		from (
			select top 1 * from @table
		)a
		left join BatteryRemoveReason r on r.BatteryRemoveReasonId = a.BatteryRemoveReasonId
		
	delete top (1) from @table
end

if @unitId = 1
update @rezult set SummaryWork = SummaryWork/1000

select * from @rezult
