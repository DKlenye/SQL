

declare @start date, @end date
SELECT @start  = '01.01.2014', @end  = '31.12.2014'


	
DECLARE @rezult TABLE(waybillId int, cargoName VARCHAR(250), srcRoutePoint VARCHAR(250),dstRoutePoint VARCHAR(250), WEIGHT DECIMAL(18,3), TaskDate date)

SELECT 	distinct w.WaybillId
	INTO #temp_w
FROM Waybill w 
INNER JOIN Vehicle v ON v.VehicleId = w.VehicleId
INNER JOIN GroupRequest gr ON gr.GroupRequestId = v.GroupRequestId AND gr.GroupRequestId IN (18,19)
WHERE cast (w.ReturnDate AS Date) BETWEEN @start AND @end AND w.ScheduleId = 6


WHILE(SELECT COUNT(*) FROM #temp_w)<>0
BEGIN

	DECLARE @WaybillId INT
	SELECT TOP 1 @WaybillId = WaybillId FROM #temp_w
		
		SELECT 
			wt.TaskId,
			wt.WaybillId,
			wt.CargoName,
			wt.TaskDepartureDate,
			wt.Weight,
			rp1.RoutePointName srcRoutePoint,
			rp2.RoutePointName dstRoutePoint,
			wt.isLoad
		INTO #temp_wt
		FROM Waybill w
		INNER JOIN WaybillTask wt ON w.WaybillId = wt.WaybillId
		LEFT JOIN RoutePoint rp1 ON rp1.RoutePointId = wt.SrcRoutPoint
		LEFT JOIN RoutePoint rp2 ON rp2.RoutePointId = wt.DstRoutPoint
		WHERE w.WaybillId = @WaybillId AND wt.DstRoutPoint IS NOT null
		ORDER BY wt.TaskDepartureDate, wt.TaskId
		
	
		--SELECT * FROM #temp_wt
		
		DECLARE @i INT
		SET @i = 0;
		
		WHILE(SELECT COUNT(*)FROM #temp_wt)<>0
		BEGIN
			
			DECLARE  @_srcRoutePoint VARCHAR(250),@_dstRoutePoint VARCHAR(250), @_cargoName VARCHAR(250), @_weight DECIMAL (18,3), @_taskDate date
					
			DECLARE @TaskId INT, @srcRoutePoint VARCHAR(250),@dstRoutePoint VARCHAR(250), @cargoName VARCHAR(250), @weight DECIMAL (18,3), @taskDate date
			
			SELECT TOP 1 
				@TaskId = TaskId,
				@srcRoutePoint = srcRoutePoint,
				@dstRoutePoint = dstRoutePoint,
				@cargoName = cargoName,
				@weight = [WEIGHT],
				@taskDate = TaskDepartureDate
			FROM #temp_wt
			ORDER BY TaskId
						
			IF(isnull(@weight,0)!=0) 
				BEGIN
					
					IF(@i=0)
					BEGIN
						
						SET @_weight = @weight
						SET @_srcRoutePoint = @srcRoutePoint
						SET @_dstRoutePoint = @dstRoutePoint
						SET @_taskDate = @taskDate		
						
												        	
					END
					ELSE
					BEGIN
						
						IF(@_weight<>@weight)
						BEGIN
							INSERT INTO @rezult VALUES(@WaybillId ,@_cargoName, @_srcRoutePoint, @_dstRoutePoint, @_weight, @_taskDate)  
														               	
							SET @_weight = @weight
							SET @_srcRoutePoint = @srcRoutePoint
							SET @_dstRoutePoint = @dstRoutePoint
							SET @_taskDate = @taskDate          	
							               	
						END
						ELSE
							begin
							SET @_dstRoutePoint = @dstRoutePoint
							SET @_taskDate = @taskDate
							SET @i = @i+1;
						end	
					END
					
											
											
					SET @i = @i+1;
					
					if isnull(@_cargoName,'')='' SET @_cargoName = @cargoName
					
					     	
			    END				
			
			
			IF(SELECT COUNT(*) FROM #temp_wt)=1
					BEGIN
						INSERT INTO @rezult VALUES(@WaybillId ,@_cargoName, @_srcRoutePoint, @_dstRoutePoint, @_weight, (SELECT returnDate FROM Waybill WHERE WaybillId = @WaybillId))
					END
			
			DELETE FROM #temp_wt WHERE TaskId = @TaskId
		END
		
		
		SET @_cargoName = NULL;
		
	DROP TABLE #temp_wt
	DELETE FROM #temp_w WHERE WaybillId = @WaybillId
END

drop table #temp_w


SELECT 
	r.*,
	w.DepartureDate,
	v.Model,
	v.GarageNumber,
	v.RegistrationNumber
FROM @rezult r
LEFT JOIN Waybill w ON w.WaybillId = r.waybillId
LEFT JOIN Vehicle v ON v.VehicleId = w.VehicleId
ORDER BY v.GarageNumber, w.DepartureDate


