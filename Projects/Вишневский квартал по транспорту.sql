declare @month int, @count INT, @year int
select @month = 10,@year = 2014, @count = 3


WHILE @count>0
BEGIN
	
	insert into __Vishnevsky
	select 
		@month m,
		2014 y,		
		f.FuelName,
		g.RefuellingGroupName,	
		SUM(t.Fact) Fact

	from [ft_AccWaybillFactNorm](@month,@year,1,null) t
	left join Waybill w on w.WaybillId = t.WaybillId
	left join Fuel f on f.FuelId = t.Fuelid
	left join Vehicle v on v.VehicleId = w.VehicleId
	left join RefuellingGroup g on g.RefuellingGroupId = v.RefuellingGroupId
	where g.RefuellingGroupId not in (4,5,7,19)
	group by g.RefuellingGroupName,	f.FuelName
	
	SET @month = @month+1
	SET @count = @count-1	
	
END







