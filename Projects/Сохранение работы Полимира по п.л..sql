SELECT 
	w.WaybillId,
	COUNT(a.prob)
FROM (
	SELECT 
		npl,
		gar_n,
		fr,
		max(d_voz) d_voz,
		sum(prob) prob,
		sum(chas2-chas1) chas1,
		sum(chas2-chas1) chas,
		sum(rgn) rgn,
		sum(rgf) rgf
	FROM _PolymirWaybill 
	WHERE zimaleto<>0 AND d_voz<'01.03.2013' AND gar_n not in (242,0) AND gar_n < 1000
	GROUP BY npl,gar_n,fr
)a
LEFT JOIN Waybill w ON RTRIM(LTRIM(a.npl))+'_'+ RTRIM(LTRIM(a.fr))=RTRIM(LTRIM(w.ReplicationId)) AND w.ReplicationSource = 2 AND a.d_voz<=w.ReturnDate
WHERE w.WaybillId IS NOT NULL AND w.WaybillId <> 493353
GROUP BY w.WaybillId



INSERT into WaybillWork 
SELECT 
	w.WaybillId,
	d_voz,a.prob,a.chas1,a.chas,a.rgn,a.rgf,
	w.VehicleId
FROM (
	SELECT 
		npl,
		gar_n,
		fr,
		max(d_voz) d_voz,
		sum(prob) prob,
		sum(chas2-chas1) chas1,
		sum(chas2-chas1) chas,
		sum(rgn) rgn,
		sum(rgf) rgf
	FROM _PolymirWaybill 
	WHERE zimaleto<>0 AND d_voz<'01.03.2013' AND gar_n not in (242,0) AND gar_n < 1000
	GROUP BY npl,gar_n,fr
)a
LEFT JOIN Waybill w ON RTRIM(LTRIM(a.npl))+'_'+ RTRIM(LTRIM(a.fr))=RTRIM(LTRIM(w.ReplicationId)) AND w.ReplicationSource = 2 AND a.d_voz<=w.ReturnDate
WHERE w.WaybillId IS NOT NULL AND w.WaybillId <> 493353