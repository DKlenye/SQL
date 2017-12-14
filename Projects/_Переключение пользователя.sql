DECLARE @owner INT
SET @owner = 3

update sClient SET ownerId = @owner  WHERE idClient = 78
update OwnerPersons SET ownerid = @owner WHERE personid = 2

/*
update sClient SET ownerId = @owner  WHERE idClient = 7
update OwnerPersons SET ownerid = @owner WHERE personid = 13078
*/



update sClient SET ownerId = @owner  WHERE idClient = 119
update OwnerPersons SET ownerid = @owner WHERE personid = 8


update sClient SET ownerId = @owner  WHERE idClient = 78
update OwnerPersons SET ownerid = @owner WHERE personid = 2










