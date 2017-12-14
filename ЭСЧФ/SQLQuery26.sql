ALTER PROC spu_AddVatInvoice 
(
	@ReplicationSourceId INT = NULL,
	@InvoiceType NVARCHAR(50),
	@OriginalInvoiceNumber NCHAR(25) = NULL,
	@SendToRecipient BIT = NULL,
	@DateCancelled DATE = NULL,
	@Account NVARCHAR(10) = null,
	--Поставщик
	@ProviderCounteragentId INT = NULL,
	
	@ProviderStatus NVARCHAR(50) = NULL,
	@ProviderDependentPerson BIT = NULL,
	@ProviderResidentsOfOffshore BIT = NULL,
	@ProviderSpecialDealGoods BIT = NULL,
	@ProviderBigCompany BIT = NULL,
	@ProviderCountryCode BIT = NULL,
	@ProviderUnp NCHAR(9) = NULL,
	@ProviderName NVARCHAR(200) = NULL,
	@ProviderAddress NVARCHAR(200) = NULL,
	--
	
	--Получатель
	@RecipientCounteragentId INT = NULL,
	@RecipientStatus NVARCHAR(50) = NULL,
	--
		
	--Грузоотправитель
	@ConsignerCounteragentId INT = NULL,
	--
	
	--Грузополучатель
	@ConsigneeCounteragentId INT = NULL,
	--
	
	--Договор
	@ContractId INT= NULL,
	@ContractNumber nvarchar(50) = NULL,
	@ContractDate DATE = NULL,
	@ContractDescription nvarchar(100) = NULL,
	
		
	@Documents TEXT = NULL,
	@RosterList TEXT = NULL
	
)
AS
BEGIN
	SET NOCOUNT ON;
	
	--Constants 
	
	DECLARE @NaftanUNP CHAR(9)
	SET @NaftanUNP = '300042199'
	
	--
		
	--Таблица результатов импорта
	DECLARE @Rezult TABLE
	(
		Type varchar(100) not null default 'Exception', --Success
		Message varchar(1000) NOT NULL,
		VatInvoiceNumber nchar(25)
	)
	
	--Проверка заполнения--
			
	--
	
	DECLARE @year INT, @number INT, @numberString NCHAR(25)
	SELECT 
			@year = YEAR(GETDATE())
	
	EXEC spu_GenerateVatInvoiceNumber
		@Year = @year,
		@Number = @number OUTPUT,
		@NumberString = @numberString OUTPUT
	
	
	DECLARE @invoiceTypeId INT, @providerStatusId INT, @recipirntStatusId INT
	SELECT TOP 1 @invoiceTypeId = InvoiceTypeId FROM InvoiceType WHERE InvoiceTypeXmlName = @InvoiceType 
	SELECT TOP 1 @recipirntStatusId = RecipientStatusId FROM RecipientStatus WHERE RecipientStatusXmlName = @RecipientStatus
	
	
	INSERT INTO VatInvoice
	(
		StatusId,
		Sender,
		[Year],
		Number,
		NumberString,
		DateTransaction,
		InvoiceTypeId, 
		OriginalInvoiceNumber,
		SendToRecipient,
		DateCancelled,
		Account
	)
	VALUES
	(
		1,
		@NaftanUNP,
		@year,
		@number,
		@numberString,
		GETDATE(),
		@invoiceTypeId,
		@OriginalInvoiceNumber,
		@SendToRecipient,
		@DateCancelled,
		@Account
	)
	
	INSERT INTO @Rezult
	(
		[Type],
		[Message],
		VatInvoiceNumber
	)
	VALUES
	(
		'Success',
		'',
		@numberString
	)
	
	SELECT * FROM @Rezult
	RETURN 0
	
END

GO 

EXEC spu_AddVatInvoice 
	@InvoiceType='ADDITIONAL',
	@OriginalInvoiceNumber='300042199-2016-0000000001',
	@Account = '900901',
	@ProviderStatus = 'SELLER',
	@RecipientStatus
	
	
	SELECT * FROM RecipientStatus AS rs
	