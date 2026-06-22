if object_id('v_SawItemSelect_Task', 'V') is not null
    drop view dbo.v_SawItemSelect_Task
go 
  
-- Версия под новую систему раскроя.  
create view dbo.v_SawItemSelect_Task  
as  
select  
  0                                as nOrder,  
  1                                as TableLevel,  
  0                                as CheckBox,  
  IsNull(Team.ID,   0 )            as idTeam,  
  IsNull(Team.Name, '')            as TeamName,  
  IsNull(Team.Name, '')            as TeamNameShow,  
  null                             as idProject,  
  T.ID                             as idTask,  
  T.AccountNum,  
  T.AccountNum                     as AccountNumShow,  
  T.AccountNum_Source,  
  T.DateSawForFilm,  
  dbo.f_TruncDate(T.Date)          as Date,  
  T.Date                           as DateShow,  
  dbo.f_TruncDate(T.DateComplite)  as DateComplite,  
  T.DateComplite                   as DateCompliteShow,  
  T.DateSetStateToManuf,  
  dbo.f_TruncDate(BSum.DateGiveManufact) as DateGiveManufact,  
  BSum.DateGiveManufact               as DateGiveManufactShow,  
  IsNull(C.Name, '')               as ClientName,  
  IsNull(C.Name, '')               as ClientNameShow,  
  IsNull(CM.Name, '')              as ClientManufactoryName,  
  IsNull(CM.Name, '')              as ClientManufactoryNameShow,  
  IsNull(T.QueryCode, '')          as QueryCode,  
  IsNull(T.QueryCode, '')          as QueryCodeShow,  
  IsNull(C.LogisticCode, '')       as LogisticCode,  
  IsNull(C.LogisticCode, '')       as LogisticCodeShow,  
  IsNull(C.LogisticPriorityIndex, '') as LogisticPriorityIndex,  
  null                             as PosNum,  
  null                             as PosNumClient,  
  T.PosCount                       as nCount,  
  T.PosCount                       as nCountShow,  
  null                             as nCountPos,  
  case GPName_Min when GPName_Max then GPName_Min else '' end as Name,       -- если формула у всех позиций одинакова то выведим ее  
  case GPName_Min when GPName_Max then GPName_Min else '' end as NameShow,    
  T.Commentary,  
  T.nParseState,  
  T.bCustomImport,  
  T.Complex,  
  T.ComplexRest,  
  IsNull(T.FrameMarkRest, '') as FrameMarkShow,  
  ''                          as FrameMark,  
  IsNull(T.ComplexText,   '') as TaskComplexTextOriginal,  
  IsNull(T.ListGlass,     '') + ' ' + IsNull(T.ComplexText,     '') as TaskComplexText,  
  IsNull(T.ListGlass,     '') + ' ' + IsNull(T.ComplexText,     '') as ProjectComplexText,  

  case when BSum.CamCount = 0 then '' else 'СП ' end +
  IsNull(T.ListGlass,     '') + ' ' + IsNull(T.ComplexText,     '') as ComplexTextShow,  
  IsNull(T.ListGlassRest, '') + ' ' + IsNull(T.ComplexTextRest, '') as TaskComplexTextRest,  
  ''                                                                as ProjectComplexTextRest,  
  IsNull(T.ListGlassRest, '') + ' ' + IsNull(T.ComplexTextRest, '') as ComplexTextRestShow,  
  
  T.Complex as ComplexPrj,  
  
  case when IsNull(T.bSelfDelivery, 0) = 1 then 'ДА' else '' end as bSelfDelivery,  
  case when IsNull(T.bSelfDelivery, 0) = 1 then 'ДА' else '' end as bSelfDeliveryShow,  
  
  dbo.f_GetClientManufactoryList(T.ID)                              as ClientManufactoryList,  
  dbo.f_GetClientManufactoryList(T.ID)                              as ClientManufactoryList_Sort,  
  
  null as Width,  
  null as Height,  
  
  null as idBarCode,  
  ''   as BarCode,  
  null as Quant,  
  null as nPartDelivery,  
  null as DateTimeDelivery,    
  case Len(IsNull(T.AddressDelivery, '')) when 0  
    then IsNull(DA.Name, '')  
    else IsNull(T.AddressDelivery, '')  
  end                             as AddressDelivery,  
  case Len(IsNull(T.AddressDelivery, '')) when 0  
    then IsNull(DA.Name, '')  
    else IsNull(T.AddressDelivery, '')  
  end                             as AddressDeliveryShow,  
  IsNull(T.CommentaryLabel,'')    as CommentaryLabel,  
  IsNull(T.CommentaryLabel,'')    as CommentaryLabelShow,  
  IsNull(T.ListOperation, '')     as ListOperation,  
  IsNull(T.ListOperation, '')     as ListOperationShow,  
  IsNull(T.bHasDontSaw, 0)        as bHasDontSaw,  
  ''                              as CommentClient,  
  0                               as bPlot,  
  0                               as bPlotAwait,  
  upper(BSum.WinAccountNum)       as WinAccountNum,  
  -- Бывшие статистические  
  BSum.nCountNoSawed,  
  BSum.nCountNoSawedShow,  
  BSum.ParseState,  
  BSum.bFilm,  
  case when BSum.bFilm <> 0 then 'Плёнка' else '' end + ' ' + BSum.Comment_Film as TagFilm,    
  convert(varchar(20), BSum.GPSOptDate, 13) + '  ' + IsNull(TeamGPS.Name, '') as GPSOptDate,  
  LabelSubType.Code               as LabelCode,  
  IsNull(T.Priority, '')          as TaskPriority,  
  IsNull(T.Priority, '')          as TaskPriorityShow,  
  IsNull(DSD.Name, '')            as DepotSubDivision,  
  IsNull(DSD.Name, '')            as DepotSubDivisionShow,  
  IsNull(T.idDepotSubDivision, 0) as idDepotSubDivision,  
  DSD.bSharedDepotSubDivision,  
  case when T.Commentary like '%брак%'  
    then 1  
    else 0  
  end as isDefect,  
  
  '' as PlotTag,  
  '' as Shpros,  
  '' as Zak,  
  '' as ModelPart  
    
from   
  ( select   
      idTask,  
      idTeam,  
      B.DateGiveManufact,  
      P.CamCount,
      count(1)                         as nCountNoSawed,  
      count(1)                         as nCountNoSawedShow,  
      min(IsNull(P.idGlass1, 0))       as ParseState,  
      max( case when IsNull(bFilm, 0) <> 0  then 1 else 0 end) as bFilm,  
      max(IsNull(Comment_Film, ''))    as Comment_Film,  
     max(IsNull(WinAccountNum, ''))   as WinAccountNum,  
      max(B.GPSOptDate)                as GPSOptDate,  
      max(IsNull(B.idTeamGPSOpt, 0))   as idTeamGPSOpt,  
      case IsNull(SCGPN.d_iNum, 0) when 0 then '' else min(IsNull(P.GPName, '')) end as GPName_Min,  
      case IsNull(SCGPN.d_iNum, 0) when 0 then '' else max(IsNull(P.GPName, '')) end as GPName_Max  
    from  
      BarCode B  
      inner join Project P      on P.ID         = B.idProject  
      inner join Product PD     on PD.ID        = P.idProd  
      left  join Config BCS_Min on BCS_Min.Name = 'MinBarCodeStateForSaw'  
      left  join Config SCGPN   on SCGPN.Name   = 'bShowCommonGPNameTask_SawItemSelect' -- показать формулу если она для всех позиций общая  
    where  
      PD.Type = 1  
      and IsNull(B.nState, 0) & 4    != 4                          -- Берем только нераскроенные СП.  
      -- Отображает только те СП, у которых статус отличен от "Минимальный статус баркода, идущего в выбор на раскрой"  
      -- Игнорируем статус "Упакован" и "Закалка присутствует"  
      and IsNull(B.nState, 0) & (0xFFFFFFFF ^ 1024) & (0xFFFFFFFF ^ 65536) >= IsNull(BCS_Min.d_iNum, 0)  
    group by   
      idTask,  
      idTeam,  
      B.DateGiveManufact,  
      P.CamCount,
      IsNull(SCGPN.d_iNum, 0)               
  ) BSum  
    
  inner join Task T               on T.ID    = BSum.idTask              
  left  join Client C             on C.ID    = T.idClient  
  left  join Team                 on Team.ID = BSum.idTeam  
  left  join Team TeamGPS         on TeamGPS.ID = BSum.idTeamGPSOpt  
  left  join ClientManufactory CM on CM.ID = T.idClientManufactory  
  left  join DeliveryAddress   DA on DA.ID = T.idDeliveryAddress  
  left  join LabelSubType         on IsNull(LabelSubType.nSubType,0) = IsNull(T.nLabelSubType,0) and   
                                     LabelSubType.idClient = T.idClient  
  left  join DepotSubDivision DSD on DSD.ID = T.idDepotSubDivision  
      
  left join Config DSD_Saw on DSD_Saw.Name = 'DepotSubDivisionToSaw'  
  left join Config STD_Max on STD_Max.Name = 'MaxSawTaskDate'  
where  
  IsNull(T.bDontSaw, 0) = 0  
  and T.Date >= STD_Max.d_datetime  
  and IsNull(T.idDepotSubDivision, 0) = case when DSD_Saw.d_iNum > 0  
                                             then DSD_Saw.d_iNum  
                                             else IsNull(T.idDepotSubDivision, 0)  
                                        end  