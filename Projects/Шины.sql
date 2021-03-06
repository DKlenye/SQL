
declare @tireId int
select @tireId = 2006;


IF(SELECT KmNorm FROM Tire WHERE TireId = @tireId) IS NOT NULL

begin

declare @table table(VehicleId int, InstallDate date, RemoveDate date, m int, y int, work decimal(18,3))

insert into @table
select 
	VehicleId,
	InstallDate,
	RemoveDate,
	m,y,
	SUM(work)
from (
select
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
	
from TireMoving m
inner join Waybill w on 
	w.VehicleId = m.VehicleId and
	w.ReturnDate between m.InstallDate and ISNULL(m.RemoveDate,getDate()) and 
	w.WaybillState>1
inner join WaybillTask wt on wt.WaybillId = w.WaybillId
inner JOIN _Norm n ON n.NormId = wt.NormConsumptionId
inner JOIN WorkType wrk ON wrk.WorkTypeId = n.WorkTypeId and wrk.WorkUnitId = 1
where m.TireId = @tireId
group by w.VehicleId,w.ReturnDate,m.InstallDate,m.RemoveDate
)a
group  by VehicleId,m,y,InstallDate,RemoveDate
order by InstallDate,y,m

END
ELSE BEGIN
     	
     	DECLARE @tireMovingId int, @start date, @end date
     	
     	declare C cursor 
		for 
			SELECT tireMovingId,InstallDate,ISNULL(RemoveDate,GETDATE()) FROM TireMoving m
     		WHERE m.TireId = @tireId		
		open C
		fetch next from C into @tireMovingId , @start , @end 
		while @@fetch_status=0
		begin
			
			WHILE @start<@end
			BEGIN
				INSERT INTO @table
				SELECT 
					tm.VehicleId,
					tm.InstallDate,
					tm.RemoveDate,
					MONTH(@start),
					YEAR(@start),
					1
				  FROM TireMoving tm WHERE tm.TireMovingId = @tireMovingId
				
				SET @start = DATEADD(month,1,@start)
			END
			
			
			fetch next from C into @tireMovingId , @start , @end 
		end
		close C 
		deallocate C
    

END

SELECT * FROM @table

/*
declare @rezult table(
	VehicleString varchar(100),	
	InstallDate date,
	RemoveDate date,
	m int,
	mName varchar(20),
	y int,
	Work decimal(18,3),
	SummaryWork decimal(18,3)
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
			a.Work,
			a.work+isnull((select SUM(work) from @rezult),0) SummaryWork
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
	cast(a.m as varchar(2))+'.'+CAST(a.y as varchar(4))+' - '+cast(cast(round(_work,3) as decimal(18,3)) as varchar(15)) _summaryString	
from (
	select 
		*,
		Work/1000 _work,
		SummaryWork/1000 _summary
	from @rezult
)a
*/