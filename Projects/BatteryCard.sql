

declare @batteryId int
select @batteryId = 1488;

declare @table table(VehicleId int, InstallDate date, RemoveDate date, RemoveReason VARCHAR(150), isWriteOff BIT, m int, y int, workKm decimal(18,3), workMh DECIMAL(18,3))

INSERT INTO @table
SELECT 
	m.VehicleId,
	m.InstallDate,
	m.RemoveDate,
	brr.BatteryRemoveReasonName,
	brr.isWriteOff,
	w.AccPeriod-(w.AccPeriod/100)*100,
	w.AccPeriod/100,
	case WHEN m.WorkUnitId = 1 THEN w.Km ELSE 0 END ,
	case WHEN m.WorkUnitId = 3 THEN w.Mh ELSE 0 END 
FROM BatteryMoving m
INNER JOIN WaybillWorkExtended w ON w.VehicleId = m.VehicleId
LEFT JOIN BatteryRemoveReason brr ON brr.BatteryRemoveReasonId = m.BatteryRemoveReasonId
WHERE 
	m.BatteryId = @batteryId and
 AccPeriod>= YEAR(m.InstallDate)+100*MONTH(m.InstallDate) AND AccPeriod<=year(ISNULL(m.RemoveDate,getDate()))*100+MONTH(ISNULL(m.RemoveDate,getDate()))

insert into @table
select 
	VehicleId,
	InstallDate,
	RemoveDate,
	BatteryRemoveReasonName,
	isWriteOff,
	m,y,
	SUM(Km),
	SUM(Mh)
from (
SELECT 
	m.InstallDate,
	m.RemoveDate,
	m.VehicleId,
	brr.BatteryRemoveReasonName,
	brr.isWriteOff,
	MONTH(ww.WorkDate)m,
	YEAR(ww.WorkDate)y,
	sum(case WHEN m.WorkUnitId = 1 THEN ww.km ELSE 0 END) Km,
	sum(case WHEN m.WorkUnitId = 3 THEN ww.MotoHour ELSE 0 END) Mh
FROM BatteryMoving m
LEFT JOIN WaybillWork ww ON m.VehicleId = ww.VehicleId AND ww.WorkDate BETWEEN m.InstallDate and ISNULL(m.RemoveDate,getDate())
LEFT JOIN BatteryRemoveReason brr ON brr.BatteryRemoveReasonId = m.BatteryRemoveReasonId
where m.BatteryId = @batteryId
group by m.VehicleId,ww.WorkDate, m.InstallDate,m.RemoveDate, m.WorkUnitId,brr.BatteryRemoveReasonName,	brr.isWriteOff
)a
group  by VehicleId,m,y,InstallDate,RemoveDate,BatteryRemoveReasonName,	isWriteOff
order by InstallDate,y,m



declare @rezult table(
	VehicleString varchar(100),	
	InstallDate date,
	RemoveDate date,
	m int,
	mName varchar(20),
	y int,
	WorkKm decimal(18,3),
	WorkMh DECIMAL(18,3),
	SummaryWorkKm decimal(18,3),
	SummaryWorkMh DECIMAL(18,3),
	RemoveReason VARCHAR(250),
	isWriteOff bit
)

declare @firstFlag tinyint
select @firstFlag = 1

while exists (select * from @table)
begin
	
	declare @vid int
	select top (1) @vid = VehicleId from @table

			
		insert into @rezult
		select 
			case when @firstFlag = 1 then v.Model+'Гос.№'+v.RegistrationNumber+', Гар.№'+CAST(v.GarageNumber as varchar(10))  else null  end VehicleString,
			case when @firstFlag = 1 then a.InstallDate else null end InstallDate,
			null,
			a.m,
			mm.[MonthName],
			a.y,
			a.WorkKm,
			a.WorkMh,
			a.workKm+isnull((select SUM(workKm) from @rezult),0) SummaryWorkKm,
			a.workMh+isnull((select SUM(workMh) from @rezult),0) SummaryWorkMh
		from (
			select top (1) * from @table
		)a
		left join Vehicle v on v.VehicleId = a.VehicleId
		left join Monthes mm on mm.Id = a.m
		
	if(@firstFlag = 1) set @firstFlag = 0;
	
	
	if(select COUNT(*) from @table where VehicleId = @vid) = 1
	begin
		insert into @rezult(RemoveDate) 
		select top (1) RemoveDate from @table
		set @firstFlag = 1;
	end
	
	delete top (1) from @table
end

select 
	*,
	cast(a.m as varchar(2))+'.'+CAST(a.y as varchar(4))+' - '+cast(cast(round(_workKm,3) as decimal(18,3)) as varchar(15)) + '('+ cast(cast(round(workMh,3) as decimal(18,2)) as varchar(15)) +')' _summaryString	
from (
	select 
		*,
		WorkKm/1000 _workKm,
		SummaryWorkKm*1.00/1000 _summary
	from @rezult
)a