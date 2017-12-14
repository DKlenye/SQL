select COUNT(*) from _PolymirWaybill where rep = 201210
select COUNT(*) from Waybill where ReplicationSource = 2 and AccPeriod = 201210





select w.WaybillId,p.ost_vy,p.ost_voz from _PolymirWaybill p 
left join Waybill w on w.AccPeriod = 201302 and rtrim(ReplicationId) = rtrim(p.npl)+'_'+rtrim(p.fr) and dbo.StrToDate(dbo.DateToStr(w.DepartureDate))=d_vy
where p.rep = 201302







insert into  WaybillFuelRemain 

select 
	distinct WaybillId,FuelId,ost_vy,ost_voz from(
select 
	w.WaybillId,p.ost_vy,p.ost_voz,
	case FuelName
		when 'ÄÒ' then 3
		when 'ÀÈ95' then 2
		when 'Í80 ' then 4
		when 'À92 ' then 1
		when 'ÃÀÇ' then 5
		end FuelId
from (
	SELECT 		
		w.*,				
	   	chas2-chas1 mh,	
		case when v.shg='Ä' THEN 'ÄÒ' WHEN v.gar_n in (84,85,86,87,88) THEN 'ÃÀÇ' else v.tip_shg END FuelName,
		v.shg_otop,
		Year(w.d_voz) yy,
		MONTH(w.d_voz) mm
	FROM _PolymirWaybill w
	LEFT JOIN _PolymirVehicle v ON v.gar_n = w.gar_n
	WHERE w.rep = 201210
)p
left join Waybill w on w.AccPeriod = 201210 and rtrim(ReplicationId) = rtrim(p.npl)+'_'+rtrim(p.fr) and dbo.StrToDate(dbo.DateToStr(w.DepartureDate))=d_vy
where w.WaybillId is not null 
)a
