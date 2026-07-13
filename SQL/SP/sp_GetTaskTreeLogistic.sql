if exists (select * from dbo.sysobjects where id = OBJECT_ID(N'[dbo].[sp_GetTaskTreeLogistic]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[sp_GetTaskTreeLogistic]
go
  
-- [ab] Вернёт таблицу строющую дерево заказов и его прохождение по логистике обработки  
create procedure sp_GetTaskTreeLogistic  
                   @AccountNum   varchar(150),  
                   @InvoiceNum   varchar(150),  
                   @ClientName   varchar(255),  
                   @TTNNum       varchar(50),   -- Номер ТТН  
                   @iPositionNum int,  
                   @sBarCodeNum  varchar(50),  
                   @sCode_1C     varchar(50)  = '',  
                   @sMarking     varchar(50)  = '',  
                   @NumCalcFact  varchar(150) = '',  
                   @StrictAN     int          = 0,   -- bool, точное совпадение по @AccountNum  
                   @bStatusReady int          = 0,   -- bool, выводит колонку с готовностью по раскрою  
                   @iWindowNum   int          = null,  
                   @ID_Import    int          = null  
as  
begin  
  set nocount on  
  
  -- СТАВЛЮ В NULL ЕЕ, ТАК КАК ПОИСК С ЭТОЙ ОПЦИЕЙ НЕ РАБОТАЕТ!
  set @ID_Import = null 

  -- Заголовки заказов.  
  create table #TaskTree  
  (  
    TableLevel    int,  
    nOrder        int,  
    Name          varchar(30)  collate Cyrillic_General_CI_AS,  
    idTask        int,  
    iAccountNum   int,  
    AccountNum    varchar(150) collate Cyrillic_General_CI_AS,  
    InvoiceNum    varchar(150) collate Cyrillic_General_CI_AS,  
    ClientName    varchar(255) collate Cyrillic_General_CI_AS,  
    idManufTask   int,  
    idSawTaskMain int,  
    idShip        int,  
    Date          datetime,  
    DateComplete  datetime,  
    nCount        int,  
    UserName      varchar(50)  collate Cyrillic_General_CI_AS,  
    Price         float,  
    idClient      int,  
    nType         int,  
    StatusReady   varchar(16)  collate Cyrillic_General_CI_AS,  
    NumCalcFact   varchar(150) collate Cyrillic_General_CI_AS,  
    ID_Import     int  
  )  
  
  -- Баркоды.  
  create table #Temp  
  (  
    idTask            int,  
    iAccountNum       int,  
    AccountNum        varchar(150) collate Cyrillic_General_CI_AS,  
    InvoiceNum        varchar(150) collate Cyrillic_General_CI_AS,  
    Date              datetime,  
    DateComplete      datetime,  
    nCount            int,  
    Price             float,  
    idUsers           int,  
    ClientName        varchar(255) collate Cyrillic_General_CI_AS,  
    idBarCode         int,  
    idBarCode_Reject  int,  
    idPyramidCompleted int,  
    idTransport        int,  
    SumWithNDSProject float,  
    nCountProject     int,  
    idClient          int,  
    NumCalcFact        varchar(150) collate Cyrillic_General_CI_AS,  
    ID_Import          int  
  )  
  
  -- Переделки.  
  create table #Temp_Reject  
  (  
    idBarCode         int,  
    idBarCode_Reject  int,  
    RejectLevel       int,  
    idTask            int,  
    iAccountNum       int,  
    AccountNum        varchar(150) collate Cyrillic_General_CI_AS,  
    Date              datetime,  
    DateComplete      datetime,  
    nCount            int,  
    SumWithNDSProject float,  
    nCountProject     int,  
    idClient          int,  
    NumCalcFact       varchar(150) collate Cyrillic_General_CI_AS,  
    ID_Import         int  
  )  
  
  -- Счёт цен  
  create table #Temp_CalcPrice  
  (  
    idProject      int,  
    idShip         int,  
    SumPrice_Ship  decimal(18, 2),                             -- Сумма по отгрузке  
    SumPrice_Pos   decimal(18, 2)                              -- Сумма по отгрузке        
  )  
  
  -- Ищем ТТН?  
  if IsNull(@TTNNum, '') != ''  
    insert into #Temp(idTask,        iAccountNum,       AccountNum,  InvoiceNum,   Date, DateComplete,   nCount,   Price,   idUsers, ClientName, idBarCode,     idBarCode_Reject,     idPyramidCompleted,   idTransport,       SumWithNDSProject,              
                                           nCountProject, idClient, NumCalcFact,   ID_Import)  
    select            T.ID, IsNull(T.iAccountNum, 0), T.AccountNum, T.Num,       T.Date, T.DateComplite, T.PosCount, T.Price, T.idUsers, C.Name, B.ID, IsNull(B.idBarCode_Reject, 0), B.idPyramidCompleted, B.idTransport,     P.SumWithNDS / case when IsNull(
P.nCount, 0) = 0 then 1 else P.nCount end, P.nCount,        C.ID, T.NumCalcFact, T.ID_Import  
    from Transport TR  
      inner join BarCode B on B.idTransport = TR.ID  
      inner join Project P on P.ID  = B.idProject  
      inner join Task T    on T.ID  = P.idTask  
      inner join Client  C on C.ID  = T.idClient  
    where  
      TR.Num like ('%' + @TTNNum + '%')  
  else  
  -- Ищем заказ?  
  if (IsNull(@AccountNum, '') != '' or  IsNull(@InvoiceNum,  '') != '') and   
     IsNull(@ClientName, '')   = '' or   
     IsNull(@sBarCodeNum, '') != '' or   
     IsNull(@ID_Import, 0) != 0  
    insert into #Temp(idTask,        iAccountNum,       AccountNum,  InvoiceNum,  Date, DateComplete,     nCount,   Price,   idUsers, ClientName, idBarCode,     idBarCode_Reject,     idPyramidCompleted,   idTransport,         SumWithNDSProject,           
                                              nCountProject, idClient, NumCalcFact,   ID_Import)  
    select            T.ID, IsNull(T.iAccountNum, 0), T.AccountNum, T.Num, T.Date, T.DateComplite, T.PosCount, T.Price, T.idUsers, C.Name,        B.ID, IsNull(B.idBarCode_Reject, 0), B.idPyramidCompleted, B.idTransport,       P.SumWithNDS / case when IsNull(P.nCount, 0) = 0 then 1 else P.nCount end, P.nCount,        C.ID, T.NumCalcFact, T.ID_Import  
    from   
      Task              T  
      left join Project P on T.ID = P.idTask  
      left join Client  C on C.ID = T.idClient  
      left join BarCode B on P.ID = B.idProject  -- [ab] Вот так найдём заказ даже без штрих-кодов.  
    where  
      ((@StrictAN = 0 and T.AccountNum like ('%' + @AccountNum  + '%') and IsNull(T.Num, '') like ('%' + @InvoiceNum + '%')) or   
       (@StrictAN = 1 and T.AccountNum =           @AccountNum)                                                              or  
       (IsNull(@ID_Import, 0) = 0 or   
        IsNull(@ID_Import, 0) = IsNull(T.ID_Import, 0)  -- Нашли заказ по ID_Import?  
       )  
      ) and  
      IsNull(B.BarCode, '') like ('%' + @sBarCodeNum + '%') and  
      (P.Num = @iPositionNum or @iPositionNum is null)      and   
      (P.NumClient = @iWindowNum or @iWindowNum is null)  
  else  
  -- Все заказы клиента?  
  if IsNull(@AccountNum, '') = '' and IsNull(@ClientName, '') != ''  
    insert into #Temp(idTask,        iAccountNum,       AccountNum, InvoiceNum,   Date, DateComplete,    nCount,   Price,   idUsers, ClientName, idBarCode,     idBarCode_Reject,     idPyramidCompleted,   idTransport,         SumWithNDSProject,            
                                             nCountProject, idClient, NumCalcFact,   ID_Import)  
    select            T.ID, IsNull(T.iAccountNum, 0), T.AccountNum, T.Num, T.Date, T.DateComplite,T.PosCount, T.Price, T.idUsers, C.Name,        B.ID, IsNull(B.idBarCode_Reject, 0), B.idPyramidCompleted, B.idTransport,       P.SumWithNDS / case when IsNull(P.nCount, 0) = 0 then 1 else P.nCount end, P.nCount,        C.ID, T.NumCalcFact, T.ID_Import  
    from BarCode B  
      inner join Project P on P.ID = B.idProject  
      inner join Task T    on T.ID = P.idTask  
      inner join Client  C on C.ID = T.idClient  
    where  
      C.Name like ('%' + @ClientName + '%')  
  else  
  -- Ищем заказ по номеру счета-фактуры?   
  if IsNull(@NumCalcFact, '') != ''  
    insert into #Temp(idTask,        iAccountNum,       AccountNum,  InvoiceNum,  Date, DateComplete,     nCount,   Price,   idUsers, ClientName, idBarCode,     idBarCode_Reject,     idPyramidCompleted,   idTransport,         SumWithNDSProject,           
                                              nCountProject, idClient, NumCalcFact,   ID_Import)  
    select            T.ID, IsNull(T.iAccountNum, 0), T.AccountNum, T.Num, T.Date, T.DateComplite, T.PosCount, T.Price, T.idUsers, C.Name,        B.ID, IsNull(B.idBarCode_Reject, 0), B.idPyramidCompleted, B.idTransport,       P.SumWithNDS / case when IsNull(P.nCount, 0) = 0 then 1 else P.nCount end, P.nCount,        C.ID, T.NumCalcFact, T.ID_Import  
    from   
      Task          T  
      left join Project P on T.ID = P.idTask  
      left join Client  C on C.ID = T.idClient  
      left join BarCode B on P.ID = B.idProject  
    where  
      T.NumCalcFact like ('%' + @NumCalcFact + '%') and  
      IsNull(B.BarCode, '') like ('%' + @sBarCodeNum + '%') and  
      (P.Num = @iPositionNum or @iPositionNum is null)  and (P.NumClient = @iWindowNum or @iWindowNum is null)  
  -- Ищем по коду 1С  
  else  
  if IsNull(@AccountNum, '') = '' and IsNull(@sCode_1C, '') != ''  
    insert into #Temp(idTask,        iAccountNum,       AccountNum, InvoiceNum,   Date, DateComplete,    nCount,   Price,   idUsers, ClientName, idBarCode,     idBarCode_Reject,     idPyramidCompleted,   idTransport,        SumWithNDSProject,            
                                             nCountProject, idClient, NumCalcFact,   ID_Import)  
    select            T.ID, IsNull(T.iAccountNum, 0), T.AccountNum, T.Num, T.Date, T.DateComplite,T.PosCount, T.Price, T.idUsers, C.Name,        B.ID, IsNull(B.idBarCode_Reject, 0), B.idPyramidCompleted, B.idTransport,      P.SumWithNDS / case when IsNull
(P.nCount, 0) = 0 then 1 else P.nCount end, P.nCount,        C.ID, T.NumCalcFact, T.ID_Import  
    from BarCode B  
      inner join Project P on P.ID = B.idProject  
      inner join Task T    on T.ID = P.idTask  
      left  join Client  C on C.ID = T.idClient  
    where  
      (@StrictAN = 1 and P.Code_1C = @sCode_1C) or (@StrictAN = 0 and P.Code_1C like ('%' + @sCode_1C + '%'))  
  else  
  -- Ищем по маркировке  
  if IsNull(@AccountNum, '') = '' and IsNull(@sMarking, '') != ''  
    insert into #Temp(idTask,        iAccountNum,       AccountNum, InvoiceNum,  Date, DateComplete,    nCount,   Price,   idUsers, ClientName, idBarCode,     idBarCode_Reject,     idPyramidCompleted,   idTransport,     SumWithNDSProject,                 
                                        nCountProject, idClient, NumCalcFact,   ID_Import)  
    select            T.ID, IsNull(T.iAccountNum, 0), T.AccountNum, T.Num, T.Date, T.DateComplite,T.PosCount, T.Price, T.idUsers, C.Name,       B.ID, IsNull(B.idBarCode_Reject, 0), B.idPyramidCompleted, B.idTransport,   P.SumWithNDS / case when IsNull(P.nCount, 0) = 0 then 1 else P.nCount end, P.nCount,        C.ID, T.NumCalcFact, T.ID_Import  
    from BarCode B  
      inner join Project P on P.ID = B.idProject  
      inner join Task T    on T.ID = P.idTask  
      left  join Client  C on C.ID = T.idClient  
    where  
      (@StrictAN = 1 and P.CommentClient = @sMarking) or (@StrictAN = 0 and P.CommentClient like ('%' + @sMarking + '%'))  
  else  
    insert into #Temp(idTask,        iAccountNum,       AccountNum, InvoiceNum,  Date,   DateComplete,   nCount,   Price,   idUsers, ClientName, idBarCode,     idBarCode_Reject,    idPyramidCompleted,   idTransport,    SumWithNDSProject,                  
                                       nCountProject, idClient, NumCalcFact,   ID_Import)  
    select            T.ID, IsNull(T.iAccountNum, 0), T.AccountNum, T.Num, T.Date, T.DateComplite, T.PosCount, T.Price, T.idUsers, C.Name,       B.ID, IsNull(B.idBarCode_Reject, 0),B.idPyramidCompleted, B.idTransport,  P.SumWithNDS / case when IsNull(P.nCount, 0) = 0 then 1 else P.nCount end, P.nCount,        C.ID, T.NumCalcFact, T.ID_Import  
    from BarCode B  
      inner join Project P on P.ID = B.idProject  
      inner join Task T    on T.ID = P.idTask  
      inner join Client  C on C.ID = T.idClient  
    where  
      (IsNull(@ClientName, '') = '' or C.Name       like ('%' + @ClientName + '%')) and  
      (IsNull(@AccountNum, '') = '' or ((@StrictAN = 0 and T.AccountNum like ('%' + @AccountNum  + '%')) or (@StrictAN = 1 and T.AccountNum = @AccountNum)))  
  
  -- рекурсивная выборка:  
  ;with RejectTree(idBarCode, idBarCode_Reject, RejectLevel, idTask, iAccountNum, AccountNum, Date, DateComplete, nCount, SumWithNDSProject, nCountProject, idClient, NumCalcFact, ID_Import)  
  as  
  (  
    select                     -- Исходные заказы  
      idBarCode,  
      idBarCode_Reject,  
      0 as RejectLevel,        -- На 0 уровне  
      idTask,  
      iAccountNum,  
      AccountNum,  
      Date,  
      DateComplete,  
      nCount,  
      SumWithNDSProject,  
      nCountProject,  
      idClient,  
      NumCalcFact,  
      ID_Import  
    from  
      #Temp  
    where  
      idBarCode_Reject != 0    -- Это не переделка, Это исходный BarCode  
  
    union all  
  
    select                     -- Переделки:  
      #Temp.idBarCode,  
      #Temp.idBarCode_Reject,  
      RT.RejectLevel + 1,      -- На последующих уровнях согласно подчинённости (переделка может ссылаться на переделку)  
      #Temp.idTask,  
      #Temp.iAccountNum,  
      #Temp.AccountNum,  
      #Temp.Date,  
      #Temp.DateComplete,  
      #Temp.nCount,  
      #Temp.SumWithNDSProject,  
      #Temp.nCountProject,  
      #Temp.idClient,  
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
    from  
      #Temp                                                              -- Из #Temp  
      inner join RejectTree RT on RT.idBarCode = #Temp.idBarCode_Reject  -- Выбираем переделки которые ссылаются на записи, которые уже выбрали в RejectTree  
  )  
  
  insert into #Temp_Reject (idBarCode, idBarCode_Reject, RejectLevel,      idTask, iAccountNum, AccountNum, Date, DateComplete, nCount, SumWithNDSProject, nCountProject, idClient, NumCalcFact, ID_Import)  
  select                    idBarCode, idBarCode_Reject, max(RejectLevel), idTask, iAccountNum, AccountNum, Date, DateComplete, nCount, SumWithNDSProject, nCountProject, idClient, NumCalcFact, ID_Import  
  from  
    RejectTree  
  group by  
    idBarCode, idBarCode_Reject, idTask, iAccountNum, AccountNum, Date, DateComplete, nCount, SumWithNDSProject, nCountProject, idClient, NumCalcFact, ID_Import  
  
  -- Заголовки заказов:  
  insert into #TaskTree (TableLevel, nOrder, Name,       idTask,                    iAccountNum,           AccountNum, InvoiceNum,              ClientName, idManufTask, idSawTaskMain,       Date,       DateComplete,       nCount, UserName,      Price,    
    idClient, nType,       NumCalcFact,       ID_Import)  
    select               1,          1,      'Нар.Зак.', #Temp.idTask, IsNull(#Temp.iAccountNum, 0), #Temp.AccountNum, #Temp.InvoiceNum,  #Temp.ClientName, 0,           0,             #Temp.Date, #Temp.DateComplete, #Temp.nCount, U.Name,   #Temp.Price, #Temp.idClient, 1,     #Temp.NumCalcFact, #Temp.ID_Import  
    from  
      #Temp  
      left  join Transport TR on TR.idTask = #Temp.idTask  
      left  join Ship SH      on SH.ID     = TR.idShip  
      left  join Users U      on U.ID      = #Temp.idUsers  
    where  
      (IsNull(@TTNNum, '') = '' or TR.Num like ('%' + @TTNNum + '%')) and  
      #Temp.idBarCode_Reject = 0  
    group by  
      #Temp.idTask,  
      #Temp.iAccountNum,  
      #Temp.AccountNum,  
      #Temp.InvoiceNum,  
      #Temp.ClientName,  
      #Temp.Date,  
      #Temp.DateComplete,  
      #Temp.nCount,  
      U.Name,  
      #Temp.Price,  
      #Temp.idClient,  
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
  
  --select * from #Temp  
  --select * from #TaskTree  
  
  -- Посчитаем количество выданных в производство по разным заданиям в производство:  
  if IsNull(@ClientName, '') != '' or IsNull(@AccountNum, '') != '' or IsNull(@NumCalcFact, '') != ''  
    insert into #TaskTree (TableLevel, nOrder, Name,          idTask,        iAccountNum,     AccountNum,    ClientName, idManufTask,      idSawTaskMain,    Date,   DateComplete, nCount,   Price,                                                            
   UserName, idClient, nType,   NumCalcFact,   ID_Import)  
    select                 2,          2,      'Зад.В Пр-во', T.ID, IsNull(T.iAccountNum, 0), MT.ManufName,  '',         IsNull(MT.ID, 0), 0,             MT.Date, T.DateComplite, count(*), sum((P.SumWithNDS / case P.nCount when 0 then 1 else P.nCount end)
), U.Name,   C.ID,     2,     T.NumCalcFact, T.ID_Import  
    from  
      #Temp  
      inner join ManufBarCode MB on MB.idBarCode = #Temp.idBarCode  
      inner join ManufProject MP on MP.ID = MB.idManufProject  
      inner join ManufTask MT    on MT.ID = MP.idManufTask  
      inner join BarCode B       on B.ID  = MB.idBarCode  
      inner join Task T          on T.ID  = MT.idTask  
      inner join Project P       on P.ID  = MP.idProject  
      inner join Client C        on C.ID  = T.idClient  
      left  join Users U         on U.ID  = MT.idUsers  
    where  
      (IsNull(@ClientName, '') = '' or C.Name       like('%' + @ClientName + '%')) and  
      (IsNull(@AccountNum, '') = '' or ((@StrictAN = 0 and T.AccountNum like ('%' + @AccountNum  + '%')) or (@StrictAN = 1 and T.AccountNum = @AccountNum))) and  
       IsNull(B.idBarCode_Reject, 0) = 0 and  
      (IsNull(@NumCalcFact, '') = '' or T.NumCalcFact like ('%' + @NumCalcFact + '%'))  
    group by  
      T.ID,  
      T.iAccountNum,  
      MT.ManufName,  
      IsNull(MT.ID, 0),  
      MT.Date,  
      T.DateComplite,  
      MT.nCountGP,  
      U.Name,  
      C.ID,  
      T.NumCalcFact,  
      T.ID_Import  
  else  
  begin  
    insert into #TaskTree (TableLevel, nOrder, Name,          idTask,        iAccountNum,        AccountNum, ClientName, idManufTask,      idSawTaskMain,    Date,   DateComplete, nCount,   Price,                                                            
   UserName, idClient, nType,   NumCalcFact,   ID_Import)  
    select                 2,          2,      'Зад.В Пр-во', T.ID, IsNull(T.iAccountNum, 0), MT.ManufName,  '',         IsNull(MT.ID, 0), 0,             MT.Date, T.DateComplite, count(*), sum((P.SumWithNDS / case P.nCount when 0 then 1 else P.nCount end)
), U.Name,   C.ID,     2,     T.NumCalcFact, T.ID_Import  
    from  
      #Temp  
      inner join ManufBarCode MB on MB.idBarCode = #Temp.idBarCode  
      inner join ManufProject MP on MP.ID = MB.idManufProject  
      inner join ManufTask MT    on MT.ID = MP.idManufTask  
      inner join BarCode B       on B.ID  = MB.idBarCode  
      inner join Task T          on T.ID  = MT.idTask  
      inner join Project P       on P.ID  = MP.idProject  
      inner join Client C        on C.ID  = T.idClient  
      inner join Transport TR    on TR.ID = B.idTransport  
      left  join Users U         on U.ID  = MT.idUsers  
    where  
      --TR.Num like('%' + @TTNNum + '%') and  
      IsNull(B.idBarCode_Reject, 0) = 0  
    group by  
      T.ID,  
      T.iAccountNum,  
      MT.ManufName,  
      IsNull(MT.ID, 0),  
      MT.Date,  
      T.DateComplite,  
      MT.nCountGP,  
      U.Name,  
      C.ID,  
      T.NumCalcFact,  
      T.ID_Import  
  end  
  
  -- Раскрои:  
  if IsNull(@ClientName, '') != '' or IsNull(@AccountNum, '') != '' or IsNull(@NumCalcFact, '') != ''  
  begin  
    -- [OK]  
    -- Поиск по клиенту и Номеру задания.  
    -- Вопрос: а зачем? Ведь всё интересное мы имеем в  #Temp  
    -- Зачем ещё раз фильтровать, если уже нафильтровано в #Temp всё?  
  
    insert into #TaskTree   
    ( TableLevel,   
      nOrder,   
      Name,        
      idTask,         
      iAccountNum,                    
      AccountNum,   
      ClientName,   
      idManufTask,   
      idSawTaskMain,   
      Date,       
      DateComplete,      
      nCount,   
      UserName,       
      idClient,   
      nType,  
      StatusReady,  
      NumCalcFact,  
      ID_Import  
    )  
    select                   
      case when IsNull(MB.ID, 0) = 0 then 2 else 3 end,  
      2,        
      'Раскрой',   
      #Temp.idTask,   
      IsNull(#Temp.iAccountNum, 0),   
      STM.Name,     
      '',        
      IsNull(MP.idManufTask, 0),   
      STM.ID,          
      STM.Data,   
      NULL,              
      count(distinct GD.idBarCode)                      as nCount,     
      U.Name,   
      #Temp.idClient,   
      3,  
      case when @bStatusReady = 1 then dbo.f_Count_bFinished(#Temp.idTask, STM.ID) end as StatusReady,  
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
    from  
      #Temp  
      inner join GlassDetails GD on GD.idBarCode = #Temp.idBarCode  
      inner join SawTaskMain STM on STM.ID       = GD.idSawTaskMain  
      left  join ManufBarCode MB on MB.idBarCode = GD.idBarCode  
      left  join ManufProject MP on MP.ID        = MB.idManufProject  
      left  join Users U         on U.ID         = STM.idUsers  
    where  
      IsNull(#Temp.idBarCode_Reject, 0) = 0  
    group by  
      case when IsNull(MB.ID, 0) = 0 then 2 else 3 end,  
      #Temp.idTask,   
      IsNull(#Temp.iAccountNum, 0),   
      STM.Name,   
      IsNull(MP.idManufTask, 0),   
      STM.ID,   
      STM.Data,   
      U.Name,   
      #Temp.idClient,  
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
  end  
  else  
  if IsNull(@TTNNum, '') != ''   
  begin  
    -- [OK]  
    -- Случай для поиска по ТТН.    
    -- Почему-то был поиск по ТТН, даже если ТТН в условиях не задана  
    -- В итоге задание в раскрое, естественно, не отгружено - а раскрой на него НЕ ПОКАЗЫВАЛО!  
    -- Исправил, чтобы явно искаkо по ТТН, когда задан ТТН  
      
    insert into #TaskTree   
    ( TableLevel,   
      nOrder,   
      Name,        
      idTask,         
      iAccountNum,                    
      AccountNum,   
      ClientName,   
      idManufTask,   
      idSawTaskMain,   
      Date,       
      DateComplete,      
      nCount,   
      UserName,       
      idClient,   
      nType,  
      StatusReady,  
      NumCalcFact,  
      ID_Import  
    )  
    select                   
      case when IsNull(MB.ID, 0) = 0 then 2 else 3 end  as TableLevel,  
      2                                                 as nOrder,        
      'Раскрой'                                         as Name,   
      #Temp.idTask,   
      IsNull(#Temp.iAccountNum, 0)                      as iAccountNum,   
      STM.Name                                          as SawTaskName,     
      ''                                                as ClientName,        
      IsNull(MP.idManufTask, 0),   
      STM.ID                                            as idSawTaskMain,          
      STM.Data                                          as DateSaw,   
      NULL                                              as DateComplete,              
      count(distinct GD.idBarCode)                      as nCount,  
      U.Name                                            as UserName,   
      #Temp.idClient                                    as idClient,    
      3                                                 as nType,  
      case when @bStatusReady = 1 then dbo.f_Count_bFinished(#Temp.idTask, STM.ID) end as StatusReady,  
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
    from  
      #Temp inner join BarCode B       on B.ID         = #Temp.idBarCode  
            inner join GlassDetails GD on GD.idBarCode = B.ID  
            inner join SawTaskMain STM on STM.ID       = GD.idSawTaskMain  
            inner join Transport TR    on TR.ID        = B.idTransport  
            left  join ManufBarCode MB on MB.idBarCode = GD.idBarCode  
            left  join ManufProject MP on MP.ID        = MB.idManufProject  
            left  join Users U         on U.ID         = STM.idUsers  
    where  
      TR.Num like('%' + @TTNNum + '%') and  
      IsNull(B.idBarCode_Reject, 0) = 0  
    group by  
      case when IsNull(MB.ID, 0) = 0 then 2 else 3 end,  
      #Temp.idTask,   
      IsNull(#Temp.iAccountNum, 0),   
      STM.Name,   
      IsNull(MP.idManufTask, 0),   
      STM.ID,   
      STM.Data,   
      U.Name,   
      #Temp.idClient,  
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
  end  
  else  
  begin  
    -- [OK] Все остальные случаи   
    -- Всё, что надо нафильтровать - оно уже лежит в #Temp  
    -- И никаких доп. фильтров не надо же? Так?  
  
    insert into #TaskTree   
    ( TableLevel,   
      nOrder,   
      Name,        
      idTask,         
      iAccountNum,                    
      AccountNum,   
      ClientName,   
      idManufTask,   
      idSawTaskMain,   
      Date,       
      DateComplete,      
      nCount,   
      UserName,       
      idClient,   
      nType,  
      StatusReady,  
      NumCalcFact,  
      ID_Import  
    )  
    select                   
      case when IsNull(MB.ID, 0) = 0 then 2 else 3 end  as TableLevel,  
      2                                                 as nOrder,        
      'Раскрой'                                         as Name,   
      #Temp.idTask,   
      IsNull(#Temp.iAccountNum, 0)                      as iAccountNum,   
      STM.Name                                          as SawTaskName,     
      ''                                                as ClientName,        
      IsNull(MP.idManufTask, 0),   
      STM.ID                                            as idSawTaskMain,          
      STM.Data                                          as DateSaw,   
      NULL                                              as DateComplete,              
      count(distinct GD.idBarCode)                      as nCount,  
      U.Name                                            as UserName,   
      #Temp.idClient                                    as idClient,    
      3                                                 as nType,  
      case when @bStatusReady = 1 then dbo.f_Count_bFinished(#Temp.idTask, STM.ID) end as StatusReady,  
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
    from  
      #Temp inner join BarCode B       on B.ID         = #Temp.idBarCode  
            inner join GlassDetails GD on GD.idBarCode = B.ID  
            inner join SawTaskMain STM on STM.ID       = GD.idSawTaskMain  
            left  join Transport TR    on TR.ID        = B.idTransport  
            left  join ManufBarCode MB on MB.idBarCode = GD.idBarCode  
            left  join ManufProject MP on MP.ID        = MB.idManufProject  
            left  join Users U         on U.ID         = STM.idUsers  
    where  
      --TR.Num like('%' + @TTNNum + '%') and  
      IsNull(B.idBarCode_Reject, 0) = 0  
    group by  
      case when IsNull(MB.ID, 0) = 0 then 2 else 3 end,  
      #Temp.idTask,   
      IsNull(#Temp.iAccountNum, 0),   
      STM.Name,   
      IsNull(MP.idManufTask, 0),   
      STM.ID,   
      STM.Data,   
      U.Name,   
      #Temp.idClient,  
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
  end  
  
  -- Брак:  
  if IsNull(@ClientName, '') != '' or IsNull(@AccountNum, '') != '' or IsNull(@TTNNum, '') != '' or IsNull(@NumCalcFact, '') != ''  
    insert into #TaskTree (TableLevel, nOrder, Name,                 idTask,        iAccountNum,     AccountNum, ClientName, idManufTask, idSawTaskMain, Date, DateComplete, nCount, idClient, nType, NumCalcFact, ID_Import)  
    select                 2 + RejectLevel, 3, 'Пер.Брака Нар.Зак.', idTask, IsNull(iAccountNum, 0), AccountNum, '',         0,           0,             Date, DateComplete, nCount, idClient, 1,     NumCalcFact, ID_Import  
    from  
      #Temp_Reject  
    group by  
      idTask, iAccountNum, RejectLevel, AccountNum, Date, DateComplete, nCount, idClient, NumCalcFact, ID_Import  
  
  -- Брак Задание в производство:  
  if IsNull(@ClientName, '') != '' or IsNull(@AccountNum, '') != '' or IsNull(@TTNNum, '') != '' or IsNull(@NumCalcFact, '') != ''  
    insert into #TaskTree (TableLevel,                    nOrder, Name,                    idTask,              iAccountNum,                         AccountNum,   ClientName, idManufTask,      idSawTaskMain, Date,    DateComplete,     nCount,   UserName, 
           idClient, nType,              NumCalcFact,              ID_Import)  
    select                 3 + #Temp_Reject.RejectLevel , 3,      'Пер.Брака Зад.В Пр-во', #Temp_Reject.idTask, IsNull(#Temp_Reject.iAccountNum, 0), MT.ManufName, '',         IsNull(MT.ID, 0), 0,             MT.Date, DateComplete,  MT.nCountGP, U.Name, #Temp_Reject.idClient, 2,     #Temp_Reject.NumCalcFact, #Temp_Reject.ID_Import  
    from  
      #Temp_Reject  
      inner join ManufTask MT on MT.idTask = #Temp_Reject.idTask  
      left  join Users U      on U.ID      = MT.idUsers  
    group by  
      #Temp_Reject.idTask, #Temp_Reject.iAccountNum, #Temp_Reject.RejectLevel, MT.ManufName, IsNull(MT.ID, 0), MT.Date, DateComplete, MT.nCountGP, U.Name, #Temp_Reject.idClient, #Temp_Reject.NumCalcFact, #Temp_Reject.ID_Import  
  
  -- Брак Задание в производство раскрой:  
  if IsNull(@ClientName, '') != '' or IsNull(@AccountNum, '') != '' or IsNull(@TTNNum, '') != '' or IsNull(@NumCalcFact, '') != ''  
    insert into #TaskTree (TableLevel,                                                                  nOrder, Name,                           idTask,              iAccountNum,                         AccountNum, ClientName, idManufTask,      idSawTaskMain, Date,     nCount, UserName,            idClient, nType,              NumCalcFact,              ID_Import)  
    select                 case when IsNull(MT.ID, 0) = 0 then 3 else 4 end + #Temp_Reject.RejectLevel, 3,      'Пер.Брака Зад.В Пр-во Раскр.', #Temp_Reject.idTask, IsNull(#Temp_Reject.iAccountNum, 0), STM.Name,   '',         IsNull(MT.ID, 0), STM.ID,    
    STM.Data, NULL,   U.Name, #Temp_Reject.idClient, 3,     #Temp_Reject.NumCalcFact, #Temp_Reject.ID_Import  
    from  
      #Temp_Reject  
      inner join GlassDetails GD on GD.idBarCode = #Temp_Reject.idBarCode  
      inner join SawTaskMain STM on STM.ID       = GD.idSawTaskMain  
      left  join ManufBarCode MB on MB.idBarCode = GD.idBarCode  
      left  join ManufProject MP on MP.ID        = MB.idManufProject  
      left  join ManufTask MT    on MT.ID        = MP.idManufTask  
      left  join Users U         on U.ID         = MT.idUsers  
    group by  
      #Temp_Reject.idTask, #Temp_Reject.iAccountNum, #Temp_Reject.RejectLevel,STM.ID, STM.Name, STM.Data, IsNull(MT.ID, 0), U.Name, #Temp_Reject.idClient, #Temp_Reject.NumCalcFact, #Temp_Reject.ID_Import  
  
  -- Отгрузка переделки:  
  insert into #TaskTree (TableLevel,                   nOrder, Name,                              idTask,                     iAccountNum,     AccountNum, ClientName, idManufTask, idSawTaskMain, idShip,    Date, nCount,   UserName, Price,                 
              idClient,              nType,              NumCalcFact,              ID_Import)  
  select                 3 + #Temp_Reject.RejectLevel, 4,      'Пер.Брака Тов.Нак.', #Temp_Reject.idTask, IsNull(#Temp_Reject.iAccountNum, 0), TR.Num,     '',         0,           0,             SH.ID,  SH.Date, count(1), U.Name,   sum(#Temp_Reject.SumWithNDSProject), #Temp_Reject.idClient, 4,     #Temp_Reject.NumCalcFact, #Temp_Reject.ID_Import  
  from  
    #Temp_Reject  
    inner join BarCode B    on B.ID  = #Temp_Reject.idBarCode  
    inner join Transport TR on TR.ID = B.idTransport  
    inner join Ship SH      on SH.ID = TR.idShip  
    inner join Project P    on P.ID  = B.idProject  
    inner join Product PD   on PD.ID = P.idProd  
    left  join Users U      on U.ID  = TR.idUsers  
  where  
    (IsNull(@TTNNum, '') = '' or TR.Num like ('%' + @TTNNum + '%')) and PD.Type in(1, 2, 4) -- Стеклопакеты, материалы, готовая продукция  
  group by  
    #Temp_Reject.idTask, #Temp_Reject.iAccountNum, #Temp_Reject.RejectLevel, TR.Num, SH.ID, SH.Date, TR.nCountGP, U.Name, TR.ID, #Temp_Reject.idClient, #Temp_Reject.NumCalcFact, #Temp_Reject.ID_Import  
  
  insert into #Temp_CalcPrice   
  select     
    P.ID,   
    isNull(TR.idShip, 2147483647),  
   case T.CalcType when 3  
      then Round(Round(SUM(P.Area)*P.PriceNoNDS,2)*1.18,2)  
      else sum( P.SumWithNDS / case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end )  
    end as SumPrice_Ship,  
    P.SumWithNDS  
  from #Temp  
    inner join BarCode B    on B.ID  = #Temp.idBarCode  
    inner join Project P    on P.ID  = B.idProject  
    inner join Product PD   on PD.ID = P.idProd  
    inner join Task T       on T.ID  = P.idTask  
    inner join Client C     on C.ID  = T.idClient  
          
    left  join Transport TR on TR.ID = B.idTransport  
    left  join Ship SH      on SH.ID = TR.idShip  
  
    left  join Users U      on U.ID  = TR.idUsers  
  where  
    (IsNull(@ClientName, '') = '' or C.Name       like ('%' + @ClientName + '%')) and  
    (IsNull(@AccountNum, '') = '' or ((@StrictAN = 0 and T.AccountNum like ('%' + @AccountNum  + '%')) or (@StrictAN = 1 and T.AccountNum = @AccountNum))) and  
    (IsNull(@TTNNum,     '') = '' or TR.Num       like ('%' + @TTNNum     + '%')) and  
    IsNull(B.idBarCode_Reject, 0) = 0 and PD.Type in(1, 2, 4) -- Стеклопакеты, материалы, готовая продукция  
  group by  
    P.ID,   
    isNull(TR.idShip, 2147483647),   
    T.CalcType,   
    TR.Num,   
    P.PriceNoNDS,   
    P.SumWithNDS    
      
  --select * from #Temp_CalcPrice    
  
  update #Temp_CalcPrice set   
    #Temp_CalcPrice.SumPrice_Ship = #Temp_CalcPrice.SumPrice_Ship + (Remain.SumPrice_Pos - Remain.SumPrice)    
  from   
    #Temp_CalcPrice inner join  
    (        
      select   
        idProject,  
        sum(SumPrice_Ship) as SumPrice,  
        SumPrice_Pos,  
        max(idShip)        as idShip_Max  
      from     
        #Temp_CalcPrice  
      group by  
        idProject,     
        SumPrice_Pos   
    ) Remain on #Temp_CalcPrice.idProject = Remain.idProject  and   
                #Temp_CalcPrice.idShip    = Remain.idShip_Max       
  
  --select * from #Temp_CalcPrice   
      
  --  Отсканировано в свободной зоне   
  
  -- не отсканироовано   
  insert into #TaskTree (TableLevel, nOrder, Name,                     idTask,              iAccountNum,           AccountNum,       InvoiceNum,        ClientName, idManufTask, idSawTaskMain,  Date, DateComplete, nCount,                           UserName
,  Price,      idClient, nType,       NumCalcFact,       ID_Import)  
    select               2,          4,      'В свободной зоне', #Temp.idTask, IsNull(#Temp.iAccountNum, 0), #Temp.AccountNum, #Temp.InvoiceNum,  #Temp.ClientName, 0,           0,              NULL, NULL,         count(distinct #Temp.idBarCode),  U.Name, 
   null, #Temp.idClient, 5,     #Temp.NumCalcFact, #Temp.ID_Import  
    from  
      #Temp  
      inner join BarCode B    on B.ID  = #Temp.idBarCode  
      inner join Project P    on P.ID  = B.idProject  
      inner join Product PD   on PD.ID = P.idProd  
      left  join Transport TR on TR.idTask = #Temp.idTask  
      left  join Ship SH      on SH.ID     = TR.idShip  
      left  join Users U      on U.ID      = #Temp.idUsers  
    where  
      isnull(#Temp.idPyramidCompleted, 0 ) != 0 and   
      isnull(#Temp.idTransport, 0 )         = 0 and   
  
      (IsNull(@TTNNum, '') = '' or TR.Num like ('%' + @TTNNum + '%')) and  
        
      IsNull(#Temp.idBarCode_Reject, 0) = 0 and PD.Type in(1, 2, 4) -- Стеклопакеты, материалы, готовая продукция  
    group by  
      #Temp.idTask,  
      #Temp.iAccountNum,  
      #Temp.AccountNum,  
      #Temp.InvoiceNum,  
      #Temp.ClientName,  
      #Temp.Date,  
      #Temp.DateComplete,  
      #Temp.nCount,  
      U.Name,  
      #Temp.Price,  
      #Temp.idClient,   
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
  
    insert into #TaskTree (TableLevel, nOrder, Name,              idTask,       iAccountNum,          AccountNum, InvoiceNum, ClientName,       idManufTask, idSawTaskMain,  Date,           DateComplete, nCount,                          UserName, Price,   
    idClient, nType,       NumCalcFact,       ID_Import)  
    select                 3,          4,     'Пирамида', #Temp.idTask, IsNull(#Temp.iAccountNum, 0), PO.BarCode, NULL,       #Temp.ClientName, 0,           0,              pC.TimePyramid, NULL,         count(distinct #Temp.idBarCode), U.Name,   null,  #Temp.idClient, 5,     #Temp.NumCalcFact, #Temp.ID_Import  
    from  
      #Temp  
      inner join BarCode B           on B.ID  = #Temp.idBarCode  
      inner join PyramidCompleted PC on PC.ID = #Temp.idPyramidCompleted  
      inner join PyramidOut       PO on PO.ID = PC.idPyramidOut  
      inner join Project P    on P.ID  = B.idProject  
      inner join Product PD   on PD.ID = P.idProd  
      left  join Transport TR on TR.idTask = #Temp.idTask  
      left  join Ship SH      on SH.ID     = TR.idShip  
      left  join Users U      on U.ID      = #Temp.idUsers  
    where  
      isnull(#Temp.idPyramidCompleted, 0 ) != 0 and   
      isnull(#Temp.idTransport, 0 )         = 0 and   
  
      (IsNull(@TTNNum, '') = '' or TR.Num like ('%' + @TTNNum + '%')) and  
        
      IsNull(#Temp.idBarCode_Reject, 0) = 0 and PD.Type in(1, 2, 4) -- Стеклопакеты, материалы, готовая продукция  
    group by  
      #Temp.idTask,  
      #Temp.iAccountNum,  
      #Temp.AccountNum,  
      #Temp.InvoiceNum,  
      #Temp.ClientName,  
      #Temp.Date,  
      #Temp.DateComplete,  
      #Temp.nCount,  
      U.Name,  
      #Temp.Price,  
      #Temp.idClient,   
      PO.BarCode,  
      pC.TimePyramid,   
      #Temp.NumCalcFact,  
      #Temp.ID_Import  
  
  -- Отгрузки:  
  insert into #TaskTree (TableLevel, nOrder, Name,             idTask,        iAccountNum,     AccountNum, ClientName, idManufTask, idSawTaskMain, idShip,   Date, nCount,   UserName, Price,       idClient, nType,   NumCalcFact,   ID_Import)  
  select                 2,          5,      'Тов. накладная', T.ID, IsNull(T.iAccountNum, 0), TR.Num,     C.Name,     0,           0,             SH.ID, SH.Date, count(1), U.Name,   GT.PriceSum, C.ID,     4,     T.NumCalcFact, T.ID_Import  
  from #Temp  
    inner join BarCode B    on B.ID  = #Temp.idBarCode  
    inner join Transport TR on TR.ID = B.idTransport  
    inner join Ship SH      on SH.ID = TR.idShip  
    inner join Project P    on P.ID  = B.idProject  
    inner join Product PD   on PD.ID = P.idProd  
    inner join Task T       on T.ID  = P.idTask  
    inner join Client C     on C.ID  = T.idClient  
   inner join (select idShip, sum(SumPrice_Ship) as PriceSum from #Temp_CalcPrice group by idShip) GT on GT.idShip = SH.ID  
    left  join Users U      on U.ID  = TR.idUsers  
  where  
    (IsNull(@ClientName, '') = '' or C.Name       like ('%' + @ClientName + '%')) and  
    (IsNull(@AccountNum, '') = '' or ((@StrictAN = 0 and T.AccountNum like ('%' + @AccountNum  + '%')) or (@StrictAN = 1 and T.AccountNum = @AccountNum))) and  
    (IsNull(@TTNNum,     '') = '' or TR.Num       like ('%' + @TTNNum     + '%')) and  
    IsNull(B.idBarCode_Reject, 0) = 0 and PD.Type in(1, 2, 4) -- Стеклопакеты, материалы, готовая продукция  
  group by  
    T.ID, T.iAccountNum, TR.Num, C.Name, SH.ID, SH.Date, TR.nCountGP, U.Name, TR.ID, C.ID, T.CalcType, GT.PriceSum, T.NumCalcFact, T.ID_Import  
  
  if not exists(select top 1 idTask from #TaskTree where TableLevel = 1)  
    update #TaskTree set TableLevel = TableLevel - 1  
  
  select * from #TaskTree order by idTask, nOrder, idManufTask, idSawTaskMain, TableLevel, Date, idClient  
  
/*  
  select #Temp.*, PC.QRBarCode  ,      PO.BarCode         as PyramidBarCode  
  from #Temp  
       left join PyramidCompleted PC  on PC.ID       = #Temp.idPyramidCompleted  
       left join PyramidOut PO        on PO.ID       = PC.idPyramidOut  
*/  
    
  drop table #TaskTree  
  drop table #Temp  
  drop table #Temp_Reject  
  
  set nocount on  
end  