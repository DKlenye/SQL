

SET NOCOUNT ON

UPDATE sClient
SET
	ownerId = 4
WHERE [Login]='kdn'

GO

INSERT INTO waybillsDriversResponse
SELECT distinct
	ownerId,
	waybillNumber,
	garageNumber,
	driverId,
	nodelete,
	_dbf	
FROM waybillsDrivers 
WHERE ownerid = 4 AND waybillNumber IN (SELECT waybillnumber FROM waybills WHERE ownerId = 4 AND accYear IS NULL)

GO

DECLARE @waybillNumber int,@garageNumber int,@ownerId INT
SELECT @ownerId = 4


declare Cur cursor 
for 

SELECT Waybillnumber,garageNumber
  FROM waybills WHERE ownerId = 4 AND accyear IS NULL AND accMonth IS NULL
				
open Cur

fetch next from Cur into @waybillNumber,@garageNumber

while @@fetch_status=0
begin

	EXECUTE AccFuelConsumption_Save
		@owner = @ownerId,
		@garagenumber = @garageNumber,
		@waybillnumber = @waybillNumber
		
fetch next from Cur into @waybillNumber,@garageNumber
end
close Cur 
deallocate Cur

GO
UPDATE sClient
SET
	ownerId = 1
WHERE [Login]='kdn'

GO

/*
UPDATE waybills SET waybillstate = 2 WHERE ownerId = 4 AND accYear IS null
*/
/*
update waybillsTasks SET customerId = 930026 WHERE ownerId = 4 AND customerId = 929541
update  waybillsTasks SET customerId = 930027   where ownerId = 4 AND customerId = 929543
update waybillstasks set customerId = 930528 where ownerId = 4 and customerId = 929544
*/


