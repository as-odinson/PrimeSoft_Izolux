exec sp_TaskMaterial_Group_Price 21652

select idTask, * from DepTrans where ID = 16673
select idClient, AccountNum, * from Task where ID = 22002
select * from Client where ID = 1320


select 
*
from Task

select * from WriteMater


select
  34.183 / 28 as fgdf,
  WM.*
from 
Project P
inner join WriteMater WM on WM.idProject = P.ID 
where P.idTask = 22002   and WM.idMaterial = 196

select * from Task where ID = 22002


select 1.882 * PriceUnit as price, * from DepReg where idMaterial = 196 and DocDate >= '2026-06-15 00:00:00.000'

select * from DepTrans where idTask = 22002
select * from DepTrans where ID = 8521


exec sp_helptext 'v_depDocMaterialsIzo'

select * from v_depDocMaterialsIzo




select   
  DepTrans.ID,  
  DepTrans.ID as idDepTrans,  
  DepTrans.DocDate,  
  DepTrans.idTask,  
  WriteMater.idMaterial,  
  Sum(IsNull(WriteMater.MaterUse, 0)) as dCount,  
  -- MaterUse, который будет использоваться если is2 = 1  
  Sum(IsNull(WriteMater.MaterUse, 0)) as MaterUse,  
  -- MaterUseFactCoef, который будет использоваться если is1 = 1  
  Sum(IsNull(WriteMater.MaterUseFactCoef, 0)) as MaterUseFactCoef,  
  Material.Coef,  
  IsNull(BarCode.idAssemblyLine, 0) as idAssemblyLine  
from   
  DepTrans  
  inner join DepTransPrj on DepTransPrj.idDepTrans = DepTrans.ID  
  inner join WriteMater on DepTransPrj.idProject = WriteMater.idProject  
  inner join Project on DepTransPrj.idProject = Project.ID  
  inner join Material on WriteMater.idMaterial = Material.ID  
  left join BarCode on BarCode.idDepTransPrj = DepTransPrj.ID  
where Project.idTask = 22190
group by  
  DepTrans.ID,  
  DepTrans.DocDate,  
  DepTrans.idTask,  
  WriteMater.idMaterial,  
  Material.Coef,  
  IsNull(BarCode.idAssemblyLine, 0)  

   -- вот это берем select * from DepTransPrj where idProject in (select ID from Project where idTask = 22190  )
   -- соединяемся с этим
   select   
  DepTrans.ID,  
  DepTrans.ID as idDepTrans,  
  DepTrans.DocDate,  
  DepTrans.idTask,  
  WriteMater.idMaterial,  
  Sum(IsNull(WriteMater.MaterUse, 0)) as dCount,  
  -- MaterUse, который будет использоваться если is2 = 1  
  Sum(IsNull(WriteMater.MaterUse, 0)) as MaterUse,  
  -- MaterUseFactCoef, который будет использоваться если is1 = 1  
  Sum(IsNull(WriteMater.MaterUseFactCoef, 0)) as MaterUseFactCoef,  
  Material.Coef,  
  IsNull(BarCode.idAssemblyLine, 0) as idAssemblyLine  
from   
  DepTrans  
  inner join DepTransPrj on DepTransPrj.idDepTrans = DepTrans.ID  
  inner join WriteMater on DepTransPrj.idProject = WriteMater.idProject  
  inner join Project on DepTransPrj.idProject = Project.ID  
  inner join Material on WriteMater.idMaterial = Material.ID  
  left join BarCode on BarCode.idDepTransPrj = DepTransPrj.ID  
where Project.idTask = 22190
group by  
  DepTrans.ID,  
  DepTrans.DocDate,  
  DepTrans.idTask,  
  WriteMater.idMaterial,  
  Material.Coef,  
  IsNull(BarCode.idAssemblyLine, 0)  


  -- берем цену из DepReg 
  -- все

   select * from DepTrans where idTask = 22190  

   select * from v_depDocMaterialsIzo