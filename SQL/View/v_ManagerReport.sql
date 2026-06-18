 if OBJECT_ID('v_ManagerReport', 'V') is not NULL
  drop view dbo.v_ManagerReport
go

--[RP] вью для отчета по менеджерам, упущенным возможностям и др.  
create view v_ManagerReport  
as  
  
with TaskDepTrans as (  
  select  
    idTask,  
    Sum(Price_NDSSum) as SumDepTransAggregated  
  from  
    DepTrans  
  where  
    idDepDocType = 2 AND is2 = 1  
  group by  
    idTask  
)  
  
select  
  DSD.Name                        as DepotName,  
  DSD.ID                          as idDepotSubDivision,  
  U.ID                            as ManagerID,  
  U.ManagerName,  
  C.ID                            as ClientID,  
  C.Name                          as ClientName,  
  C.City                          as ClientCity,  
  CamC.SPSum,  
  Sum(P.nCount)                   as SumPos,  
  Sum(P.Area * P.nCount)          as SumArea,  
  Sum(P.SumWithNDS)               as SumPrice,  
  T.ID                            as idTask,  
  T.Date,  
  T.DateComplite,  
  T.Num,  
  FORMAT(T.Date, 'MMMM', 'ru-RU') as Month,  
  Month(T.Date)                   as MonthNum,  
  Year(T.Date)                    as Year,  
  case   
    when (T.nState & 4) = 0 then 1   
    else 0   
  end                             as bNotSaw,  
  TDT.SumDepTransAggregated       as SumDepTrans,  
  T.nState,  
  case  
    when T.AccountNum like 'П%' or T.AccountNum like 'В%'or T.AccountNum like 'Р%' then 1   
    else 0  
  end as bRemake  
from Task T  
  inner join Project            P on P.idTask   = T.ID  
  left  join Client             C on C.ID       = T.idClient  
  left  join Users              U on U.ID       = C.idUsers_Primarymanager  
  left  join DepotSubDivision DSD on DSD.ID     = T.idDepotSubDivision  
  left  join TaskDepTrans     TDT on TDT.idTask = T.ID   
  left  join (select  
                P_Cam.idTask,  
                Sum(P_Cam.nCount) as SPSum  
              from  
                Project as P_Cam  
              where  
                P_Cam.CamCount != 0  
              group by  
                P_Cam.idTask)CamC on CamC.idTask = T.ID  
group by  
  DSD.Name,  
  DSD.ID,  
  U.ID,  
  U.ManagerName,  
  C.ID,  
  C.Name,  
  C.City,  
  T.ID,  
  T.Date,  
  T.DateComplite,  
  CamC.SPSum,  
  T.Num,  
  T.nState,  
  T.AccountNum,  
  TDT.SumDepTransAggregated  


