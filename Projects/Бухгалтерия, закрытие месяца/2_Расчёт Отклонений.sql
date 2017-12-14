declare  @month int, @year int
select @month = 10, @year = 2017

DECLARE @ownerId int; set @ownerId = 1;
DECLARE @pmonth INT,@pyear INT

IF @month=1 SELECT @pmonth=12,@pyear=@year-1
ELSE SELECT @pmonth=@month-1,@pyear=@year


update AccFuelRemain
	set DiffCost = ISNULL(a.Diff,0)
from AccFuelRemain r
left join (	
	select AccountingId,VehicleId,FuelId, Sum(RefuellingCost-RefuellingCostDiff) Diff from ft_VehicleRefuellingCost((@pyear*100+@pmonth),@ownerId,null)
	group by AccountingId,VehicleId,FuelId
)a on a.AccountingId =  r.AccountingId and a.FuelId = r.FuelId and a.VehicleId = r.VehicleId
where r.AccPeriod = @year*100+@month











