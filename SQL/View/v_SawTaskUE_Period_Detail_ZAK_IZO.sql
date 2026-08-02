if object_id(N'dbo.v_SawTaskUE_Period_Detail_ZAK_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Detail_ZAK_IZO
go

create view dbo.v_SawTaskUE_Period_Detail_ZAK_IZO
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
    idSectorManufact
  from SheduleOperator
  group by idPlanCalendar, idOperator, idSectorManufact
),

BrigadierScheduleCandidate as
(
  select distinct
    SO.ID as idSheduleOperator,
    SO.idPlanCalendar,
    SO.idOperator as idOperatorBrigadier,
    OG.idSectorManufact,

    case
      when SO.idSectorManufact = OG.idSectorManufact then 0
      when SO.idSectorManufact is null then 1
      else 2
    end as Priority

  from SheduleOperator SO
  inner join OperatorGroup OG on OG.idOperatorBrigadier = SO.idOperator

  where SO.idSectorManufact = OG.idSectorManufact
     or SO.idSectorManufact is null
),

BrigadierScheduleRanked as
(
  select
    idSheduleOperator,
    idPlanCalendar,
    idOperatorBrigadier,
    idSectorManufact,

    row_number() over
    (
      partition by idPlanCalendar, idSectorManufact
      order by Priority, idSheduleOperator desc
    ) as RowNum

  from BrigadierScheduleCandidate
),

ZakOperation as
(
  select
    idProject,
    nGlass,
    nGlassTriplex,
    idProd
  from ProjectItem
  where isnull(nTypeOper, 0) = 2
    and nType = 8
),

GlassBase as
(
  select
    GD.ID as idGlassDetails,
    GD.idGlass,
    GD.idProject,
    GD.idProjectItem,
    GD.idSawTaskMain,
    GD.Width,
    GD.Height,

    GP.idSectorManufact,
    GP.idSheduleOperator as idSheduleOperatorSource,
    GP.TimeMarkManufact,

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

  where SM.nType = 3
    and GP.TimeMarkManufact is not null
),

ResolvedBase as
(
  select
    GB.idGlassDetails,
    GB.idGlass,
    GB.idProject,
    GB.idProjectItem,
    GB.idSawTaskMain,
    GB.Width,
    GB.Height,
    GB.idSectorManufact,
    GB.TimeMarkManufact,

    CalendarResolved.idPlanCalendar,
    GB.DateComplete,
    GB.nSmena,

    ResolvedOperator.idOperatorBrigadier,

    coalesce
    (
      ResolvedSOExact.ID,
      ResolvedSONull.ID,

      case
        when SourceSO.idOperator = ResolvedOperator.idOperatorBrigadier then
          SourceSO.ID
      end,

      BS.idSheduleOperator
    ) as idSheduleOperatorBrigadier,

    case
      when OM.idOperatorBrigadier = SourceSO.idOperator then 1
      when OM.idOperatorBrigadier is not null then 2
      when SourceSO.ID is null
       and BS.idOperatorBrigadier is not null then 3
      when SourceSO.ID is not null then 4
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

  left join OperatorMap OM
    on OM.idOperator = SourceSO.idOperator
   and OM.idSectorManufact = GB.idSectorManufact

  left join BrigadierScheduleRanked BS
    on BS.idPlanCalendar = CalendarResolved.idPlanCalendar
   and BS.idSectorManufact = GB.idSectorManufact
   and BS.RowNum = 1

  cross apply
  (
    select
      case
        when OM.idOperatorBrigadier is not null then
          OM.idOperatorBrigadier

        when SourceSO.ID is not null then
          SourceSO.idOperator

        else
          BS.idOperatorBrigadier
      end as idOperatorBrigadier
  ) ResolvedOperator

  left join SheduleOperatorOne ResolvedSOExact
    on ResolvedSOExact.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSOExact.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSOExact.idSectorManufact = GB.idSectorManufact

  left join SheduleOperatorOne ResolvedSONull
    on ResolvedSONull.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSONull.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSONull.idSectorManufact is null
)

select
  Task.ID as idTask,
  Task.AccountNum,

  SawTaskMain.ID as idSawTask,
  SawTaskMain.Name as SawTaskName,

  RB.DateComplete,
  RB.nSmena,
  RB.idPlanCalendar,

  Product.ID as idGlass,
  Product.Name as GlassName,

  FinalSO.ID as idSheduleOperatorBrigadier,
  RB.idOperatorBrigadier,
  FinalSO.idTeam,
  RB.BrigadierResolveType,

  case
    when isnull(GlassWorkAdd.dCoefUZM, 0) = 0 then
      Product.dCoefUZM
    else
      GlassWorkAdd.dCoefUZM
  end as dCoefUZM,

  count(1) as nCountDetails,

  cast
  (
    sum(1.0 * RB.Width * RB.Height) / 1000000.0
    as decimal(18, 6)
  ) as SumArea,

  cast
  (
    sum
    (
      1.0 * RB.Width * RB.Height / 1000000.0 *
      case
        when isnull(GlassWorkAdd.dCoefUZM, 0) = 0 then
          Product.dCoefUZM
        else
          GlassWorkAdd.dCoefUZM
      end
    )
    as decimal(18, 6)
  ) as SumAreaUZM

from ResolvedBase RB
inner join Product on Product.ID = RB.idGlass
inner join SawTaskMain on SawTaskMain.ID = RB.idSawTaskMain
inner join Project on Project.ID = RB.idProject
inner join Task on Task.ID = Project.idTask

inner join ProjectItem
  on ProjectItem.ID = RB.idProjectItem

inner join ZakOperation ZAK
  on ZAK.idProject = ProjectItem.idProject
 and ZAK.nGlass = ProjectItem.nGlass
 and ZAK.nGlassTriplex = ProjectItem.nGlassTriplex

left join GlassWorkAdd
  on GlassWorkAdd.idProduct_Glass = Product.ID
 and GlassWorkAdd.idProduct_Work = ZAK.idProd

left join SheduleOperator FinalSO
  on FinalSO.ID = RB.idSheduleOperatorBrigadier

where isnull(Product.dCoefUZM, 0) > 0

group by
  Task.ID,
  Task.AccountNum,

  SawTaskMain.ID,
  SawTaskMain.Name,

  RB.DateComplete,
  RB.nSmena,
  RB.idPlanCalendar,

  Product.ID,
  Product.Name,
  Product.dCoefUZM,
  GlassWorkAdd.dCoefUZM,

  FinalSO.ID,
  FinalSO.idTeam,
  RB.idOperatorBrigadier,
  RB.BrigadierResolveType
go