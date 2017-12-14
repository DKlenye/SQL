SELECT 
	
	sd.DirectionId,
	sap.AgreementPurposeId,

	sa.AgreementName,
	DepartmentName,
	sd.DirectionNumber,
	sp.PurposeName,
	
	sa.AgreementShortName+' '+case when DepartmentName LIKE 'иные' THEN sdg.ShortName+' '+DepartmentName ELSE DepartmentName END+' ['+sp.PurposeName+']'
	
	
FROM ServiceDirection AS sd
LEFT JOIN ServiceDepartment AS d ON d.DepartmentId = sd.DepartmentId
LEFT JOIN ServiceDepartmentGroup AS sdg ON sdg.ServiceDepartmentGroupId = d.ServiceDepartmentGroupId
LEFT JOIN ServiceAgreement AS sa ON sa.AgreementId = sd.AgreementId
LEFT JOIN ServiceAgreementPurpose AS sap ON sap.AgreementId = sa.AgreementId
LEFT JOIN ServicePurpose AS sp ON sp.PurposeId = sap.PurposeId
WHERE sd.DirectionId IN (220,221,222)



INSERT INTO Customer
(
	CustomerName,
	CostCode,
	OwnerId,
	ReplicationId,
	ReplicationSource,
	CustomerName1,
	notActual,
	SHZ,
	PolymirCostCode,
	tmpId,
	isPolymir,
	PolymirId,
	[Description],
	DirectionId,
	PurposeId
)

SELECT 
	
	sa.AgreementShortName+' '+case when DepartmentName LIKE 'иные' THEN sdg.ShortName+' '+DepartmentName ELSE DepartmentName END+' ['+sp.PurposeName+']',
	'20',
	1,
	NULL,
	NULL,
	sa.AgreementShortName+' '+case when DepartmentName LIKE 'иные' THEN sdg.ShortName+' '+DepartmentName ELSE DepartmentName END+' ['+sp.ShortName+']',
	0,
	sa.AgreementShortName,
	NULL,
	NULL,
	0,
	NULL,
	NULL,
	sd.DirectionId,
	sap.AgreementPurposeId
	
FROM ServiceDirection AS sd
LEFT JOIN ServiceDepartment AS d ON d.DepartmentId = sd.DepartmentId
LEFT JOIN ServiceDepartmentGroup AS sdg ON sdg.ServiceDepartmentGroupId = d.ServiceDepartmentGroupId
LEFT JOIN ServiceAgreement AS sa ON sa.AgreementId = sd.AgreementId
LEFT JOIN ServiceAgreementPurpose AS sap ON sap.AgreementId = sa.AgreementId
LEFT JOIN ServicePurpose AS sp ON sp.PurposeId = sap.PurposeId
WHERE sd.DirectionId IN (220,221,222)
