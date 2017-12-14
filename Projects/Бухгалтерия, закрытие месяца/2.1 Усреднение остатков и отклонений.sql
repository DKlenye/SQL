DECLARE @accPeriod INT
SET @accPeriod = 201710

DECLARE @Summary TABLE(AccountingId INT, FuelId INT, Quantity DECIMAL(18,2), Cost DECIMAL(18,2), Diff DECIMAL(18,2))

INSERT INTO @Summary
SELECT AccountingId,FuelId,SUM(Quantity),SUM(Cost), SUM(DiffCost) FROM AccFuelRemain 
WHERE AccPeriod = @accPeriod
GROUP BY AccountingId,FuelId


select * from @Summary

UPDATE AccFuelRemain
SET
	Cost = r.Quantity * Price,
	DiffCost = r.Quantity * DiffPrice
FROM AccFuelRemain r
LEFT JOIN (
SELECT *,
	case when Quantity = 0 then 0 else round(Cost/Quantity,2) end as Price,
	case when Quantity = 0 then 0 else round(Diff/Quantity,2) end AS DiffPrice
FROM @Summary
)s ON r.AccountingId = s.AccountingId AND r.FuelId = s.FuelId
where r.AccPeriod = @accPeriod


SELECT * FROM AccFuelRemain WHERE AccPeriod = @accPeriod

DECLARE @AccountingId INT, @FuelId INT, @Quantity DECIMAL(18,2), @Cost DECIMAL(18,3), @Diff DECIMAL(18,2)

DECLARE Cur CURSOR FOR	SELECT * FROM @Summary
OPEN Cur
fetch next from Cur into @AccountingId , @FuelId , @Quantity , @Cost , @Diff 

while @@fetch_status=0
begin

DECLARE @tmpDiff DECIMAL(18,3)
SET @tmpDiff = 0

SELECT @tmpDiff = @Cost - SUM(Cost) FROM AccFuelRemain WHERE AccPeriod = @accPeriod AND AccountingId = @AccountingId AND FuelId = @FuelId

IF(@tmpDiff<>0)
BEGIN
	UPDATE TOP (1) AccFuelRemain SET Cost = @tmpDiff + Cost  WHERE AccPeriod = @accPeriod AND FuelId = @FuelId AND AccountingId = @AccountingId AND Quantity<>0
END

SELECT @tmpDiff = @Diff - SUM(DiffCost) FROM AccFuelRemain WHERE AccPeriod = @accPeriod AND AccountingId = @AccountingId AND FuelId = @FuelId

IF(@tmpDiff<>0)
BEGIN
	UPDATE TOP (1) AccFuelRemain SET DiffCost = @tmpDiff + DiffCost  WHERE AccPeriod = @accPeriod AND FuelId = @FuelId AND AccountingId = @AccountingId AND Quantity<>0
END

fetch next from Cur into @AccountingId , @FuelId , @Quantity , @Cost , @Diff 
end
close Cur 
deallocate Cur
