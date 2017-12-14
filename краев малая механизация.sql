
SELECT 
	FuelId,
	sum(Consumption) Consumption
FROM SmallMechFuelReport AS r
INNER JOIN SmallMechMechanisms m ON m.Id = r.MechId	
WHERE r.ReportDate BETWEEN '01.01.2016' AND '31.12.2016' 
GROUP BY FuelId




EXEC ssrs_SmallMechFuelConsumption
	@Year = null,
	@Month = null,
	@FuelId = null,
	@EmployeeId = NULL
	
