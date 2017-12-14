DECLARE @date1 smallDatetime;
DECLARE @date2 smallDatetime;
set @date1 = dbo.StrToFullDate('01.10.2014 7:00')
set @date2 = dbo.StrToFullDate('31.10.2014 19:00')


 if datepart(hh,@date1)<=7 set @date1= dbo.StrToDate(dbo.DateToStr(@date1)) 
 if datepart(hh,@date2)>=19 or datepart(hh,@date2)=00   set @date2= dbo.StrToFullDate(dbo.DateToStr(@date2)+' 23:59') 



select @date1,@date2


select 
	g.GroupAccName,
	case when isnull(t.ColumnId,5)=5 then null else t.ColumnId end ColumnId,
	t.garageNumber,
	t.registrationNumber,
	t.Model,	
	f.fuelName,		
	isnull(ff.BS,23) + isnull(ff.SBS,46) SBS,
	r.quantity,	
	--cast(fi.worth as int) worth,
	cast(fi.worth*r.quantity as int) summ
from _reoilOther r
inner join reoilSheets s on s.sheetNum = r.sheetNum
left join TransportFacilities t on t.ownerId = r.ownerId and r.GarageNumber = t.GarageNumber
left join Fuel f on f.FuelId = r.FuelId
left join GroupAcc g on g.groupAccId = t.GroupAccId
left join fortran ff on ff.GroupAccId = g.GroupAccId
left join fuelIncomeWorth fi on fi.fuelId = r.fuelId and fi.accYear = 2014 and accmonth = 10
where placeId = 1 and  r.reoilDate >= @date1 and r.reoilDate<@date2
order by 2,1,6

--select * from fuelIncomeWorth

