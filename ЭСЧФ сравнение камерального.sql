
SELECT 
vi.InvoiceId,
vi.NumberString,

c.[Ñóììà ÍÄÑ],
vi.RosterTotalVat,

c.[Ñóììà ÍÄÑ]/vi.RosterTotalVat AS diff,

c.[Ñòàòóñ ÝÑ×Ô],
vi.StatusId

FROM Cameral c
LEFT JOIN (
	SELECT 
		v.InvoiceId,
		v.StatusId,
		v.NumberString,
		isnull(d.Summ,v.RosterTotalVat- ISNULL(e.RosterTotalVat,0)) RosterTotalVat
	FROM VatInvoice v
	LEFT JOIN (
		SELECT 
			d.InvoiceId,
			SUM(d.SummaVat) AS Summ
		FROM Deductions d WHERE idTypeDeduction = 1
		GROUP BY d.InvoiceId
	)d ON d.InvoiceId = v.InvoiceId
	LEFT JOIN (
		select 
			VendorInvoiceNumber,
			sum(isNull(RosterTotalCost,0)) as RosterTotalCost, 
			sum(isNull(RosterTotalVat,0)) as RosterTotalVat
		from VatInvoice
		where 
			ISNULL(VendorInvoiceNumber,'') <> ''AND
			StatusId <> 7  AND
			isNull(VatInvoice.IsDefect,0)<>1 
		group by VendorInvoiceNumber
	)e ON e.VendorInvoiceNumber = v.NumberString
)AS vi ON vi.NumberString = c.[¹ ÝÑ×Ô]
WHERE c.[Ñóììà ÍÄÑ]<>vi.RosterTotalVat AND vi.RosterTotalVat <>0
ORDER BY 5

/*
SELECT * FROM Deductions AS d
WHERE d.InvoiceId = 23642


SELECT * FROM Cameral AS c*/




/*300000252-2016-0322003135*/


	