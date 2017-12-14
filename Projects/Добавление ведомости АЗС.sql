declare @date date
declare @fuelId int


select @date = '02.05.2013',@fuelId = 3

declare @tankId int
declare @density decimal(18,3)

select @tankId = 1, @density = 0.842

insert into RefuellingSheet(RefuellingDate,FuelId,AzsId,TankId,density,SheetState) values(@date,@fuelId,1,@TankId,@density,2)

select SCOPE_IDENTITY()







