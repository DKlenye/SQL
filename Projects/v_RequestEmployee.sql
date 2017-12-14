
CREATE VIEW v_RequestEmployee
as

SELECT 
	*
FROM Employee 
WHERE 
		DismissDate IS NULL
	AND	DSC=1
	AND (
			Office LIKE '%генерального%'
			
			OR Office LIKE 'начальник производства%'
			OR Office LIKE 'начальник цеха'
			OR Office LIKE 'начальник управления'
			OR Office LIKE 'начальник отдела'
			OR Office LIKE 'помощник'
			
			OR Office LIKE 'заместитель начальника производства%'
			OR Office LIKE 'заместитель начальника цеха%'
			OR Office LIKE 'заместитель начальника управления%'
			OR Office LIKE 'заместитель начальника отдела%'
			
			OR Office LIKE 'главный%'
			OR Office LIKE 'заместитель главного%'
			
	)


UNION ALL

SELECT 
	*
FROM Employee 
WHERE 
		DismissDate IS NULL
	AND	DSC=2
	AND (
				Office LIKE 'директор'
			OR	Office LIKE 'заместитель директора%'
			
			OR Office LIKE 'главный%'
			OR Office LIKE 'заместитель главного%'
			
			OR Office LIKE 'начальник отдела'
			OR Office LIKE 'заместитель начальника отдела%'
	)
