



SELECT 
	swi.serviceMonth,
	swi.serviceYear,
	sum(swi.hourWork) hourWork,
	sum(swi.km) km,
	sum(swi.mkm+swi.mhour) AS Summ
FROM ServiceWaybillsInfo AS swi
LEFT JOIN Customer AS c ON c.CustomerId = swi.customerId
LEFT JOIN Vehicle v ON v.GarageNumber = swi.garageNumber
LEFT JOIN ServiceGroup AS sg ON sg.ServiceGroupId = v.ServiceGroupId
WHERE len(c.SHZ) = 2 AND sg.ServiceGroupId IN (15,16,17) AND swi.serviceYear*100+swi.serviceMonth BETWEEN 201601 AND 201609
GROUP BY swi.serviceMonth,	swi.serviceYear
ORDER BY swi.Ser



1-09 сент 2016 сумма без ндс пробег часы 

SELECT * FROM ServiceGroup AS sg WHERE 