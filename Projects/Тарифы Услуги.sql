
INSERT INTO serviceTariff
SELECT 
	2014,3,0,idServiceGroup,hourTariff,kmTariff,massKmTariff,summTariff,0.2	
FROM tServiceTariff WHERE DateTariff = '01.03.2014'