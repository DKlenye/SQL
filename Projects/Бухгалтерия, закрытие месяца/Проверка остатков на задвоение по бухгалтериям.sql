SELECT VehicleId,FuelId,afr.AccPeriod,COUNT(AccountingId) cnt
  FROM AccFuelRemain afr WHERE afr.AccPeriod = 201308
GROUP BY  VehicleId,FuelId,afr.AccPeriod
having COUNT(AccountingId)>1