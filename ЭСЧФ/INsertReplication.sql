

DECLARE @counter INT
SET @counter = 100

WHILE @counter>0
begin

INSERT INTO [Replication]
(
	ReplicationSourceId,
	BuySaleTypeId,
	Account,
	DateTransaction,
	InvoiceTypeId,
	DocumentId,
	ProviderCounteragentId,
	RecipientCounteragentId,
	RosterNumber,
	RosterName,
	RosterCost,
	RosterVatRateTypeId,
	RosterSummaVat
)
VALUES
(
	1,
	1,
	'900901',
	'22.04.2016',
	1,
	@counter,
	50000,
	1,
	1,
	'стул',
	0,
	1,
	0
)

SET @counter = @counter-1

END


EXEC spu_ReplicateVatInvoices
	@ReplicationSourceId = 1



--SELECT * FROM [Replication] AS r

--DELETE FROM [Replication]

/*
DELETE FROM Consignees
DELETE FROM Consignors
DELETE FROM Documents
DELETE FROM RosterList
DELETE FROM VatInvoice
*/


--SELECT * FROM VatInvoice AS vi