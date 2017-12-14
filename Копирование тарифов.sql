
insert into ServicePeriod
select 2016,02


insert into ServiceTariff
select 
	periodYear,
	2,
	version,
	serviceGroupId,
	hourTariff,
	kmTariff,
	tonneKmTariff,
	SummaTariff,
	taxRate
from ServiceTariff where PeriodYear = 2016 and periodMonth = 01

insert into serviceVersion
select 
	periodYear,
	2,
	version
from serviceVersion  where PeriodYear = 2016 and periodMonth = 01

select * from ServiceTariff where PeriodYear = 2016 and periodMonth = 02
select * from serviceVersion where PeriodYear = 2016 and periodMonth = 02