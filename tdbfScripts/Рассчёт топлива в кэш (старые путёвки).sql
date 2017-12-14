

SELECT * FROM waybillsTasks wt WHERE waybillnumber IN (
SELECT waybillnumber FROM waybills WHERE garageNumber = 784 AND accYear = 2008 AND accMonth = 2
)