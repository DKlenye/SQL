declare  @month int, @year int, @accountingId int

select @month = 10, @year = 2014, @accountingId = 2

DECLARE @ownerId int; set @ownerId = 1;
DECLARE @pmonth INT,@pyear INT

IF @month=1 SELECT @pmonth=12,@pyear=@year-1
ELSE SELECT @pmonth=@month-1,@pyear=@year

IF @accountingId = 0 SET @accountingId=NULL;


declare @remain table(VehicleId int, FuelId int,RemainCost decimal(18,3),RemainQuantity decimal(18,3),RemainDiff decimal(18,3))
insert into @remain
select 
	r.VehicleId,
	r.FuelId,
	sum(r.Cost) RemainCost,
	sum(r.Quantity)RemainQuantity,
	SUM(r.DiffCost) RemainDiff
from AccFuelRemain r
where r.AccPeriod = @year*100+@month AND r.AccountingId = isnull(@accountingId,r.AccountingId)
group by r.VehicleId,r.FuelId


declare @_refuelling table(AccountingId int,VehicleId int,FuelId int,RefuellingPlaceId int,RefuellingQuantity decimal(18,3))
insert into @_refuelling

SELECT
		a.AccountingId,
		v.VehicleId,
		r.FuelId,
		r.RefuellingPlaceId,
		sum(r.Quantity) Quantity
	from 
	VehicleRefuelling r
	INNER join Waybill w on w.WaybillId = r.WaybillId
	INNER join Vehicle v on v.VehicleId = w.VehicleId and v.OwnerId = @ownerId
	INNER JOIN TransportColumn tc ON tc.ColumnId = isnull(v.ColumnId,5)
	INNER join Accounting a on a.AccountingId = isnull(r.AccountingId,isnull(w.AccountingId,tc.AccountingId)) and a.AccountingId = isnull(@accountingId,a.AccountingId)
	where 
		(month(r.RefuellingDate)=@month and year(r.RefuellingDate)=@year AND r.AccPeriod is null)
		or r.AccPeriod = @year*100+@month
	Group BY a.AccountingId,v.VehicleId,r.FuelId,r.RefuellingPlaceId


declare @_refuellingPrice table(AccountingId int,FuelId int,RefuellingPlaceId int,Price decimal(18,13))
insert into @_refuellingPrice
select 
	a.AccountingId,
	a.FuelId,
	a.RefuellingPlaceId,
	case when a.RefuellingQuantity = 0 then 0 else ff.Cost/a.RefuellingQuantity end Price
from ( 
select 
	r.AccountingId,
	r.FuelId,
	r.RefuellingPlaceId,
	SUM(r.RefuellingQuantity) RefuellingQuantity 
from @_refuelling r 
group by r.AccountingId,r.FuelId,r.RefuellingPlaceId
)a
left join FuelFilledCost ff on ff.AccountingId = a.AccountingId and ff.AccPeriod = @year*100+@month and ff.RefuellingPlaceId = a.RefuellingPlaceId and ff.FuelId = a.FuelId


declare @refuelling table(VehicleId int,FuelId int,RefuellingPlaceId int,RefuellingQuantity decimal(18,3), Cost decimal(18,3))
insert into @refuelling 

select 
r.VehicleId,
r.FuelId,
r.RefuellingPlaceId,
r.RefuellingQuantity,
r.RefuellingQuantity*rp.Price Cost
from @_refuelling r
left join @_refuellingPrice rp on 
	rp.AccountingId = r.AccountingId and 
	rp.FuelId = r.FuelId and 
	r.AccountingId = rp.AccountingId and 
	r.RefuellingPlaceId = rp.RefuellingPlaceId


declare @waste table(AccountingId INT, WaybillId INT,fuelid INT,driverId int, cons decimal(18,2))
insert into @waste
SELECT w.AccountingId,w.WaybillId,w.fuelId,ww.DriverId,w.fact-w.norm from ft_AccWaybillFactNorm(@month,@year,@ownerId,@accountingId)w
left join Waybill ww on w.WaybillId = ww.WaybillId
where 	w.fact>w.norm

delete from @waste where driverId not in (
	select driverId from @waste
	group by driverId
	having sum(cons)>=1
)


declare @consumption table(VehicleId int, FuelId int,Consumption decimal(18,3), ConsumptionCost decimal(18,3))
INSERT INTO @consumption
select 	
	a.VehicleId,
	a.FuelId,
	SUM(cons) cons,
	sum(cast (round(cons*isnull(p.Price,0),0) as int)) cost
from (
	SELECT 
		w2.VehicleId,
		w.AccountingId,
		wt.FuelId,
		case when wst.WaybillId is null then  round(wt.Consumption*(case when w.norm<>0 then (w.fact/w.norm) else 0 end),2) else wt.Consumption end  cons
	FROM ft_AccWaybillFactNorm(@month,@year,@ownerId,@accountingId)w
	INNER JOIN Waybill w2 on w2.WaybillId = w.WaybillId
	INNER JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId AND wt.FuelId = w.fuelid AND isnull(wt.Consumption,0)<>0
	INNER JOIN Vehicle v ON v.VehicleId = w2.VehicleId
	INNER JOIN TransportColumn tc on tc.ColumnId = isnull(v.ColumnId,5)
	LEFT JOIN Accounting a ON a.AccountingId = w2.AccountingId
	left join @waste wst on wst.WaybillId = w.WaybillId and w.fuelId = wst.fuelId
	)a
	left join AccFuelPrice p on p.AccountingId = a.AccountingId and p.AccPeriod = @year*100+@month and p.FuelId = a.FuelId
	group by a.VehicleId,a.FuelId




UPDATE c SET 
	c.Consumption = c.Consumption + cc.cons,
	c.ConsumptionCost = c.ConsumptionCost + cc.cost 
FROM @consumption c
INNER JOIN(
	SELECT 
	w2.VehicleId,
	w.FuelId,
	SUM(cons)cons,
	SUM(ROUND(cons*p.Price,0))cost
	FROM @waste w
	inner join Waybill w2 on w2.WaybillId = w.WaybillId
	INNER JOIN AccFuelPrice p on w.fuelid = p.FuelId AND p.AccPeriod = @year*100+@month AND p.AccountingId = w.AccountingId
	GROUP BY w2.VehicleId,w.FuelId
)cc ON c.VehicleId = cc.VehicleId AND c.FuelId=cc.FuelId

INSERT INTO @consumption
SELECT 
	cc.VehicleId,
	cc.FuelId,
	cc.cons,
	cc.cost
FROM @consumption c 
Right JOIN(
	SELECT 
	w2.VehicleId,
	w.FuelId,
	SUM(cons)cons,
	SUM(ROUND(cons*p.Price,0))cost
	FROM @waste w
	inner join Waybill w2 on w2.WaybillId = w.WaybillId
	INNER JOIN AccFuelPrice p on w.fuelid = p.FuelId AND p.AccPeriod = @year*100+@month AND p.AccountingId = w.AccountingId
	GROUP BY w2.VehicleId,w.FuelId
)cc ON c.VehicleId = cc.VehicleId AND c.FuelId=cc.FuelId




/*

SELECT 
	w2.VehicleId,
	w.FuelId,
	SUM(cons)cons,
	SUM(ROUND(cons*p.Price,0))cost
	FROM @waste w
	inner join Waybill w2 on w2.WaybillId = w.WaybillId
	INNER JOIN AccFuelPrice p on w.fuelid = p.FuelId AND p.AccPeriod = @year*100+@month AND p.AccountingId = w.AccountingId
	GROUP BY w2.VehicleId,w.FuelId

*/













SELECT * FROM @consumption WHERE VehicleId = 1243


insert into @remain
select distinct r.VehicleId,r.FuelId,0,0,0 from @refuelling r
left join  @remain f on f.VehicleId = r.VehicleId and r.FuelId = f.FuelId
where f.VehicleId is null


insert into @remain
select distinct r.VehicleId,r.FuelId,0,0,0 from @consumption r
left join  @remain f on f.VehicleId = r.VehicleId and r.FuelId = f.FuelId
where f.VehicleId is null





	select 
	a.*,
	RemainQuantity+RefuellingQuantity-Consumption  EndRemain,
	RemainCost+isnull(RemainDiff,0)+RefuellingCost-ConsumptionCost  EndRemainCost
	from (
	select 
		v.VehicleId,
		v.GarageNumber,
		v.RegistrationNumber,
		v.Model,
		r.FuelId,
		ff.FuelName,
		r.RemainQuantity,
		r.RemainCost,
		r.RemainDiff,
		ISNULL(f.RefuellingQuantity,0)RefuellingQuantity,
		ISNULL(f.Cost,0)RefuellingCost,
		ISNULL(c.Consumption,0)Consumption,
		ISNULL(c.ConsumptionCost,0)ConsumptionCost
	from @remain r
	left join (select VehicleId,FuelId,SUM(RefuellingQuantity)RefuellingQuantity,SUM(Cost) Cost from @refuelling group by VehicleId,FuelId)f on f.FuelId = r.FuelId and f.VehicleId = r.VehicleId
	left join @consumption c on c.FuelId = r.FuelId and c.VehicleId = r.VehicleId
	left join Vehicle v on v.VehicleId = r.VehicleId
	left join Fuel ff on ff.FuelId = r.FuelId
	)a
	WHERE VehicleId = 1243
