if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_SawTaskUE_Period_Detail_Shipment]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].f_SawTaskUE_Period_Detail_Shipment
go

create function dbo.f_SawTaskUE_Period_Detail_Shipment (@DateBeg datetime,  @DateEnd datetime,  @idTeam  int) returns table  
-- Список отгрузки
as return  
(  
  select   
    Task.ID                  as idTask,  
    Task.AccountNum,  
    SawTaskMain.ID           as idSawTask,  
    SawTaskMain.Name         as SawTaskName,  
    Ship.Date                as DateComplete,     
  
    Product.ID               as idGlass,  
    Product.Name             as GlassName,  
  
    count(1)                 as nCountDetails,  
  
    Project.GPName,  
    round(sum((GlassDetails.Width *  GlassDetails.Height)/1000000.0), 2) as SumArea,  
    round(sum((GlassDetails.Width *  GlassDetails.Height)/1000000.0), 2) as SumAreaUZM  
  
  from  
    GlassDetails   
      inner join BarCode on BarCode.ID = GlassDetails.idBarCode
      inner join Operator on Operator.ID = BarCode.idOperator
      inner join OperatorGroupItem on Operator.ID = OperatorGroupItem.idOperator
      inner join OperatorGroup on OperatorGroup.ID = OperatorGroupItem.idOperatorGroup
      inner join Product         on Product.ID         = GlassDetails.idGlass  
      inner join SawTaskMain     on SawTaskMain.ID     = GlassDetails.idSawTaskMain  
      inner join Project         on Project.ID         = GlassDetails.idProject  
      inner join Task            on Task.ID            = Project.idTask
      inner join PyramidCompleted on PyramidCompleted.ID = BarCode.idPyramidCompleted
      left join Ship on Ship.GUID = PyramidCompleted.guidShip

  where  
    IsNull(BarCode.nState, 0) & 128 = 128 and
    IsNull(Operator.ID, 0) != 0 and
    IsNull(Ship.bLock, 0) = 1 and
    Ship.Date >= @DateBeg and
    Ship.Date <= @DateEnd
  group by  
    Task.ID,  
    Task.AccountNum,  
    SawTaskMain.ID,  
    SawTaskMain.Name,  
    Project.GPName,  
    Ship.Date, 
    Product.ID,  
    Product.Name  
)  