
SELECT * FROM (
SELECT 
	w.WaybillId,
	w.Fact,
	SUM(wt.FactConsumption) TasksFact
FROM dbo.ft_AccWaybillFactNorm(11,2014,1,1) w
LEFT JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId AND wt.FuelId = w.Fuelid
GROUP BY w.WaybillId,	w.Fact
)a
WHERE Fact<>TasksFact
