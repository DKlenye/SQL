
INSERT INTO WaybillWork
SELECT	
	npl,
	d_voz,
	sum(prob),
	sum(case when prob = 0 then chas ELSE 0 END) chas,
	SUM((case when prob = 0 then chas ELSE 0 END)* 0.7) moto,
	sum(rgn), 
	sum(rgf),
	v.VehicleId,
	1
FROM _PolymirWaybill 
inner JOIN Vehicle v ON v.OwnerId = 1 AND v.GarageNumber = 20000+gar_n
WHERE rep<201303 AND gar_n<>0
GROUP BY npl,	d_voz,v.VehicleId

delete FROM waybillwork WHERE WaybillId = 654963 AND replicationSource = 1



INSERT INTO WaybillWork
SELECT	
	npl,
	d_voz,
	sum(prob),
	0,
	0,
	0, 
	0,
	v.VehicleId,
	1
FROM _PolymirWaybill 
inner JOIN Vehicle v ON v.OwnerId = 1 AND v.GarageNumber = 20000+gar_np
WHERE rep<201303 AND gar_np<>0 
GROUP BY npl,	d_voz,v.VehicleId

