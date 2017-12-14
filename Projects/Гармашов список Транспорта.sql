SELECT
    v.VehicleId ���,   
    d.DepartmentName [���/������������],   
    tc.ColumnName �������,   
    v.Model �����,  
    v.GarageNumber [���.�],  
    v.RegistrationNumber [���.�],  
    v.InventoryNumber [���.�],  
    v.MakeYear [��� �������],   
    v.ServiceDocNumber [� ���.��������],   
    rg2.RefuellingGroupName [������ �� ��������(������)],   
    gan.GroupAccName [������ �� �����������(2)],   
    v.InputDate [���� ����� � ������������],   
    v.NotUsedDate [���� ������ �� ������������],   
    v.WriteOffDate [���� ��������],   
    v.BodyNumber [����� ������],   
    bt.BodyTypeName [��� ��],   
    v.Width [������],   
    v.Length [�����],   
    v.Height [������],   
    v.RegSertificate [��-�� � �����������],   
    v.RegEnd [���� �������� ��-�� � ���-���],   
    v.SelfMass [����� ��� ��������, ��],   
    v.FullMass [������ �����, ��],   
    v.CapacityTonns [����������������, �],   
    v.CapacityPassengers [����������� ����������],   
    t.GarageNumber [���.� �������],   
    t.model [����� �������],   
    et.EngineTypeName [��� ���������],   
    ec.EcologyClassName [������������� �����],   
    v.EngineModel [������ ���������],   
    v.EngineNumber [� ���������],   
    v.EngineVolume [����� ���������],   
    v.EnginePower [�������� ���������, ���],   
    v.FuelVolume [����� ���������� ����],   
    v.CoolantVolume [���� ���. ��������],   
    v.EngineOilVolume [����� ��������� �����],  
     v.Disposal [� ��� ������������],   
     ag.AccGroupName [������ �� �����������],   
     gr.GroupRequestName [������ �� ����������],   
     sg.ServiceGroupName [������ �� �������],   
     rg.ReportGroupName [������ ��� �������],   
     tt.TransmissionTypeName [��� ���] ,
     i.DateOfTerm as[���� �������� ���������],
     i.InsuranceNumber AS [� ���������],
     insp.DateOfTerm AS [���� �������� ���.�������]
FROM Vehicle v  
LEFT JOIN EcologyClass ec ON ec.EcologyClassId = v.EcologyClassId  
LEFT JOIN EngineType et ON et.EngineTypeId = v.EngineTypeId  
LEFT JOIN Department d ON d.DepartmentId = v.DepartmentId  
LEFT JOIN TransportColumn tc ON tc.ColumnId = ISNULL(v.ColumnId,5)  
LEFT JOIN GroupAcc ga ON ga.GroupAccId = v.GroupAccId  
LEFT JOIN BodyType bt ON bt.BodyTypeId = v.BodyTypeId  
LEFT JOIN Vehicle t ON t.VehicleId = v.TrailerId  
LEFT JOIN WaybillType wt ON wt.WaybillTypeId = v.WaybillTypeId  
LEFT JOIN AccGroup ag ON ag.AccGroupId = v.AccGroupId  
LEFT JOIN GroupRequest gr ON gr.GroupRequestId = v.GroupRequestId  
LEFT JOIN TransmissionType tt ON tt.TransmissionTypeId = v.TransmissionTypeId  
LEFT JOIN ServiceGroup sg ON sg.ServiceGroupId = v.ServiceGroupId  
LEFT JOIN ReportGroup rg ON rg.ReportGroupId = v.ReportGroupId  
LEFT JOIN RefuellingGroup rg2 ON rg2.RefuellingGroupId = v.RefuellingGroupId  
LEFT JOIN GroupAcc_New gan ON gan.GroupAccId = v.AccGroupNewId  
LEFT JOIN (
SELECT MAX(i.DateOfTerm) DateOfTerm, VehicleId FROM Insurance i
GROUP BY i.VehicleId	
) ins on ins.VehicleId = v.VehicleId
LEFT JOIN (
SELECT MAX(i.DateOfTerm) DateOfTerm, VehicleId FROM Inspection i
GROUP BY i.VehicleId	
) insp on insp.VehicleId = v.VehicleId

LEFT JOIN Insurance i ON i.DateOfTerm = ins.DateOfTerm AND ins.VehicleId = i.VehicleId
WHERE v.OwnerId = 1 AND v.dsc = 1



