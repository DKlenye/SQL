
UPDATE Customer SET
	CustomerName = REPLACE(c.CustomerName,d.ShortName, ltrim(rtrim(pd.ShortName))+' '+ltrim(rtrim(d.ShortName))),
	CustomerName1 = REPLACE(c.CustomerName1,d.ShortName, ltrim(rtrim(pd.ShortName))+' '+ltrim(rtrim(d.ShortName)))
FROM Customer c
inner JOIN ServiceDirection AS sd ON sd.DirectionId = c.DirectionId
INNER JOIN serviceDepartment d ON d.DepartmentId = sd.DepartmentId
INNER JOIN servicedepartment pd ON pd.DepartmentId = d.ParentDepartmentId
WHERE d.DepartmentId<>d.ServiceDepartmentGroupId

UPDATE ServiceDepartment
set
ServiceDepartment.DepartmentName = (select ShortName FROM ServiceDepartment WHERE DepartmentId = sd.ParentDepartmentId)+' '+sd.DepartmentName,
ServiceDepartment.ShortName = (select ShortName FROM ServiceDepartment WHERE DepartmentId = sd.ParentDepartmentId)+' '+sd.ShortName
FROM ServiceDepartment AS sd
WHERE sd.ParentDepartmentId IS NOT NULL

