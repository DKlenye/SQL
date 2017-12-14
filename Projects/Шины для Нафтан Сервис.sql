
alter PROC ssrs_NaftanServiceInfo
as
SELECT 
	v.DSC,
	v.GarageNumber,
	v.InventoryNumber,
	v.RegistrationNumber,
	v.Model,	
	t.TireId,
	t.IsSpare,
	tm.TireMakerName,
	t.FactoryNumber,
	t.Cost,
	t.[Size],
	t.KmNorm,
	t.MonthNorm,
	CASE WHEN t.TireId IS NULL THEN NULL ELSE  (SELECT COUNT(y*100+m) FROM dbo.ft_VehicleWorkByPeriod(v.VehicleId,t.InstallDate,t.RemoveDate)) end tireMonthes,
	CASE WHEN t.TireId IS NULL THEN NULL ELSE  (SELECT SUM(km) FROM dbo.ft_VehicleWorkByPeriod(v.VehicleId,t.InstallDate,t.RemoveDate)) end tireKm,
	(SELECT SUM(km) FROM dbo.ft_VehicleWorkByPeriod(v.VehicleId,NULL,null) ) allKm,
	(SELECT SUM(mh) FROM dbo.ft_VehicleWorkByPeriod(v.VehicleId,NULL,null) ) allMh
FROM Vehicle v
LEFT JOIN Tire t ON t.VehicleId = v.VehicleId
LEFT JOIN TireMaker tm ON tm.TireMakerId = t.TireMakerId
WHERE InventoryNumber IN (
'13151005',
'13150799',
'13150754',
'13150755',
'13151004',
'13150463',
'13150661',
'13150810',
'13150811',
'06281128',
'13150893',
'13150918',
'13151203',
'13151205',
'13150786',
'13151009',
'13151221',
'13150746',
'13150747',
'06280529',
'06280526',
'04152069',
'04150091',
'04150175',
'04150137',
'04150988',
'04150090',
'06280437',
'06261056',
'13150783',
'13151318',
'06280568',
'13151289',
'13150778',
'06280532'
)

AND v.OwnerId = 1