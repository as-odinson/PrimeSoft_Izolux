  if exists (select * from dbo.sysobjects where id = OBJECT_ID(N'[dbo].[sp_RTB_ProjectCopy]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[sp_RTB_ProjectCopy]
go

-- Создание/копирование позиции. (вспомогательная процедура для sp_RemakeTaskByBarCodes).  
create procedure sp_RTB_ProjectCopy  
  @idProjectSrc     int,  
  @Num              int,  
  @nCount           int,  
  @idTask           int,  
  @bNullPrice       bit,  
  @idProjectItemSrc int = 0,  
  @sGPName          varchar(max) = '',   
  @nGlass           tinyint = 0,  
  @nGlassTriplex    tinyint = 0,  
  @bFullTriplex     bit     = 0, -- Флаг что переданы все стекла триплекса  
  @sCommentReject   varchar(256) = '',  
  @PInType          int = 0,  
  @idProjectNew     int output  
as  
begin  
  set nocount on  
  
  declare   
    @sSQL               nvarchar(max),  
    @sFieldList         nvarchar(max),  
    @sFieldListExclude  nvarchar(max),  
    @sFieldListPI       nvarchar(max),  
    @sFieldListDrill    nvarchar(max),  
    @sPriceValues       nvarchar(1000),  
    @guidProjectSrc     uniqueidentifier,  
    @guidProjectNew     uniqueidentifier,  
    @nCountItem         int,  
    @idProjectItemNew   int,  
    @guidProjectItemNew uniqueidentifier,  
    @bSetRecalcPriceLockToZero int--,  
 --@sGlassNameWithOper nvarchar(max),  
 --@sGPNameProject     nvarchar(max)  
  
  select @guidProjectSrc = GUID from Project where ID = @idProjectSrc  
  
  select   
    @nCountItem       = 1,  
    @idProjectItemSrc = IsNull(@idProjectItemSrc, 0)  
  
  -- Если нулевая цена, то пишем нули.  
  if @bNullPrice = 1  
    set @sPriceValues = '0,0,0'  
  else  
    set @sPriceValues = 'SumNoNDS / nCount * '   + cast(@nCount as varchar(4)) +  
                       -- Исправил нестыковку копеек в NDS.  
                       ',Round(SumWithNDS / nCount * ' + cast(@nCount as varchar(4)) + ', 2) - Round(SumNoNDS / nCount * ' + cast(@nCount as varchar(4)) + ', 2)' +  
                       ',SumWithNDS / nCount * ' + cast(@nCount as varchar(4))  
  
  set @sFieldListExclude = 'Num,nCount,idTask,bRecalcPriceLock,Commentary,SumNoNDS,SumNDS,SumWithNDS,ID,GUID,onReplication,nCountManufakted,bRecalcPriceLock'  
  
  if IsNull(@idProjectItemSrc, 0) > 0  
    set @sFieldListExclude = @sFieldListExclude + ',GPName'  
  
  select @sFieldList      = dbo.f_GetTableFieldList('Project', @sFieldListExclude, ''),  
         @sFieldListPI    = dbo.f_GetTableFieldList('ProjectItem', 'ID,idProject,GUID,guidProject,onReplication',                 ''),  
         @sFieldListDrill = dbo.f_GetTableFieldList('Drill',       'ID,idProjectItem,guidProjectItem,GUID,onReplication',         '')  
  
  -- Если пришел флаг о триплексе, зачистим позицию которую сделали  
  if @bFullTriplex = 1  
  begin  
    delete from Drill                 where idProjectItem in (select ID from ProjectItem where idProject = @idProjectNew)  
    delete from ProjectItemProcessing where idProject = @idProjectNew  
    delete from ProjectItem           where idProject = @idProjectNew  
    delete from Project               where ID = @idProjectNew  
  end  
  
  set @sSQL = 'insert into Project(Num,nCount,idTask,SumNoNDS,SumNDS,SumWithNDS,bRecalcPriceLock,Commentary'  
    
  if IsNull(@idProjectItemSrc, 0) > 0  
    set @sSQL = @sSQL + ',GPName'  
    
  /*  
  if IsNull(@idProjectItemSrc, 0) > 0  
  begin  
    select @sGPNameProject = GPName from Project where ID = @idProjectSrc  
 set @sGlassNameWithOper = dbo.f_GetGlassStruct(@sGPNameProject , @nGlass)  
  end  
  */  
    
  set @sSQL = @sSQL +','+ @sFieldList + ') select ' + cast(@Num as varchar) +','+ cast(@nCount as varchar) +','+ cast(@idTask as varchar) +','+  @sPriceValues  
   
  if IsNull(@idProjectItemSrc, 0) = 0  
    set @sSQL = @sSQL + ',1,left(IsNull(Commentary, '''') + '' '' + ''' + IsNull(@sCommentReject, 'Переделка брака!!!') + ''', 250)'  
  else  
  begin  
    if @PInType = 6  
      set @sSQL = @sSQL + ',0,left(IsNull(Commentary, '''') + ''Переделка брака ' + cast(@nGlass as varchar) + '-й рамки!!!'',250),' +''''+ @sGPName +''''  
    else if @PInType = 5  
      set @sSQL = @sSQL + ',0,left(IsNull(Commentary, '''') + ''Переделка брака ' + cast(@nGlass as varchar) + '-го стекла!!!'',250),' +''''+ @sGPName +''''  
    else
     set @sSQL = @sSQL + ',0,left(IsNull(Commentary, '''') + ''Переделка брака!!!'',250),' + '''' + @sGPName + ''''
  end  
      
  set @sSQL = @sSQL + ',' + @sFieldList  
                    + ' from Project where ID = ' + cast(@idProjectSrc as varchar)  
                    + ' select @idProjectOUT = SCOPE_IDENTITY()'  
  
  --print @idProjectNew  
  exec sp_executesql @sSQL, N'@idProjectOUT int output', @idProjectOUT = @idProjectNew output  
  --print @idProjectNew  

  select @bSetRecalcPriceLockToZero = d_iNum from Config where Name = 'bSetRecalcPriceLockToZero'  
  if @bSetRecalcPriceLockToZero = 1  
    update Project set bRecalcPriceLock = 0 where ID = @idProjectNew  -- при создании переделки цена на основной заказ может быть заблокирована, если хотим что бы в переделке цена пересчиытвалась из справочника, ставим 0  
  
  select @guidProjectNew = GUID from Project where ID = @idProjectNew  
  -- Копирование чертежа.  
  exec sp_PlotCopy @guidProjectSrc, @guidProjectNew  
  
  if @PInType = 6  
  begin  
    -- ProjectItem  
    declare curProjectItem cursor for  
    select ID from ProjectItem  
    where  
    idProject = @idProjectSrc and  
    nGlass    = @nGlass       and   
    nType     = 6  
        
      order by Num, ID -- забираем не только само стекло, но и обработки  
  end  
  else  
  begin  
    -- ProjectItem  
    -- Делаем через курсор, т.к нужно сверления привязать к нужному новому ProjectItem    
    declare curProjectItem cursor for  
    select ID from ProjectItem  
    where  
    idProject = @idProjectSrc and  
    (  
      (@idProjectItemSrc = 0 and @bFullTriplex = 0 or (nGlass = @nGlass and nGlassTriplex = @nGlassTriplex and nType in (5,8))) or  
      (@bFullTriplex = 1 and nGlass = @nGlass and nGlassTriplex > 0 and nType in (5,7,8))  
    )  
        
    order by Num, ID -- забираем не только само стекло, но и обработки  
  end  
  
  open curProjectItem  
  while 1 = 1  
  begin  
    fetch next from curProjectItem into @idProjectItemSrc  
    if @@FETCH_STATUS != 0  
      break  
  
    set @sSQL = 'insert into ProjectItem (idProject,guidProject,' + @sFieldListPI + ')'  
              + ' select ' + CAST(@idProjectNew   as varchar)  
              + ','''      + CAST(@guidProjectNew as varchar(38))  
              + ''','      + @sFieldListPI  
              + ' from ProjectItem'  
              + ' where ID = ' + CAST(@idProjectItemSrc as varchar)  
              + ' select @idProjectItemOUT = SCOPE_IDENTITY()'  
  
    exec sp_executesql @sSQL, N'@idProjectItemOUT int output', @idProjectItemOUT = @idProjectItemNew output  
    select @guidProjectItemNew = GUID from ProjectItem where ID = @idProjectItemNew  
  
    -- Drill сверления  
    set @sSQL = 'insert into Drill (idProjectItem, guidProjectItem,' + @sFieldListDrill + ')'  
              + ' select ' + CAST(@idProjectItemNew   as varchar)  
              + ','''      + CAST(@guidProjectItemNew as varchar(38))  
              + ''','      + @sFieldListDrill  
              + ' from Drill'  
              + ' where idProjectItem = ' + CAST(@idProjectItemSrc as varchar)  
    exec(@sSQL)  
  end  
  close curProjectItem  
  deallocate curProjectItem  
  
  insert into ProjectItemProcessing  
  (  
    idProject,  
    guidProject,  
    nGlassProjectItem,  
    idSectorManufact,  
    nOrderItemProcessing,  
-- Забыли поля а на них строятся и диалоги и отчеты  
    RequiredTime,  
    NumProject,  
    NumItem,  
    nCount,  
    NumProjectItem  
  )  
  select  
    @idProjectNew,  
    @guidProjectNew,  
    nGlassProjectItem,  
    idSectorManufact,  
    nOrderItemProcessing,  
    RequiredTime,  
    NumProject,  
    NumItem,  
    nCount,  
    NumProjectItem  
  from ProjectItemProcessing  
  where ProjectItemProcessing.idProject = @idProjectSrc  
  
  -- процессинги забыли  
  while @nCountItem <= @nCount  
  begin  
    insert into GlassProcessing  
    (  
      TimeProcessing,  
      idSectorManufact,  
      guidProjectItemProcessing,  
      GPNum,  
      guidProject  
    )  
    select  
      RequiredTime,  
      idSectorManufact,  
      GUID,  
      @nCountItem,  
      guidProject  
    from ProjectItemProcessing      where ProjectItemProcessing.guidProject = @guidProjectNew  
  
    set @nCountItem = @nCountItem + 1  
  end  
  
  set nocount off  
end  