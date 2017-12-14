SELECT 
	2 m ,2013 y,
	ff.fuelId,
	SUM(isnull(cons,0)) Consumption,
	SUM(ISNULL(cons,0)*fw.worth) Summ
	
	
FROM ft_AccConsumption(2,2013,1) ff
LEFT JOIN fuelWorth fw ON fw.fuelId = ff.fuelId AND fw.accYear = 2013 AND fw.accMonth = 2 AND fw.OwnerId = 1
WHERE groupAccId IN (2,10,11)
GROUP BY ff.fuelId