DECLARE @VehicleId INT, @fuelId INT, @AccPeriod INT, @Quantity DECIMAL (18,3)
SELECT @VehicleId = 1678, @Quantity = 13.85, @fuelId = 3, @AccPeriod = 201512

DECLARE @CostPrice DECIMAL(18,9), @DiffPrice DECIMAL (18,9)

SELECT
	@CostPrice = Cost/Quantity,
	@DiffPrice = DiffCost/Quantity
FROM AccFuelRemain WHERE AccPeriod = @AccPeriod AND VehicleId = @VehicleId AND FuelId = @fuelId


SELECT * FROM AccFuelRemain WHERE AccPeriod = @AccPeriod AND FuelId= @fuelId AND VehicleId = @VehicleId


UPDATE AccFuelRemain set
	Quantity = Quantity - @Quantity,
	Cost = (Quantity - @Quantity)*@CostPrice,
	DiffCost = (Quantity - @Quantity)*@DiffPrice
WHERE AccPeriod = @AccPeriod AND FuelId = @fuelId AND VehicleId = @VehicleId


INSERT INTO AccFuelRemain
(
	VehicleId,
	FuelId,
	AccPeriod,
	Quantity,
	Cost,
	DiffCost,
	AccountingId
)
SELECT
	@VehicleId,
	@fuelId,
	@AccPeriod,
	@Quantity,
	@Quantity*@CostPrice,
	@Quantity*@DiffPrice,
	1

SELECT * FROM AccFuelRemain WHERE AccPeriod = @AccPeriod AND FuelId= @fuelId AND VehicleId = @VehicleId




/*
UPDATE AccFuelRemain
SET
	Quantity = 76.830,
	Cost = 459212.910,
	DiffCost = -77828.790
WHERE VehicleId = 66 and
	FuelId = 1 and
	AccPeriod = 201512 and
	AccountingId = 3
	
DELETE FROM AccFuelRemain WHERE VehicleId = 66 and
	FuelId = 1 and
	AccPeriod = 201512 and
	AccountingId = 1
	*/
	