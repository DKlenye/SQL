DECLARE @month INT, @year INT
SELECT @month = 12, @year = 2014

DECLARE @start Date
SET @start = CONVERT(Date,'01.'+CAST(@month AS CHAR(2))+'.'+CAST(@year AS CHAR(4)),104)

DECLARE @end Date
SET @end = Dateadd(Day,-1,DATEADD(MONTH,1,@start))


SELECT * FROM dbo.Calendar(@start,@end) c