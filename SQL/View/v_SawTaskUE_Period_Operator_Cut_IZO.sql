if object_id(N'dbo.v_SawTaskUE_Period_Operator_Cut_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Operator_Cut_IZO
go

create view dbo.v_SawTaskUE_Period_Operator_Cut_IZO
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
  select
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
Base as
(
  /*
    ќсновной путь Ч дл€ строк, где idSheduleOperator есть.
  */
  select
    GD.idGlass,
    GD.idProject,
    GD.idSawTaskMain,
    GD.Width,
    GD.Height,
    GP.idSectorManufact,

    case
      when OM.idOperatorBrigadier is null then SourceSO.ID
      else coalesce(BrigadierSOExact.ID, BrigadierSONull.ID)
    end as idSheduleOperator,

    PC.Data as DateComplete,
    GP.TimeMarkManufact,
    PC.nSmena

  from GlassDetails GD
  inner join GlassProcessing GP on GP.idGlassDetails = GD.ID
  inner join SectorManufact SM on SM.ID = GP.idSectorManufact
  inner join SheduleOperator SourceSO on SourceSO.ID = GP.idSheduleOperator
  inner join PlanCalendar PC on PC.ID = SourceSO.idPlanCalendar

  left join OperatorMap OM on OM.idOperator = SourceSO.idOperator
                          and OM.idSectorManufact = GP.idSectorManufact

  left join SheduleOperatorOne BrigadierSOExact
    on BrigadierSOExact.idPlanCalendar = PC.ID
   and BrigadierSOExact.idOperator = OM.idOperatorBrigadier
   and BrigadierSOExact.idSectorManufact = GP.idSectorManufact

  left join SheduleOperatorOne BrigadierSONull
    on BrigadierSONull.idPlanCalendar = PC.ID
   and BrigadierSONull.idOperator = OM.idOperatorBrigadier
   and BrigadierSONull.idSectorManufact is null

  where SM.nType = 1

  union all

  /*
    «апасной путь Ч дл€ строк без idSheduleOperator.
    Ѕригадир определ€етс€ по календарю смены и участку.
  */
  select
    GD.idGlass,
    GD.idProject,
    GD.idSawTaskMain,
    GD.Width,
    GD.Height,
    GP.idSectorManufact,

    BS.idSheduleOperator,

    PC.Data as DateComplete,
    GP.TimeMarkManufact,
    PC.nSmena

  from GlassDetails GD
  inner join GlassProcessing GP on GP.idGlassDetails = GD.ID
  inner join SectorManufact SM on SM.ID = GP.idSectorManufact

  left join SheduleOperator SourceSO on SourceSO.ID = nullif(GP.idSheduleOperator, 0)

  inner join PlanCalendar PC
    on PC.Data = dateadd
    (
      day,
      datediff(day, 0, dateadd(hour, -8, GP.TimeMarkManufact)),
      0
    )
   and PC.nSmena =
    case
      when datepart(hour, GP.TimeMarkManufact) >= 8
       and datepart(hour, GP.TimeMarkManufact) < 20 then 1
      else 2
    end

  inner join BrigadierScheduleRanked BS
    on BS.idPlanCalendar = PC.ID
   and BS.idSectorManufact = GP.idSectorManufact
   and BS.RowNum = 1

  where SM.nType = 1
    and SourceSO.ID is null
    and GP.TimeMarkManufact is not null
)

select
  Personnel.ID,
  Personnel.Name,
  FinalSO.ID as idSheduleOperator,
  ShedulePersonnel.KTU,
  KTU.SumKTU,

  PriceChina.DataCalc as PriceChina,
  PriceLisec.DataCalc as PriceLisec,

  CuttingTable.Name as CuttingTableName,
  Base.DateComplete,
  Base.nSmena,

  SectorManufact.dPriceOfUnitProd,

  count(1) as nCountDetails,
  round(sum((Base.Width * Base.Height) / 1000000.0), 2) as SumArea,
  round(sum((Base.Width * Base.Height) / 1000000.0), 2) as SumAreaUZM,

  round
  (
    sum((Base.Width * Base.Height) / 1000000.0) *
    ShedulePersonnel.KTU * SectorManufact.dPriceOfUnitProd / KTU.SumKTU,
    2
  ) as SumUE,

  round
  (
    sum((Base.Width * Base.Height) / 1000000.0) *
    ShedulePersonnel.KTU * PriceChina.DataCalc / KTU.SumKTU,
    2
  ) as SumUEChina,

  round
  (
    (
      sum((Base.Width * Base.Height) / 1000000.0) +
      sum(isnull(UGA.WasteArea, 0) / TaskStats.TotalCount)
    ) *
    ShedulePersonnel.KTU * PriceLisec.DataCalc / KTU.SumKTU,
    2
  ) as SumUELisec,

  round(sum(isnull(UGA.WasteArea, 0) / TaskStats.TotalCount), 2) as SumWasteArea,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 0 then 1
    else 0
  end as bTripNoCoat,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 1 then 1
    else 0
  end as bTripCoat,

  isnull(Product.IsTriplex, 0) as bTriplex

from Base
inner join Product on Product.ID = Base.idGlass
inner join SectorManufact on SectorManufact.ID = Base.idSectorManufact
inner join Project on Project.ID = Base.idProject
inner join SheduleOperator FinalSO on FinalSO.ID = Base.idSheduleOperator

inner join
(
  select
    idSheduleOperator,
    sum(KTU) as SumKTU
  from ShedulePersonnel
  group by idSheduleOperator
) KTU on KTU.idSheduleOperator = FinalSO.ID

left join ShedulePersonnel on ShedulePersonnel.idSheduleOperator = FinalSO.ID
left join Personnel on Personnel.ID = ShedulePersonnel.idPersonnel

inner join SawTaskMain on SawTaskMain.ID = Base.idSawTaskMain

left join Cutting on Cutting.idSawTaskMain = SawTaskMain.ID
                       and Cutting.idGlass = Product.ID
                       and Cutting.bMain = 1

inner join
(
  select
    idSawTaskMain,
    idGlass,
    count(idGlass) as TotalCount
  from GlassDetails
  group by idSawTaskMain, idGlass
) TaskStats on TaskStats.idSawTaskMain = SawTaskMain.ID
           and TaskStats.idGlass = Product.ID

left join CuttingTable on CuttingTable.ID = Cutting.idCuttingTable
left join Config PriceChina on PriceChina.Name = 'dPriceUEChina'
left join Config PriceLisec on PriceLisec.Name = 'dPriceUELisec'

left join
(
  select
    UG.idSawTask,
    UG.idGlass,

    round
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
      ) / 1000000.0,
      4
    ) as WasteArea

  from UsedGlass UG
  inner join Product P on P.ID = UG.idGlass
  group by UG.idSawTask, UG.idGlass
) UGA on UGA.idSawTask = SawTaskMain.ID
     and UGA.idGlass = Product.ID

where Base.idSheduleOperator is not null

group by
  Personnel.ID, Personnel.Name,
  FinalSO.ID,
  ShedulePersonnel.KTU,
  KTU.SumKTU,
  PriceChina.DataCalc, PriceLisec.DataCalc,
  CuttingTable.Name,
  Base.DateComplete, Base.nSmena,
  SectorManufact.dPriceOfUnitProd,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 0 then 1
    else 0
  end,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 1 then 1
    else 0
  end,

  isnull(Product.IsTriplex, 0)
go