
DECLARE @month int, @year int,@accountingId INT
SELECT @month=12,@year=2016,@accountingId=1

declare @ownerId int
SELECT @ownerId = 1

DECLARE @waybills TABLE(WaybillId INT,fuelid INT,fact DECIMAL(18,2),norm DECIMAL(18,2))

INSERT INTO @waybills
SELECT WaybillId,Fuelid,Fact,Norm FROM ft_AccWaybillFactNorm(@month,@year,@ownerId,@accountingId)


DECLARE @tempPrice TABLE (fuelId INT,Price DECIMAL(18,15))
INSERT INTO @tempPrice
SELECT aa.fuelId,aa.diff/a.fact
FROM (
SELECT ffc.FuelId, SUM(diff) diff FROM FuelFilledCost ffc
WHERE ffc.AccPeriod = @year*100+@month AND ffc.AccountingId = @accountingId
GROUP BY ffc.FuelId
)aa
LEFT JOIN (SELECT fuelId,sum(fact)fact FROM @waybills GROUP BY fuelId) a ON a.fuelId = aa.fuelId

DECLARE @tempprov TABLE(debet VARCHAR(10),summ int)
INSERT INTO @tempprov
SELECT 
	w.Debet,
	round(SUM(w.AccConsumption*p.Price),0)
FROM dbo.ft_AccWaybillWorkInfo(@month,@year,@ownerId,@accountingId) w
left join @tempPrice p on p.FuelId = w.FuelId
GROUP BY w.Debet

DECLARE @credit VARCHAR(10)
SELECT @credit = FuelCostCode FROM Accounting WHERE AccountingId = @accountingId


DELETE FROM AccPostingDiff WHERE AccYear = @year*100+@month AND AccountingId = @accountingId
INSERT INTO AccPostingDiff
SELECT 
@accountingId,
@year*100+@month,
debet,
credit,
sum(summ)
FROM (
SELECT debet,@credit credit,summ FROM @tempprov WHERE debet NOT IN (SELECT DISTINCT inputdeb FROM Provsettings)
UNION all
SELECT s.outputdeb,isnull(s.outputcred,@credit),p.summ FROM @tempprov p
INNER JOIN Provsettings s ON s.inputdeb = p.debet
)a
where summ<>0 
GROUP BY debet,credit

DECLARE @Dif INT
SELECT @Dif = SUM(Summ) FROM AccPostingDiff WHERE AccYear = @year*100+@month AND AccountingId = @accountingId AND credit LIKE '10%'
SELECT @Dif = @Dif - sum(Diff) FROM FuelFilledCost WHERE AccPeriod = @year*100+@month AND AccountingId = @accountingId

update AccPostingDiff SET Summ = Summ-@Dif WHERE AccYear = @year*100+@month AND AccountingId = @accountingId AND debet = (
SELECT TOP 1 debet FROM AccPostingDiff WHERE AccYear = @year*100+@month AND AccountingId = @accountingId ORDER BY DEBET
)

SELECT SUM(summ) FROM AccPostingDiff WHERE AccYear = @year*100+@month AND AccountingId = @accountingId AND credit LIKE '10%'
SELECT * FROM AccPostingDiff  WHERE AccYear = @year*100+@month AND AccountingId = @accountingId 
