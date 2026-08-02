if object_id(N'dbo.v_SawTaskUE_Period_Detail_Assembly_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Detail_Assembly_IZO
go

create view dbo.v_SawTaskUE_Period_Detail_Assembly_IZO
as

with OperatorMap as
(
  select
    idOperator,
    idSectorManufact,
    min(idOperatorBrigadier) as idOperatorBrigadier
  from dbo.v_OperatorBrigadierMap
  group by idOperator, idSectorManufact
  having count(distinct idOperatorBrigadier) = 1
),

PlanCalendarOne as
(
  select
    max(ID) as ID,
    Data,
    nSmena
  from PlanCalendar
  where nSmena in (1, 2)
  group by Data, nSmena
),

SheduleOperatorOne as
(
  select
    max(ID) as ID,
    idPlanCalendar,
    idOperator,
    idSectorManufact,
    idTeam
  from SheduleOperator
  group by
    idPlanCalendar,
    idOperator,
    idSectorManufact,
    idTeam
),

BrigadierScheduleCandidate as
(
  select
    SO.ID as idSheduleOperator,
    SO.idPlanCalendar,
    SO.idTeam,
    SO.idOperator as idOperatorBrigadier,

    case
      when exists
      (
        select 1
        from ShedulePersonnel SP
        where SP.idSheduleOperator = SO.ID
      ) then 0
      else 1
    end as PersonnelPriority

  from SheduleOperator SO
  where isnull(SO.idTeam, 0) <> 0
    and exists
    (
      select 1
      from OperatorGroup OG
      where OG.idOperatorBrigadier = SO.idOperator
    )
),

BrigadierScheduleRanked as
(
  select
    idSheduleOperator,
    idPlanCalendar,
    idTeam,
    idOperatorBrigadier,

    row_number() over
    (
      partition by idPlanCalendar, idTeam
      order by PersonnelPriority, idSheduleOperator desc
    ) as RowNum

  from BrigadierScheduleCandidate
),

GlassBase as
(
  select
    GD.ID as idGlassDetails,
    GD.idGlass,
    GD.idProject,

    coalesce
    (
      nullif(GD.idSawTaskMain, 0),
      nullif(GP.idSawTaskMain, 0)
    ) as idSawTaskMain,

    GD.Width,
    GD.Height,

    GP.idSectorManufact,
    GP.idSawLimit,
    GP.idSheduleOperator as idSheduleOperatorSource,
    GP.TimeMarkManufact,

    STM.idTeam,
    STM.idAssemblyLine,

    case
      when datepart(hour, GP.TimeMarkManufact) < 8 then
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact) - 1, 0)
      else
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact), 0)
    end as DateComplete,

    case
      when datepart(hour, GP.TimeMarkManufact) >= 8
       and datepart(hour, GP.TimeMarkManufact) < 20 then 1
      else 2
    end as nSmena

  from GlassDetails GD
  inner join GlassProcessing GP on GP.idGlassDetails = GD.ID
  inner join SectorManufact SM on SM.ID = GP.idSectorManufact

  inner join SawTaskMain STM
    on STM.ID = coalesce
    (
      nullif(GD.idSawTaskMain, 0),
      nullif(GP.idSawTaskMain, 0)
    )

  where SM.nType = 2
    and GP.TimeMarkManufact is not null
),

ResolvedBase as
(
  select
    GB.idGlassDetails,
    GB.idGlass,
    GB.idProject,
    GB.idSawTaskMain,
    GB.Width,
    GB.Height,

    GB.idSectorManufact,
    GB.idSawLimit,
    GB.TimeMarkManufact,

    CalendarResolved.idPlanCalendar,
    TeamResolved.idTeam,
    GB.idAssemblyLine,

    GB.DateComplete,
    GB.nSmena,

    ResolvedOperator.idOperatorBrigadier,

    coalesce
    (
      BS.idSheduleOperator,
      ResolvedSOExact.ID,
      ResolvedSONull.ID,

      case
        when SourceValid.bValid = 1
         and SourceSO.idOperator = ResolvedOperator.idOperatorBrigadier then
          SourceSO.ID
      end
    ) as idSheduleOperatorBrigadier,

    case
      when SourceValid.bValid = 1
       and SourceSO.idOperator = ResolvedOperator.idOperatorBrigadier then 1

      when SourceValid.bValid = 1
       and OM.idOperatorBrigadier is not null then 2

      when BS.idOperatorBrigadier is not null then 3

      else 0
    end as BrigadierResolveType

  from GlassBase GB

  left join SheduleOperator SourceSO
    on SourceSO.ID = nullif(GB.idSheduleOperatorSource, 0)

  left join PlanCalendarOne PC
    on PC.Data = GB.DateComplete
   and PC.nSmena = GB.nSmena

  cross apply
  (
    select
      coalesce(PC.ID, SourceSO.idPlanCalendar) as idPlanCalendar
  ) CalendarResolved

  cross apply
  (
    select
      coalesce
      (
        nullif(GB.idTeam, 0),
        nullif(SourceSO.idTeam, 0)
      ) as idTeam
  ) TeamResolved

  cross apply
  (
    select
      case
        when SourceSO.ID is not null
         and nullif(SourceSO.idTeam, 0) = TeamResolved.idTeam then 1
        else 0
      end as bValid
  ) SourceValid

  left join OperatorMap OM
    on OM.idOperator = SourceSO.idOperator
   and OM.idSectorManufact = GB.idSectorManufact
   and SourceValid.bValid = 1

  left join BrigadierScheduleRanked BS
    on BS.idPlanCalendar = CalendarResolved.idPlanCalendar
   and BS.idTeam = TeamResolved.idTeam
   and BS.RowNum = 1

  cross apply
  (
    select
      case
        when SourceValid.bValid = 1
         and OM.idOperatorBrigadier is not null then
          OM.idOperatorBrigadier

        when BS.idOperatorBrigadier is not null then
          BS.idOperatorBrigadier

        when SourceValid.bValid = 1
         and exists
         (
           select 1
           from OperatorGroup OG
           where OG.idOperatorBrigadier = SourceSO.idOperator
         ) then
          SourceSO.idOperator

        else null
      end as idOperatorBrigadier
  ) ResolvedOperator

  left join SheduleOperatorOne ResolvedSOExact
    on ResolvedSOExact.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSOExact.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSOExact.idSectorManufact = GB.idSectorManufact
   and ResolvedSOExact.idTeam = TeamResolved.idTeam

  left join SheduleOperatorOne ResolvedSONull
    on ResolvedSONull.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSONull.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSONull.idSectorManufact is null
   and ResolvedSONull.idTeam = TeamResolved.idTeam
)

select
  Task.ID as idTask,
  Task.AccountNum,

  SawTaskMain.ID as idSawTask,
  SawTaskMain.Name as SawTaskName,

  RB.idTeam,
  RB.idAssemblyLine,

  RB.DateComplete,
  RB.nSmena,
  RB.idPlanCalendar,

  Product.ID as idGlass,
  Product.Name as GlassName,

  FinalSO.ID as idSheduleOperatorBrigadier,
  RB.idOperatorBrigadier,
  RB.BrigadierResolveType,

  count(1) as nCountDetails,
  Project.GPName,

  cast
  (
    sum(dbo.f_GetUE_ForAssemblyPlastica(Project.ID))
    as decimal(18, 6)
  ) as SumUE

from ResolvedBase RB
inner join Product on Product.ID = RB.idGlass
inner join SawTaskMain on SawTaskMain.ID = RB.idSawTaskMain
inner join Project on Project.ID = RB.idProject
inner join Task on Task.ID = Project.idTask

left join SheduleOperator FinalSO
  on FinalSO.ID = RB.idSheduleOperatorBrigadier

group by
  Task.ID, Task.AccountNum,
  SawTaskMain.ID, SawTaskMain.Name,

  RB.idTeam,
  RB.idAssemblyLine,

  RB.DateComplete,
  RB.nSmena,
  RB.idPlanCalendar,

  Product.ID,
  Product.Name,

  FinalSO.ID,
  RB.idOperatorBrigadier,
  RB.BrigadierResolveType,

  Project.GPName
go