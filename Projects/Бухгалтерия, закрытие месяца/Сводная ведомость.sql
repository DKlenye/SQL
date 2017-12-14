declare @month int, @year int,@accountingId INT
SELECT @month=12,@year=2013
declare @ownerId int
SELECT @ownerId = 1

DELETE FROM  __ExpenseList
INSERT INTO __ExpenseList

SELECT 
	c.AccGroupId,
	g.AccGroupName,
	SUBSTRING(g.CostCode,1,2) bs,
	SUBSTRING(g.CostCode,3,4) sbs,
	debet,
	round(Mh,2) Mh,
	round(Km,2) Km,
	Cons,
	Cost,
	@month accmonth,
	@year accyear
FROM (
	SELECT 
	AccGroupId,
	debet,
	cast(SUM(isnull(AccConsumption,0)) AS INT) Cons,
	SUM(isnull(AccCost,0)) Cost,
	SUM(isnull(km,0)) Km,
	SUM(isnull(mh,0)) Mh

	FROM (
		SELECT 
			i.*,
			g.AccGroupId	
		FROM dbo.ft_AccWaybillWorkInfo(@month, @year,@ownerId, @accountingId) i
		INNER JOIN Vehicle v ON v.VehicleId = i.VehicleId
		LEFT JOIN AccGroup g ON g.AccGroupId = v.AccGroupId
		WHERE isnull(i.ColumnId,5)<>5
	)b
	GROUP BY AccGroupId,debet
)c
LEFT JOIN AccGroup g ON g.AccGroupId = c.AccGroupId
