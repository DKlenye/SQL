Alter PROC spu_ReplicateVatInvoices @ReplicationSourceId INT
AS

DECLARE @NaftanUNP CHAR(9)
SET @NaftanUNP = '300042199'

DECLARE @date date, @year smallint
SELECT @date = GETDATE(), @year = YEAR(@date)

BEGIN TRANSACTION ReplicationInvoices

DECLARE @number INT
SELECT @number = isnull(MAX (Number),0) FROM VatInvoice WHERE [Year]=@year AND Sender = @NaftanUNP

/*
	Проверки:
		1.Есть ли запись по оригиналам в существующих счетах 
		
*/

DECLARE @Rezult TABLE
(
	DocumentId INT NOT NULL,
	IsException bit NOT NULL,
	[Message] NVARCHAR(1000) NOT NULL,
	InvoiceNumber NCHAR(25)
)

INSERT INTO @Rezult
SELECT DISTINCT r.DocumentId,1,'Исходный ЭСЧФ для документа уже сформирован.',vi.NumberString  FROM [Replication] AS r
INNER JOIN VatInvoice AS vi ON r.DocumentId = vi.ReplicationId AND r.ReplicationSourceId = vi.ReplicationSourceId 
WHERE r.ReplicationSourceId = @ReplicationSourceId AND r.InvoiceTypeId = 1

DELETE FROM [Replication] WHERE ReplicationSourceId = @ReplicationSourceId AND InvoiceTypeId = 1 AND DocumentId IN (SELECT DISTINCT DocumentId FROM @Rezult)

INSERT INTO VatInvoice
(
	InOut,
	ReplicationSourceId,
	ReplicationId,
	StatusId,
	BuySaleTypeId,
	Account,
	VatAccount,
	Sender,
	[Year],
	Number,
	NumberString,
	DateTransaction,
	InvoiceTypeId,
	OriginalInvoiceNumber,
	SendToRecipient,
	DateCancelled,
	ProviderCounteragentId,
	ProviderStatusId,
	ProviderDependentPerson,
	ProviderResidentsOfOffshore,
	ProviderSpecialDealGoods,
	ProviderBigCompany,
	ProviderCountryCode,
	ProviderUnp,
	ProviderName,
	ProviderAddress,
	PrincipalInvoiceNumber,
	PrincipalInvoiceDate,
	VendorInvoiceNumber,
	VendorInvoiceDate,
	ProviderDeclarationNumber,
	ProviderDeclarationDate,
	DateRelease,
	DateActualExport,
	ProviderTaxeNumber,
	ProviderTaxeDate,
	RecipientCounteragentId,
	RecipientStatusId,
	RecipientDependentPerson,
	RecipientResidentsOfOffshore,
	RecipientSpecialDealGoods,
	RecipientBigCompany,
	RecipientCountryCode,
	RecipientUnp,
	RecipientName,
	RecipientAddress,
	RecipientDeclarationNumber,
	RecipientDeclarationDate,
	RecipientTaxeNumber,
	RecipientTaxeDate,
	ContractId,
	ContractNumber,
	ContractDate,
	ContractDescription,
	RosterTotalCostVat,
	RosterTotalExcise,
	RosterTotalVat,
	RosterTotalCost
)
SELECT 
	1,
	@ReplicationSourceId,
	DocumentId,
	1,
	BuySaleTypeId,
	Account,
	VatAccount,
	@NaftanUNP,
	@year,
	Number,
	@NaftanUNP+'-'+CAST(@year AS CHAR(4))+'-'+ RIGHT(REPLICATE('0', 10) + CAST(Number AS varchar(10)), 10),
	DateTransaction,
	InvoiceTypeId,
	OriginalInvoiceNumber,
	SendToRecipient,
	DateCancelled,
	ProviderCounteragentId,
	ProviderStatusId,
	ProviderDependentPerson,
	ProviderResidentsOfOffshore,
	ProviderSpecialDealGoods,
	ProviderBigCompany,
	isnull(ProviderCountryCode,cp.CountryCode) AS ProviderCountryCode,
	isnull(ProviderUnp,cp.Unp) AS ProviderUnp,
	isnull(ProviderName,cp.Name) AS ProviderName,
	isnull(ProviderAddress,cp.[Address]) AS ProviderAddress,
	PrincipalInvoiceNumber,
	PrincipalInvoiceDate,
	VendorInvoiceNumber,
	VendorInvoiceDate,
	ProviderDeclarationNumber,
	ProviderDeclarationDate,
	DateRelease,
	DateActualExport,
	ProviderTaxeNumber,
	ProviderTaxeDate,
	RecipientCounteragentId,
	RecipientStatusId,
	RecipientDependentPerson,
	RecipientResidentsOfOffshore,
	RecipientSpecialDealGoods,
	RecipientBigCompany,
	isnull(RecipientCountryCode,cr.CountryCode) AS RecipientCountryCode,
	isnull(RecipientUnp,cr.Unp) AS RecipientUnp,
	isnull(RecipientName,cr.Name) AS RecipientName,
	isnull(RecipientAddress,cr.[Address]) AS RecipientAddress,
	RecipientDeclarationNumber,
	RecipientDeclarationDate,
	RecipientTaxeNumber,
	RecipientTaxeDate,
	ContractId,
	ContractNumber,
	ContractDate,
	ContractDescription,
	RosterCostVat,
	RosterSummaExcise,
	RosterSummaVat,
	RosterCost
FROM (
	SELECT 
		ROW_NUMBER() OVER (ORDER BY a.DocumentId)+@number AS Number,
		a.*
	FROM (
		SELECT
			BuySaleTypeId,
			VatAccount,
			Account,
			DateTransaction,
			InvoiceTypeId,
			OriginalInvoiceNumber,
			SendToRecipient,
			DateCancelled,
			ProviderCounteragentId,
			ProviderStatusId,
			ProviderDependentPerson,
			ProviderResidentsOfOffshore,
			ProviderSpecialDealGoods,
			ProviderBigCompany,
			ProviderCountryCode,
			ProviderUnp,
			ProviderName,
			ProviderAddress,
			PrincipalInvoiceNumber,
			PrincipalInvoiceDate,
			VendorInvoiceNumber,
			VendorInvoiceDate,
			ProviderDeclarationNumber,
			ProviderDeclarationDate,
			DateRelease,
			DateActualExport,
			ProviderTaxeNumber,
			ProviderTaxeDate,
			RecipientCounteragentId,
			RecipientStatusId,
			RecipientDependentPerson,
			RecipientResidentsOfOffshore,
			RecipientSpecialDealGoods,
			RecipientBigCompany,
			RecipientCountryCode,
			RecipientUnp,
			RecipientName,
			RecipientAddress,
			RecipientDeclarationNumber,
			RecipientDeclarationDate,
			RecipientTaxeNumber,
			RecipientTaxeDate,
			ContractId,
			ContractNumber,
			ContractDate,
			ContractDescription,
			DocumentId,
			sum(RosterCostVat) RosterCostVat,
			sum(RosterSummaExcise) RosterSummaExcise,
			sum(RosterSummaVat) RosterSummaVat,
			sum(RosterCost) RosterCost
			
		FROM [Replication] WHERE ReplicationSourceId = @ReplicationSourceId
		GROUP BY BuySaleTypeId,	VatAccount,	Account, DateTransaction, InvoiceTypeId, OriginalInvoiceNumber,	SendToRecipient, DateCancelled,	ProviderCounteragentId,	ProviderStatusId,ProviderDependentPerson, ProviderResidentsOfOffshore, ProviderSpecialDealGoods,
			ProviderBigCompany,	ProviderCountryCode,ProviderUnp,ProviderName,ProviderAddress,PrincipalInvoiceNumber,PrincipalInvoiceDate,
			VendorInvoiceNumber,VendorInvoiceDate,ProviderDeclarationNumber,ProviderDeclarationDate,DateRelease,DateActualExport,ProviderTaxeNumber,ProviderTaxeDate,RecipientCounteragentId,RecipientStatusId,RecipientDependentPerson,
			RecipientResidentsOfOffshore,RecipientSpecialDealGoods,RecipientBigCompany,	RecipientCountryCode,RecipientUnp,RecipientName,RecipientAddress,RecipientDeclarationNumber,RecipientDeclarationDate,
			RecipientTaxeNumber,RecipientTaxeDate,ContractId,ContractNumber,ContractDate,ContractDescription,
			DocumentId
	)a
)b
LEFT JOIN view_Counteragents cp ON cp.counteragentId = b.ProviderCounteragentId
LEFT JOIN view_Counteragents cr ON cr.counteragentId = b.RecipientCounteragentId
ORDER BY b.Number

INSERT INTO Documents
(
	ReplicationId,
	InvoiceId,
	DocTypeCode,
	DocTypeValue,
	BlancCode,
	Number,
	Seria,
	[Date]
)
SELECT DISTINCT 
	DocumentId,
	vi.InvoiceId,
	DocumentTypeCode,
	DocumentTypeValue,
	DocumentBlancCode,
	DocumentNumber,
	DocumentSeria,
	DocumentDate
FROM [Replication]  r
LEFT JOIN  VatInvoice AS vi ON vi.ReplicationId = r.DocumentId AND vi.ReplicationSourceId = r.ReplicationSourceId
WHERE r.ReplicationSourceId = @ReplicationSourceId


INSERT INTO Consignors
(
	ConsignorCounteragentId,
	InvoiceId,
	CountryCode,
	Unp,
	Name,
	[Address]
)
SELECT DISTINCT 
	ConsignorCounteragentId,
	vi.InvoiceId,
	isnull(ConsignorCounteragentId,c.CountryCode),
	isnull(ConsignorUnp,c.Unp),
	isnull(ConsignorName,c.Name),
	isnull(ConsignorAddress,c.[Address])
FROM [Replication]  r
LEFT JOIN VatInvoice AS vi ON vi.ReplicationId = r.DocumentId AND vi.ReplicationSourceId = r.ReplicationSourceId
LEFT JOIN view_Counteragents c ON c.counteragentId = r.ConsignorCounteragentId
WHERE r.ReplicationSourceId = @ReplicationSourceId


INSERT INTO Consignees
(
	ConsigneeCounteragentId,
	InvoiceId,
	CountryCode,
	Unp,
	Name,
	[Address]
)
SELECT DISTINCT 
	ConsigneeCounteragentId,
	vi.InvoiceId,
	isnull(ConsigneeCountryCode,c.CountryCode),
	isnull(ConsigneeUnp,c.Unp),
	isnull(ConsigneeName,c.Name),
	isnull(ConsigneeAddress,c.[Address])
FROM [Replication] AS r
LEFT JOIN VatInvoice AS vi ON vi.ReplicationId = r.DocumentId AND vi.ReplicationSourceId = r.ReplicationSourceId
LEFT JOIN view_Counteragents c ON c.counteragentId = r.ConsigneeCounteragentId
WHERE r.ReplicationSourceId = @ReplicationSourceId


INSERT INTO RosterList
(
	InvoiceId,
	Number,
	Name,
	Code,
	CodeOced,
	Units,
	[Count],
	Price,
	Cost,
	SummaExcise,
	VatRate,
	VatRateTypeId,
	SummaVat,
	CostVat,
	[Description]
)

SELECT 
	vi.InvoiceId,
	r.RosterNumber,
	r.RosterName,
	r.RosterCode,
	r.RosterCodeOced,
	r.RosterUnits,
	r.RosterCount,
	r.RosterPrice,
	r.RosterCost,
	r.RosterSummaExcise,
	r.RosterVatRate,
	r.RosterVatRateTypeId,
	r.RosterSummaVat,
	r.RosterCostVat,
	r.RosterDescription
FROM [Replication] AS r
LEFT JOIN VatInvoice AS vi ON vi.ReplicationId = r.DocumentId AND vi.ReplicationSourceId = r.ReplicationSourceId
WHERE r.ReplicationSourceId = @ReplicationSourceId


INSERT INTO @Rezult
SELECT 
	DocumentId,
	0,
	'' AS [Message],
	vi.NumberString
FROM (
	SELECT distinct DocumentId, ReplicationSourceId FROM [Replication]
	WHERE ReplicationSourceId = @ReplicationSourceId
 )a
 LEFT JOIN VatInvoice AS vi ON vi.ReplicationId = a.DocumentId AND vi.ReplicationSourceId = a.ReplicationSourceId

DELETE FROM [Replication] WHERE ReplicationSourceId = @ReplicationSourceId

COMMIT TRANSACTION ReplicationInvoices

SELECT * FROM @Rezult