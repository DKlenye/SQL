DECLARE @tireId INT
SELECT @tireId = 55

DECLARE @KmNorm INT, @MonthNorm int

SELECT @KmNorm=KmNorm,@MonthNorm =MonthNorm FROM Tire
WHERE TireId = @tireId

declare @table table(ORDER_ID int, m INT, y INT,TireMovingId INT,VehicleId INT, InstallDate date, RemoveDate date,  work decimal(18,3), sumWork DECIMAL(18,3), isHanded bit)

insert into @table
EXECUTE VehicleTireWork_Select @tireId=@tireId

SELECT  (1-((isnull(@KmNorm,@MonthNorm)-SUM(work))/isnull(@KmNorm,@MonthNorm)))*100 FROM @table




