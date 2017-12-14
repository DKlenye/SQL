SELECT p.fio,o.* FROM tOrders o 
LEFT JOIN persons AS p ON o.IdMan = p.id_men
WHERE IdServicePeriod = 161


SELECT * FROM tServicePeriod AS tsp


UPDATE tOrders SET IdServiceTariff=null, handSum = 11.67 WHERE IdOrder = 8873

UPDATE torders SET IdServiceTariff = NULL WHERE IdOrder IN (8801,8802,8803)



SELECT * FROM FuelIncome AS fi WHERE NoDoc = '5898279'

update FuelIncome SET cost = 826.47 WHERE NoDoc = '5898279'


