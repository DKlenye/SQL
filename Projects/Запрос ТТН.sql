declare @Id int
SELECT @Id = 16

DECLARE 
	@TotalAmount DECIMAL(20,3),
	@TotalCost DECIMAL(20,5),
	@TotalSumVAT DECIMAL(20,5),	
	@TotalFullSum DECIMAL(20,5),
	@TotalPackageCount INT

--Временная таблица для хранения сумм
DECLARE @SumTable TABLE (
Id_Header [INT] NOT NULL,	
Id_Product [INT] NOT NULL,	
ActualAmount [DECIMAL](10,3) NOT NULL,	
Price [DECIMAL](10,3) NOT NULL,	
VAT [INT] NOT NULL,
PackageCount [INT] NULL,
Cost [DECIMAL](20,6) NOT NULL,
SumVAT [DECIMAL](20,6) NOT NULL,
FullSum [DECIMAL](20,6) NOT NULL)
 

INSERT into @SumTable
SELECT 
	rd.RefuellingDocId,
	r.DocRefuellingId,
	r.Quantity,
	r.Cost,
	0,
	1,
	round(r.Cost*r.Quantity,0),
	0,
	0	
FROM
RefuellingDoc rd
INNER JOIN DocRefuelling r ON r.RefuellingDocId = rd.RefuellingDocId
WHERE rd.DSC = 'ttn' AND rd.RefuellingDocId = @Id

UPDATE @SumTable SET FullSum = Cost	

SELECT 
	@TotalAmount = SUM(ActualAmount), 
	@TotalCost = SUM(Cost), 
	@TotalSumVAT = SUM(SumVAT), 
	@TotalFullSum = SUM(FullSum), 
	@TotalPackageCount = SUM(PackageCount) 
FROM @SumTable


SELECT 
	rd.RefuellingDocId,
	rd.Serial,
	rd.Number,
	rd.RefuellingDate,
	v.VehicleId,
	v.Model+' Гос.№ '+v.RegistrationNumber AS CarModel,
	w.WaybillId,
	d.Fio,
	
	-- Раздел 1
	
	f.FuelName,
	r.Quantity,
	r.Cost,
	SumTable.Cost AS FuelCost,
	SumTable.FullSum  AS FullSum,
	1 AS PackageCount,
	TotalPackageCount = @TotalPackageCount,
	TotalFullSum = CAST(@TotalFullSum AS FLOAT),
	TotalCost = CAST(@TotalCost AS FLOAT)
	
FROM
RefuellingDoc rd
INNER JOIN DocRefuelling r ON r.RefuellingDocId = rd.RefuellingDocId
INNER JOIN Waybill w ON w.WaybillId = rd.WaybillId
INNER JOIN Vehicle v ON w.VehicleId = v.VehicleId
LEFT JOIN v_Driver d ON d.DriverId = w.DriverId
LEFT JOIN Fuel f ON f.FuelId = r.FuelId
INNER JOIN	@SumTable AS SumTable ON r.DocRefuellingId = SumTable.Id_Product
WHERE rd.DSC = 'ttn' AND rd.RefuellingDocId = @Id
 
 
 /*

	
		
		-- Раздел 1
				
		product.PackageCount,
		Note = 'Прейскурант ' + RTRIM(vidcen.pres) + ' от ' + CONVERT(VARCHAR(10), priceList.date, 104),
		TotalAmount = @TotalAmount,
		TotalCost = CAST(@TotalCost AS FLOAT),
		TotalSumVAT = CAST(@TotalSumVAT AS FLOAT),	
		TotalFullSum = CAST(@TotalFullSum AS FLOAT),				
		TotalPackageCount = @TotalPackageCount,
		TotalAmountStr = dbo.udf_WeightFormatForNum(@TotalAmount, product.unit),
		TotalSumVATStr = dbo.udf_MoneyFormatForNum(@TotalSumVAT,currencies.currencyIsoId),
		TotalFullSumStr = dbo.udf_MoneyFormatForNum(@TotalFullSum,currencies.currencyIsoId),
		TotalPackageCountStr = dbo.numToStr(@TotalPackageCount),
		ShipmentAllowed = sh_a.userName,
		PassedConsigner = p_c.userName,
		Forvarder = header.Forwarder,
		Warrant = '№ ' + CAST(header.WarrantNumber as VARCHAR(10)) + ' от ' + CONVERT(VARCHAR(10), header.WarrantDate, 104),
		WarrantGranted = w_Granted.counteragentName,
		Loader = loader.counteragentName,
		Loading = loading.Name,
		CommingDateTime = CONVERT(VARCHAR(10), header.CommingDateTime, 104) + ' ' + CONVERT(VARCHAR(5), header.CommingDateTime, 114),
		DepartureDateTime = CONVERT(VARCHAR(10), header.DepartureDateTime, 104) + ' ' + CONVERT(VARCHAR(5), header.DepartureDateTime, 114),
		header.Downtime,
		AdditionalOperation = add_op.Name,
		header.AdditionalTime,
		
		
		header.TripCount,
		header.FormType_Id,
		product.Product_Id
		
		
		
FROM		dbo.TTN1_Header			AS header 
INNER JOIN	dbo.TTN1_Product		AS product		ON product.TTN1_Header_Id = header.Id
INNER JOIN	dbo.view_counteragents	AS consigner	ON consigner.counteragentId = header.Consigner_Id
INNER JOIN	dbo.view_counteragents	AS consignee	ON consignee.counteragentId = header.Consignee_Id
INNER JOIN	dbo.view_counteragents	AS payer		ON payer.counteragentId = header.TransportationPayer_Id
LEFT JOIN	dbo.view_counteragents	AS recipient	ON recipient.counteragentId = header.RecipientOfRequest_Id
INNER JOIN	dbo.ttn1_Car			AS car			ON car.Id = header.Car_Id 
LEFT JOIN	dbo.ttn1_Trailer		AS trailer		ON trailer.Id = header.Trailer_Id
INNER JOIN	dbo.view_counteragents	AS carOwner		ON carOwner.counteragentId = car.Counteragent_Id
INNER JOIN  dbo.ttn1_Driver			AS driver		ON driver.Id = header.Driver_Id
INNER JOIN	dbo.view_agreements		AS agreement	ON agreement.agreementId = header.Agreement_Id
INNER JOIN	dbo.ttn1_PlaceOfUnloading AS placeL		ON placeL.Id = header.PlaceOfLoading_Id
INNER JOIN	dbo.ttn1_PlaceOfUnloading AS placeUL	ON placeUL.Id = header.PlaceOfUnLoading_Id
INNER JOIN	dbo.view_products		AS v_product	ON v_product.productId = product.Product_Id
INNER JOIN	dbo.dbf_svidcen			AS vidcen		ON vidcen.vidcen = product.PriceType_Id
INNER JOIN	dbo.dbf_prodcen			AS priceList	ON priceList.idprodcen = product.PriceList_Id
INNER JOIN	@SumTable				AS SumTable		ON product.Id = SumTable.Id_Product
INNER JOIN	dbo.view_currencies		AS currencies	ON currencies.currencyId = product.PriceCurrency_Id
INNER JOIN	dbo.view_users			AS sh_a			ON sh_a.userId = header.ShipmentAllowed_Id
LEFT JOIN	dbo.view_users			AS p_c			ON p_c.userId = header.PassedConsigner_Id
INNER JOIN	dbo.view_counteragents	AS w_Granted	ON w_Granted.counteragentId = header.WarrantGranted_Id
INNER JOIN	dbo.view_counteragents	AS loader		ON loader.counteragentId = header.Loader_Id
INNER JOIN	dbo.ttn1_LoadingType	AS loading		ON loading.Id = header.LoadingType_Id
LEFT JOIN	dbo.ttn1_AdditionalOperation AS add_op	ON add_op.Id = header.AdditionalOperation_Id


WHERE header.Id=@Id

*/

