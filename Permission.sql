SELECT 
	'grant '+PermissionName+' on '+ObjectName+' to ['+UserName+']'
FROM (
	SELECT
		OBJECT_NAME(major_id) ObjectName, USER_NAME(grantee_principal_id) AS UserName, permission_name AS PermissionName
	FROM
		sys.database_permissions p
	WHERE
		p.class = 1 AND
		OBJECTPROPERTY(major_id, 'IsMSSHipped') = 0
)a
ORDER BY a.UserName
