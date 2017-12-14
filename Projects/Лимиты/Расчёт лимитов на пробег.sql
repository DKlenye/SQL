declare @month int, @year int,@owner int
select @month = 07,@year=2013,@owner = 1


create proc CalculateKmLimits @month int, @year int
as

declare @owner int
select @owner = 1

declare @date date
select @date = CONVERT(Date, '01.'+cast(@month as varchar(2))+'.'+cast(@year as varchar(4)) ,104)


delete from VehicleLimits where KmLimit is not null and Period = @year*100+@month

insert into VehicleLimits(VehicleId,Period,FuelLimit,KmLimit)
select 
	l.VehicleId,
	@year*100+@month,
	dbo.getFuelConsumptionByLimit(l.VehicleId,@date,l.KmLimit) FuelLimit,
	l.KmLimit
from (
select 
	l.VehicleId,
	max(l.Period) Period
from VehicleKmLimits l
inner join Vehicle v on v.VehicleId = l.VehicleId and v.OwnerId = @owner
where l.Period<=@year*100+@month
group by l.VehicleId
)a
inner join VehicleKmLimits l on l.VehicleId = a.VehicleId and l.Period = a.Period



select * from VehicleLimits