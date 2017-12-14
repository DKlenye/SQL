/*create function [dbo].[ft_FuelLimits_Select](@month int,@year int,@garagenumber int)
returns @t table(garagenumber int,limit decimal(18,1),quantity int, cons decimal(18,2),diff decimal(18,2))
as
*/
create proc CalculateFuelLimits @month int,@year int
as
/*
declare @month int,@year int
select @month=07,@year=2013
*/
declare @tmp table(VehicleId int, FuelLimit int)
insert into @tmp
select VehicleId,FuelLimit from dbo.getMonthLimits(@month,@year)


delete from VehicleLimits where KmLimit is null and Period = @year*100+@month

insert into VehicleLimits(VehicleId,Period,FuelLimit,KmLimit)

select 
	VehicleId,
	@year*100+@month,
	FuelLimit,
	null
	
from (

	select VehicleId,FuelLimit from @tmp
	union all
	select VehicleId,FuelLimit from DayLimitsToMonth(@month, @year) where VehicleId not in (select Vehicleid from @tmp)

)a
