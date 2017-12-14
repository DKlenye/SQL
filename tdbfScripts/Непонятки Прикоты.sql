DECLARE @m INT,@y INT,@ownerId INT
SELECT @y = 2011,@m = 08,@ownerId = 3


SELECT 
c.inputsDebit,
sum(wt.accConsumption*fw.worth)
FROM
waybills w 
LEFT JOIN waybillsTasks wt ON wt.ownerId = w.ownerId AND wt.waybillNumber = w.waybillNumber AND wt.garageNumber = w.garageNumber
LEFT JOIN _customers c ON c.customerId = wt.customerId
LEFT JOIN fuelNorms fn ON fn.fuelNormId = wt.fuelNormId
LEFT JOIN fuelWorth fw ON fw.fuelId=fn.fuelId AND fw.accYear = @y AND fw.accMonth=@m AND fw.OwnerId = @ownerId
WHERE 
w.ownerId = @ownerId AND w.accYear=@y AND w.accMonth = @m
GROUP BY c.inputsDebit
ORDER BY 1