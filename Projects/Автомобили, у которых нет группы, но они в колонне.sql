SELECT * FROM Vehicle WHERE 
OwnerId = 1
AND ISNULL(ColumnId,5)<>5
AND AccGroupId IS NULL
AND dsc=1

