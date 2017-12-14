SELECT * FROM WaybillWork

INSERT INTO WaybillWork
select  
	w.nput,
	w.ret_data,
	ret_km-out_km pr,
	w.ret_moto mh,
	0,
	fuelnorma,
	w.out_fuel+fuelgive-ret_fuel fact,
	v.VehicleId,
	3
from DBSRV2_putlist w
LEFT JOIN WaybillWork ww ON ww.ReplicationSource = 2 AND ww.WaybillId = w.nput
inner JOIN Vehicle v ON v.OwnerId = 1 AND v.GarageNumber = w.garnom
WHERE ww.WaybillId IS null