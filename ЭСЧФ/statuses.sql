


SELECT * FROM [OLE DB Destination] AS odd


DECLARE @str VARCHAR(5000) 
SET @str=''
select 
@str = @str+' '+cast(InvoiceId AS VARCHAR(10))+','
FROM (

SELECT a.f1, a.n, v.InvoiceId, v.StatusId FROM (
SELECT SUBSTRING(f1,CHARINDEX('¹',f1)+1,25) n, f1 FROM [OLE DB Destination] AS odd WHERE odd.F1 LIKE '%COMPLETED %'
)a
LEFT JOIN VatInvoice AS v ON v.NumberString = a.n
WHERE v.StatusId = 4
)b

SELECT  @str



DECLARE @str VARCHAR(5000) 
SET @str=''
select 
@str = @str+' '+cast(InvoiceId AS VARCHAR(10))+','
FROM (

SELECT a.f1, a.n, v.InvoiceId, v.StatusId,v.IsIncome FROM (
SELECT SUBSTRING(f1,CHARINDEX('¹',f1)+1,25) n, f1 FROM [OLE DB Destination] AS odd WHERE odd.F1 LIKE '%err%'
)a
LEFT JOIN VatInvoice AS v ON v.NumberString = a.n
LEFT JOIN VatInvoiceXml AS vix ON vix.InvoiceId = v.InvoiceId
WHERE v.StatusId = 3
)bv

SELECT  @str



SELECT a.f1, a.n, v.InvoiceId, v.StatusId FROM (
SELECT SUBSTRING(f1,CHARINDEX('¹',f1)+1,25) n, f1 FROM [OLE DB Destination] AS odd WHERE odd.F1 LIKE '%can %'
)a
LEFT JOIN VatInvoice AS v ON v.NumberString = a.n