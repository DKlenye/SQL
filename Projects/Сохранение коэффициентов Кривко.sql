
DECLARE @Model VARCHAR(100), @Id INT, @Km0 VARCHAR(15),@Km100 VARCHAR(15),@Km300 VARCHAR(15),@Km500 VARCHAR(15),@Km700 VARCHAR(15) ,@Km900 VARCHAR(15)

DECLARE @_Model VARCHAR(100)


declare Cur cursor 
for 
	
SELECT 
a.Model,
b.Id,
a.Km0,a.Km100,a.Km300,a.Km500,a.Km700,a.Km900
FROM (
select 
	*
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=C:\test.xls','SELECT * FROM [Ëèñò2$]')
)a
inner JOIN (
SELECT 1 Id,'ÇÏ' NAME 
union	SELECT 2 ,'ÌÇ' 
union	SELECT 3 ,'ÑÌ' 
) b ON b.[NAME]=a.[Type]
				
open Cur

fetch next from Cur into @Model,@Id, @Km0 ,@Km100 ,@Km300 ,@Km500 ,@Km700  ,@Km900

while @@fetch_status=0
begin

IF(@Model IS null) SET @Model = @_Model
SET @_Model = @Model

DECLARE @str VARCHAR(250)
SET @str = 'insert into TariffCostItem values('+
+''''+@Model+''','+
cast(@Id AS VARCHAR(10))+','+
isnull(@Km0,'null')+','+
isnull(@Km100,'null')+','+
isnull(@Km300,'null')+','+
isnull(@Km500,'null')+','+
isnull(@Km700,'null')+','+
isnull(@Km900,'null')+')'

PRINT @str

fetch next from Cur into @Model,@Id, @Km0 ,@Km100 ,@Km300 ,@Km500 ,@Km700  ,@Km900
end
close Cur 
deallocate Cur
