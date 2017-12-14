
DECLARE @month INT, @year INT
SELECT @month = 10, @year = 2015


SELECT 
	--a.*,
	'EXEC UslugDokFromTrans_Insert
	@NomDokAktSchetFaktur = '+cast(scoreNo AS VARCHAR(10))+',
	@DatDokAktSchetFaktur = '''+CONVERT(varchar(12),scoreDate,104)+''',
	@DatOfDok = '''+CONVERT(varchar(12),scoreDate,104)+''',
	@IdPredpr = '+cast(kgr AS VARCHAR(10)) +',
	@IdAgree = '+cast(KDOG AS VARCHAR(10))+',
	@ZaChto = ''возмещение услуг'',
	@SumDokVal = '+cast(allSumm AS VARCHAR(10))+', 
	@SumDokRb = '+cast(allSumm AS VARCHAR(10))+',
	@SumItogoNdsSchetFakturVal = '+cast(allSumm AS VARCHAR(10))
FROM (
SELECT 
	na.kgr,
	b.KDOG,
	na.osn,	
	c2.customerName,
	b.scoreNo,
	b.scoreDate,
	b.summ,
	b.taxsumm,
	b.taxRate,
	cast(b.summ + b.taxsumm AS INT) allSumm 
FROM (
SELECT 
	a.*,
	ss.scoreDate,
	dbo.f_GetAgreeId(ss.customerId,ss.scoreDate) KDOG
FROM (
SELECT 
	swi.scoreNo,
	swi.taxRate,
	/*SUM(isnull(swi.travelExpense,0))+*/SUM(isnull(swi.tollRoad,0)) summ,
	/*SUM(ISNULL(swi.taxtravelExpense,0))+*/SUM(ISNULL(swi.taxtollRoad,0)) taxsumm
FROM serviceWaybillsInfo swi
WHERE swi.serviceMonth = @month AND swi.serviceYear=@year
GROUP BY swi.scoreNo, swi.taxRate
HAVING SUM(isnull(swi.travelExpense,0))+SUM(isnull(swi.tollRoad,0))>0
)a
LEFT JOIN serviceScore ss ON ss.scoreNo = a.scoreNo
)b
LEFT JOIN NSD2_Agree na ON na.kdog = b.KDOG
LEFT JOIN custcontragent c ON c.idContragent = na.kgr
LEFT JOIN _customers c2 ON c2.customerId = c.customerId
WHERE b.summ<>0
)a