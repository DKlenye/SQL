
DECLARE @t TABLE( _from INT,_to INT)

INSERT INTO @t
			select 910,906
	UNION	select 913,902
	UNION	select 914,907
	UNION	select 917,905
	UNION	select 918,904
	UNION	select 923,908
	UNION	select 919,903
	UNION	select 934,925	
	UNION	select 937,926
	UNION	select 938,930
	UNION	select 941,932
	UNION	select 942,927
	UNION	select 945,931
	UNION	select 946,928
	UNION	select 952,929



DECLARE @from INT, @to INT 


declare Cur cursor 
for 

SELECT * from @t
				
open Cur

fetch next from Cur into @from, @to 

while @@fetch_status=0
begin

	UPDATE WaybillTask
	SET
		CustomerId = @to
	WHERE TaskId IN (	
		SELECT wt.TaskId FROM Waybill w
		INNER JOIN WaybillTask wt ON wt.WaybillId = w.WaybillId
		WHERE w.AccPeriod IS NULL AND wt.CustomerId = @from
	)
		
	UPDATE Customer
	SET		notActual = 1
	WHERE CustomerId = @from
	
	
fetch next from Cur into @from, @to 
end
close Cur 
deallocate Cur






