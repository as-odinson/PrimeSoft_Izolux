    update DepTrans
     set
        NumInvoice = 
        case when IsNull(T.NumCalcFact, '') = ''
        then ''
        else 'ÐÍ-' + T.NumCalcFact
        end
     from DepTrans DT
     left join Task T on T.ID = DT.idTask
     where  
     DT.idDepDocType = 2


select * From DepTrans where ID = 10768
select * From DepTrans where ID = 10803


if object_id('tempdb..#DepTrans_NumInvoice_Backup') is not null
  drop table #DepTrans_NumInvoice_Backup

select
  DT.ID,
  DT.NumInvoice,
  T.NumCalcFact
into #DepTrans_NumInvoice_Backup
from DepTrans DT
left join Task T on T.ID = DT.idTask
where DT.idDepDocType = 2