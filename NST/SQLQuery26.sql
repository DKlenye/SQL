update Customer SET notActual = 1 WHERE SHZ IN ('Ä1','Ä2','Ä3')  AND DirectionId IS NULL AND PurposeId IS NULL



update Customer SET notActual = 0   WHERE SHZ IN ('Ä1','Ä2','Ä3')  AND DirectionId IS NULL AND PurposeId IS NULL
update Customer SET notActual = 1  WHERE SHZ IN ('Ä1','Ä2','Ä3')  AND DirectionId IS NOT NULL AND PurposeId IS NOT NULL


SELECT * FROM ServiceDirection AS sd