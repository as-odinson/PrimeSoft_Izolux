if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_SawTaskUE_Period_Operator_Shipment]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].f_SawTaskUE_Period_Operator_Shipment
go

create function dbo.f_SawTaskUE_Period_Operator_Shipment (@DateBeg datetime,  @DateEnd datetime,  @idTeam  int) returns table  
-- Список марок из хренилища, у которых нет слоёв покраски  
as return  
(  
  select   
    Personnel.ID,  
    Personnel.Name,  
    OGI_Main.Coef as KTU,  
    KTU.SumKTU,  
    Ship.Date as DateComplete,  
  
    25 as dPriceOfUnitProd,  
  
    count(1)                                                             as nCountDetails,  
    round(sum((GlassDetails.Width *  GlassDetails.Height)/1000000.0), 2) as SumArea,  
    round(sum((GlassDetails.Width *  GlassDetails.Height)/1000000.0), 2) as SumAreaUZM,  
  
    round(sum((GlassDetails.Width *  GlassDetails.Height)/1000000.0) * OGI_Main.Coef * 25/KTU.SumKTU, 2) as SumUE  
  from  
    GlassDetails   
      inner join Product         on Product.ID        = GlassDetails.idGlass  
      inner join Project         on Project.ID        = GlassDetails.idProject  
      inner join BarCode on BarCode.ID = GlassDetails.idBarCode
      inner join Operator on Operator.ID = BarCode.idOperator
      inner join OperatorGroupItem on Operator.ID = OperatorGroupItem.idOperator
      inner join OperatorGroup on OperatorGroup.ID = OperatorGroupItem.idOperatorGroup
      inner join OperatorGroupItem OGI_Main on OGI_Main.idOperatorGroup = OperatorGroup.ID
      inner join Operator OperatorMain on OperatorMain.ID = OGI_Main.idOperator
      left join Personnel on Personnel.ID = OperatorMain.idPersonnel
  
      inner join SawTaskMain      on SawTaskMain.ID     = GlassDetails.idSawTaskMain  

      inner join PyramidCompleted on PyramidCompleted.ID = BarCode.idPyramidCompleted
      left join Ship on Ship.GUID = PyramidCompleted.guidShip
      cross apply
      (
          select sum(OGI2.Coef) as SumKTU
          from OperatorGroupItem OGI2
          where OGI2.idOperatorGroup = OperatorGroup.ID
      ) KTU
  where  
    IsNull(BarCode.nState, 0) & 128 = 128 and
    IsNull(Operator.ID, 0) != 0 and
    IsNull(Ship.bLock, 0) = 1 and
    Ship.Date >= @DateBeg and
    Ship.Date <= @DateEnd
  group by  
    Personnel.ID,  
    Personnel.Name,  
    OGI_Main.Coef,  
    KTU.SumKTU,  
    Ship.Date
)  