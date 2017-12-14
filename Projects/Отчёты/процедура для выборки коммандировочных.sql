DECLARE @s DATETIME, @e DATETIME
SELECT @s = '20131201', @e = '20131202'
SELECT * FROM [dbo].[fInfoForBusinessTrip] (2, @s, @e)