DECLARE @AgreementId INT = 2

SELECT 
	sdg.ServiceDepartmentGroupId,
	sdg.Name
FROM ServiceDepartmentGroup AS sdg

DECLARE @ServiceDepartmentGroupId INT = 2

SELECT 
	DirectionId,
	DirectionNumber + '  '+DepartmentName DirectionName
FROM ServiceDirection s
LEFT JOIN ServiceDepartment AS sd ON sd.DepartmentId = s.DepartmentId
WHERE s.AgreementId = @AgreementId AND sd.ServiceDepartmentGroupId = @ServiceDepartmentGroupId


SELECT 
	AgreementPurposeId,
	sap.PurposeNumber+' '+sp.PurposeName
FROM ServiceAgreementPurpose AS sap
LEFT JOIN ServicePurpose AS sp ON sp.PurposeId = sap.PurposeId
WHERE sap.AgreementId = @AgreementId  AND (sp.ServiceDepartmentGroupId IS NULL OR sp.ServiceDepartmentGroupId = @ServiceDepartmentGroupId)