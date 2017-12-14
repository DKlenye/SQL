

DECLARE @tireMovings TABLE (TireMovingId int)

INSERT INTO @tireMovings
SELECT 2309
UNION select 2310

WHILE (SELECT COUNT(*) FROM @tireMovings)>0
BEGIN
	
			DECLARE @tireMovingId INT
			SELECT TOP 1 @tireMovingId = TireMovingId FROM @tireMovings
			
			DECLARE @TireId INT, @InstallDate date

		SELECT 
			@TireId = tireId, 
			@InstallDate = InstallDate 
		FROM TireMoving tm WHERE tm.TireMovingId = @tireMovingId

		declare @table table(ORDER_ID int, m INT, y INT,TireMovingId INT,VehicleId INT, InstallDate date, RemoveDate date,  work decimal(18,3), sumWork DECIMAL(18,3), isHanded bit)
		insert into @table
		EXECUTE VehicleTireWork_Select @tireId=@tireId

		DECLARE @beforeWork TABLE(TireMovingId INT, VehicleId INT, InstallDate Date, RemoveDate Date, Work INT, SumWork int)
		INSERT INTO @beforeWork
		SELECT TireMovingId,VehicleId,InstallDate,RemoveDate, SUM(work) WORK, MAX(sumWork) sumWork FROM @table WHERE InstallDate<@InstallDate
		GROUP BY TireMovingId,VehicleId,InstallDate,RemoveDate


		DELETE FROM @table WHERE TireMovingId <> @tireMovingId

		DECLARE @card TABLE(
			TireMovingId INT,
			VehicleId int,
			InstallDate Date,
			RemoveDate Date,
			Work INT,
			SumWork INT,
			TechState VARCHAR(50),
			RemoveReasonName VARCHAR(50)	
		)
		
		WHILE ((SELECT COUNT(*) FROM @beforeWork)>0)
		BEGIN	
			
			DECLARE @BeforeTireMovingId INT
			SELECT TOP 1 @BeforeTireMovingId = TireMovingId FROM @beforeWork ORDER BY InstallDate
				
			INSERT INTO @card 		
			SELECT 
				@tireMovingId,
				m.VehicleId,
				m.InstallDate,
				m.RemoveDate,
				m.Work,
				m.SumWork,
				'',
				trr.TireRemoveReasonName
			FROM @beforeWork m
			LEFT JOIN TireMoving tm ON tm.TireMovingId = m.TireMovingId
			LEFT JOIN TireRemoveReason trr ON trr.TireRemoveReasonId = tm.TireRemoveReasonId
			WHERE m.TireMovingId = @BeforeTireMovingId
			
		END

		DELETE FROM @beforeWork WHERE TireMovingId = @BeforeTireMovingId

		WHILE (SELECT COUNT(*) FROM @table )>0
		BEGIN
			
			DECLARE @orderId INT
			SELECT TOP 1 @orderId = ORDER_ID FROM @table
			
			INSERT INTO @card
			
			select 
				@tireMovingId,
				t.VehicleId,
				t.InstallDate,
				t.RemoveDate,
				t.Work,
				t.sumWork,
				'',
				''
			FROM @table  t 
			WHERE t.ORDER_ID = @orderId
			
			DELETE FROM @table WHERE ORDER_ID = @orderId	
		END	
	
	DELETE FROM @tireMovings WHERE TireMovingId = @tireMovingId
END


SELECT 
	v2.Model+' '+v2.RegistrationNumber vehicle,
	c.*,
	tc.*,
	t.Size,
	ISNULL(t.KmNorm,t.MonthNorm) Norm,
	CASE WHEN t.KmNorm IS null THEN 'לוס.' ELSE 'עûס.ךל' END Unit,
	t.FactoryNumber,
	t.Cost,
	tmd.TireModelName,
	tm2.TireMakerName
FROM @card c
LEFT JOIN TireMoving tm ON tm.TireMovingId = c.TireMovingId
LEFT JOIN Vehicle v ON tm.VehicleId = v.VehicleId
LEFT JOIN Vehicle v2 ON v2.VehicleId = c.VehicleId
LEFT JOIN Tire t ON t.TireId = tm.TireId
LEFT JOIN TireModel tmd ON tmd.TireModelId = t.TireModelId
LEFT JOIN TireMaker tm2 ON tm2.TireMakerId = t.TireMakerId
LEFT JOIN (

	SELECT 
		a.ColumnId,
		e1.Office Office1,
		e1.Fio Fio1,
		e2.Office Office2,
		e2.Fio Fio2,
		e3.Office Office3,
		e3.Fio Fio3
	FROM (
		SELECT  ColumnId, [1] AS Num1, [2] AS Num2, [3] AS Num3
		from
		(
		  SELECT *
		  from BatteryComission 
		) d
		pivot
		(
		  max(EmployeeId)
		  for Num in ([1],[2],[3])
		) piv
	)a
	LEFT JOIN v_Employee e1 ON e1.EmployeeId = a.Num1
	LEFT JOIN v_Employee e2 ON e2.EmployeeId = a.Num2
	LEFT JOIN v_Employee e3 ON e3.EmployeeId = a.Num3
)tc ON tc.ColumnId = ISNULL(v.ColumnId,5)