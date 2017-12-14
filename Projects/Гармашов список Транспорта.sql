SELECT
    v.VehicleId Код,   
    d.DepartmentName [Цех/Производство],   
    tc.ColumnName Колонна,   
    v.Model Марка,  
    v.GarageNumber [Гар.№],  
    v.RegistrationNumber [Гос.№],  
    v.InventoryNumber [Инв.№],  
    v.MakeYear [Год выпуска],   
    v.ServiceDocNumber [№ тех.паспорта],   
    rg2.RefuellingGroupName [Группа по заправке(старая)],   
    gan.GroupAccName [Группа по бухгалтерии(2)],   
    v.InputDate [Дата ввода в эксплуатацию],   
    v.NotUsedDate [Дата вывода из эксплуатации],   
    v.WriteOffDate [Дата списания],   
    v.BodyNumber [Номер кузова],   
    bt.BodyTypeName [Тип ТС],   
    v.Width [Ширина],   
    v.Length [Длина],   
    v.Height [Высота],   
    v.RegSertificate [Св-во о регистрации],   
    v.RegEnd [Срок действия св-ва о рег-ции],   
    v.SelfMass [Масса без нагрузки, кг],   
    v.FullMass [Полная масса, кг],   
    v.CapacityTonns [Грузоподъёмность, т],   
    v.CapacityPassengers [Вместимость пассажиров],   
    t.GarageNumber [Гар.№ прицепа],   
    t.model [Марка прицепа],   
    et.EngineTypeName [Тип двигателя],   
    ec.EcologyClassName [Экологический класс],   
    v.EngineModel [Модель двигателя],   
    v.EngineNumber [№ двигателя],   
    v.EngineVolume [Объём двигателя],   
    v.EnginePower [Мощность двигателя, квт],   
    v.FuelVolume [Объём топливного бака],   
    v.CoolantVolume [Оъём охл. жидкости],   
    v.EngineOilVolume [Объём моторного масла],  
     v.Disposal [В чъё распоряжение],   
     ag.AccGroupName [Группа по бухгалтерии],   
     gr.GroupRequestName [Группа по разнарядке],   
     sg.ServiceGroupName [Группа по услугам],   
     rg.ReportGroupName [Группа для отчётов],   
     tt.TransmissionTypeName [Тип КПП] ,
     i.DateOfTerm as[Срок действия страховки],
     i.InsuranceNumber AS [№ страховки],
     insp.DateOfTerm AS [Срок действия тех.осмотра]
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



