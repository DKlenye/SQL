


declare  @month int, @year INT
SELECT @month = 03,@year = 2015


DECLARE @date date
SELECT @date = '01.'+CAST(@month AS VARCHAR(2))+'.'+CAST(@year AS VARCHAR(4))


SELECT 
	AccGroupName,
	ServiceGroupName,
	GarageNumber,
	RegistrationNumber,
	Model,
	SUM(Okm) Okm,
	SUM(km) km,
	SUM(OHourWork) OHourWork,
	SUM(HourWork) HourWork,
	SUM(OServiceSumm) OServiceSumm,
	SUM(ServiceSumm) ServiceSumm,
	SUM(cost) Cost,
	SUM(ActualCost) ActualCost,
	SUM(AdvanceReport) AdvanceReport
FROM (
SELECT 
*,
CASE WHEN CostCode LIKE '90%' THEN skm ELSE 0 end Okm,
CASE WHEN CostCode Not LIKE '90%' THEN skm ELSE 0 end km,
CASE WHEN CostCode LIKE '90%' THEN sHourWork ELSE 0 end OHourWork,
CASE WHEN CostCode Not LIKE '90%' THEN sHourWork ELSE 0 end HourWork,
CASE WHEN CostCode LIKE '90%' THEN _ServiceSumm ELSE 0 end OServiceSumm,
CASE WHEN CostCode Not LIKE '90%' THEN _ServiceSumm ELSE 0 end ServiceSumm
FROM (
SELECT 
	ag.AccGroupName,
	sg.ServiceGroupName,
	a.WaybillId,
	v.GarageNumber,
	v.RegistrationNumber,
	v.Model,
	a.CustomerId,
	c.CostCode,
	a.cost,
	isnull(a.km*ac.km,0)+ ISNULL(a.mh*ac.mh,0) ActualCost,
	isnull(ar.Cost,0) AdvanceReport,
	isnull(isnull(swi.km,so.km),a.km) skm,
	isnull(isnull(swi.hourWork,so.hourWork),isnull(wcwt.Minutes,0)/60.0) sHourWork ,
	isnull(isnull(swi.mkm+swi.mhour+ swi.mmass,so.allSumm),round(isnull(a.km,0)* isnull(tt.kmTariff,0) + (isnull(wcwt.Minutes,0)/60.0) * isnull(tt.hourTariff,0),0)) AS _ServiceSumm,
	tt.hourTariff,
	tt.kmTariff
FROM (
SELECT 
	WaybillId,
	CustomerId,
	SUM(km) km,
	SUM(mh) mh,
	SUM(AccConsumption) cons,
	SUM(AccCost) cost	
FROM dbo.ft_AccWaybillWorkInfo(@month,@year,1,null) fawwi
GROUP BY WaybillId,	CustomerId
)a
LEFT JOIN WaybillCustomerWorkingTime wcwt ON wcwt.WaybillId = a.WaybillId AND wcwt.CustomerId = a.CustomerId
LEFT JOIN Customer c ON c.CustomerId = a.CustomerId
LEFT JOIN _serviceWaybillsInfo swi ON swi.waybillNumber = a.WaybillId 
LEFT JOIN _ServiceOrders so ON so.WaybillNumber = a.WaybillId
LEFT JOIN Waybill w ON w.WaybillId = a.WaybillId
LEFT JOIN Vehicle v ON v.VehicleId = w.VehicleId
LEFT JOIN ServiceGroup sg ON sg.ServiceGroupId = v.ServiceGroupId
LEFT JOIN AccGroup ag ON ag.AccGroupId = v.AccGroupId
LEFT JOIN (
	SELECT t.* FROM (
	SELECT 
		idServiceGroup,
		MAX(DateTariff) DateTariff
	FROM _tServiceTariff WHERE DateTariff <= @date
	GROUP BY idServiceGroup	
)a
LEFT JOIN _tServiceTariff t ON t.idServiceGroup = a.idServiceGroup AND t.DateTariff = a.DateTariff
) tt ON tt.idServiceGroup = sg.ReplicationId
LEFT JOIN ActualCost ac ON ac.AccPeriod = @year*100+@month AND ac.AccGroupId = v.AccGroupId
LEFT JOIN (
	SELECT WaybillId,CustomerId,sum(Cost) Cost FROM WaybillAdvanceReport GROUP BY  WaybillId, CustomerId
)ar ON ar.WaybillId = a.WaybillId AND ar.CustomerId = a.CustomerId
WHERE isnull(v.ColumnId,5)<>5
)b
)c
GROUP BY AccGroupName,	ServiceGroupName,	GarageNumber,	RegistrationNumber,	Model
ORDER BY AccGroupName,ServiceGroupName
