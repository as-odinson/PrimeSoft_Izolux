if object_id(N'dbo.v_OperatorBrigadierMap', N'V') is not null
  drop view dbo.v_OperatorBrigadierMap
go

create view dbo.v_OperatorBrigadierMap
as

-- Сам бригадир
select
  OG.idOperatorBrigadier as idOperator,
  OG.idOperatorBrigadier,
  OG.ID as idOperatorGroup,
  OG.idSectorManufact,
  cast(1 as bit) as bBrigadier
from OperatorGroup OG

union all

-- Подчинённые
select
  OGI.idOperator,
  OG.idOperatorBrigadier,
  OG.ID as idOperatorGroup,
  OG.idSectorManufact,
  cast(0 as bit) as bBrigadier
from OperatorGroupItem OGI
inner join OperatorGroup OG on OG.ID = OGI.idOperatorGroup
where OGI.idOperator <> OG.idOperatorBrigadier
go