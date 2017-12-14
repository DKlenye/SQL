CREATE TABLE #CLOC(txt VARCHAR(255))
DECLARE @objName VARCHAR(255)

declare ObjCur cursor 
for SELECT name FROM sysobjects WHERE [type] IN ('P','V','TF') AND NAME NOT LIKE 'sp_%' ORDER BY NAME
open ObjCur
fetch next from ObjCur into @objName
while @@fetch_status=0
	begin
		INSERT INTO #CLOC EXEC sp_helptext @objName
		fetch next from ObjCur into @objName
	end
close ObjCur 
deallocate ObjCur

SELECT 'all' as NAME, count(txt) AS CLOC FROM #CLOC
UNION ALL 
SELECT 'not empty' as CLOC, count(txt) AS cloc FROM #CLOC WHERE LEN(txt)>2
DROP table #CLOC