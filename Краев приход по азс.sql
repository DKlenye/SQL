
declare @sDate varchar(16)
declare @eDate varchar(16)

SELECT @sDate = '01.01.2016', @eDate = '31.12.2016'


declare @sD smallDatetime
declare @eD smallDatetime

select @sD = dbo.StrToFullDate(@sDate)
select @eD = dbo.StrToFullDate(@eDate)


SELECT
	StartDate,
	NoDoc,
	volume,
	density,
	fuelName,
	incomePlaceName,
	mass,
	cost,
	--CASE WHEN @sDate>='01.07.2016' THEN round(cena/1000,2) ELSE cena END cena
	round(mass*cost/1000,2) cena --change vlad 08.2016
FROM (
SELECT
	sr.startDate, 
	NoDoc,
	volume ,
	density,
	f.fuelName+isnull(' '+fs.FuelSortName,'') fuelName,
	s.incomePlaceName+' '+dbo.DateToStr(sr.startDate) incomePlaceName,
	case WHEN f.fuelGroupId IS NULL THEN  round(density*volume,2) ELSE round(density*volume,0) end mass,
	cost,
	case when f.fuelGroupId IS NULL THEN  round(round(density*volume,2)*cost,0) ELSE round(round(density*volume,0)*cost,0) end cena
	from shiftReport sr
inner join fuelIncome fi on fi.shiftReportId = sr.shiftReportId
LEFT JOIN FuelSort fs ON fs.FuelSortId = fi.FuelSortId
inner join fuel f on f.fuelId = fi.fuelId 
inner join  fuelincomePlaces s on s.incomePlaceId = fi.incomePlaceId
where startDate>=@sDate and endDate<=@eDate
)a
ORDER BY fuelName,StartDate