
declare @BatteryMovingId int
set @BatteryMovingId = 11


declare @table table(BatteryMovingId int,VehicleId int, BatGarageNumber varchar(10),BatteryMakerName varchar(50),BatteryTypeName varchar(50), MakeDate date, Cost int, Doc varchar(50),InitKmWork decimal(18,3),InitMhWork decimal(18,3),MonthStart int,ResidueCost int)
insert into @table
select
	top 1 
	m.BatteryMovingId,
	m.VehicleId,
	m.BatGarageNumber,
	bm.BatteryMakerName,
	bt.BatteryTypeName,
	b.MakeDate,
	isnull(b.Cost,-1) Cost,
	b.Doc,
	b.InitKmWork,
	b.InitMhWork,
	b.MonthStart,
	null
from Battery b
left join BatteryMaker bm on bm.BatteryMakerId = b.BatteryMakerId
left join BatteryType bt on bt.BatteryTypeId = b.BatteryTypeId
inner join BatteryMoving m on m.BatteryMovingId = @BatteryMovingId and m.BatteryId = b.BatteryId

declare @BatId int, @InstallDate date
select @BatId = BatteryId,@InstallDate = InstallDate from BatteryMoving where BatteryMovingId = @BatteryMovingId



declare @work table(BatteryMovingId int ,VehicleId int, InstallDate date, RemoveDate date, m int, y int, workKm decimal(18,3), workMh DECIMAL(18,3), MonthCount int)

INSERT INTO @work
SELECT 
	m.BatteryMovingId,
	m.VehicleId,
	m.InstallDate,
	m.RemoveDate,
	w.AccPeriod-(w.AccPeriod/100)*100,
	w.AccPeriod/100,
	case WHEN m.WorkUnitId = 1 THEN w.Km ELSE 0 END ,
	case WHEN m.WorkUnitId = 3 THEN w.Mh ELSE 0 END,
	DATEDIFF(Month,m.InstallDate,ISNULL(m.RemoveDate,getDate()))
FROM BatteryMoving m
INNER JOIN WaybillWorkExtended w ON w.VehicleId = m.VehicleId
WHERE 
	m.BatteryId = @BatId and
 AccPeriod>= YEAR(m.InstallDate)+100*MONTH(m.InstallDate) AND AccPeriod<=year(ISNULL(m.RemoveDate,getDate()))*100+MONTH(ISNULL(m.RemoveDate,getDate()))




insert into @work
select 
	BatteryMovingId,
	VehicleId,
	InstallDate,
	RemoveDate,
	m,y,
	SUM(Km),
	SUM(Mh),
	DATEDIFF(Month,InstallDate,ISNULL(RemoveDate,getDate()))
from (
SELECT 
	m.BatteryMovingId,
	m.BatteryRemoveReasonId,
	m.InstallDate,
	m.RemoveDate,
	m.VehicleId,
	MONTH(ww.WorkDate)m,
	YEAR(ww.WorkDate)y,
	sum(case WHEN m.WorkUnitId = 1 THEN ww.km ELSE 0 END) Km,
	sum(case WHEN m.WorkUnitId = 3 THEN ww.MotoHour ELSE 0 END) Mh
FROM BatteryMoving m
LEFT JOIN WaybillWork ww ON m.VehicleId = ww.VehicleId AND ww.WorkDate BETWEEN m.InstallDate and ISNULL(m.RemoveDate,getDate())
where m.BatteryId = @BatId
group BY m.BatteryMovingId, m.VehicleId,ww.WorkDate, m.InstallDate,m.RemoveDate,m.BatteryRemoveReasonId
)a
group  by BatteryMovingId,VehicleId,m,y,InstallDate,RemoveDate,BatteryRemoveReasonId
order by InstallDate,y,m


--Количество отработанных месяцев до установки
declare @WorkMonth int
select @WorkMonth = SUM(isnull(MonthCount,0)) from(
	select distinct BatteryMovingId,MonthCount from @work where InstallDate<@InstallDate
)a



--Работа до постановки
declare @WorkKmAmount decimal(18,3), @WorkMhAmount DECIMAL(18,3)
select @WorkKmAmount = SUM(workKm), @WorkMhAmount = SUM(workMh) from @work where InstallDate<@InstallDate

update @table set 
	InitKmWork = (isnull(InitKmWork,0)+isnull(@WorkKmAmount,0)), 
	MonthStart = isnull(MonthStart,0)+isnull(@WorkMonth,0),
	InitMhWork = (isnull(InitMhWork,0)+isnull(@WorkMhAmount,0))


--Остаточная стоимость
declare @ResidueCost int
select 
	@ResidueCost = case when MonthCost<WorkCost then MonthCost else WorkCost end 
from (
	select 
		round(b.Cost*((b.Warrantly-t.MonthStart)/cast(b.Warrantly as decimal(18,3))),0) MonthCost,
		round(b.Cost*(1-( case WHEN b.KmNorm = 0 THEN 0 ELSE (t.InitKmWork/b.KmNorm) END  +  case WHEN b.MhNorm = 0 THEN 0 ELSE (t.InitMhWork/b.MhNorm) end),0) WorkCost
	from @table t
	left join Battery b on b.BatteryId = @BatId
)a

update @table set ResidueCost = case when @ResidueCost < 0 then 0 else @ResidueCost end


declare @WorkMonth2 INT
select @WorkMonth2 = SUM(isnull(MonthCount,0)) from(
	select distinct BatteryMovingId,MonthCount from @work where InstallDate<=@InstallDate
)a

declare @WorkKmAmount2 decimal(18,3), @WorkMhAmount2 DECIMAL(18,3)
select @WorkKmAmount2 = SUM(workKm),@WorkMhAmount2 = SUM(workMh) from @work where InstallDate<=@InstallDate

declare @ResidueCost2 int
select 
	@ResidueCost2 = case when MonthCost<WorkCost then MonthCost else WorkCost end 
from (
select 
	round(b.Cost*((b.Warrantly-(b.MonthStart+@WorkMonth2))/cast(b.Warrantly as decimal(18,3))),0) MonthCost,
	round(b.Cost*((b.InitKmWork+@WorkKmAmount2)/b.KmNorm + (b.InitMhWork+@WorkMhAmount2)/b.MhNorm ),0) WorkCost
from Battery b
where b.BatteryId = @BatId
)a

if @ResidueCost2 < 0 set @ResidueCost2 = 0


select 
	t.*,
	d.Fio,
	mm.MonthName,
	m.InstallDate,
	case when r.isWriteOff is not null
		then case when r.isWriteOff = 1
			then 'Не годна к эксплуатации'
			else 'Оприходовать на склад, остаточная стоимость'+cast(@ResidueCost2 as varchar(10))+' руб.'
			end
		else ''
	end CommissionString,
	@WorkMonth2 workMonth,
	@WorkKmAmount2 workAmount
from @table t
left join Vehicle v on v.VehicleId = t.VehicleId
left join v_Driver d on d.DriverId = v.DriverId
left join BatteryMoving m on t.BatteryMovingId = m.BatteryMovingId
left join BatteryRemoveReason r on r.BatteryRemoveReasonId = m.BatteryRemoveReasonId
left join Monthes mm on mm.Id = MONTH(m.InstallDate)
