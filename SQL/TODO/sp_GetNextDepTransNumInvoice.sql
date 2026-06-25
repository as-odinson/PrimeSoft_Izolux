if OBJECT_ID('sp_GetNextDepTransNumInvoice', 'P') is not NULL
  drop procedure dbo.sp_GetNextDepTransNumInvoice
go
-- Достать следующий номер накладной документа.
-- @nType Тип накладной: 1 — приход, 2 — расход
-- @NumCalcFact Номер счет фактуры
-- Выходной параметр: следующий номер накладной
create procedure dbo.sp_GetNextDepTransNumInvoice  @idDepDocType int, @NumCalcFact varchar(64), @NumInvoice varchar(10) output
as
begin
  set nocount on
    
  declare @iNum bigint
  declare @LastNum int

  if @idDepDocType = 1
  begin

    -- Последний номер приходной накладной
    if not exists(select * from Config where Name = 'LastNumInvoiceDepTrans_PN' and DataCalc = 0)
    begin
      select  @LastNum = 0
      insert into Config (Name, DataCalc, d_iNum) values ('LastNumInvoiceDepTrans_PN', 0, @LastNum)
    end
    
    update Config set 
      @iNum  = d_iNum = d_iNum + 1
    where 
      Name = 'LastNumInvoiceDepTrans_PN' and DataCalc = 0
    
    set @NumInvoice = 'ПН-' + Cast(IsNull(@iNum, 0) as varchar(10))
  end

  if @idDepDocType = 2
  begin
    -- Номер расходной накладной должен совпадать с номером счет фактуры заказа
    if (isNull(@NumCalcFact, '') != '')
     set @NumInvoice = 'РН-' + isNull(@NumCalcFact, '')
  end

  set nocount off
end
go
