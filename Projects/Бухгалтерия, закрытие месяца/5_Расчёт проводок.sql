/*create proc AccPostingCalculate @month int, @year int,@accountingId int
as
*/

DECLARE @month int, @year int,@accountingId INT
SELECT @month=10,@year=2017,@accountingId=1

declare @ownerId int
SELECT @ownerId = 1

DECLARE @waybills TABLE(WaybillId INT,fuelid INT,fact DECIMAL(18,2),norm DECIMAL(18,2))

INSERT INTO @waybills
SELECT WaybillId,Fuelid,Fact,Norm FROM ft_AccWaybillFactNorm(@month,@year,@ownerId,@accountingId)

--3.–ассчитать перерасход топлива

declare @waste table(WaybillId INT,fuelid INT,driverId int, cons decimal(18,2))

insert into @waste
select w.WaybillId,w.fuelId,ww.DriverId,w.fact-w.norm from @waybills w
left join Waybill ww on w.WaybillId = ww.WaybillId
where 	w.fact>w.norm

delete from @waste where driverId not in (
	select driverId from @waste
	group by driverId
	having sum(cons)>=1
)

DECLARE @tempprov TABLE(debet VARCHAR(10),summ DECIMAL(18,2))
INSERT INTO @tempprov
SELECT 
	w.Debet,
	SUM(w.AccCost)
FROM dbo.ft_AccWaybillWorkInfo(@month,@year,@ownerId,@accountingId) w
GROUP BY w.Debet

INSERT INTO @TempProv
SELECT '94110100',SUM(ROUND(cons*/*p.RetailPrice* 09.2014 изменено на Price*/p.Price,2)) FROM @waste w
INNER JOIN AccFuelPrice p on w.fuelid = p.FuelId AND p.AccPeriod = @year*100+@month AND p.AccountingId = @accountingId

DECLARE @credit VARCHAR(10)
SELECT @credit = FuelCostCode FROM Accounting WHERE AccountingId = @accountingId

delete from AccPosting where AccPeriod = @year*100+@month and AccountingId = @accountingId
insert into AccPosting  (AccountingId,AccPeriod,Debet,Credit,Summ)
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


/*
SELECT SUM(Summ) FROM AccPosting WHERE AccountingId = 1
SELECT SUM(Summ) FROM AccPosting WHERE AccountingId = 2
*/

/*
DECLARE @provsettings TABLE(inputdeb VARCHAR(10), outputdeb VARCHAR(10), outputcred VARCHAR(10))

INSERT INTO @provsettings

SELECT '44020805','44020805',@credit
UNION
SELECT '44020805','90040260','44020000'
UNION
SELECT '44080105','44080105',@credit
UNION
SELECT '44080105','90100260','44080000'

UNION
SELECT '90090160','23752605',@credit
UNION
SELECT '90090160','90090160','23750000'

UNION
SELECT '90260160','23752605',@credit
UNION
SELECT '90260160','90260160','23750000'

UNION
SELECT '90390100','23750105',@credit
UNION
SELECT '90390100','90390160','23750000'

UNION
SELECT '90440160','23752605',@credit
UNION
SELECT '90440160','90440160','23750000'

UNION
SELECT '90644500','23752605',@credit
UNION
SELECT '90644500','90644500','23750000'

UNION
SELECT '90810100','23752605',@credit
UNION
SELECT '90810100','90810160','23750000'


UNION
SELECT '90533500','23752605',@credit
UNION
SELECT '90533500','90533500','23750000'


UNION
SELECT '90533000','23752605',@credit
UNION
SELECT '90533000','90533000','23750000'


UNION
SELECT '90531400','23752605',@credit
UNION
SELECT '90531400','90531400','23750000'
*/