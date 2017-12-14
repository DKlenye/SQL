


declare @tmpTable table(
	[DatPrihRash] datetime,
    [InvNomer] varchar(8),
    [FioDriver] varchar(30),
    [id_men] int,
    [kolfakt] numeric(14,4),
    [cenRasch] numeric(19,4),
    [KEdIzm] varchar(6),
    [kmc] varchar(30),
    [NaimMc] varchar(100),
    [marka] varchar(20),
    [tehhar] varchar(30),
    [massamc] numeric(9,3),
    [nomenklnom] int,
    [koef_peresch_to] numeric(14,6),
    [idsklspec] int
)
insert into @tmpTable
exec mcToCar_Get '01.07.2013','01.08.2013'

select * from @tmpTable where kmc like '%¿ ”Ã%' or kmc like '%¿  ”Ã%'

