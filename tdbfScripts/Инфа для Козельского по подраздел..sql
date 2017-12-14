alter PROC afa_TFInfo    
AS
DECLARE @owner INT 
SELECT @owner = 1

DECLARE @t TABLE(garagenumber INT, driverid int)


INSERT INTO @t
SELECT tf.garageNumber,dtr.driverId FROM TransportFacilities tf
inner JOIN driversToResponse dtr ON dtr.ownerId = tf.ownerId AND dtr.garageNumber = tf.garageNumber
INNER JOIN drivers d ON d.driverId = dtr.driverId AND d.data_uv IS null
WHERE tf.ownerId = @owner AND tf.writeOff IS NULL


INSERT INTO @t
SELECT distinct tf.garageNumber,(
		SELECT TOP 1 dtt.driverId FROM driversToTransport dtt
		INNER JOIN drivers d ON d.driverId = dtt.driverId AND d.data_uv IS null
		WHERE dtt.ownerId = tf.ownerId AND dtt.garageNumber = tf.garageNumber
) driverId FROM TransportFacilities tf

WHERE tf.ownerId = @owner AND tf.writeOff IS NULL AND tf.garageNumber NOT IN (SELECT distinct garageNumber FROM @t)





SELECT
	isnull(tso.subOwnerName,'не закреплено') subOwnerName,	
	vtg.groupAccName groupName1,
	tf.garageNumber,
	tf.model,
	tf.registrationNumber,
	d.fio,
	d.zex,
	d.tab,
	d.dol
FROM transportFacilities tf
	LEFT JOIN @t t ON t.garagenumber = tf.garageNumber AND tf.ownerId=@owner
	LEFT JOIN drivers d ON d.driverId = t.driverid
	LEFT JOIN TransportSubOwner tso ON tso.subOwnerId = tf.subOwnerId
	LEFT JOIN groupAcc vtg ON vtg.groupAccId = tf.groupAccId
WHERE tf.ownerId = @owner AND tf.writeOff IS NULL
ORDER BY 1,2

GRANT EXECUTE ON afa_TFInfo TO transp_2

SELECT * FROM v_transportGroups vtg