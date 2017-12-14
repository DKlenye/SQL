
--В подсобное
UPDATE sClient 
SET OwnerId = 4
WHERE [Login] = 'gko_fuel'

GO

/**/

--Назад
UPDATE sClient 
SET OwnerId = 3
WHERE [Login] = 'gko_fuel'

GO