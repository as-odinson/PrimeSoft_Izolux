if object_id(N'dbo.v_SawTaskUE_Period_Detail_Cut_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Detail_Cut_IZO
go

create view dbo.v_SawTaskUE_Period_Detail_Cut_IZO
as

select
  Task.ID as idTask,
  Task.AccountNum,
  SawTaskMain.ID as idSawTask,
  SawTaskMain.Name as SawTaskName,
  CuttingTable.Name as CuttingTableName,

  CalendarResolved.DateComplete,
  CalendarResolved.nSmena,
  CalendarResolved.idPlanCalendar,

  Product.ID as idGlass,
  Product.Name as GlassName,
  Product.dCoefUZM,

  BrigadierSO.ID as idSheduleOperatorBrigadier,
  ResolvedBrigadier.idOperatorBrigadier,
  coalesce(BrigadierSO.idTeam, SheduleOperatorSource.idTeam) as idTeam,

  case
    when DirectBrigadier.idOperatorBrigadier = SheduleOperatorSource.idOperator then 1
    when DirectBrigadier.idOperatorBrigadier is not null then 2
    when InferredBrigadier.BrigadierCount = 1 then 3
    else 0
  end as BrigadierResolveType,

  count(1) as nCountDetails,

  cast
  (
    sum(1.0 * GlassDetails.Width * GlassDetails.Height) / 1000000.0
    as decimal(18,6)
  ) as SumArea,

  cast
  (
    sum((GlassDetails.Width * GlassDetails.Height) / 1000000.0)
    as decimal(18,6)
  ) as SumAreaUZM,

  cast
  (
    isnull(UGA.WasteArea, 0) /
    nullif(count(*) over(partition by SawTaskMain.ID, Product.ID), 0)
    as decimal(18,6)
  ) as SumWasteArea,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 0 then 1
    else 0
  end as bTripNoCoat,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 1 then 1
    else 0
  end as bTripCoat

from GlassDetails
inner join Product on Product.ID = GlassDetails.idGlass
inner join GlassProcessing on GlassProcessing.idGlassDetails = GlassDetails.ID
inner join SectorManufact on SectorManufact.ID = GlassProcessing.idSectorManufact
inner join SawTaskMain on SawTaskMain.ID = GlassDetails.idSawTaskMain
inner join Project on Project.ID = GlassDetails.idProject
inner join Task on Task.ID = Project.idTask

left join SheduleOperator SheduleOperatorSource  on SheduleOperatorSource.ID = nullif(GlassProcessing.idSheduleOperator, 0)
left join PlanCalendar PlanCalendarSource        on PlanCalendarSource.ID = SheduleOperatorSource.idPlanCalendar

left join Cutting on Cutting.idSawTaskMain = SawTaskMain.ID
                       and Cutting.idGlass = Product.ID
                         and Cutting.bMain = 1

left join CuttingTable on CuttingTable.ID = Cutting.idCuttingTable

left join
(
  select
    UG.idSawTask,
    UG.idGlass,

    cast
    (
      sum
      (
        case
          when UG.Width < 0 then
            UG.Width * UG.BilletHeight * UG.nCount -
            (UG.Width - P.MarginLeft - P.MarginRight - P.MarginInner) *
            (UG.BilletHeight - P.MarginBottom - P.MarginInner) * UG.nCount
          else
            UG.BilletWidth * UG.BilletHeight * UG.nCount -
            (UG.BilletWidth - P.MarginLeft) *
            (UG.BilletHeight - P.MarginBottom - P.MarginInner) * UG.nCount
        end
      ) / 1000000.0
      as decimal(18, 6)
    ) as WasteArea

  from UsedGlass UG
  inner join Product P on P.ID = UG.idGlass
  group by UG.idSawTask, UG.idGlass
) UGA
  on UGA.idSawTask = SawTaskMain.ID
 and UGA.idGlass = Product.ID

/*
  ќпредел€ем производственную дату и смену по TimeMarkManufact.

  1 смена: 08:00Ц20:00.
  2 смена: 20:00Ц08:00 следующего дн€.
*/
cross apply
(
  select
    case
      when datepart(hour, GlassProcessing.TimeMarkManufact) < 8 then
        dateadd(day, datediff(day, 0, GlassProcessing.TimeMarkManufact) - 1, 0)
      else
        dateadd(day, datediff(day, 0, GlassProcessing.TimeMarkManufact), 0)
    end as DateComplete,

    case
      when datepart(hour, GlassProcessing.TimeMarkManufact) >= 8
       and datepart(hour, GlassProcessing.TimeMarkManufact) < 20 then 1
      else 2
    end as nSmena
) ShiftInfo

/*
  ѕо рассчитанным дате и смене находим насто€щую строку PlanCalendar.
  TOP 1 не даст размножить детали, если там внезапно есть дубли.
*/
outer apply
(
  select top 1
    PC.ID,
    PC.Data,
    PC.nSmena
  from PlanCalendar PC
  where PC.Data = ShiftInfo.DateComplete
    and PC.nSmena = ShiftInfo.nSmena
  order by PC.ID desc
) PlanCalendarByTime

/*
  —начала используем PlanCalendar, найденный по TimeMarkManufact.
  —тарый PlanCalendar от idSheduleOperator Ч только запасной вариант.
*/
cross apply
(
  select
    coalesce(PlanCalendarByTime.ID, PlanCalendarSource.ID) as idPlanCalendar,
    coalesce(PlanCalendarByTime.Data, PlanCalendarSource.Data, ShiftInfo.DateComplete) as DateComplete,
    coalesce(PlanCalendarByTime.nSmena, PlanCalendarSource.nSmena, ShiftInfo.nSmena) as nSmena
) CalendarResolved

-- ≈сли в старом SheduleOperator записан подчинЄнный, получаем его бригадира.
outer apply
(
  select top 1
    OBM.idOperatorBrigadier
  from dbo.v_OperatorBrigadierMap OBM
  where OBM.idOperator = SheduleOperatorSource.idOperator
  order by
    case
      when OBM.idOperator = OBM.idOperatorBrigadier then 0
      else 1
    end,
    OBM.idOperatorGroup
) DirectBrigadier

/*
  ≈сли исходного SheduleOperator нет, ищем бригадира
  среди расписаний этого участка, даты и смены.

  »спользуем только если найден один уникальный бригадир.
*/
outer apply
(
  select
    count(distinct SO2.idOperator) as BrigadierCount,
    min(SO2.idOperator) as idOperatorBrigadier
  from SheduleOperator SO2
  where SO2.idSectorManufact = GlassProcessing.idSectorManufact
    and
    (
      SO2.idPlanCalendar = CalendarResolved.idPlanCalendar
      or
      (
        CalendarResolved.idPlanCalendar is null
        and GlassProcessing.TimeMarkManufact >= SO2.dtBegin
        and GlassProcessing.TimeMarkManufact < SO2.dtEnd
      )
    )
    and exists
    (
      select 1
      from dbo.v_OperatorBrigadierMap OBM2
      where OBM2.idOperator = SO2.idOperator
        and OBM2.idOperatorBrigadier = SO2.idOperator
    )
) InferredBrigadier

cross apply
(
  select
    coalesce
    (
      DirectBrigadier.idOperatorBrigadier,
      case
        when InferredBrigadier.BrigadierCount = 1 then
          InferredBrigadier.idOperatorBrigadier
        else null
      end
    ) as idOperatorBrigadier
) ResolvedBrigadier

-- ѕолучаем уже конкретную строку SheduleOperator именно бригадира.
outer apply
(
  select top 1
    SO3.ID,
    SO3.idPlanCalendar,
    SO3.idOperator,
    SO3.idTeam
  from SheduleOperator SO3
  where SO3.idOperator = ResolvedBrigadier.idOperatorBrigadier
    and SO3.idSectorManufact = GlassProcessing.idSectorManufact
    and
    (
      SO3.idPlanCalendar = CalendarResolved.idPlanCalendar
      or
      (
        CalendarResolved.idPlanCalendar is null
        and GlassProcessing.TimeMarkManufact >= SO3.dtBegin
        and GlassProcessing.TimeMarkManufact < SO3.dtEnd
      )
    )
  order by
    case
      when SO3.idPlanCalendar = CalendarResolved.idPlanCalendar then 0
      else 1
    end,
    SO3.ID desc
) BrigadierSO

where SectorManufact.nType = 1
  and GlassProcessing.TimeMarkManufact is not null

group by
  Task.ID,
  Task.AccountNum,
  SawTaskMain.ID,
  SawTaskMain.Name,
  CuttingTable.Name,
  CalendarResolved.DateComplete,
  CalendarResolved.nSmena,
  CalendarResolved.idPlanCalendar,
  Product.ID, Product.Name, Product.dCoefUZM,
  BrigadierSO.ID,
  ResolvedBrigadier.idOperatorBrigadier,
  coalesce(BrigadierSO.idTeam, SheduleOperatorSource.idTeam),

  case
    when DirectBrigadier.idOperatorBrigadier = SheduleOperatorSource.idOperator then 1
    when DirectBrigadier.idOperatorBrigadier is not null then 2
    when InferredBrigadier.BrigadierCount = 1 then 3
    else 0
  end,

  UGA.WasteArea,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 0 then 1
    else 0
  end,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 1 then 1
    else 0
  end
go