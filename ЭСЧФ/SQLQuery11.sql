SELECT
	codeStat,
	inCu,
	Name
FROM 
DBSRV2.NSI.dbo.vt_rCountry 
WHERE _Deleted=0 AND codeStat IS NOT NULL


SELECT * FROM VatInvoice AS vi WHERE vi.InvoiceId = 120
SELECT * FROM VatInvoiceXml AS vix WHERE InvoiceId = 120
SELECT * FROM Documents AS d WHERE InvoiceId = 120
SELECT * FROM RosterList AS rl WHERE rl.InvoiceId = 120
SELECT * FROM RosterDescription AS rd

SELECT * FROM DocumentType AS dt


DELETE FROM VatInvoiceXml WHERE InvoiceId = 133
UPDATE VatInvoice SET StatusId = 1  WHERE InvoiceId = 133


update VatInvoice SET AccountingDate = '01.05.2016' WHERE AccountingDate IS NULL


MERGE INTO VatInvoice v
USING (
	SELECT 
		InvoiceId,
		SUM(isnull(rl.CostVat,0)) AS RosterTotalCostVat,
		SUM(isnull(rl.SummaExcise,0)) as RosterTotalExcise,
		SUM(isnull(rl.SummaVat,0)) AS RosterTotalVat,
		SUM(isnull(rl.Cost,0)) AS RosterTotalCost
	FROM RosterList rl 
	WHERE InvoiceId = 133 
	GROUP BY InvoiceId
)S ON S.InvoiceId = v.InvoiceId
WHEN MATCHED THEN 
	UPDATE SET
	RosterTotalCostVat = S.RosterTotalCostVat,
	RosterTotalExcise = S.RosterTotalExcise,
	RosterTotalVat = S.RosterTotalVat,
	RosterTotalCost = S.RosterTotalCost;
