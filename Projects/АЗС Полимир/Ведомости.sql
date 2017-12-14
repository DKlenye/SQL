SELECT 
	*
FROM VehicleRefuelling r 
LEFT JOIN RefuellingSheet rs ON r.SheetId = rs.SheetId
WHERE r.SheetId IS NOT NULL
AND cast(r.RefuellingDate AS Date)<>rs.RefuellingDate
AND YEAR(r.RefuellingDate)>=2014