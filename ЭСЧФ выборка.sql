DECLARE
	@Start DATE,
	@End DATE,
	@VatRate DECIMAL(18,2),
	@VatRateTypeId INT,
	@DescriptionTypeId INT

SELECT @Start='01.01.2017', @End = '31.01.2017'
	
SELECT 
	vi.RegistryNumber [№ реестра],
	vi.InvoiceId [Код ЭСЧФ],
	s.StatusName [Статус],
	vi.NumberString [№ ЭСЧФ],
	vi.Account [Счёт],
	vi.DateTransaction [Дата сов. Операции],
	rs.Name [Учётная система],	
	vi.ApproveUser [Кто проверил],
	vrt.VatRateTypeName [Тип ставки НДС],
	a.VatRate [Ставка НДС],
	dt.DescriptionTypeName [Доп сведения],
	a.Cost [Сумма без НДС],
	a.SummaVat [Сумма НДС],
	a.CostVat [Сумма с НДС]
FROM (
	SELECT 
		vi.InvoiceId,
		rl.VatRateTypeId,
		rl.VatRate,
		rd.DescriptionTypeId,
		SUM(rl.Cost) Cost,
		SUM(rl.SummaVat) SummaVat,
		SUM(rl.CostVat) CostVat
	FROM VatInvoice AS vi
	LEFT JOIN RosterList AS rl ON rl.InvoiceId = vi.InvoiceId
	LEFT JOIN RosterDescription AS rd ON rd.RosterId = rl.Id 
	WHERE 
		vi.IsIncome = 0 AND
		vi.BuySaleTypeId = 2 AND
		vi.DateTransaction BETWEEN @Start AND @End AND
		isnull(rd.DescriptionTypeId,0) = ISNULL(@DescriptionTypeId,isnull(rd.DescriptionTypeId,0)) AND 
		isnull(rl.VatRateTypeId,0) = ISNULL(@VatRateTypeId,isnull(rl.VatRateTypeId,0)) AND 
		isnull(rl.VatRate,0) = ISNULL(@VatRate,isnull(rl.VatRate,0))
	GROUP BY vi.InvoiceId,	rl.VatRateTypeId,	rl.VatRate,	rd.DescriptionTypeId
)a
LEFT JOIN VatInvoice AS vi ON vi.InvoiceId = a.InvoiceId
LEFT JOIN VatRateType AS vrt ON vrt.VatRateTypeId = a.VatRateTypeId
LEFT JOIN DescriptionType AS dt ON dt.DescriptionTypeId = a.DescriptionTypeId
LEFT JOIN ReplicationSource AS rs ON rs.ReplicationSourceId = vi.ReplicationSourceId
LEFT JOIN InvoiceStatus AS s ON s.StatusId = vi.StatusId
ORDER BY vi.RegistryNumber, vi.NumberString



/*
SELECT RosterId, COUNT(descriptionTypeId) FROM RosterDescription
GROUP BY RosterId HAVING COUNT(descriptionTypeId)>1
*/