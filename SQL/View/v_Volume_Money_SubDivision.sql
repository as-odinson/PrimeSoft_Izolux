if object_id('v_Volume_Money_SubDivision', 'V') is not null
    drop view dbo.v_Volume_Money_SubDivision
go 
      
create view dbo.v_Volume_Money_SubDivision  
as  
select   
  Sum(IsNull(ProjectPrice, 0)) as SumPrice,  
  Sum(IsNull(Task.Area, 0))   as SumArea,  
  Sum(SPCount.nCount)         as SumPosCount,  
  Task.idClient,  
  Task.DateComplite           as Date,  
  Task.TypeOrder,  
  case Task.TypeOrder   
    when 0 then 'Безнал'  
    when 1 then 'Нал'  
    when 2 then 'ОБ'  
  end                         as TypeOrderName,  
  Client.Name                 as ClientName,  
  IsNull(DepotSubDivision.name, 'Цех 1') as SubDivisionName  
from   
  Task   
  inner join Client           on Task.idClient = Client.ID  
  left  join DepotSubDivision on Task.idDepotSubDivision = DepotSubDivision.ID  
  left  join  
  (  
    select  
      Project.idTask,  
      sum(Project.nCount)                            as nCount,  
      sum(IsNull(Project.SumWithNDS, 0))          as ProjectPrice,  
      sum(IsNull(Project.Area,  0) * Project.nCount) as ProjectArea  
    from   
      Project  
    group by   
      Project.idTask  
  ) SPCount on Task.ID = SPCount.idTask  
where  
  dbo.f_GetTaskState_ForReport(Task.ID) = 1 and  
  dbo.f_GetExistsRejectFromTask(Task.ID) = 0  
group by   
  Task.DateComplite,  
  Task.TypeOrder,  
  Task.idClient,  
  Client.Name,  
  IsNull(DepotSubDivision.name, 'Цех 1')  
go