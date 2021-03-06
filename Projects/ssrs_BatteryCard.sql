declare @BatteryMovingId int
SET @BatteryMovingId = 1874

declare @batteryId int, @InstallDate date
select @batteryId = BatteryId, @InstallDate=InstallDate from BatteryMoving where BatteryMovingId = @BatteryMovingId

declare @table table(VehicleString VARCHAR(250), InstallDate date, RemoveDate date, m int, mName VARCHAR(10), y int, workKm decimal(18,3), workMh DECIMAL(18,3), summaryWorkKm DECIMAL(18,3), summaryWorkMh DECIMAL(18,3), _workKm DECIMAL(18,3), _summary decimal(18,3), _summaryString VARCHAR(250))


INSERT INTO @table
EXEC BatteryCard
	@BatteryId = @batteryId


declare @rezult table(
	VehicleString varchar(100),	
	InstallDate date,
	RemoveDate date,
	WorkKm decimal(18,3),
	SummaryWorkKm decimal(18,3),
	WorkMh DECIMAL(18,3),
	SummaryWorkMh DECIMAL(18,3),
	TechState varchar(50),
	RemoveReason varchar(100)
)

while exists (select * from @table)
begin

	DECLARE @_InstallDate date
	select top 1 @_InstallDate = InstallDate from @table

	--Обрезаем лишние данные в карточке
	IF(@_InstallDate IS NOT NULL AND @_InstallDate > @InstallDate)
	BEGIN
		DELETE FROM @table
	END
	
	ELSE
		BEGIN
		INSERT INTO @rezult
		SELECT 
			a.VehicleString,
			a.InstallDate,
			a.RemoveDate,
			a.WorkKm / 1000,
			a.SummaryWorkKm / 1000,
			a.WorkMh,
			a.summaryWorkMh,
			CASE WHEN a.installDate IS NOT NULL 
				THEN CASE WHEN a.SummaryWorkKm - WorkKm <>0 OR a.SummaryWorkMh - WorkMh <>0 
					THEN 'бывшая в эксплуатации' ELSE 'новая' END
				ELSE ''
			END,
			''
		FROM (
			select top 1 * from @table
		)a
		
			delete top (1) from @table
			
		END




	/*insert into @rezult
	select 
		v.Model+', Гос.№'+v.RegistrationNumber+', Гар.№'+CAST(v.GarageNumber as varchar(10)),
		a.InstallDate,
		a.RemoveDate,
		a.work,
		a.work+@SummaryWork,
		case when @SummaryWork = 0 then 'новая' else 'бывшая в эксплуатации' end,
		r.BatteryRemoveReasonName
	from (
		select top 1 * from @table1
	)a
	left join Vehicle v on v.VehicleId = a.VehicleId
	left join BatteryRemoveReason r on r.BatteryRemoveReasonId = a.BatteryRemoveReasonId*/
			

end

/*
declare @firstFlag tinyint
select @firstFlag = 1

while exists (select * from @table)
begin
	
	
	
	
	
	declare @cnt int
	select @cnt = count(*) from @table
	
	insert into @rezult(VehicleString,InstallDate,Work,SummaryWork,TechState)
	select 
		case when @firstFlag=1 then  v.Model+', Гос.№'+v.RegistrationNumber+', Гар.№'+CAST(v.GarageNumber as varchar(10)) else null end,
		case when @firstFlag=1 then  a.InstallDate else null end,		
		a.work,
		a.work+@SummaryWork,
		case when @firstFlag=1 THEN case when @SummaryWork = 0 then 'новая' else 'бывшая в эксплуатации' end end
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
*/

select * from @rezult
