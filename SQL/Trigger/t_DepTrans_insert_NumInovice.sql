if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_DepTrans_insert_NumInovice]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[t_DepTrans_insert_NumInovice]
go

create trigger dbo.t_DepTrans_insert_NumInovice on DepTrans  after insert 
as
begin
  
  declare 
    @idDepTrans       int = 0,
    @idDepDocType     int,
    @idUsers          int,
    @NumInvoice       varchar(10),
    @NumCalcFact      varchar(64)

  select @idUsers = ID from Users where Name = SYSTEM_USER
  
  select top 1 
    @idDepTrans       = I.ID,
    @idDepDocType     = I.idDepDocType,
    @NumCalcFact      = T.NumCalcFact
  from 
    Inserted I
  inner join DepName DN on DN.ID = I.idDepName_Credit or
                           DN.ID = I.idDepName_Debet
  left join Task T on T.ID = I.idTask
  where DN.nType = 0
   
  if @idDepTrans != 0
  begin
    exec sp_GetNextDepTransNumInvoice @idDepDocType, @NumCalcFact, @NumInvoice output

    update DepTrans set
      idUsers    = isNull(@idUsers, 0),
      NumInvoice = @NumInvoice
    from 
      Inserted inner join DepTrans on DepTrans.ID = Inserted.ID
  end
end
go
