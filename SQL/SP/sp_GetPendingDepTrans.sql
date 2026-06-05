if OBJECT_ID('sp_GetPendingDepTrans', 'P') is not NULL
  drop procedure dbo.sp_GetPendingDepTrans
go

-- Для отчета не списанные заказы на дату    
create procedure dbo.sp_GetPendingDepTrans @BegDate datetime, @EndDate datetime, @idSubDivision int    
as    
begin    
with cte as  
(  
  select    
    @BegDate            as BegDate,    
    @EndDate            as EndDate,    
    DT.DateInvoice,    
    DT.DocDate,    
    DT.NumInvoice,    
    DT.DepNum,    
    DT.idParent,    
    DT.ID,    
    DT.idDepDocType,    
    IsNull(DT.iDep, 1) as iDep,    
    T.AccountNum,    
    T.DateComplite,    
    C.Name              as ClientName,    
        
    DepotSubDivision.ID as idDepotSubDivision,    
    DT.bWrite,    
    case     
      when isnull(DT.idParent, 0) != 0 then    
      case    
        when exists     
        (    
          select 1    
          from DepTransMater DTM    
          where DTM.idDepTrans = DT.ID and isnull(DTM.PriceSum, 0) = 0    
        )                                                     then 'Позиции с нулевой ценой'    
        when DT.bWrite = 0                                    then 'Накладная не проведена'    
        when IsNull(DT.bWrite, 0) = 2 and DT.idDepDocType = 1 then 'Нет списания'    
        else ''    
       end    
      else 'Нет списаний'    
    end as strState    
  from Task T    
  inner join DepotSubDivision   on T.idDepotSubDivision = DepotSubDivision.ID    
  left  join Client  C          on T.idClient           = C.ID                                            
  outer apply    
  (     
    select     
      DateInvoice,    
      DocDate,    
      NumInvoice,    
      Num as DepNum,    
      idParent,    
      ID,    
      idDepDocType,    
      bWrite,    
      bCheck,
      nType,
      case     
        when IsNull(is1, 0) = 1 then 1    
        when IsNull(is2, 0) = 1 then 2    
      end iDep    
    from DepTrans    
    where DepTrans.idTask = T.ID    
  )  DT    
  where     
    (    
      (
        IsNull(DT.bWrite, 0) != 2 and
        IsNull(DT.nType, 0)  != 4
      ) or
      (   
        DT.idDepDocType = 1 and    
        not exists     
        (    
          select 1    
          from DepTrans    
          where idParent = DT.ID    
        )    
      )    
    ) and    
    T.DateComplite >= @BegDate and    
    T.DateComplite <= @EndDate and    
    DepotSubDivision.ID = @idSubDivision    
)  
-- Забираем все данные  
select * from cte  
union all -- если idParent = 0 тогда списания для склада 2 также нет  
  select    
    BegDate,   
    EndDate,   
    DateInvoice,   
    DocDate,  
    NumInvoice,   
    DepNum,   
    idParent,   
    ID,   
    idDepDocType,    
    2 as iDep,       -- склад 2  
    AccountNum,   
    DateComplite,   
    ClientName,   
    idDepotSubDivision,   
    bWrite,  
    strState  
  from cte  
  where idParent = 0  
  order by DateComplite    
end  

