
alter PROC ssrs_VehiclesByRegistrationNumber @type int
AS

IF @type = 1 
SELECT 
	case WHEN dsc = 1 THEN isnull(rg.RefuellingGroupName,'-- ��� ������ --') ELSE '������' END _Group,
	tc.ColumnName,
	v.GarageNumber,
	v.RegistrationNumber,
	v.Model
FROM Vehicle v
LEFT JOIN RefuellingGroup rg ON rg.RefuellingGroupId = v.RefuellingGroupId
LEFT JOIN TransportColumn tc ON tc.ColumnId = ISNULL(v.ColumnId,5)
WHERE v.ownerId = 1 and
(v.RegistrationNumber IS NULL or  v.RegistrationNumber = LTRIM(RTRIM('')) OR  LTRIM(RTRIM(v.RegistrationNumber)) LIKE '�/�' OR LTRIM(RTRIM(v.RegistrationNumber)) LIKE '���%')
AND
v.WriteOffDate IS NULL

ELSE
	
	SELECT 
	case WHEN dsc = 1 THEN isnull(rg.RefuellingGroupName,'-- ��� ������ --') ELSE '������' END _Group,
	tc.ColumnName,
	v.GarageNumber,
	v.RegistrationNumber,
	v.Model
FROM Vehicle v
LEFT JOIN RefuellingGroup rg ON rg.RefuellingGroupId = v.RefuellingGroupId
LEFT JOIN TransportColumn tc ON tc.ColumnId = ISNULL(v.ColumnId,5)
WHERE v.ownerId = 1 and
(v.RegistrationNumber IS NOT NULL AND v.RegistrationNumber <> LTRIM(RTRIM('')) AND  LTRIM(RTRIM(v.RegistrationNumber)) NOT LIKE '�/�' AND LTRIM(RTRIM(v.RegistrationNumber)) NOT LIKE '���%')
AND
v.WriteOffDate IS NULL
	ORDER BY v.RegistrationNumber