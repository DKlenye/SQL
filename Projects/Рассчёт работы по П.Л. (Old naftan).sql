SELECT DISTINCT accyear*100+accmonth from waybills ORDER BY accyear*100+accmonth
 

DECLARE @month INT, @year INT 
SELECT @month = 12, @year = 2005

SELECT 
	a.*,
	c.norm,
	c.fact
FROM (
SELECT 
	w.waybillNumber,
	w.garageNumber,
	w.returnDate,
	SUM(wt.km) km,
	SUM( case when isnull(fn.coefficientMh,1)=1 OR fn.coefficientMh = 0 THEN wt.mh ELSE round(wt.mh/fn.coefficientMh,2) end) mh,
	SUM( case when isnull(fn.coefficientMh,1)=1 OR fn.coefficientMh = 0 THEN wt.mh * 0.7 ELSE wt.mh end) moto
FROM Waybills w
INNER JOIN waybillsTasks wt ON wt.ownerId = w.ownerId AND wt.waybillNumber = w.waybillNumber AND wt.garageNumber = w.garageNumber
INNER JOIN fuelNorms fn ON fn.fuelNormId = wt.fuelNormId
WHERE w.accYear=@year AND w.accMonth = @month AND w.ownerId = 1
GROUP BY w.waybillNumber,w.returnDate,w.garageNumber
)a
LEFT JOIN(
	SELECT 
		b.waybillnumber,
		b.fact,
		SUM(c.norm) norm
	FROM (
	SELECT waybillnumber,SUM(fact) fact  FROM  dbo.waybillFactConsumption_Get(@month,@year,1) GROUP BY waybillnumber
	)b
	LEFT JOIN dbo.waybilltaskNormConsumption_Get(@month,@year,1) c ON b.waybillnumber = c.waybillnumber
GROUP BY b.waybillnumber,	b.fact
)c ON c.waybillnumber = a.waybillNumber

