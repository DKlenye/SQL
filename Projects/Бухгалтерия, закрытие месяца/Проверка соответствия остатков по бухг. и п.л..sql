DECLARE @columnId INT , @departmentId INT, @driverId int

IF @columnId = 0 SET @columnId = NULL
IF @departmentId = 0 SET @departmentId = null
IF @driverId = 0 SET @driverId = null


DECLARE @date DATE, @Owner int
SELECT @date = '01.11.2014',@Owner=1

DECLARE @fuelPrice TABLE(AccountingId INT, FuelId INT, Price INT)

INSERT INTO @fuelPrice
SELECT 
	AccountingId,
	FuelId,
	Round(CASE WHEN Quantity = 0 THEN 0 ELSE  Cost/Quantity END,0) Price
FROM(
	SELECT 
		FuelId,
		AccountingId,
		round(SUM(Quantity),2) Quantity,
		round(SUM(Cost),0) Cost
	FROM AccFuelRemain afr
	WHERE afr.AccPeriod = YEAR(@date)*100+MONTH(@date)
	GROUP BY FuelId,	AccountingId
)a

declare @remains table(
	WaybillId int,
	VehicleId int,
	FuelId int, 
	Remain decimal(18,2),
	Trip varchar(5)
)

insert into @remains
select 
w.WaybillId,
w.VehicleId,
FuelId,
DepartureRemain + Refuelling as Remain,
case when w.ReturnDate>@date then 'ком' else null end
from(
	select 
		w.WaybillId,
		w.VehicleId,
		fr.FuelId,
		fr.DepartureRemain,
		SUM(isnull(r.Quantity,0)) Refuelling
	from (
		select 
			w.VehicleId,
			min(w.Position) Position
		from Waybill w 
		inner join Vehicle v on v.VehicleId = w.VehicleId AND v.OwnerId = @Owner
		where 
			w.WaybillState=1 and w.DepartureDate < @date
		group by w.VehicleId
	)a
	inner join Waybill w on w.VehicleId = a.VehicleId and w.Position = a.Position
	left join WaybillFuelRemain fr on fr.WaybillId = w.WaybillId
	left join Waybill ww on ww.VehicleId = w.VehicleId and ww.Position>=w.Position
	left join VehicleRefuelling r on fr.FuelId = r.FuelId and r.RefuellingDate>=w.DepartureDate and r.RefuellingDate < @date and r.WaybillId = ww.WaybillId
	group by w.WaybillId, w.VehicleId, fr.FuelId, fr.DepartureRemain
)b
inner join Waybill w on w.WaybillId = b.WaybillId

insert into @remains
select 
		w.WaybillId,
		w.VehicleId,
		fr.FuelId,
		fr.ReturnRemain,
		case when w.ReturnDate>=@date then 'п' else null end
	from (
		select 
			w.VehicleId,
			max(w.Position) Position
		from Waybill w 
		INNER JOIN Vehicle v on v.VehicleId = w.VehicleId AND v.OwnerId = @Owner
		LEFT JOIN @remains r ON r.VehicleId = v.VehicleId
		where 
			r.VehicleId IS NULL and
			w.DepartureDate < @date AND w.WaybillState > 1
		group by w.VehicleId
	)a
	inner join Waybill w on w.VehicleId = a.VehicleId and w.Position = a.Position
	INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId 
	left join WaybillFuelRemain fr on fr.WaybillId = w.WaybillId
	group by w.WaybillId, w.VehicleId,w.ReturnDate, fr.FuelId, fr.ReturnRemain

delete r from @remains as r
left join norm n on n.VehicleId = r.VehicleId
left join NormFuels nf on nf.NormId = n.NormId and nf.FuelId = r.FuelId
where isnull(Remain,0) = 0 and nf.FuelId is NULL


SELECT 	
	v.VehicleId,
	v.Model,
	r.WaybillId,
	v.GarageNumber,
	r.Trip,
	f.FuelName,
	r.Remain,
	ar.Quantity,
	ar.AccountingId,
	r.Remain - ar.Quantity diff	
FROM @remains r
LEFT JOIN AccFuelRemain ar ON r.FuelId = ar.FuelId AND ar.VehicleId = r.VehicleId AND ar.AccPeriod = 201411
LEFT JOIN Vehicle v ON v.VehicleId = r.VehicleId
LEFT JOIN Fuel f ON f.FuelId = r.FuelId
WHERE ISNULL(r.Remain,0)<>ISNULL(ar.Quantity,0) AND ar.AccountingId = 2 --AND r.FuelId = 3
ORDER BY 10
--select * from AccFuelRemain where AccPeriod = 201411 and fuelId = 4 and ACCOUNTINGiD = 2
--select * from _PolymirWaybill where gar_n = 1437
	
	
	
	
	/*
	SELECT 
		*,
		r.Remain - ar.Quantity diff	
	FROM AccFuelRemain ar
	LEFT JOIN @remains r ON r.VehicleId = ar.VehicleId AND r.FuelId = ar.FuelId
	WHERE ar.AccPeriod = 201311 AND ISNULL(r.Remain,0)<>ISNULL(ar.Quantity,0) AND r.FuelId = 2
	
	
	
	SELECT v.GarageNumber,afr.* FROM AccFuelRemain afr 
	LEFT JOIN Vehicle v ON v.VehicleId = afr.VehicleId
	WHERE Accperiod = 201311 AND afr.FuelId = 4
	*/
	
	
	
	
	
	
	--SELECT * FROM AccFuelRemain WHERE VehicleId IN (117)
	
/*
update AccFuelRemain set Quantity = Quantity-5.51 WHERE VehicleId in(1301) and accPeriod = 201411 and fuelId = 3
update AccFuelRemain set Quantity = Quantity+5.51 WHERE VehicleId in(1037) and accPeriod = 201411 and fuelId = 3
*/

--update WaybillFuelRemain SET DepartureRemain = DepartureRemain-43.1 WHERE WaybillId = 656345 AND FuelId = 3


--SELECT SUM(afr.Quantity)  FROM AccFuelRemain afr WHERE Accperiod = 201311 AND afr.FuelId = 2
/*
SELECT * FROM @remains r
LEFT JOIN Vehicle v ON v.VehicleId = r.VehicleId
WHERE v.WriteOffDate IS NOT NULL AND ISNULL(r.Remain,0)<>0
*/


--SELECT * FROM AccFuelRemain WHERE AccPeriod = 201411 AND FuelId = 3 AND AccountingId = 1 ORDER BY Quantity