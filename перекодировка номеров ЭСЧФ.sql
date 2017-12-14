--SELECT * FROM ReplicationSource AS rs

DECLARE @Year INT
SET @year = 2017


DECLARE @id int
declare _Cur cursor 
for 
SELECT InvoiceId
FROM VatInvoice 
WHERE invoiceId = 70895
	/*IsIncome = 0 AND
	StatusId IN (1,2) AND
	NumberString LIKE '%-2016-%' AND
	 ReplicationSourceId IN(1,2,8)*/
				
open _Cur

fetch next from _Cur into @id

while @@fetch_status=0
begin
BEGIN
	
BEGIN TRAN;


	DECLARE @NumberString NCHAR(25), @Number INT
	SELECT @NumberString = NULL, @Number = null
	
	EXEC spu_GenerateVatInvoiceNumber
		@Year = @year,
		@Number = @Number OUTPUT,
		@NumberString = @NumberString OUTPUT
	
	INSERT INTO NumberChange
	(
		InvoiceId,
		OldNumber,
		NewNumber
	)
	SELECT InvoiceId,NumberString, @NumberString FROM VatInvoice WHERE InvoiceId = @id
	
	UPDATE VatInvoice SET NumberString = @NumberString, Number = @Number, [Year] = @Year WHERE InvoiceId = @id
	
COMMIT;
END
fetch next from _Cur into @id
end
close _Cur 
deallocate _Cur






