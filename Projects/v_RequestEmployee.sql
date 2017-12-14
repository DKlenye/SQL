
CREATE VIEW v_RequestEmployee
as

SELECT 
	*
FROM Employee 
WHERE 
		DismissDate IS NULL
	AND	DSC=1
	AND (
			Office LIKE '%������������%'
			
			OR Office LIKE '��������� ������������%'
			OR Office LIKE '��������� ����'
			OR Office LIKE '��������� ����������'
			OR Office LIKE '��������� ������'
			OR Office LIKE '��������'
			
			OR Office LIKE '����������� ���������� ������������%'
			OR Office LIKE '����������� ���������� ����%'
			OR Office LIKE '����������� ���������� ����������%'
			OR Office LIKE '����������� ���������� ������%'
			
			OR Office LIKE '�������%'
			OR Office LIKE '����������� ��������%'
			
	)


UNION ALL

SELECT 
	*
FROM Employee 
WHERE 
		DismissDate IS NULL
	AND	DSC=2
	AND (
				Office LIKE '��������'
			OR	Office LIKE '����������� ���������%'
			
			OR Office LIKE '�������%'
			OR Office LIKE '����������� ��������%'
			
			OR Office LIKE '��������� ������'
			OR Office LIKE '����������� ���������� ������%'
	)
