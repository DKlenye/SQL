SELECT 
	zex,
	tab,
	fio,
	data_pr,
	data_uv,
	id_men,
	zex + ' ' + tab + ' ' + fio AS string,
	dol
FROM (
SELECT 
	zex,
	tab,
	ltrim(rtrim(Surname)) + ' '+ltrim(rtrim(NAME))+' '+ltrim(rtrim(Patronymic)) AS fio,
	WorkBegin AS data_pr,
	WorkEnd AS data_uv,
	idEmployee AS id_men,
	JobTitleNew AS dol
FROM db3.Salary_Polymir.dbo.vEmployee WHERE Surname LIKE '%агеев%'
)a

SELECT * FROM db3.Salary_Polymir.dbo.vEmployee

SELECT        
	zex,
	tab,
	fio,
	data_pr,
	data_uv,
	id_men,
	zex + ' ' + tab + ' ' + fio AS string
FROM            kdr.dbo.[personal1]