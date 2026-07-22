if object_id('dbo.sp_GetMaterialsWithDateGap', 'P') is not null
  drop procedure dbo.sp_GetMaterialsWithDateGap
go

create procedure dbo.sp_GetMaterialsWithDateGap @DateBegin datetime, @DateEnd   datetime
as
begin
  set nocount on

  declare @DateBeginDay datetime
  declare @DateEndDay   datetime
  declare @DateEndNext  datetime

  /*
    Нормализуем входные даты.

    Например:
      @DateBegin = 01.06.2026
      @DateEnd   = 30.06.2026

    Интервал ParentDT:
      >= 01.06.2026 00:00
      <  01.07.2026 00:00
  */
  set @DateBeginDay = dateadd(day, datediff(day, 0, @DateBegin), 0)
  set @DateEndDay   = dateadd(day, datediff(day, 0, @DateEnd),   0)
  set @DateEndNext  = dateadd(day, 1, @DateEndDay)

  if @DateBeginDay > @DateEndDay
  begin
    raiserror('Дата начала интервала не может быть больше даты окончания.', 16, 1)

    return
  end


  ;with ParentDocs
  as
  (
    /*
      Берём родительские бухгалтерские документы,
      которые входят в выбранный интервал.
    */
    select
      ParentDT.ID
    from DepTrans ParentDT
    where
          ParentDT.DocDate >= @DateBeginDay
      and ParentDT.DocDate <  @DateEndNext
  ),

  DT0
  as
  (
    /*
      Склад 0.

      Берём только документы, которые находятся
      ПОСЛЕ даты разделения.

      Сразу группируем по:
        - родительскому документу;
        - подразделению;
        - материалу.

      Это защищает от перемножения строк при JOIN со складом 2.
    */
    select
      D0.idParent,
      DN0.Name                       as DepName,
      DTM0.idMaterial,

      sum(isnull(DTM0.dCount, 0))     as dCount0,
      sum(isnull(DTM0.PriceSum, 0))   as PriceSum0,
      sum(isnull(DTM0.NDSSum, 0))     as NDSSum0,
      sum(isnull(DTM0.PriceNDSSum, 0)) as PriceNDSSum0

    from ParentDocs P
    inner join DepTrans D0 on D0.idParent = P.ID
    inner join DepTransMater DTM0 on DTM0.idDepTrans = D0.ID
    inner join DepNameList DNL0 on DNL0.idDepName = D0.idDepName_Debet
    inner join DepName DN0 on DN0.ID = DNL0.idDepName
    inner join DepList DL0 on  DL0.ID  = DNL0.idDepList
                           and DL0.is1 = 1 
    inner join Task T0 on T0.ID = D0.idTask
    where
      T0.DateComplite > @DateEndNext and
      D0.is1 = 1

    group by
      D0.idParent,
      DN0.Name,
      DTM0.idMaterial
  ),

  DT2
  as
  (
    /*
      Склад 2.

      Берём только документы, которые находятся
      ДО даты разделения.

      Вся дата @DateEnd включительно.
    */
    select
      D2.idParent,
      DTM2.idMaterial,

      sum(isnull(DTM2.dCount, 0))      as dCount2,
      sum(isnull(DTM2.PriceSum, 0))    as PriceSum2,
      sum(isnull(DTM2.NDSSum, 0))      as NDSSum2,
      sum(isnull(DTM2.PriceNDSSum, 0)) as PriceNDSSum2

    from ParentDocs P
    inner join DepTrans D2 on D2.idParent = P.ID
    inner join DepTransMater DTM2 on DTM2.idDepTrans = D2.ID
    inner join DepNameList DNL2 on DNL2.idDepName = D2.idDepName_Debet
    inner join DepList DL2 on  DL2.ID  = DNL2.idDepList
                           and DL2.is2 = 1
    inner join Task T2 on T2.ID = D2.idTask
    where
      T2.DateCompliteGP <= @DateEndDay and
      D2.is2 = 1

    group by
      D2.idParent,
      DTM2.idMaterial
  ),

  MaterialsByDocument
  as
  (
    /*
      Соединяем уже просчитанные данные складов.

      Здесь получается одна строка материала
      на родительский документ и подразделение.
    */
    select
      DT0.DepName,
      DT0.idMaterial,

      DT0.dCount0,
      DT0.PriceSum0,
      DT0.NDSSum0,
      DT0.PriceNDSSum0,

      DT2.dCount2,
      DT2.PriceSum2,
      DT2.NDSSum2,
      DT2.PriceNDSSum2

    from DT0

    inner join DT2 on  DT2.idParent   = DT0.idParent
                   and DT2.idMaterial = DT0.idMaterial
  )

  /*
    Итоговая группировка.

    Одна строка результата:
      подразделение + материал.

    Никакой группировки по:
      - дате;
      - заказу;
      - накладной;
      - родительскому документу.
  */
  select
    @DateBeginDay                 as DateBegin,
    @DateEndDay                   as DateEnd,
    @DateEndDay                   as DateGap,

    MDB.DepName,

    M.ID                          as idMaterial,
    M.Name                        as MaterialName,

    sum(MDB.dCount0)              as dCount0,
    sum(MDB.dCount2)              as dCount2,

    sum(MDB.PriceSum0)            as PriceSum0,
    sum(MDB.PriceSum2)            as PriceSum2,

    sum(MDB.NDSSum0)              as NDSSum0,
    sum(MDB.NDSSum2)              as NDSSum2,

    sum(MDB.PriceNDSSum0)         as PriceNDSSum0,
    sum(MDB.PriceNDSSum2)         as PriceNDSSum2

  from MaterialsByDocument MDB

  inner join Material M on M.ID = MDB.idMaterial

  group by
    MDB.DepName,
    M.ID,
    M.Name

  order by
    M.Name,
    MDB.DepName

  set nocount off
end
go