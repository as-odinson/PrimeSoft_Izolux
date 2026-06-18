-- Создание заказов на переделку брака.  
create procedure dbo.sp_RemakeTaskByBarCodes   
                       @SPID                    int,   
                       @bAddInExistsTask        bit = 0, -- Добавление СП в существующий заказ на переделку, если таковой есть.  
                       @bCreateCreditNote       bit = 0, -- [ab] Создавать кредит-ноту?  
                       @bCheckCombinationReject bit = 1, -- проверять ли существование  комбинации браков:  
                                                         -- 0 - не проверяем (вызов из фактори тул)  
                                                         -- 1 - проверяем    (вызов из Гласса)   
                       @sListProjectItem        varchar(max) = '',  
                       @idBarCode               int = 0        --  ID баркода (Пока будем подавать из FactoryTool)  
                       --@sListIDTask_Remake      varchar(max) output -- вывод списка созданых тасков                                
as  
begin  
  set nocount on  
  
  create table #BC  
  (  
    idTask           int,  
    AccountNum       varchar(150) collate Cyrillic_General_CI_AS,  
    idProject        int,  
    idBarCode_Reject int,  
    idBarCode_Reject_Father int,  
    PosNum           int,  
    bWarranty        bit,  
    bNullPrice       bit,  
    CommentReject    varchar(256)  
  )  
  
  create table #ProjectNew  
  (  
    ID     int,  
    idTask int  
  )  
    
  -- ProjectItem  
  create table #PI  
  (  
    ID          int,  
    Name        varchar(256),  
    Num         tinyint,  
    NumTriplex  tinyint,  
    sGlassOper  varchar(256)  
  )  
  
  print 'Вставка бракованных ' + convert(varchar, getdate(), 104) + ' @bCheckCombinationReject = ' + cast(@bCheckCombinationReject as varchar)   
  
  -- Запуск из Glass:   
  if  @idBarCode = 0 and @SPID > 0   
    insert into #BC(idTask, AccountNum, idProject, idBarCode_Reject, idBarCode_Reject_Father, PosNum, bWarranty, bNullPrice, CommentReject)  
    select  
      P.idTask,  
      T.AccountNum,  
      B.idProject,  
      B.ID,  
      IsNull(idBarCode_Reject_Father, 0),  
      P.Num,  
      TE.bWarranty,  
      TE.bNullPrice,  
      IsNull(CR.CommentReject, CR_D.CommentReject)  
    from  
      IDTempStore ITS  
        inner join BarCode B              on B.ID    = ITS.ID  
        inner join Project P              on P.ID    = B.idProject  
        inner join Task T                 on T.ID    = P.idTask  
        left  join CombinationReject CR   on CR.ID   = B.idCombinationReject  
        left  join CombinationReject CR_D on CR_D.ID = B.idCombinationReject_Declare  
        left  join TypeExpense TE         on TE.ID   = CR.idTypeExpense  
    where  
      ITS.SPID  = @SPID and  
      ITS.nType = 3     and  
      ( @bCheckCombinationReject = 0 or        -- проверять ли комбинации браков  
        -- если выставлен фактический брак   
        (  
          IsNull(CR.idRejectType,  0) != 0 and  
          IsNull(CR.idReject,      0) != 0 and  
          IsNull(CR.idRejectPlace, 0) != 0 and  
          IsNull(CR.idRejectAct,   0) != 0 and  
          IsNull(CR.idTypeExpense, 0) != 0  
        ) or  
        -- если выставлен заявленый брак  
        (  
          IsNull(CR_D.idRejectType,  0) != 0 and  
          IsNull(CR_D.idReject,      0) != 0 and  
          IsNull(CR_D.idRejectPlace, 0) != 0 and  
          IsNull(CR_D.idRejectAct,   0) != 0 and  
          IsNull(CR_D.idTypeExpense, 0) != 0  
        )  
      )  
  -- Запуск из FactoryTool: подаем только 1 штрихкод  
  else  
    insert into #BC(idTask, AccountNum, idProject, idBarCode_Reject, idBarCode_Reject_Father, PosNum, bWarranty, bNullPrice, CommentReject)  
    select  
      P.idTask,  
      T.AccountNum,  
      B.idProject,  
      B.ID,  
      IsNull(idBarCode_Reject_Father, 0),  
      P.Num,  
      TE.bWarranty,  
      TE.bNullPrice,  
      ''  
    from  
      BarCode B  
        inner join Project P              on P.ID    = B.idProject  
        inner join Task T                 on T.ID    = P.idTask  
        left  join CombinationReject CR   on CR.ID   = B.idCombinationReject  
        left  join CombinationReject CR_D on CR_D.ID = B.idCombinationReject_Declare  
        left  join TypeExpense TE         on TE.ID   = CR.idTypeExpense  
    where  
      B.ID  = @idBarCode and  
      ( @bCheckCombinationReject = 0 or        -- проверять ли комбинации браков  
        -- если выставлен фактический брак  
        (  
          IsNull(CR.idRejectType,  0) != 0 and  
          IsNull(CR.idReject,      0) != 0 and  
          IsNull(CR.idRejectPlace, 0) != 0 and  
          IsNull(CR.idRejectAct,   0) != 0 and  
          IsNull(CR.idTypeExpense, 0) != 0  
        ) or  
        -- если выставлен заявленый брак  
        (  
          IsNull(CR_D.idRejectType,  0) != 0 and  
          IsNull(CR_D.idReject,      0) != 0 and  
          IsNull(CR_D.idRejectPlace, 0) != 0 and  
          IsNull(CR_D.idRejectAct,   0) != 0 and  
          IsNull(CR_D.idTypeExpense, 0) != 0  
        )  
      )  
  
  --select * from #BC  
  
  declare   
    @idTask                  int,  
    @idTaskOld               int,  
    @idProject               int,  
    @idProjectNew            int,  
    @idProjectOld            int,  
    @nCountBCPos             int,  
    @nCountBCTask            int,  
    @idTaskRemake            int,  
    @PosNum                  int,  
    @PosNumOld               int,  
    @sAccountNum             varchar(64),  
    @sAccountNumOld          varchar(64),  
    @idBarCode_Reject        int,  
    @idBarCode_Reject_Father int,  
    @idBCNew                 int,  
    @bBreak                  bit,  
    @bWarranty               bit,  
    @bNullPrice              bit,  
    @idClient                int,  
    @Price                   float,  
    @bAssignZeroPriceRemake  bit, -- Всегда присваивать нулевую цену переделанным по браку позициям  
    @sSQL                    nvarchar(max),  
    @sFieldList              nvarchar(max),  
    @idProjectItemSrc        int,  
    @sGPName                 varchar(256),  
    @sGPNamePrev             varchar(256),  
    @sGlassTriplexOper       varchar(256),  
    @sSymbolTriplex          varchar(2),  
    @nGlass                  tinyint,  
    @nGlass_Prev             tinyint,  
    @nGlassTriplex           tinyint,  
    @bFullTriplex            bit,  
    @idNDS                   int,  
    @CurDate                 datetime,  
    @sGlassOper              varchar(256),  
    @bTypeOrderRemake        bit,  
    @CommentReject           varchar(256)  
      
  -- Текущая дата  
  select   
    @CurDate            = GetDate()--,  
    --@sListIDTask_Remake = ''  
      
  -- Вытащим текущий НДС раз и навсегда на все заказы    
  select top 1   
    @idNDS = ID   
  from   
    NDS   
  where   
     DateBegin <= @CurDate and    
     DateEnd   >= @CurDate  
  order by   
     isNull(bDef, 0) desc,  -- берём первый из тех, кто bDef, если bDef не выставлен вообще, то первый попавшийся  
     ID           
            
  select @bAssignZeroPriceRemake = d_iNum from Config where Name = 'bAssignZeroPriceRemake'  
    
  select @bTypeOrderRemake = d_iNum from Config where Name = 'bTypeOrderRemake'  
  
  -- [ab] TODO: Сделать более сложный алгоритм. Пока так:  
  select top 1   
    @idClient = T.idClient,   
    @Price    = case when IsNull(P.nCount, 0) = 0 then 0 else P.SumWithNDS / P.nCount end  
  from  
    IDTempStore ITS inner join BarCode B   on B.ID = ITS.ID  
                    inner join Project P   on P.ID = B.idProject  
                    inner join Task    T   on T.ID = P.idTask  
  
  select  
    @idTaskOld    = -1,  
    @idProjectNew =  0,  
    @idProjectOld = -1,  
    @nCountBCPos  =  0,  
    @nCountBCTask =  0,  
    @idTaskRemake =  0,  
    @bBreak       =  0,  
    @nGlass_Prev  =  0,  
    @bFullTriplex =  0  
  
  print 'Курсор по бракам ' + convert(varchar, getdate(), 104)  
  
  declare curB cursor for  
  select  
    idTask,  
    AccountNum,  
    idProject,  
    idBarCode_Reject,  
    PosNum,  
    bWarranty,  
    bNullPrice,  
    CommentReject  
  from   
    #BC  
  order by   
    idTask,   
    idProject,   
    idBarCode_Reject  
  
  open curB  
  
  while 1 = 1  
  begin  
    fetch next from curB into @idTask, @sAccountNum, @idProject, @idBarCode_Reject, @PosNum, @bWarranty, @bNullPrice, @CommentReject  
    if @@FETCH_STATUS != 0  
      break  
  
    print @idTask  
  
    set @nCountBCPos    = @nCountBCPos + 1  
    set @sAccountNumOld = @sAccountNum  
  
    if IsNull(@bAssignZeroPriceRemake, 0) = 1  -- Всегда присваивать нулевую цену переделанным по браку позициям?  
      set @bNullPrice = 1  
  
    if @idTask != @idTaskOld  
    begin  
      if @idTaskRemake != 0  
      begin  
        set @nCountBCPos  = @nCountBCPos - 1  
          
        if LEN(@sListProjectItem) = 0  
        begin  
          exec sp_RTB_ProjectCopy @idProjectOld, @PosNumOld, @nCountBCPos, @idTaskRemake, @bNullPrice, 0,'', 0, 0, 0, @CommentReject, @idProjectNew output  
          insert into #ProjectNew (ID, idTask) values (@idProjectNew, @idTaskRemake)  
        end  
        else  
        begin  
          truncate table #PI  
          set @sSQL = 'insert into #PI select PI.ID as ID, Pr.Name, PI.nGlass as Name, PI.nGlassTriplex, dbo.f_GetGP_GlassOper(PI.idProject, PI.nGlass, PI.nGlassTriplex, 5) as sGlassOper from ProjectItem PI '   
                    + ' inner join Product Pr on Pr.ID = PI.idProd '   
                    + 'where PI.idProject = ' + cast(@idProjectOld as nvarchar) + ' and PI.ID in (' + @sListProjectItem + ') '  
  
          exec sp_executesql @sSQL  
  
          declare curPI cursor for select ID, Name, Num, NumTriplex, sGlassOper from #PI  
          open curPI  
          while 1 = 1  
          begin  
            fetch next from curPI into @idProjectItemSrc, @sGPName, @nGlass, @nGlassTriplex, @sGlassOper  
            if @@FETCH_STATUS != 0  
              break  
  
            -- Вывод пленки не нужен, если одно стекло  
            if charindex('.', @sGlassOper) > 0  
              set @sSymbolTriplex = '.'  
            else if charindex('+', @sGlassOper) > 0  
              set @sSymbolTriplex = '+'  
  
            if @nGlassTriplex > 0 and Len(IsNull(@sGlassOper, '')) > 0 and charindex(@sSymbolTriplex , @sGlassOper) > 0  
            begin  
              set @sGlassTriplexOper = right(@sGlassOper, charindex(@sSymbolTriplex , reverse(@sGlassOper))) -- оставляем только последнюю часть  
              set @sGlassOper        = left(@sGlassOper,  Len(@sGlassOper) - charindex(@sSymbolTriplex , reverse(@sGlassOper)))  
            end  
            else  
              set @sGlassTriplexOper = ''  
  
              -- если есть обработка на стекле  
            if Len(IsNull(@sGlassOper, '')) > 0  
              set @sGPName = @sGPName + '+' + @sGlassOper  
  
            -- Если предыдущее номер стекла совпадает с текущим и стоит значение триплекса, тогда ставим флаг что необходимо создать полностью триплексное стекло  
            if @nGlass = @nGlass_Prev and @nGlassTriplex > 0  
            begin  
              set @bFullTriplex = 1  
              set @sGPName      = @sGPNamePrev + @sGPName  
            end  
            else   
              set @bFullTriplex = 0  
  
            print @sGPName  
  
            exec sp_RTB_ProjectCopy @idProjectOld, @PosNumOld, @nCountBCPos, @idTaskRemake, 1, @idProjectItemSrc, @sGPName, @nGlass, @nGlassTriplex, @bFullTriplex, @CommentReject, @idProjectNew output  
                                                                                                        --| - обнулить стоимость   
            insert into #ProjectNew (ID, idTask) values (@idProjectNew, @idTaskRemake)  
  
            set @nGlass_Prev = @nGlass  
            set @sGPNamePrev = @sGPName + @sGlassTriplexOper  
          end  
            
          close curPI  
          deallocate curPI  
        end  
  
        set @idProjectOld = @idProject  
        set @PosNumOld    = @PosNum  
        set @nCountBCTask = @nCountBCTask + @nCountBCPos  
        set @nCountBCPos  = 1  
  
        -- создание баркодов на новый заказ.  
        exec sp_FillBarCodeTask @idTaskRemake  
        -- пересчет сложности заказа.  
        exec sp_TaskCheckComplex @idTaskRemake  
        -- установка кол-ва СП в заказе, признак ожидания отправки реплики сбрасывам  
        update Task set PosCount = @nCountBCTask, bWaitReplic = 0 where ID = @idTaskRemake  
  
        -- пересчет цены заказа.  
        exec sp_RecalcTask_Price @idTaskRemake, 1  
  
        -- присвоим idBarCode_Reject новым баркодам.  
        declare curBCOld cursor for  
          -- [YK] заменил IsNull на case, так как проверка IsNull есть ранее  
          select  
            idBarCode_Reject,  
            case when idBarCode_Reject_Father = 0 then idBarCode_Reject else idBarCode_Reject_Father end as idBarCode_Reject_Father  
          from #BC  
          where idTask = @idTaskOld  
          order by idProject, idBarCode_Reject  
  
        -- Обнаружил такую неприятную особенность:  
        -- Если объявлен курсор, в котором запрос с сортировкой, то:  
        -- В отсутствии индекса на Project c единственным ключом по idTask будет идти сканирование Project.  
        -- В отсутствии индекса на BarCode c единственным ключом по idProject будет идти сканирование BarCode.  
        -- Т.е. индексы i_Project_idTask_idProd и i_BarCode_idProject_idTransport рассматриваться не будут!  
        -- Но если убрать сортировку или запустить запрос с сортировкой, но без создания курсора, то составные индексы будут использованы.  
        declare curBCNew cursor for  
          select  
            B.ID  
          from #ProjectNew PN  
            inner join BarCode B on B.idProject = PN.ID  
          where PN.idTask = @idTaskRemake  
          order by PN.ID, B.ID  
          option(force order)  
  
        open curBCOld  
        open curBCNew  
  
        while 1 = 1  
        begin  
          fetch next from curBCOld into @idBarCode_Reject, @idBarCode_Reject_Father  
          if @@FETCH_STATUS != 0  
            break  
          fetch next from curBCNew into @idBCNew  
          if @@FETCH_STATUS != 0  
            break  
  
          update BarCode set  
            idBarCode_Reject        = @idBarCode_Reject,  
            idBarCode_Reject_Father = @idBarCode_Reject_Father,  
            nState                  = IsNull(nState, 0) | 2      -- Выставляем признак "Производить" чтобы можно было включить в раскрой  
          where ID = @idBCNew  
        end  
  
        close      curBCOld  
        deallocate curBCOld  
        close      curBCNew  
        deallocate curBCNew  
      end  
  
      -- создадим заказ.  
      if @bAddInExistsTask = 1  
      begin  
        -- Поищем заказ на переделку, в котором есть СП с данного заказа.  
        set @idTaskRemake = 0  
        select top 1  
          @idTaskRemake = P.idTask  
        from Project P  
          inner join BarCode B on B.idProject = P.ID  
          inner join (select  
                        B.ID  
                      from Project P  
                        inner join BarCode B on B.idProject = P.ID  
                      where P.idTask = @idTask) BR on BR.ID = B.idBarCode_Reject  
  
      end  
  
      if @bAddInExistsTask = 0 or @bAddInExistsTask = 1 and @idTaskRemake = 0  
      begin  
        -- Теперь номер заказа-переделки генерим ф-цией.  
        select @sAccountNum = dbo.f_GetNextAccountNumForRejectTask(@idTask, @idBarCode_Reject)  
  
        -- Вставляем в новый заказ поля со старого заказа.  
        declare  @sClientNum       varchar(100),  
                 @sTypeOrderValue  varchar(1)     -- для TypeOrder  
  
        set @sClientNum = 'Брак по счёту № ' + @sAccountNumOld  
        -- [ab] Очень нужно Стису писать  
  
        if @bTypeOrderRemake = 1  
        begin  
          set @sTypeOrderValue = '1'  
          -- Task  
          select @sFieldList = dbo.f_GetTableFieldList('Task', 'AccountNum,NumCalcFact,NumCalcFact_Dealer,iNumCalcFact,Commentary,ID,nReplicState,GUID,onReplication,Area,PosCount,Price,Paid,nState,nStateManuf,Date,bWarranty,ClientNum,TypeOrder', '')  
          set @sSQL = 'insert into Task(AccountNum,Commentary,bWarranty,TypeOrder,' + @sFieldList + ',ClientNum)'  
                    + ' select ''' + @sAccountNum + ''', left(IsNull(Commentary, '''') + '' Переделка брака!!!'', 250), '  
                    + cast(IsNull(@bWarranty, 0) as varchar(1)) + ',' + @sTypeOrderValue + ',' + @sFieldList + ', ''' + @sClientNum + ''' '  
                    + ' from Task'  
                    + ' where ID = ' + CAST(@idTask as varchar)  
                    + ' select @idTaskOUT = SCOPE_IDENTITY()'          
  
          exec sp_executesql @sSQL, N'@idTaskOUT int output', @idTaskOUT = @idTaskRemake output  
        end  
        else  
        begin  
          -- Task  
          select @sFieldList = dbo.f_GetTableFieldList('Task', 'AccountNum,NumCalcFact,NumCalcFact_Dealer,iNumCalcFact,Commentary,ID,nReplicState,GUID,onReplication,Area,PosCount,Price,Paid,nState,nStateManuf,Date,bWarranty,ClientNum', '')  
          set @sSQL = 'insert into Task(AccountNum,Commentary,bWarranty,' + @sFieldList + ',ClientNum)'  
                    + ' select ''' + @sAccountNum + ''',left(IsNull(Commentary, '''') + ''Переделка брака!!!'', 250),' + cast(IsNull(@bWarranty, 0) as varchar(1)) + ',' + @sFieldList + ', ''' + @sClientNum + ''' '  
                    + ' from Task'  
                    + ' where ID = ' + CAST(@idTask as varchar)  
                    + ' select @idTaskOUT = SCOPE_IDENTITY()'          
  
          exec sp_executesql @sSQL, N'@idTaskOUT int output', @idTaskOUT = @idTaskRemake output  
        end  
        -- Вот тут достанем действующий НДС и присвоим его  
      end  
  
      -- После вставки записи в Task по триггеру на after insert могут слететь некоторые поля. Восстановим их!  
      declare   
        @CalcType               int,  
        @idDeliveryAddress      int,  
        @idClientBank_Client    int,  
        @idClientBank_Seller    int,  
        @idClientBank_Consignee int,  
        @idClientBank_Shipper   int,  
        @Date                   datetime,  
        @DateGiveManufact       datetime  
  
      select  
        @CalcType               = CalcType,  
        @idDeliveryAddress      = idDeliveryAddress,  
        @idClientBank_Client    = idClientBank_Client,  
        @idClientBank_Seller    = idClientBank_Seller,  
        @idClientBank_Consignee = idClientBank_Consignee,  
        @idClientBank_Shipper   = idClientBank_Shipper,  
        @Date                   = Date,  
        @DateGiveManufact       = DateGiveManufact  
      from   
        Task   
      where   
        ID = @idTask  
        
      if @DateGiveManufact < floor(cast(@Date as float))  
        set @DateGiveManufact = floor(cast(@Date as float)) -- Дату изготовления выставим как дату создания, если она меньше даты создания.  
          
      declare @idClientRemakeReject int  
      select @idClientRemakeReject = d_iNum from Config where Name = 'idClientForRemakeReject'  
      set @idClientRemakeReject = IsNull(@idClientRemakeReject, 0)  
  
      if @idClientRemakeReject = 0  
        update Task set  
          CalcType               = @CalcType,  
          idDeliveryAddress      = @idDeliveryAddress,  
          idClientBank_Client    = @idClientBank_Client,  
          idClientBank_Seller    = @idClientBank_Seller,  
          idClientBank_Consignee = @idClientBank_Consignee,  
          idClientBank_Shipper   = @idClientBank_Shipper,  
          DateGiveManufact       = @DateGiveManufact,  
          idNDS                  = @idNDS  
        where   
          ID = @idTaskRemake  
      else  
        update Task set  
          idClient               = @idClientRemakeReject,  
          idDeliveryAddress      = null,  
          idClientBank_Client    = null,  
          idClientBank_Seller    = null,  
          idClientBank_Consignee = null,  
          idClientBank_Shipper   = null,  
          DateGiveManufact       = @DateGiveManufact,  
          idNDS                  = @idNDS  
        where   
          ID = @idTaskRemake  
  
      set @idTaskOld = @idTask  
        
      -- Сформируем список вывода  
      /*  
      if len(@sListIDTask_Remake) <> 0  
        set @sListIDTask_Remake = @sListIDTask_Remake + ','  
        
      set @sListIDTask_Remake = @sListIDTask_Remake + ltrim(str(@idTaskRemake))   
      */  
        
      -- хочу через таблицо  
      insert into IDTempStore(ID, nType, SPID)  
      values  
      (  
        @idTaskRemake, -- ID    - int  
        100,           -- nType - int - e_SPID_Reject_Task  
        @SPID  
      )  
        
      /* № Заказа присваиваем тот же, что и у исходного заказа, с припиской _1, поэтому счетчик не дергаем.  
      if exists(select ID from Config where Name = 'TaskAccountNum' and d_iNum = 1)  
        -- Обновим счетчик iAccountNum в Config.  
        update Config set d_iNum = d_iNum + 1 where Name = 'iAccountNumCurNum'  
      */  
        
    end  
  
    if @idProject != @idProjectOld and @idProjectOld != -1  
    begin  
      -- создаем позицию.  
      set @nCountBCPos = @nCountBCPos - 1  
        
      select   
        @nCountBCTask = count(*)   
      from   
        Project P inner join BarCode B on B.idProject = P.ID   
      where   
        P.idTask = @idTaskRemake  
  
      if LEN(@sListProjectItem) = 0  
      begin  
        exec sp_RTB_ProjectCopy @idProjectOld, @PosNumOld, @nCountBCPos, @idTaskRemake, @bNullPrice, 0, '', 0, @nGlassTriplex, 0, @CommentReject, @idProjectNew output  
        insert into #ProjectNew (ID, idTask) values (@idProjectNew, @idTaskRemake)  
      end  
      else  
      begin  
        truncate table #PI  
        set @sSQL = 'insert into #PI select PI.ID as ID, Pr.Name, PI.nGlass as Name, PI.nGlassTriplex as NumTriplex, dbo.f_GetGP_GlassOper(PI.idProject, PI.nGlass, PI.nGlassTriplex, 5) as sGlassOper from ProjectItem PI '    
                  + ' inner join Product Pr on Pr.ID = PI.idProd '   
                  + 'where PI.idProject = ' + cast(@idProjectOld as nvarchar) + ' and PI.ID in (' + @sListProjectItem + ') '  
  
        exec sp_executesql @sSQL  
  
        declare curPI cursor for select ID, Name, Num, NumTriplex, sGlassOper from #PI  
        open curPI  
        while 1 = 1  
        begin  
          fetch next from curPI into @idProjectItemSrc, @sGPName, @nGlass, @nGlassTriplex, @sGlassOper  
          if @@FETCH_STATUS != 0  
            break  
  
          -- Вывод пленки не нужен, если одно стекло  
          if charindex('.', @sGlassOper) > 0  
            set @sSymbolTriplex = '.'  
          else if charindex('+', @sGlassOper) > 0  
            set @sSymbolTriplex = '+'  
  
          if @nGlassTriplex > 0 and Len(IsNull(@sGlassOper, '')) > 0 and charindex(@sSymbolTriplex , @sGlassOper) > 0  
          begin  
            set @sGlassTriplexOper = right(@sGlassOper, charindex(@sSymbolTriplex , reverse(@sGlassOper))) -- оставляем только последнюю часть  
            set @sGlassOper        = left(@sGlassOper,  Len(@sGlassOper) - charindex(@sSymbolTriplex , reverse(@sGlassOper)))  
          end  
          else  
            set @sGlassTriplexOper = ''  
  
            -- если есть обработка на стекле  
          if Len(IsNull(@sGlassOper, '')) > 0  
            set @sGPName = @sGPName + '+' + @sGlassOper  
  
          -- Если предыдущее номер стекла совпадает с текущим и стоит значение триплекса, тогда ставим флаг что необходимо создать полностью триплексное стекло  
          if @nGlass = @nGlass_Prev and @nGlassTriplex > 0  
          begin  
            set @bFullTriplex = 1  
            set @sGPName      = @sGPNamePrev + @sGPName  
          end  
          else   
            set @bFullTriplex = 0  
  
          --print @sGPName  
  
          exec sp_RTB_ProjectCopy @idProjectOld, @PosNumOld, @nCountBCPos, @idTaskRemake, 1, @idProjectItemSrc, @sGPName, @nGlass, @nGlassTriplex, @bFullTriplex, @CommentReject, @idProjectNew output  
                                                                                                      --| - обнулить стоимость   
          insert into #ProjectNew (ID, idTask) values (@idProjectNew, @idTaskRemake)  
  
 set @nGlass_Prev = @nGlass  
          set @sGPNamePrev = @sGPName + @sGlassTriplexOper  
        end  
          
        close curPI  
        deallocate curPI  
      end  
  
      set @nCountBCTask = @nCountBCTask + @nCountBCPos  
      set @nCountBCPos  = 1  
    end  
    set @idProjectOld = @idProject  
    set @PosNumOld    = @PosNum  
  
    -- [ab] Создаём кредит-ноту?  
    if @bCreateCreditNote = 1  
    begin  
      insert into Payment (idClient,  nType, DatePay,                    SumPay, idPayDocType)  
      values              (@idClient, 0,     dbo.f_TruncDate(getdate()), @Price, 2)  
  
      print 'Кредит-Нот'  
    end  
  end  
  
  close      curB  
  deallocate curB  
  
  -- Если заказ на переделку не создан, то дальше нам тут делать нечего.  
  if IsNull(@idProjectOld, 0) <= 0 or IsNull(@idTaskRemake, 0) <= 0  
    return  
  
  print 'Начинаем делать копию ' + convert(varchar, getdate(), 104)  
  
  select @nCountBCTask = count(*) from Project P inner join BarCode B on B.idProject = P.ID where P.idTask = @idTaskRemake  
  
  if LEN(@sListProjectItem) = 0  
  begin  
    exec sp_RTB_ProjectCopy @idProjectOld, @PosNumOld, @nCountBCPos, @idTaskRemake, @bNullPrice, 0, '', 0, 0, 0, @CommentReject, @idProjectNew output  
    insert into #ProjectNew (ID, idTask) values (@idProjectNew, @idTaskRemake)  
  end  
  else  
  begin  
    truncate table #PI  
    set @sSQL = 'insert into #PI select PI.ID as ID, Pr.Name, PI.nGlass as Name, PI.nGlassTriplex as NumTriplex, dbo.f_GetGP_GlassOper(PI.idProject, PI.nGlass, PI.nGlassTriplex, 5) as sGlassOper from ProjectItem PI '   
              + ' inner join Product Pr on Pr.ID = PI.idProd '   
              + 'where PI.idProject = ' + cast(@idProjectOld as nvarchar) + ' and PI.ID in (' + @sListProjectItem + ') '  
  
    exec sp_executesql @sSQL  
  
    declare curPI cursor for select ID, Name, Num, NumTriplex, sGlassOper from #PI  
    open curPI  
    while 1 = 1  
    begin  
      fetch next from curPI into @idProjectItemSrc, @sGPName, @nGlass, @nGlassTriplex, @sGlassOper  
      if @@FETCH_STATUS != 0  
        break  
      -- Вывод пленки не нужен, если одно стекло  
      if charindex('.', @sGlassOper) > 0  
        set @sSymbolTriplex = '.'  
      else if charindex('+', @sGlassOper) > 0  
        set @sSymbolTriplex = '+'  
  
      if @nGlassTriplex > 0 and Len(IsNull(@sGlassOper, '')) > 0 and charindex(@sSymbolTriplex , @sGlassOper) > 0  
      begin  
        set @sGlassTriplexOper = right(@sGlassOper, charindex(@sSymbolTriplex , reverse(@sGlassOper))) -- оставляем только последнюю часть  
        set @sGlassOper        = left(@sGlassOper,  Len(@sGlassOper) - charindex(@sSymbolTriplex , reverse(@sGlassOper)))  
      end  
      else  
        set @sGlassTriplexOper = ''  
  
        -- если есть обработка на стекле  
      if Len(IsNull(@sGlassOper, '')) > 0  
        set @sGPName = @sGPName + '+' + @sGlassOper  
  
      -- Если предыдущее номер стекла совпадает с текущим и стоит значение триплекса, тогда ставим флаг что необходимо создать полностью триплексное стекло  
      if @nGlass = @nGlass_Prev and @nGlassTriplex > 0  
      begin  
        set @bFullTriplex = 1  
        set @sGPName      = @sGPNamePrev + '+' + @sGPName  
      end  
      else   
        set @bFullTriplex = 0  
  
      exec sp_RTB_ProjectCopy @idProjectOld, @PosNumOld, @nCountBCPos, @idTaskRemake, 1, @idProjectItemSrc, @sGPName, @nGlass, @nGlassTriplex, @bFullTriplex, @CommentReject, @idProjectNew output  
                                                                                                  --| - обнулить стоимость   
      insert into #ProjectNew (ID, idTask) values (@idProjectNew, @idTaskRemake)  
  
      set @nGlass_Prev = @nGlass  
      set @sGPNamePrev = @sGPName + @sGlassTriplexOper  
    end  
      
    close curPI  
    deallocate curPI  
  end  
  
  set @nCountBCTask = @nCountBCTask + @nCountBCPos  
  
  print 'Создаём баркоды ' + convert(varchar, getdate(), 104)  
  -- создание баркодов на новый заказ.  
  exec sp_FillBarCodeTask @idTaskRemake  
  -- пересчет сложности заказа.  
  exec sp_TaskCheckComplex @idTaskRemake  
  -- установка кол-ва СП в заказе, признак ожидания отправки реплики сбрасывам  
  update Task set PosCount = @nCountBCTask, bWaitReplic = 0 where ID = @idTaskRemake  
  -- пересчет цены заказа.  
  exec sp_RecalcTask_Price @idTaskRemake, 1  
  
  -- Если без проверки существования комбинаций браков (из фактори тула вызов),  
  -- то присвоим сразу статус Производить заказу  
  if @bCheckCombinationReject = 0  
  begin  
    /*  
    update Task set nState = IsNull(nState, 0) | 2 where ID = @idTaskRemake  
  
    update B set B.nState = IsNull(B.nState, 0) | 2  -- Производить  
    from BarCode B   
      inner join Project P on P.ID = B.idProject  
    where P.idTask = @idTaskRemake  
    */  
  
    update Task set   
      nState = IsNull(nState, 0) | 2                                 -- e_TaskState_ToManuf  
    where ID in   
    (  
      select ID from IDTempStore where nType = 100 and SPID = @SPID  -- e_SPID_Reject_Task  
    )  
  
    update B set   
      B.nState = IsNull(B.nState, 0) | 2                             -- e_TaskState_ToManuf - Производить  
    from   
      BarCode B inner join Project P on P.ID = B.idProject  
    where   
      P.idTask in   
      (  
        select ID from IDTempStore where nType = 100 and SPID = @SPID  -- e_SPID_Reject_Task  
      )  
  
    /*  
      insert into IDTempStore(ID, nType, SPID)  
      values  
      (  
        @idTaskRemake, -- ID    - int  
        100,           -- nType - int  
        @SPID  
      )  
    */  
  end  
  
  -- присвоим idBarCode_Reject новым баркодам.  
  declare curBCOld cursor for  
    select  
      idBarCode_Reject,  
      case when idBarCode_Reject_Father = 0 then idBarCode_Reject else idBarCode_Reject_Father end as idBarCode_Reject_Father  
    from #BC  
    where idTask = @idTaskOld  
    order by idProject, idBarCode_Reject  
  
  declare curBCNew cursor for  
    select  
      B.ID  
    from #ProjectNew PN  
      inner join BarCode B on B.idProject = PN.ID  
    where PN.idTask = @idTaskRemake  
    order by PN.ID, B.ID  
    option(force order)  
  
  open curBCOld  
  open curBCNew  
  
  while 1 = 1  
  begin  
    fetch next from curBCOld into @idBarCode_Reject, @idBarCode_Reject_Father  
    if @@FETCH_STATUS != 0  
      break  
    fetch next from curBCNew into @idBCNew  
    if @@FETCH_STATUS != 0  
      break  
  
    update BarCode set  
      idBarCode_Reject        = @idBarCode_Reject,  
      idBarCode_Reject_Father = @idBarCode_Reject_Father,  
      nState                  = IsNull(nState, 0) | 2      -- Выставляем признак "Производить" чтобы можно было включить в раскрой  
    where ID = @idBCNew  
  end  
  
  close      curBCOld  
  deallocate curBCOld  
  close      curBCNew  
  deallocate curBCNew  
  
  -- добавим статус переделан.  
  update B set nState = IsNull(nState, 0) | 2048 from #BC inner join BarCode B on B.ID = #BC.idBarCode_Reject  
  drop table #ProjectNew  
  drop table #BC  
  drop table #PI  
  
  set nocount off  
end  



