declare  @ID int
select   @ID = ID from Config where Name = 'bNeedEqual_DepTransNumInvoice_To_TaskNumCalcFact'
if       @ID is NULL
begin
  insert into Config (Name, d_iNum, Descr) values ('bNeedEqual_DepTransNumInvoice_To_TaskNumCalcFact', 1, 'нужно соответствие счет фактуры заказа с расходной накладной')
end
go
