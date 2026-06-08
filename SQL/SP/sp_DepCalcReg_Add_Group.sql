if exists (select * from dbo.sysobjects where id = OBJECT_ID(N'[dbo].[sp_DepCalcReg_Add_Group]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[sp_DepCalcReg_Add_Group]
go

create procedure sp_DepCalcReg_Add_Group @idDepTransList varchar(max)
as
begin
  set nocount on

  print 'sp_DepCalcReg_Add_Group'

  declare  @DocDate   datetime,
           @StartDate datetime,
           @SQL       varchar(max),
           @nCount    int,
           @MinDate   datetime

  if exists(select 1 from Config where Name = 'ProceedRecalc')
  begin
    print 'Идёт пересчёт склада Config where Name = ProceedRecalc'
    return
  end

  select @StartDate = DataCalc from Config where Name = 'DepRecalc_StartDate'

  set @StartDate = IsNull(@StartDate, '01.01.2000')  -- предохранитель

  create table #DelInputInfo
  (
    ID      int,
    DocDate datetime
  )

  set @SQL = 'select ID, DocDate from DepTrans where ID in ('+ @idDepTransList +') ' +
             'and DocDate >= ''' + cast(@StartDate as varchar(20)) + '''' -- Возможно это и не надо, подумать головой

  print 'Пересчёт документов: ' + @SQL

  insert into #DelInputInfo
  exec(@SQL)

  select
    @nCount  = count(1),
    @MinDate = min(DocDate)
  from
    #DelInputInfo

  -- нечего выводить из регистров - не выводим
  if IsNull(@nCount, 0) = 0
    return

  -- финальная дата пересчета
  if IsNull(@MinDate, '01.01.2000') > @StartDate
    set @StartDate = IsNull(@MinDate, '01.01.2000')

  update DT  set bWrite = 2 from #DelInputInfo DII inner join DepTrans      DT  on DT.ID          = DII.ID where IsNull(DT.bWrite,  0) != 2  -- пометили на запись
  update DTM set bWrite = 1 from #DelInputInfo DII inner join DepTransMater DTM on DTM.idDepTrans = DII.ID where IsNull(DTM.bWrite, 0) != 1  -- пометили на запись

  drop table #DelInputInfo

  -- Вот здесь: здесь через , введены idDepTrans надо как-то вызывать на основе того что я тебе дал exec sp_GetNextDepTransNumInvoice @idDepDocType, @NumCalcFact, @NumInvoice output
  
  declare @bNeedRecalcNumCalcFact int
  select @bNeedRecalcNumCalcFact = d_iNum from Config where Name = 'bNeedEqual_DepTransNumInvoice_To_TaskNumCalcFact'

  if @bNeedRecalcNumCalcFact = 1
  begin
     update DepTrans
     set
        NumInvoice = 'РН-' + T.NumCalcFact
     from DepTrans DT
     left join Task T on T.ID = DT.idTask
     where  
     DT.idDepDocType = 2 and
     DT.ID in (@idDepTransList)
  end

  exec sp_AddProtocol_DepTrans_List 0, @idDepTransList -- запись в протокол ("0" - добовление док. в регистр)

  exec sp_depResetBase     @StartDate
  exec sp_depRecalcFromDay @StartDate   -- посчитали день целиком

  set nocount off
end
go
