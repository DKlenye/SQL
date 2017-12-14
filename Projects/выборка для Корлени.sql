SELECT 
	v.GarageNumber,
	v.RegistrationNumber,
	v.Model,
	c.CustomerName,
	bt.BodyTypeName
FROM Vehicle v
LEFT JOIN Customer c ON c.CustomerId = v.CustomerId
LEFT JOIN BodyType bt ON bt.BodyTypeId = v.BodyTypeId
WHERE v.OwnerId = 1 AND v.WriteOffDate IS NULL
AND bt.BodyTypeId IN (
69,15,41,13,
44,1,8,6,46	
)
ORDER BY 4,5