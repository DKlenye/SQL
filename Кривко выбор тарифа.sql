USE [transport_dbf_store]
GO
/****** Object:  StoredProcedure [dbo].[serviceWaybill_INSERT]    Script Date: 14.03.2016 17:06:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[serviceWaybill_INSERT]  @waybillnumber bigint,@garagenumber int,@mh varchar(8),@km varchar(8),@mass varchar(8),@massRace varchar(8),@hourWork varchar(8), @scoreNo int,@travelExpense varchar(8),@tollRoad varchar(8),@ownerId tinyint = null
as
if @scoreNo is null RAISERROR('Выбирите счёт для путевого', 16,10)


	declare @_owner tinyint
	--set  @_owner = isnull(@ownerId,dbo.getCurrentOwner())
	select TOP 1 @_owner=ownerId from waybillstasks where garageNumber = @garagenumber and WaybillNumber = @waybillnumber
	
	DECLARE @ver INT
	DECLARE @customerName VARCHAR(200)
	SELECT @customerName = customerName  FROM customers WHERE customerId = (SELECT customerId FROM serviceScore WHERE scoreNo = @scoreNo)
	

if(SELECT customerId FROM serviceScore WHERE scoreNo = @scoreNo) = (SELECT TOP 1 CustomerId  FROM customers WHERE customerName like 'УП "Нафтан-Спецтранс"') 
	BEGIN
		SET @ver = 10
	END
	
ELSE IF @customerName LIKE '%Д1%' OR @customerName LIKE '%Д2%' OR @customerName LIKE '%Д3%' OR @customerName LIKE '%Д4%'
BEGIN
	SET @ver = CASE WHEN @customerName LIKE '%Д1%' THEN 15 WHEN  @customerName LIKE '%Д2%' THEN 17 ELSE 8 end
END
	
ELSE 
	BEGIN
		--SET @ver = cast (dbo.strToDecimal(@hourWork) AS INT)
	select @ver = sum(mh) from (
	SELECT DISTINCT c.customerId, mh
		FROM waybillsTasks wt
		LEFT JOIN customers c ON c.customerId = wt.customerId
		WHERE wt.waybillNumber = @waybillnumber AND c.customerName LIKE '%договор%'	
	) a
		
	
	IF(@ver>8) SET @ver = 8
	
	IF NOT EXISTS(
	SELECT st.version FROM serviceScore ss
	INNER JOIN transportFacilities tf ON tf.ownerId = @_owner AND tf.garageNumber = @garagenumber
	INNER JOIN serviceTariff st ON st.periodYear = year(ss.scoreDate) AND st.periodMonth = MONTH(ss.scoreDate) AND st.version = @ver AND st.serviceGroupId = tf.groupServiceId
	WHERE ss.scoreNo = @scoreNo
	)
	SET @ver=0
	END

	
	insert into serviceWaybill(ownerId,waybillnumber,garagenumber,mass,hourWork,km,mh,masskm,scoreNo,version,travelExpense,tollRoad)
	values (@_owner,@waybillnumber,@garagenumber,dbo.strToDecimal(@mass),dbo.strToDecimal(@hourWork),dbo.strToDecimal(@km),dbo.strToDecimal(@mh),dbo.strToDecimal(@massRace),@scoreNo,@ver,dbo.strToDecimal(@travelExpense),dbo.strToDecimal(@tollRoad))


		