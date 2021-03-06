
DECLARE @month int, @year int,@accountingId INT
SELECT @month=12,@year=2013

declare @ownerId int
SELECT @ownerId = 1

DECLARE @costCode VARCHAR(10); SET @costCode = '78011200';
IF @accountingId = 0 SET @accountingId=NULL;



DECLARE @t TABLE(CustomerId INT, Cons DECIMAL(18,3), Cost DECIMAL(18,3))
INSERT INTO @t
	SELECT 
	CustomerId,
	SUM(isnull(AccConsumption,0)) Cons,
	SUM(isnull(AccCost,0)) Cost
	FROM (
		SELECT 
			i.*		
		FROM dbo.ft_AccWaybillWorkInfo(@month, @year,@ownerId, @accountingId) i
		INNER JOIN Vehicle v ON v.VehicleId	= i.VehicleId				
		WHERE i.Debet = @costCode AND isnull(i.ColumnId,5)<>5
	)b
	GROUP BY CustomerId


DECLARE @s INT
SELECT @s = SUM(Summ) FROM AccPostingDiff apd WHERE apd.AccYear=@year*100+@month AND apd.Debet = @costCode

DECLARE @k DECIMAL(18,3)

SELECT @k = SUM(Cost)/@s FROM @t

SELECT @s,SUM(Cost) FROM @t



SELECT c.PolymirCostCode,c.CustomerName,cast(round(Cost/@k,0) AS INT) s
  FROM @t t
LEFT JOIN Customer c ON c.CustomerId = t.CustomerId
ORDER BY 1
