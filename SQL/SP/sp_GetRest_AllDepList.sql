-- Для отчета "Остатки ТМЦ".  
if object_id('dbo.sp_GetRest_AllDepList', 'P') is not null
  drop procedure dbo.sp_GetRest_AllDepList
go

--drop proc sp_GetRest_AllDepList
create procedure sp_GetRest_AllDepList @idSubDivision       int,  
                                       @DocDateEnd          datetime,  
                                       @bNDS                bit  
as  
begin  
  set nocount on  
   
  
  create table #DepList  
  (  
    ID            int,  
    Name          varchar(100),  
    nOrderDepList int  
  )  
  
  create table #MaterialColor  
  (  
    idMaterial  int,  
    FolderPath  varchar(1000)  
  )  
  
  insert into #DepList (ID, Name, nOrderDepList)   
    select   
      DL.ID,   
      DL.Name,   
      DL.nOrder   
    from DepList DL  
    inner join DepNameList DNL on DNL.idDepList = DL.ID  
    inner join DepName     DN  on DNL.idDepName = DN.ID  
    where DL.is1 = 1 and
          (
            DN.idDepotSubDivision = @idSubDivision
            or @idSubDivision = 0
          )   -- Если не передали параметр выводим все из всех складов  
  insert into #MaterialColor (idMaterial, FolderPath)  
    select M.ID, dbo.f_GetTreeMaterialFolder(IsNull(M.IdtGroup, 0))  
    from Material M  
      
  
  declare @sDepList varchar(2000)  
  set @sDepList = ''  
  
  select @sDepList = @sDepList + Name + ', ' from #DepList  
  
  if DATALENGTH (@sDepList) > 0  
    select @sDepList = left(@sDepList, LEN(@sDepList) - 2)  -- заменим datalength() на len(), datalength() для nvarchar вернет длину x2   
  
  declare @idDepList     int,          -- Для строк с папками.  
          @sDepListName  varchar(100), -- Для строк с папками.  
          @nOrderDepList int           -- Для строк с папками.  
  
  select top 1 @idDepList = ID, @sDepListName = Name, @nOrderDepList = nOrderDepList from #DepList  
  
  select  
    2 as nOrder,  
    DL.nOrderDepList,  
    MC.idMaterial,  
    RC.MaterName as Name,  
    MC.FolderPath,  
    @DocDateEnd as DateEnd,  
    case when @bNDS = 1 then 'с НДС' else 'без НДС' end as sNDS,  
    @sDepList as sDepList,  
    RC.DocDate,  
    RC.MaterArt,  
    RC.UnitName,  
    RC.DepListName,  
    RC.idDepList,  
    round(RT.Rest, 3) as Rest,  
    RT.PriceSum,  
    RC.Mass,  
    RC.dTotalCount,  
    RC.dTotalWeight,  
    round(IsNull(RC.PriceAvg, 0), 2) as PriceAvg,  
    RT.PriceUnit  
  from #MaterialColor MC  
    inner join dbo.f_GetRest_Cross(@DocDateEnd, @bNDS) RC on RC.idMaterial = MC.idMaterial      
    inner join #DepList DL on DL.ID = RC.idDepList--) t  
    inner join dbo.f_GetrestTMC(@DocDateEnd) RT on RT.idMaterial = RC.idMaterial
                                               and RT.idDepList  = RC.idDepList
  --order by  
  --  FolderPath, nOrder, idMaterial, idColorIns, idColorBase, idColorExt  
  
  drop table #DepList  
  drop table #MaterialColor  
  
  set nocount off  
end  