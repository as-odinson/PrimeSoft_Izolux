/*
    Базовая VIEW для отчёта:
    "Средний процент отхода по видам стекла за период
     в разрезе подразделений".

    Одна строка VIEW = один SawTaskMain + один вид стекла.

    ВАЖНО:
    Процент сначала считается по суммарным площадям всех основных
    раскроев данного вида стекла внутри одного SawTaskMain.
    Только после этого отчёт берёт AVG за период.

    Это защищает расчёт от размножения строк через
    GlassDetails -> GlassProcessing.
*/

if object_id(N'dbo.v_Report_GlassWasteBySawTask', 'V') is not null
    drop view dbo.v_Report_GlassWasteBySawTask;
go

create view dbo.v_Report_GlassWasteBySawTask
as
with GlassArea as
(
    select
        GD.idCutting,
        sum(GD.Width * GD.Height) as SumAreaDetail
    from GlassDetails GD
    where GD.idCutting is not null
    group by
      GD.idCutting
),
BilletRestArea as
(
    -- Суммарная площадь сохранённых остатков по раскрою
    select
      BR.idCutting_Source,
      sum(BR.Width * BR.Height) as SumAreaRest
    from BilletRest BR
    where BR.idCutting_Source is not null
    group by
      BR.idCutting_Source
),
CuttingBase as
(
    -- Одна строка на один основной раскрой
    select
      C.ID as idCutting,
      C.idSawTaskMain,
      C.idGlass,

     isnull(C.SheetSquare_NoMargin, 0) as SheetSquare_NoMargin,
     isnull(C.SheetSquare, 0) as SheetSquare,
     isnull(BR.SumAreaRest, 0) as SumAreaRest,

     case when isnull(C.SquareUsed, 0) > 0
       then C.SquareUsed
       else isnull(GD.SumAreaDetail, 0)
     end
     as UsedArea

    from Cutting C
        left join GlassArea GD on GD.idCutting = C.ID
        left join BilletRestArea BR on BR.idCutting_Source = C.ID
    where C.bMain = 1
),
SawTaskGlass as
(
    /*
        Собираем все основные раскрои одного вида стекла
        внутри одного SawTaskMain.
    */
    select
      CB.idSawTaskMain,
      CB.idGlass,

      count_big(*) as CuttingCount,

      sum(CB.SheetSquare_NoMargin) as SheetSquare_NoMargin,
      sum(CB.SumAreaRest)          as SumAreaRest,
      sum(CB.UsedArea)             as UsedArea,

      sum
      (
        CB.SheetSquare_NoMargin -
        CB.SumAreaRest
      ) as SheetArea

    from CuttingBase CB
    group by
        CB.idSawTaskMain,
        CB.idGlass
)
select
  STM.ID                       as idSawTaskMain,
  STM.Data                     as SawTaskDate,

  STM.idDepotSubDivision,
  DSD.Name                     as DepotSubDivisionName,
  P.ID                         as idProduct,
  P.Name                       as ProductName,
  P.Type                       as ProductType,

  S.CuttingCount,
  S.SheetSquare_NoMargin,
  S.SumAreaRest,
  S.UsedArea,
  S.SheetArea,

  -- Аналог WastePct из v_SawTask_Statistics:
  -- 1 - использованная площадь / (площадь листов без кромки - сохранённые остатки)
  case
    when isnull(S.SheetSquare_NoMargin, 0) <= 0
      then 0

    when isnull(S.SumAreaRest, 0) >= isnull(S.SheetSquare_NoMargin, 0)
      then 0

    when isnull(S.SheetArea, 0) <= 0
      then 0

    when isnull(S.UsedArea, 0) > isnull(S.SheetArea, 0)
      then 0

    else round
    (
      ( 1 - (S.UsedArea / nullif(S.SheetArea, 0) ) ) * 100.0,
      2
    )
  end as WastePct,

  /*
      Аналог WastePctReal из v_SawTask_Statistics.
      Оставлен для проверки и возможного второго показателя.
  */
  case
    when isnull(S.SheetSquare_NoMargin, 0) <= 0
      then 0

    when isnull(S.SumAreaRest, 0) >= isnull(S.SheetSquare_NoMargin, 0)
      then 0

    when isnull(S.UsedArea, 0) > isnull(S.SheetArea, 0)
      then 0

    else round
    (
      ( S.SheetSquare_NoMargin - (S.SumAreaRest + S.UsedArea) ) * 100.0 / nullif(S.SheetSquare_NoMargin, 0),
      2
    )
  end as WastePctReal

from SawTaskGlass S
    inner join SawTaskMain STM on STM.ID = S.idSawTaskMain
    inner join Product P on P.ID = S.idGlass
                     and P.Type in (5, 105)
    left join DepotSubDivision DSD on DSD.ID = STM.idDepotSubDivision;
go
