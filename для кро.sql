

SELECT 
	c.Summ AS [����� ��� ���],
	c.SummNDS AS [����� � ���],
	sa.Number AS �������,
	c.Y AS ���,
	c.M AS �����,
	rtrim(ltrim(replace(replace(replace(cu.CustomerName,'������� 1',''),'������� 2',''),'������� 3',''))) AS ��������
FROM (
SELECT 
	SUM(isnull(Summ,0)) AS Summ,
	SUM(ISNULL(SummNDS,0)) AS SummNDS,
	SHZ,
	CustomerId,
	Y,M
FROM (
	SELECT 
		a.WaybillId,
		swi.mkm+swi.mhour AS Summ,
		swi.mkm+swi.mhour+swi.taxmkm+swi.taxmhour AS SummNDS,
		a.SHZ,
		a.CustomerId,
		YEAR(ss.scoreDate) AS Y,
		MONTH(ss.scoreDate) AS M
	FROM (
		SELECT
			distinct 
			w.WaybillId,
			c.CustomerId,
			c.SHZ
		FROM waybill w 
		INNER JOIN WaybillTask AS wt ON wt.WaybillId = w.WaybillId
		INNER JOIN Customer c ON c.CustomerId = wt.CustomerId
		WHERE 
			CAST(returnDate AS Date) between '01.12.2015' AND '30.09.2016'
			AND c.SHZ IN ('�1','�2','�3')
	)a
	LEFT JOIN ServiceWaybillsInfo AS swi ON swi.CustomerId = a.CustomerId AND swi.waybillNumber = a.WaybillId
	LEFT JOIN serviceScore AS ss ON ss.scoreNo = swi.scoreNo
)b
WHERE Summ>0
GROUP BY SHZ,CustomerId,Y,M
)c
LEFT JOIN Customer AS cu ON cu.CustomerId = c.CustomerId
LEFT JOIN ServiceAgreement AS sa ON c.SHZ=sa.AgreementShortName
ORDER BY cu.CustomerName, Y,M