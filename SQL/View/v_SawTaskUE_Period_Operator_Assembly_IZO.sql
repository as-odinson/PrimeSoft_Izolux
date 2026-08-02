if object_id(N'dbo.v_SawTaskUE_Period_Operator_Assembly_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Operator_Assembly_IZO
go

create view dbo.v_SawTaskUE_Period_Operator_Assembly_IZO
as

with PlanCalendarOne as
(
  select
    max(ID) as ID,
    Data,
    nSmena
  from PlanCalendar
  where nSmena in (1, 2)
  group by Data, nSmena
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
    GP.idSheduleOperator as idSheduleOperatorSource,
    GP.TimeMarkManufact,

    STM.idTeam,

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
    GB.TimeMarkManufact,

    CalendarResolved.idPlanCalendar,
    TeamResolved.idTeam,

    case
      when TeamResolved.idTeam = 1 then 1
      when TeamResolved.idTeam in (7, 11) then 2
      else null
    end as idAssemblyLine,

    case
      when TeamResolved.idTeam = 1 then 7
      when TeamResolved.idTeam in (7, 11) then 8
      else null
    end as idSawLimit,

    GB.DateComplete,
    GB.nSmena,

    TeamSO.idOperator as idOperatorBrigadier,
    TeamSO.ID as idSheduleOperator

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

  /*
    Состав бригады ищем по производственной дате и команде.

    Совпадающая смена идёт первой.
    Если пользователи записали бригаду на другую смену того же дня,
    используем её как запасной вариант.
  */
  outer apply
  (
    select top 1
      SO.ID,
      SO.idOperator,
      SO.idTeam,
      SO.idSectorManufact,
      SO.idPlanCalendar,
      PCSO.nSmena as SheduleSmena

    from SheduleOperator SO
    inner join PlanCalendar PCSO on PCSO.ID = SO.idPlanCalendar

    where PCSO.Data = GB.DateComplete
      and SO.idTeam = TeamResolved.idTeam
      and exists
      (
        select 1
        from ShedulePersonnel SP
        where SP.idSheduleOperator = SO.ID
      )

    order by
      case
        when PCSO.nSmena = GB.nSmena then 0
        else 1
      end,

      case
        when SO.idSectorManufact = GB.idSectorManufact then 0
        when SO.idSectorManufact is null then 1
        else 2
      end,

      SO.ID desc
  ) TeamSO
)

select
  Personnel.ID,
  Personnel.Name,


  SawLimit.ID as idSawLimit,
  SawLimit.Name as SawLimitName,

  RB.idTeam,
  RB.idAssemblyLine,

  FinalSO.ID as idSheduleOperator,
  RB.idOperatorBrigadier,

  ShedulePersonnel.KTU,
  KTU.SumKTU,

  RB.DateComplete,
  RB.nSmena,

  SectorManufact.dPriceOfUnitProd,

  count(1) as nCountDetails,

  cast
  (
    sum(dbo.f_GetUE_ForAssemblyPlastica(Project.ID)) *
    ShedulePersonnel.KTU /
    nullif(KTU.SumKTU, 0)

    as decimal(18, 6)
  ) as SumUE

from ResolvedBase RB
inner join SectorManufact on SectorManufact.ID = RB.idSectorManufact
inner join Project on Project.ID = RB.idProject
inner join SawTaskMain on SawTaskMain.ID = RB.idSawTaskMain
inner join SawLimit on SawLimit.ID = RB.idSawLimit

inner join SheduleOperator FinalSO
  on FinalSO.ID = RB.idSheduleOperator

inner join
(
  select
    idSheduleOperator,
    sum(KTU) as SumKTU
  from ShedulePersonnel
  group by idSheduleOperator
) KTU on KTU.idSheduleOperator = FinalSO.ID

inner join ShedulePersonnel
  on ShedulePersonnel.idSheduleOperator = FinalSO.ID

inner join Personnel
  on Personnel.ID = ShedulePersonnel.idPersonnel

where RB.idTeam in (1, 7, 11)

group by
  Personnel.ID,
  Personnel.Name,

  SawLimit.ID,
  SawLimit.Name,

  RB.idTeam,
  RB.idAssemblyLine,

  FinalSO.ID,
  RB.idOperatorBrigadier,

  ShedulePersonnel.KTU,
  KTU.SumKTU,

  RB.DateComplete,
  RB.nSmena,

  SectorManufact.dPriceOfUnitProd
go