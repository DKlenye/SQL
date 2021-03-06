USE [NDSInvoices]
GO
/****** Object:  StoredProcedure [dbo].[spu_AddVatInvoice]    Script Date: 10.06.2016 9:52:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[spu_AddVatInvoice] 
(
	@ReplicationSourceId INT,
	@ReplicationId INT,
	@IsApprove BIT = 0,
	@ApproveUser NVARCHAR(100) = null,
	@BuySaleType TINYINT,
	@InvoiceTypeId TINYINT,
	@DateTransaction DATE,
	@VatAccount NVARCHAR(8) = NULL,
	@Account NVARCHAR(8),
	@AccountingDate date, 
	@OriginalInvoiceNumber NCHAR(25) = NULL,
	@SendToRecipient BIT = 0,
	@DateCancelled DATE = NULL,
	
	--Поставщик
	@ProviderCounteragentId INT = NULL,
	
	@ProviderStatusId TINYINT = NULL,
	@ProviderDependentPerson BIT = 0,
	@ProviderResidentsOfOffshore BIT = 0,
	@ProviderSpecialDealGoods BIT = 0,
	@ProviderBigCompany BIT = 0,
	@ProviderCountryCode INT = NULL,
	@ProviderUnp NCHAR(9) = NULL,
	@ProviderBranchCode NVARCHAR(50) = NULL,
	@ProviderName NVARCHAR(512) = NULL,
	@ProviderAddress NVARCHAR(512) = NULL,
	@PrincipalInvoiceNumber NCHAR(25) = NULL,
	@PrincipalInvoiceDate DATE = NULL,
	@VendorInvoiceNumber NCHAR(25) = NULL,
	@VendorInvoiceDate DATE = NULL,
	@ProviderDeclaration NVARCHAR(50) = NULL,
	@DateRelease DATE = NULL,
	@DateActualExport DATE = NULL,
	@ProviderTaxeNumber NVARCHAR(50) = NULL,
	@ProviderTaxeDate DATE = NULL,
	--
	
	--Получатель
	@RecipientCounteragentId INT = NULL,
	
	@RecipientStatusId TINYINT = NULL,
	@RecipientDependentPerson BIT = 0,
	@RecipientResidentsOfOffshore BIT = 0,
	@RecipientSpecialDealGoods BIT = 0,
	@RecipientBigCompany BIT = 0,
	@RecipientCountryCode INT = NULL,
	@RecipientUnp NCHAR(9) = NULL,
	@RecipientBranchCode NVARCHAR(50) = NULL,
	@RecipientName NVARCHAR(512) = NULL,
	@RecipientAddress NVARCHAR(512) = NULL,
	@RecipientDeclaration NVARCHAR(50) = NULL,
	@RecipientTaxeNumber NVARCHAR(50) = NULL,
	@RecipientTaxeDate DATE = NULL,
	@DateImport DATE = NULL,
	
		
	--Договор
	@ContractId	INT = NULL,
	@ContractNumber NVARCHAR(50) = NULL,
	@ContractDate DATE = NULL,
	@ContractDescription NVARCHAR(100) = NULL,
	
	
	--Документ
	@DocumentId INT = NULL,
	@DocumentTypeCode INT = NULL,
	@DocumentBlancCode NVARCHAR(50) = NULL,
	@DocumentNumber NVARCHAR(50) = NULL,
	@DocumentSeria NVARCHAR(50) = NULL,
	@DocumentDate DATE = NULL,
		
	@Documents NTEXT = NULL,
		
	--Грузоотправитель
	@ConsignorCounteragentId INT = NULL,
	
	@ConsignorCountryCode INT = NULL,
	@ConsignorUnp NCHAR(9) = NULL,
	@ConsignorName NVARCHAR(512) = NULL,
	@ConsignorAddress NVARCHAR(512) = NULL,
	
	@Consignors NTEXT = NULL,
	
	
	--Грузополучатель
	@ConsigneeCounteragentId INT = NULL,
	
	@ConsigneeCountryCode INT = NULL,
	@ConsigneeUnp NCHAR(9) = NULL,
	@ConsigneeName NVARCHAR(200) = NULL,
	@ConsigneeAddress NVARCHAR(200) = NULL,
	
	@Consignees NTEXT = NULL,
	--
			
	--Товары
	@RosterList NTEXT = NULL
	
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
		IsException BIT NOT NULL,
		[Message] varchar(1000) NOT NULL,
		VatInvoiceNumber nchar(25),
		VatInvoiceId  int
	)
	
	
	
	--Проверка заполнения--
		
		
	--
	DECLARE @invoiceId INT, @status TINYINT, @numberString NCHAR(25), @number BIGINT
	
	IF(@InvoiceTypeId=1)
	BEGIN
		
		SELECT 
			@invoiceId = InvoiceId,
			@numberString = NumberString,
			@number = Number,
			@status = StatusId
		FROM VatInvoice WHERE ReplicationSourceId = @ReplicationSourceId AND ReplicationId =  @ReplicationId AND InvoiceTypeId = 1
		
		--если исходный счёт фактура уже сформирован по документу и он ещё не отправлен на портал, то удаляем её сохраняем новые данные со старым номером 
		IF(@invoiceId is not NULL)
		BEGIN
			IF(@status IN (1,2))
			BEGIN
				EXEC spu_RemoveVatInvoice
				@Number = @numberString
			END
			ELSE BEGIN
								
			     	INSERT INTO @Rezult
				VALUES
				(
					1,
					'Исходный ЭСЧФ по документу уже сформирован и отправлен на портал, изменение данных невозможно',
					NULL,
					NULL
				)
	
				
	
				SELECT * FROM @Rezult
				RETURN 0
			     END
		END
		
		
	END
	
	
	DECLARE @year INT
	SELECT 
			@year = YEAR(GETDATE())
	
	IF(@numberString IS null)
		
		EXEC spu_GenerateVatInvoiceNumber
			@Year = @year,
			@Number = @number OUTPUT,
			@NumberString = @numberString OUTPUT
	
	
	
	--Поставщик
	
	/*Если задан код контрагента то пытаемся найти его данные из общезаводского справочника*/
	IF(@ProviderCounteragentId IS NOT NULL)
		EXEC spu_FindCounteragent
			@CounteragentId = @ProviderCounteragentId,
			@Name = @ProviderName OUTPUT,
			@Unp = @ProviderUnp OUTPUT,
			@CountryCode = @ProviderCountryCode OUTPUT,
			@Address = @ProviderAddress OUTPUT
	
	--Получатель
	
	/*Если задан код контрагента то пытаемся найти его данные из общезаводского справочника*/
	IF(@RecipientCounteragentId IS NOT NULL)
		EXEC spu_FindCounteragent
			@CounteragentId = @RecipientCounteragentId,
			@Name = @RecipientName OUTPUT,
			@Unp = @RecipientUnp OUTPUT,
			@CountryCode = @RecipientCountryCode OUTPUT,
			@Address = @RecipientAddress OUTPUT
	
	/*Если задан код договора, то пытаемся найти его данные из общезаводского справочника*/
	IF(@ContractId IS NOT null)
		EXEC spu_FindContract
			@ContractId = @ContractId,
			@Number = @ContractNumber OUTPUT,
			@Date = @ContractDate OUTPUT
	
	
	BEGIN TRANSACTION AddInvoiceTransaction
	
	INSERT INTO VatInvoice
	(
		IsIncome,
		ReplicationSourceId,
		ReplicationId,
		BuySaleTypeId,
		VatAccount,
		Account,
		AccountingDate,
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
		ContractId, 
		ContractNumber,
		ContractDate,
		ContractDescription,
		ProviderCounteragentId,
		ProviderCountryCode,
		ProviderBranchCode,
		ProviderUnp,
		ProviderName,
		ProviderAddress,
		ProviderStatusId,
		ProviderDependentPerson,
		ProviderResidentsOfOffshore,
		ProviderSpecialDealGoods,
		ProviderBigCompany,
		PrincipalInvoiceNumber,
		PrincipalInvoiceDate,
		VendorInvoiceNumber,
		VendorInvoiceDate,
		ProviderDeclaration,
		DateRelease,
		DateActualExport,
		ProviderTaxeNumber,
		ProviderTaxeDate,
		RecipientCounteragentId, 
		RecipientCountryCode, 
		RecipientBranchCode, 
		RecipientUnp, 
		RecipientName, 
		RecipientAddress,
		RecipientStatusId,
		RecipientDependentPerson,
		RecipientResidentsOfOffshore,
		RecipientSpecialDealGoods,
		RecipientBigCompany,
		RecipientDeclaration,
		RecipientTaxeNumber,
		RecipientTaxeDate,
		DateImport,
		ApproveDate,
		ApproveUser,
		IsValidate
	)
	VALUES
	(
		0,
		@ReplicationSourceId,
		@ReplicationId,
		@BuySaleType,
		@VatAccount,
		@Account,
		@AccountingDate,
		1,
		@NaftanUNP,
		@year,
		@number,
		@numberString,
		@DateTransaction,
		@InvoiceTypeId,
		@OriginalInvoiceNumber,
		@SendToRecipient,
		@DateCancelled,
		@ContractId,
		@ContractNumber,
		@ContractDate,
		@ContractDescription,
		@ProviderCounteragentId,
		@ProviderCountryCode,
		@ProviderBranchCode,
		@ProviderUnp,
		@ProviderName,
		@ProviderAddress, 
		@ProviderStatusId,
		@ProviderDependentPerson,
		@ProviderResidentsOfOffshore,
		@ProviderSpecialDealGoods,
		@ProviderBigCompany,
		@PrincipalInvoiceNumber,
		@PrincipalInvoiceDate,
		@VendorInvoiceNumber,
		@VendorInvoiceDate,
		@ProviderDeclaration,
		@DateRelease,
		@DateActualExport,
		@ProviderTaxeNumber,
		@ProviderTaxeDate,
		@RecipientCounteragentId,
		@RecipientCountryCode,
		@RecipientBranchCode,
		@RecipientUnp,
		@RecipientName,
		@RecipientAddress,
		@RecipientStatusId,
		@RecipientDependentPerson,
		@RecipientResidentsOfOffshore,
		@RecipientSpecialDealGoods,
		@RecipientBigCompany,
		@RecipientDeclaration,
		@RecipientTaxeNumber,
		@RecipientTaxeDate,
		@DateImport,
		CASE WHEN @IsApprove = 1 THEN GETDATE() ELSE NULL END,
		CASE WHEN @IsApprove = 1 THEN @ApproveUser ELSE NULL END,
		0
	)
		
	SET @InvoiceId = SCOPE_IDENTITY()
	
	--Временная таблица для извлечения контрагентов
	DECLARE @counteragents TABLE(N int, CounteragentId INT,NAME NVARCHAR(200),Unp NCHAR(9),CountryCode INT,[Address] NVARCHAR(200))
	DECLARE @counter INT
	
	/* Грузоотправители
		* Если грузоотправителей несколько, то они задаются списком в формате xml параметр @Consignors
		* Иначе обрабатываем одного грузоотправителя
	*/
	
	IF(@Consignors IS NULL)
	BEGIN
		
		/*Если задан код контрагента то пытаемся найти его данные из общезаводского справочника*/
		IF(@ConsignorCounteragentId IS NOT NULL)
			EXEC spu_FindCounteragent
			@CounteragentId = @ConsignorCounteragentId,
			@Name = @ConsignorName OUTPUT,
			@Unp = @ConsignorUnp OUTPUT,
			@CountryCode = @ConsignorCountryCode OUTPUT,
			@Address = @ConsignorAddress OUTPUT
			
		INSERT INTO Consignors
		VALUES
		(
			@ConsignorCounteragentId,
			@invoiceId,
			@ConsignorCountryCode,
			@ConsignorUnp,
			@ConsignorName,
			@ConsignorAddress
		)
		
	END
	ELSE
	BEGIN
				
		DECLARE @idXmlConsignors INT

		EXEC sp_xml_preparedocument @idXmlConsignors OUTPUT, @Consignors
		
		INSERT INTO @counteragents
		SELECT ROW_NUMBER() OVER ( ORDER BY CounteragentId),* FROM
			OPENXML (@idXmlConsignors, '/Consignors/Consignor') WITH 
			(
				CounteragentId INT '@CounteragentId',
				NAME NVARCHAR(200) '@Name',
				Unp NCHAR(9) '@Unp',
				CountryCode INT '@CountryCode',
				[Address] NVARCHAR(200) '@Address'
			)
		EXEC sp_xml_removedocument @idXmlConsignors

		SELECT @counter = COUNT(*) FROM @counteragents
				
		WHILE @counter>0
		BEGIN
			SELECT 
				@ConsignorCounteragentId = CounteragentId,
				@ConsignorCountryCode = CountryCode,
				@ConsignorUnp = Unp,
				@ConsignorName = NAME,
				@ConsignorAddress = [Address]
			FROM @counteragents WHERE N = @counter
	
		IF(@ConsignorCounteragentId IS NOT NULL)
			EXEC spu_FindCounteragent
				@CounteragentId = @ConsignorCounteragentId,
				@Name = @ConsignorName OUTPUT,
				@Unp = @ConsignorUnp OUTPUT,
				@CountryCode = @ConsignorCountryCode OUTPUT,
				@Address = @ConsignorAddress OUTPUT
				
			INSERT INTO Consignors
			VALUES
			(
				@ConsignorCounteragentId,
				@invoiceId,
				@ConsignorCountryCode,
				@ConsignorUnp,
				@ConsignorName,
				@ConsignorAddress
			)
	
			DELETE FROM @counteragents WHERE N = @counter
			SET @counter = @counter-1
		END
		
	END
		
		
	/* Грузополучатели
		* Если грузополучателей несколько, то они задаются списком в формате xml параметр @Consignees
		* Иначе обрабатываем одного грузополучателя
	*/
	
	IF(@Consignees IS NULL)
	BEGIN
		
		/*Если задан код контрагента то пытаемся найти его данные из общезаводского справочника*/
		IF(@ConsigneeCounteragentId IS NOT NULL)
			EXEC spu_FindCounteragent
			@CounteragentId = @ConsigneeCounteragentId,
			@Name = @ConsigneeName OUTPUT,
			@Unp = @ConsigneeUnp OUTPUT,
			@CountryCode = @ConsigneeCountryCode OUTPUT,
			@Address = @ConsigneeAddress OUTPUT
			
		INSERT INTO Consignees
		VALUES
		(
			@ConsigneeCounteragentId,
			@invoiceId,
			@ConsigneeCountryCode,
			@ConsigneeUnp,
			@ConsigneeName,
			@ConsigneeAddress
		)
		
	END
	ELSE
	BEGIN
				
		DECLARE @idXmlConsignees INT

		EXEC sp_xml_preparedocument @idXmlConsignees OUTPUT, @Consignees
		
		INSERT INTO @counteragents
		SELECT ROW_NUMBER() OVER ( ORDER BY CounteragentId),* FROM
			OPENXML (@idXmlConsignees, '/Consignees/Consignee') WITH 
			(
				CounteragentId INT '@CounteragentId',
				NAME NVARCHAR(200) '@Name',
				Unp NCHAR(9) '@Unp',
				CountryCode INT '@CountryCode',
				[Address] NVARCHAR(200) '@Address'
			)
		EXEC sp_xml_removedocument @idXmlConsignees

		SELECT @counter = COUNT(*) FROM @counteragents
				
		WHILE @counter>0
		BEGIN
			SELECT 
				@ConsigneeCounteragentId = CounteragentId,
				@ConsigneeCountryCode = CountryCode,
				@ConsigneeUnp = Unp,
				@ConsigneeName = NAME,
				@ConsigneeAddress = [Address]
			FROM @counteragents WHERE N = @counter
	
			IF(@ConsigneeCounteragentId IS NOT NULL)
			EXEC spu_FindCounteragent
				@CounteragentId = @ConsigneeCounteragentId,
				@Name = @ConsigneeName OUTPUT,
				@Unp = @ConsigneeUnp OUTPUT,
				@CountryCode = @ConsigneeCountryCode OUTPUT,
				@Address = @ConsigneeAddress OUTPUT
				
			INSERT INTO Consignees
			VALUES
			(
				@ConsigneeCounteragentId,
				@invoiceId,
				@ConsigneeCountryCode,
				@ConsigneeUnp,
				@ConsigneeName,
				@ConsigneeAddress
			)
	
			DELETE FROM @counteragents WHERE N = @counter
			SET @counter = @counter-1
		END
		
	END
	
		
	IF(@Documents IS NULL AND @DocumentTypeCode IS NOT NULL)
	BEGIN
		INSERT INTO Documents
		VALUES
		(
			@DocumentId,
			@invoiceId,
			@DocumentTypeCode,
			@DocumentBlancCode,--CASE WHEN @DocumentBlancCode IS NULL AND @DocumentTypeCode IN (602,603) THEN dbo.f_FindBlankCode(@DocumentSeria, @DocumentNumber) ELSE @DocumentBlancCode END,
			@DocumentNumber,
			@DocumentSeria,
			@DocumentDate
		)
	END	
	ELSE 
	BEGIN
		DECLARE @idXmlDocuments INT
		EXEC sp_xml_preparedocument @idXmlDocuments OUTPUT, @Documents 
		
		INSERT INTO Documents		
		SELECT 
			DocumentId,
			@invoiceId,
			DocumentTypeCode,
			DocumentBlancCode,--CASE WHEN DocumentBlancCode IS NULL AND DocumentTypeCode IN (602,603) THEN dbo.f_FindBlankCode(DocumentSeria, DocumentNumber) ELSE DocumentBlancCode END,
			DocumentNumber,
			DocumentSeria,
			DocumentDate
		FROM
			OPENXML (@idXmlDocuments, '/Documents/Document') WITH 
			(
				DocumentId INT '@Id',
				DocumentTypeCode INT '@TypeCode',
				DocumentBlancCode NVARCHAR(50) '@BlancCode',
				DocumentNumber NVARCHAR(50) '@Number',
				DocumentSeria NVARCHAR(50) '@Seria',
				DocumentDate Date '@Date'
			)
		EXEC sp_xml_removedocument @idXmlDocuments
	END
	
	
	DECLARE @idXmlRosterList INT
	EXEC sp_xml_preparedocument @idXmlRosterList OUTPUT, @RosterList 
	
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
			@invoiceId,
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
		FROM
			OPENXML (@idXmlRosterList, '/RosterList/Roster') WITH 
			(
				Number INT '@Number',
				Name NVARCHAR(512) '@Name',
				Code NVARCHAR(10) '@Code',
				CodeOced NVARCHAR(5) '@CodeOced',
				Units INT '@Units',
				[Count] DECIMAL(18,6) '@Count',
				Price DECIMAL(18,3) '@Price',
				Cost DECIMAL(18,3) '@Cost',
				SummaExcise DECIMAL(18,3) '@SummaExcise',
				VatRate DECIMAL(4,2) '@VatRate',
				VatRateTypeId TINYINT '@VatRateTypeId',
				SummaVat DECIMAL(18,3) '@SummaVat',
				CostVat DECIMAL(18,3) '@CostVat',
				[Description] NVARCHAR(256) '@Description'
			)
			
		INSERT INTO RosterDescription
		SELECT l.Id,a.DescriptionTypeId
		FROM OPENXML (@idXmlRosterList, '/RosterList/Roster/Description',2)	WITH (
			Number	INT	'../@Number',
			DescriptionTypeId  TINYINT '@DescriptionTypeId'
		)a
		LEFT JOIN RosterList AS l ON l.InvoiceId = @invoiceId AND l.Number = a.Number
		WHERE a.DescriptionTypeId IS NOT NULL AND a.DescriptionTypeId<>0
											
		EXEC sp_xml_removedocument @idXmlRosterList
	
	
	UPDATE VatInvoice
	SET
		RosterTotalCostVat = a.RosterTotalCostVat,
		RosterTotalExcise = a.RosterTotalExcise,
		RosterTotalVat = a.RosterTotalVat,
		RosterTotalCost = a.RosterTotalCost
	FROM (
	SELECT 
		InvoiceId,
		SUM(isnull(rl.CostVat,0)) AS RosterTotalCostVat,
		SUM(isnull(rl.SummaExcise,0)) as RosterTotalExcise,
		SUM(isnull(rl.SummaVat,0)) AS RosterTotalVat,
		SUM(isnull(rl.Cost,0)) AS RosterTotalCost
	FROM RosterList rl WHERE InvoiceId = @invoiceId
	GROUP BY InvoiceId
	)a
	WHERE VatInvoice.InvoiceId = @invoiceId
	
	
	INSERT INTO @Rezult
	VALUES
	(
		0,
		'',
		@numberString,
		@invoiceId
	)
	
	COMMIT TRANSACTION AddInvoiceTransaction
	
	SELECT * FROM @Rezult
	RETURN 1
	
END


