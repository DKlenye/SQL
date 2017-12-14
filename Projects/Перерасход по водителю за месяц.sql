
DECLARE @driverId INT
SET @driverId = 756

DECLARE @month int, @year int, INT, @ownerId INT
SELECT @month=01,@year=2014,@ownerId = 1

SELECT * FROM WaybillWork ww
INNER JOIN Waybill w ON w.WaybillId = ww.WaybillId
WHERE 
	w.DriverId = @driverId 	AND
	w.ReturnDate








/*

DECLARE @month int, @year int,@accountingId INT, @ownerId INT
SELECT @month=01,@year=2014,@accountingId=null,@ownerId = 1

DECLARE @waybills TABLE(WaybillId INT,fuelid INT,fact DECIMAL(18,2),norm DECIMAL(18,2))

INSERT INTO @waybills
SELECT WaybillId,Fuelid,Fact,Norm FROM ft_AccWaybillFactNorm(@month,@year,@ownerId,@accountingId)

SELECT isnull(SUM(w.fact-w.norm),0) FROM @waybills w
INNER JOIN Waybill ww ON w.WaybillId = ww.WaybillId AND ww.DriverId = @driverId
WHERE w.fact>w.norm

*/