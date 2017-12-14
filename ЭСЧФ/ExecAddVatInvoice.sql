DELETE FROM Consignees
DELETE FROM Consignors
DELETE FROM VatInvoice
DELETE FROM RosterList
DELETE FROM Documents



DECLARE @counter INT
SET @counter = 10

WHILE @counter>0
begin

EXEC spu_AddVatInvoice
	@ReplicationSourceId = 1,
	@BuySaleType = 1,
	@InvoiceType = 'ORIGINAL',
	@Account = '900901',
	@VatAccount = '180000'
	--@ProviderCounteragentId = 50000,
	--@RecipientCounteragentId = 1,
	--@ConsigneeCounteragentId = 50000,
	/*@Consignees = '<Consignees>
			<Consignee CounteragentId="50000" Name="Some Name"></Consignee>
			<Consignee CounteragentId="10"></Consignee>
		</Consignees>',*/
	--@ConsignorCounteragentId = 10
	/*@Consignors = '<Consignors>
			<Consignor CounteragentId="50000" Name="Some Name"></Consignor>
			<Consignor CounteragentId="10"></Consignor>
		</Consignors>'*/

SET @counter = @counter-1

END



SELECT * FROM VatInvoice AS vi
SELECT * FROM Documents AS d
SELECT * FROM Consignees AS c
SELECT * FROM Consignors AS c
SELECT * FROM RosterList AS rl
