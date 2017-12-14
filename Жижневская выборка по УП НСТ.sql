declare    @start DATE, @end DATE
SELECT @start = '01.02.2016', @end = '01.03.2016'

SELECT 
	b.WaybillId,
	b.DepartureDate,
	b.ReturnDate,
	b.Way,
	b.CustomerId,
	b.ReplicationId,
	c.CustomerName,
	b.KM,
	b.Pass,
	b.[Weight],
	wcwt.Minutes,
	(swi.mkm+swi.mhour) as ServiceSumm,
	dc.RequestId,
	rt.RequestTypeName,
	v.GarageNumber,
	v.RegistrationNumber,
	v.Model,
	v.CapacityPassengers,
	v.CapacityTonns,
	sg.ServiceGroupName,
	rp.TripPurpose AS Purpose,
	dbo.[WaybillInvoiceNumberToString](b.WaybillId) AS Number,
	dbo.[WaybillInvoiceDateToString](b.WaybillId) AS [Date],
	CASE WHEN rc.RequestId IS NOT NULL THEN 'Грузовой' ELSE (CASE WHEN rp.RequestId IS NOT NULL THEN 'Пассажирский' ELSE (CASE WHEN rf.RequestId IS NOT NULL THEN 'Кран' ELSE '' end ) end ) END Request_type
FROM (
	SELECT 
		WaybillId,
		DepartureDate,
		ReturnDate,
		Way,
		CustomerId,
		ReplicationId,
		SUM(km) AS KM,
		SUM(passengers) AS Pass,
		SUM(weight) AS [Weight]
	FROM (
		SELECT 
			w.WaybillId,
			w.DepartureDate,
			w.ReturnDate,
			case when w.ScheduleId = 6 THEN w.Way ELSE '' END Way,
			CASE WHEN wt2.WorkUnitId = 1 THEN isnull(wt.WorkAmount,0) ELSE 0 END AS KM,
			isnull(wt.Passengers,0) Passengers,
			CASE WHEN wt.isLoad=1 THEN isnull(wt.[Weight],0) ELSE 0 end Weight,
			wt.CustomerId,
			c.ReplicationId
		FROM Waybill w
		INNER JOIN WaybillTask AS wt ON wt.WaybillId = w.WaybillId
		INNER JOIN Customer AS c ON c.CustomerId = wt.CustomerId 
		INNER JOIN _Norm AS n ON n.NormId = wt.NormConsumptionId
		INNER JOIN WorkType AS wt2 ON wt2.WorkTypeId = n.WorkTypeId
		WHERE 
			w.WaybillState = 2 AND
			c.SHZ IN ('Д1','Д2','Д3','Д4') AND
			w.ReturnDate BETWEEN @start AND @end
	)a
	GROUP BY WaybillId,	DepartureDate,	ReturnDate,	Way, CustomerId, ReplicationId
)b 
LEFT JOIN Waybill w ON w.WaybillId = b.WaybillId
LEFT JOIN WaybillCustomerWorkingTime AS wcwt ON wcwt.WaybillId = b.WaybillId AND b.CustomerId = wcwt.CustomerId
LEFT JOIN _ServiceWaybillsInfo AS swi ON swi.waybillNumber = b.WaybillId AND swi.customerId = b.ReplicationId
LEFT JOIN DistributionListWaybills AS dlw ON dlw.WaybillId = b.WaybillId
LEFT JOIN DistributionListDetails AS dld  ON dld.ListDetailId = dlw.ListDetailId
LEFT JOIN DistributionCustomers AS dc ON dc.ListDetailId = dld.ListDetailId
LEFT JOIN Request AS r ON r.RequestId = dc.RequestId
LEFT JOIN Vehicle AS v ON v.VehicleId = w.VehicleId
LEFT JOIN ServiceGroup AS sg ON sg.ServiceGroupId = v.ServiceGroupId
LEFT JOIN RequestPassengers AS rp ON rp.RequestId = r.RequestId
LEFT JOIN RequestFreight AS rf ON rf.RequestId = r.RequestId
LEFT JOIN RequestCrane AS rc ON rc.RequestId = r.RequestId
LEFT JOIN Customer AS c ON c.CustomerId = b.CustomerId
LEFT JOIN RequestType AS rt ON rt.RequestTypeId = r.RequestTypeId
ORDER BY v.GarageNumber