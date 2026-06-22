if OBJECT_ID('v_Invoice_Reject_IZO', 'V') is not NULL
  drop view dbo.v_Invoice_Reject_IZO
go

-- Вьюха для распечатки Актов по браку (объединенная: обычный брак и заявленный брак)  
-- Это информация о заказах переделках, которые были сделаны на основании брака.  
-- Выводить нужно инфу о виде брака из заказа,в котором был брак , а не из в переделки  
create view v_Invoice_Reject_IZO  
as  
-- Обычный брак (Reject)  
select  
  T.ID as idTask,  
  T.Num as TaskNum,  
  T.AccountNum,  
  T.Date as TaskDate,  
  IsNull(T.NumCalcFact,'')  as NumCalcFact,  
  IsNull(T.DateComplite,'') as DateComplete,  
  T.Price as TaskPrice,  
  T.Komission,  
  T.DatePayDoc,  
  case when IsNull(C.NameFull, '') != '' then C.NameFull else IsNull(C.Name, '') end as ClientName,  
  C.NameFull as ClientNameFull,  
  C.Adress as ClientAdress,  
  C.AdressSubDiv,  
  C.Tel as ClientTel,  
  C.OKPO as ClientOKPO,  
  C.UNN as ClientUNN,  
  C.KPP as ClientKPP,  
  CB_C.KS as ClientKS,  
  BK_C.BIC as ClientBIC,  
  C.OKOHX as ClientOKOHX,  
  CB_C.RS as ClientRS,  
  BK_C.Name as ClientBank,  
  S.Name as SellerName,  
  S.NameFull as SellerNameFull,  
  S.AlternativeName as SellerAlternativeName,  
  S.UNN as SellerUNN,  
  S.Adress as SellerAdress,  
  CB_S.RS as SellerRS,  
  BK_S.Name as SellerBank,  
  S.Tel as SellerTel,  
  S.Fax as SellerFax,  
  S.eMail as SellerEMail,  
  S.OKOHX as SellerOKOHX,  
  S.OKPO as SellerOKPO,  
  CB_S.KS as SellerKS,  
  BK_S.BIC as SellerBIC,  
  S.KPP as SellerKPP,  
  S.AccountantName as SellerAccountantName,  
  S.ChiefName as SellerChiefName,  
  S.ShiperName,  
  S.AdressSubDiv as SubDivisionAddress,  
  IsNull(CSG.NameFull, C.NameFull) as ConsigneeNameFull,  
  IsNull(CSG.Adress, C.Adress) as ConsigneeAdress,  
  P.Num,  
  P.PriceNoNDS as PriceOfUnit,  
  P.SumNoNDS + P.SumNDS as PriceWithNDS,  
  P.SumNDS as NDS,  
  P.SumNoNDS,  
  P_R.SumNoNDS as SumNoNDS_Reject,
  P_R.SumNoNDS + P_R.SumNDS as PriceWithNDS_Reject,
  P.Mass * P.nCount as Mass,  
  case when IsNull(P.IsPriceByCount, 0) = 1  
       then 'шт.'  
       else 'кв.м.'  
  end as Unit,  
  P.nCount as nCount,  
  case when IsNull(P.IsPriceByCount, 0) = 1  
       then P.nCount  
       else P.nCount * P.Area  
  end as nCountArea,  
  P.GPName,  
  dbo.f_RUS_To_Eng(P.GPName) as GPNameEng,  
  cast(P.Width   as varchar(5)) as Width,  
  cast(P.Height  as varchar(5)) as Height,  
  P.Area,  
  IsNull(P.IsPriceByCount, 0) as IsPriceByCount,  
  case P.CamCount  
       when 1 then 'СПО'  
       when 2 then 'СПД'  
       else ''  
  end as CamCountStr,  
  P.PriceByM as Pricekvm,  
  cast(P.Thickness as varchar(3)) as Thickness,  
  replace(IsNull(P.Commentary, ''), 'Переделка брака!!!', '') + ' ' + IsNull(P.CommentClient, '') + ' ' + IsNull(P.Comment_Film, '') + ' ' + IsNull(P.Comment_Form, '') as Commentary,  
  PD.Name as ProductName,  
  DSD.Name as DepotName,  
  DSD.Tel as DepotSubDivisionTel,  
  BC.idUser_SetCombinationReject as ManagerID,  
  IsNull(M.ManagerName, M.Name) as ManagerName,  
  dbo.MassPhrase((select sum(round(Mass * nCount,        -1)) from Project where idTask = T.ID), 0) as MassPhraseTonn,  
  dbo.MassPhrase((select sum(round(Mass * nCount * 1000, -1)) from Project where idTask = T.ID), 1) as MassPhraseKg,  
  TR.idShip,  
  TR.Num as TransportNum,  
  abs(dbo.f_PaymentClientPaymentSum_All(1, C.ID, dbo.f_TruncDate(T.Date), 1)) as CurSaldo,  
  dbo.f_PaymentClientPaymentSum_All(1, C.ID, dbo.f_TruncDate(T.Date), 1) as sign_CurSaldo,  
  P.ID as idProject,  
  case P.CamCount  
       when 0 then '000000001'  
       when 1 then '000000002'  
       else        '000000003'  
  end as Code,  
  sum(1) as nCountReject,  
    
  -- Данные для обычного брака (Reject)  
  vCR.NameReject as RejectName,  
  vCR.NameRejectType as RejectType,  
  vCR.NameRejectPlace as RejectPlace,  
  vCR.idRejectAct as idRejectAct,  
  vCR.NameRejectAct,  
  vCR.NameTypeExpense as TypeExpenseName,  
  vCR.CommentReject as RejectComment,  
    
  IsNull(dbo.f_GetRejectAccountNum(BC.idBarCode_Reject),'') as RejectAccountNum,  
  IsNull(dbo.f_GetRejectTaskDate(BC.idBarCode_Reject),'') as RejectTaskDate,  
  IsNull(dbo.f_GetRejectDateGiveManufact(BC.idBarCode_Reject),'') as RejectDateGiveManufact,  
  IsNull(dbo.f_GetRejectNumCalcFact(BC.idBarCode_Reject),'') as RejectNumCalcFact,  
  IsNull(dbo.f_GetRejectDateComplite(BC.idBarCode_Reject),'') as RejectDateComplete,  
  IsNull(dbo.f_GetRejectTransportNum(BC.idBarCode_Reject),'') as RejectTransportNum,  
  IsNull(dbo.f_GetRejectShipDate(BC.idBarCode_Reject),'') as RejectShipDate,  
  IsNull(Ship.Date,'') as ShipDate,  
  IsNull(US.ManagerName,'') as CurrentUserName,  
  IsNull(BC.idManufactReason,1) as idManufactReason,  
  IsNull(dbo.f_GetSawNamesOfTask(T_R.ID),'') as SawNames,  
  Team.Name as TeamName,  
  Team.Num as TeamNum,  
  BC_R.nSmena,  
  case when max(BC_R.TimeScan) is not null then 'Возврат' else '' end as sReturn,  
  case when max(BC_R.TimeScan) is not null then 1 else 0 end as bReturn,  
  Tm_BC.Name as TeamName_BC,  
  AL.Name as AssemblyLineName,  
  IsNull(PG.Name, '') as PersonnelGuiltyName,  
    
  1 as Reject  
  
from  
  Task T  
  inner join Project             P     on T.ID     = P.idTask  
  inner join Product             PD    on PD.ID    = P.idProd  
  left  join Client              C     on C.ID     = T.idClient  
  left  join Client              S     on S.ID     = T.idSeller  
  left  join Client              CSG   on CSG.ID   = T.idConsignee  
  left  join ClientBank          CB_C  on CB_C.ID  = T.idClientBank_Client  
  left  join Bank                BK_C  on BK_C.ID  = CB_C.idBank  
  left  join ClientBank          CB_S  on CB_S.ID  = T.idClientBank_Seller  
  left  join Bank                BK_S  on BK_S.ID  = CB_S.idBank  
  left  join DepotSubDivision    DSD   on DSD.ID   = T.idDepotSubDivision  
  left  join Barcode             BC    on P.ID     = BC.idProject  
  left  join Transport           TR    on TR.ID    = BC.idTransport  
  left  join Ship                      on Ship.ID  = TR.idShip  
  left  join Barcode             BC_R  on BC_R.ID  = BC.idBarCode_Reject  
  left  join Project             P_R   on P_R.ID   = BC_R.idProject  
  left  join Task                T_R   on T_R.ID   = P_R.idTask  
  left  join Team                      on Team.ID  = T_R.idTeam  
  left  join Team                Tm_BC on Tm_BC.ID = BC_R.idTeam  
  left  join AssemblyLine        AL    on AL.ID    = BC_R.idAssemblyLine  
  left  join Personnel           PG    on PG.ID    = BC_R.idPersonnel_Guilty  
  left  join Users               US    on US.Name  = case CURRENT_USER when 'dbo' then 'sa' else CURRENT_USER end  
  left  join Users               M     on M.ID     = BC_R.idUser_SetCombinationReject  
  left  join v_CombinationReject vCR   on vCR.ID   = BC_R.idCombinationReject  
where  
  PD.Type = 1 and  
  IsNull(BC.idBarCode_Reject, 0) > 0 and  
  IsNull(BC_R.idCombinationReject, 0) != 0

group by  
  T.ID,  
  T.Num,  
  T.AccountNum,  
  T.Date,  
  IsNull(T.NumCalcFact, ''),  
  IsNull(T.DateComplite, ''),  
  T.Price,  
  T.Komission,  
  T.DatePayDoc,  
  C.ID,  
  case when IsNull(C.NameFull, '') != '' then C.NameFull else IsNull(C.Name, '') end,  
  C.NameFull,  
  C.Adress,  
  C.AdressSubDiv,  
  C.Tel,  
  C.OKPO,  
  C.UNN,  
  C.KPP,  
  CB_C.KS,  
  BK_C.BIC,  
  C.OKOHX,  
  CB_C.RS,  
  BK_C.Name,  
  S.Name,  
  S.NameFull,  
  S.AlternativeName,  
  S.UNN,  
  S.Adress,  
  CB_S.RS,  
  BK_S.Name,  
  S.Tel,  
  S.Fax,  
  S.eMail,  
  S.OKOHX,  
  S.OKPO,  
  CB_S.KS,  
  BK_S.BIC,  
  S.KPP,  
  S.AccountantName,  
  S.ChiefName,  
  S.ShiperName,  
  S.AdressSubDiv,  
  IsNull(CSG.NameFull, C.NameFull),  
  IsNull(CSG.Adress, C.Adress),  
  P.Num,  
  P.PriceNoNDS,  
  P.SumNoNDS,  
  P.SumNDS,  
  P.Mass,  
  case when P.IsPriceByCount = 1 then 'шт.' else 'кв.м.' end,  
  P.nCount,  
  case when P.IsPriceByCount = 1 then P.nCount else P.nCount * P.Area end,  
  P.GPName,  
  dbo.f_RUS_To_Eng(P.GPName),  
  cast(P.Width as varchar(5)),  
  cast(P.Height as varchar(5)),  
  P.Area,  
  P.IsPriceByCount,  
  case P.CamCount when 1 then 'СПО' when 2 then 'СПД' else '' end,  
  P.PriceByM,  
  cast(P.Thickness as varchar(3)),  
  replace(IsNull(P.Commentary, ''), 'Переделка брака!!!', '') + ' ' + IsNull(P.CommentClient, '') + ' ' + IsNull(P.Comment_Film, '') + ' ' + IsNull(P.Comment_Form, ''),  
  P_R.SumNoNDS,
  P_R.SumNDS,
  PD.Name,  
  DSD.Name,  
  DSD.Tel,  
  BC.idUser_SetCombinationReject,  
  IsNull(M.ManagerName, M.Name),  
  TR.idShip,  
  TR.Num,  
  T.Date,  
  P.ID,  
  case P.CamCount when 0 then '000000001' when 1 then '000000002' else '000000003' end,  
  BC.idBarCode_Reject,  
  BC_R.nSmena,  
  AL.Name,  
  IsNull(Ship.Date, ''),  
  IsNull(US.ManagerName, ''),  
  IsNull(BC.idManufactReason,1),  
  T_R.ID,  
  Team.Name,  
  Team.Num,  
  Tm_BC.Name,  
  IsNull(PG.Name, ''),  
  vCR.NameReject,  
  vCR.NameRejectType,  
  vCR.NameRejectPlace,  
  vCR.idRejectAct,  
  vCR.NameRejectAct,  
  vCR.NameTypeExpense,  
  vCR.CommentReject  
  
union all  
  
-- Заявленный брак (Declare)  
select  
  T.ID as idTask,  
  T.Num as TaskNum,  
  T.AccountNum,  
  T.Date as TaskDate,  
  IsNull(T.NumCalcFact,'')  as NumCalcFact,  
  IsNull(T.DateComplite,'') as DateComplete,  
  T.Price as TaskPrice,  
  T.Komission,  
  T.DatePayDoc,  
  case when IsNull(C.NameFull, '') != '' then C.NameFull else IsNull(C.Name, '') end as ClientName,  
  C.NameFull as ClientNameFull,  
  C.Adress as ClientAdress,  
  C.AdressSubDiv,  
  C.Tel as ClientTel,  
  C.OKPO as ClientOKPO,  
  C.UNN as ClientUNN,  
  C.KPP as ClientKPP,  
  CB_C.KS as ClientKS,  
  BK_C.BIC as ClientBIC,  
  C.OKOHX as ClientOKOHX,  
  CB_C.RS as ClientRS,  
  BK_C.Name as ClientBank,  
  S.Name as SellerName,  
  S.NameFull as SellerNameFull,  
  S.AlternativeName as SellerAlternativeName,  
  S.UNN as SellerUNN,  
  S.Adress as SellerAdress,  
  CB_S.RS as SellerRS,  
  BK_S.Name as SellerBank,  
  S.Tel as SellerTel,  
  S.Fax as SellerFax,  
  S.eMail as SellerEMail,  
  S.OKOHX as SellerOKOHX,  
  S.OKPO as SellerOKPO,  
  CB_S.KS as SellerKS,  
  BK_S.BIC as SellerBIC,  
  S.KPP as SellerKPP,  
  S.AccountantName as SellerAccountantName,  
  S.ChiefName as SellerChiefName,  
  S.ShiperName,  
  S.AdressSubDiv as SubDivisionAddress,  
  IsNull(CSG.NameFull, C.NameFull) as ConsigneeNameFull,  
  IsNull(CSG.Adress, C.Adress) as ConsigneeAdress,  
  P.Num,  
  P.PriceNoNDS as PriceOfUnit,  
  P.SumNoNDS + P.SumNDS as PriceWithNDS,  
  P.SumNDS as NDS,  
  P.SumNoNDS,  
  P_R.SumNoNDS as SumNoNDS_Reject,
  P_R.SumNoNDS + P_R.SumNDS as PriceWithNDS_Reject,
  P.Mass * P.nCount as Mass,  
  case when IsNull(P.IsPriceByCount, 0) = 1  
       then 'шт.'  
       else 'кв.м.'  
  end as Unit,  
  P.nCount as nCount,  
  case when IsNull(P.IsPriceByCount, 0) = 1  
       then P.nCount  
       else P.nCount * P.Area  
  end as nCountArea,  
  P.GPName,  
  dbo.f_RUS_To_Eng(P.GPName) as GPNameEng,  
  cast(P.Width   as varchar(5)) as Width,  
  cast(P.Height  as varchar(5)) as Height,  
  P.Area,  
  IsNull(P.IsPriceByCount, 0) as IsPriceByCount,  
  case P.CamCount  
       when 1 then 'СПО'  
       when 2 then 'СПД'  
       else ''  
  end as CamCountStr,  
  P.PriceByM as Pricekvm,  
  cast(P.Thickness as varchar(3)) as Thickness,  
  replace(IsNull(P.Commentary, ''), 'Переделка брака!!!', '') + ' ' + IsNull(P.CommentClient, '') + ' ' + IsNull(P.Comment_Film, '') + ' ' + IsNull(P.Comment_Form, '') as Commentary,  
  PD.Name as ProductName,  
  DSD.Name as DepotName,  
  DSD.Tel as DepotSubDivisionTel,  
  BC.idUser_SetCombinationReject_Declare as ManagerID,  
  IsNull(M.ManagerName, M.Name) as ManagerName,  
  dbo.MassPhrase((select sum(round(Mass * nCount,        -1)) from Project where idTask = T.ID), 0) as MassPhraseTonn,  
  dbo.MassPhrase((select sum(round(Mass * nCount * 1000, -1)) from Project where idTask = T.ID), 1) as MassPhraseKg,  
  TR.idShip,  
  TR.Num as TransportNum,  
  abs(dbo.f_PaymentClientPaymentSum_All(1, C.ID, dbo.f_TruncDate(T.Date), 1)) as CurSaldo,  
  dbo.f_PaymentClientPaymentSum_All(1, C.ID, dbo.f_TruncDate(T.Date), 1) as sign_CurSaldo,  
  P.ID as idProject,  
  case P.CamCount  
       when 0 then '000000001'  
       when 1 then '000000002'  
       else        '000000003'  
  end as Code,  
  sum(1) as nCountReject,  
    
  -- Данные для заявленного брака (Declare)  
  vCR.NameReject as RejectName,  
  vCR.NameRejectType as RejectType,  
  vCR.NameRejectPlace as RejectPlace,  
  vCR.idRejectAct as idRejectAct,  
  vCR.NameRejectAct,  
  vCR.NameTypeExpense as TypeExpense,  
  vCR.CommentReject as RejectComment,  
    
  IsNull(dbo.f_GetRejectAccountNum(BC.idBarCode_Reject),'') as RejectAccountNum,  
  IsNull(dbo.f_GetRejectTaskDate(BC.idBarCode_Reject),'') as RejectTaskDate,  
  IsNull(dbo.f_GetRejectDateGiveManufact(BC.idBarCode_Reject),'') as RejectDateGiveManufact,  
  IsNull(dbo.f_GetRejectNumCalcFact(BC.idBarCode_Reject),'') as RejectNumCalcFact,  
  IsNull(dbo.f_GetRejectDateComplite(BC.idBarCode_Reject),'') as RejectDateComplete,  
  IsNull(dbo.f_GetRejectTransportNum(BC.idBarCode_Reject),'') as RejectTransportNum,  
  IsNull(dbo.f_GetRejectShipDate(BC.idBarCode_Reject),'') as RejectShipDate,  
  IsNull(Ship.Date,'') as ShipDate,  
  IsNull(US.ManagerName,'') as CurrentUserName,  
  IsNull(BC.idManufactReason,1) as idManufactReason,  
  IsNull(dbo.f_GetSawNamesOfTask(T_R.ID),'') as SawNames,  
  Team.Name as TeamName,  
  Team.Num as TeamNum,  
  BC_R.nSmena,  
  case when max(BC_R.TimeScan) is not null then 'Возврат' else '' end as sReturn,  
  case when max(BC_R.TimeScan) is not null then 1 else 0 end as bReturn,  
  Tm_BC.Name as TeamName_BC,  
  AL.Name as AssemblyLineName,  
  IsNull(PG.Name, '') as PersonnelGuiltyName,  
    
  0 as Reject  
  
from  
  Task T  
  inner join Project             P     on T.ID     = P.idTask  
  inner join Product             PD    on PD.ID    = P.idProd  
  left  join Client              C     on C.ID     = T.idClient  
  left  join Client              S     on S.ID     = T.idSeller  
  left  join Client              CSG   on CSG.ID   = T.idConsignee  
  left  join ClientBank          CB_C  on CB_C.ID  = T.idClientBank_Client  
  left  join Bank                BK_C  on BK_C.ID  = CB_C.idBank  
  left  join ClientBank          CB_S  on CB_S.ID  = T.idClientBank_Seller  
  left  join Bank                BK_S  on BK_S.ID  = CB_S.idBank  
  left  join DepotSubDivision    DSD   on DSD.ID   = T.idDepotSubDivision  
  left  join Barcode             BC    on P.ID     = BC.idProject  
  left  join Transport           TR    on TR.ID    = BC.idTransport  
  left  join Ship                      on Ship.ID  = TR.idShip  
  left  join Barcode             BC_R  on BC_R.ID  = BC.idBarCode_Reject  
  left  join Project             P_R   on P_R.ID   = BC_R.idProject  
  left  join Task                T_R   on T_R.ID   = P_R.idTask  
  left  join Team                      on Team.ID  = T_R.idTeam  
  left  join Team                Tm_BC on Tm_BC.ID = BC_R.idTeam  
  left  join AssemblyLine        AL    on AL.ID    = BC_R.idAssemblyLine  
  left  join Personnel           PG    on PG.ID    = BC_R.idPersonnel_Guilty_Declare  
  left  join Users               US    on US.Name  = case CURRENT_USER when 'dbo' then 'sa' else CURRENT_USER end  
  left  join Users               M     on M.ID     = BC_R.idUser_SetCombinationReject_Declare  
  left  join v_CombinationReject vCR   on vCR.ID   = BC_R.idCombinationReject_Declare  
where  
  PD.Type = 1 and  
  IsNull(BC.idBarCode_Reject, 0) > 0 and  
  IsNull(BC_R.idCombinationReject_Declare, 0) != 0
  
group by  
  T.ID,  
  T.Num,  
  T.AccountNum,  
  T.Date,  
  IsNull(T.NumCalcFact, ''),  
  IsNull(T.DateComplite, ''),  
  T.Price,  
  T.Komission,  
  T.DatePayDoc,  
  C.ID,  
  case when IsNull(C.NameFull, '') != '' then C.NameFull else IsNull(C.Name, '') end,  
  C.NameFull,  
  C.Adress,  
  C.AdressSubDiv,  
  C.Tel,  
  C.OKPO,  
  C.UNN,  
  C.KPP,  
  CB_C.KS,  
  BK_C.BIC,  
  C.OKOHX,  
  CB_C.RS,  
  BK_C.Name,  
  S.Name,  
  S.NameFull,  
  S.AlternativeName,  
  S.UNN,  
  S.Adress,  
  CB_S.RS,  
  BK_S.Name,  
  S.Tel,  
  S.Fax,  
  S.eMail,  
  S.OKOHX,  
  S.OKPO,  
  CB_S.KS,  
  BK_S.BIC,  
  S.KPP,  
  S.AccountantName,  
  S.ChiefName,  
  S.ShiperName,  
  S.AdressSubDiv,  
  IsNull(CSG.NameFull, C.NameFull),  
  IsNull(CSG.Adress, C.Adress),  
  P.Num,  
  P.PriceNoNDS,  
  P.SumNoNDS,  
  P.SumNDS,  
  P.Mass,  
  case when P.IsPriceByCount = 1 then 'шт.' else 'кв.м.' end,  
  P.nCount,  
  case when P.IsPriceByCount = 1 then P.nCount else P.nCount * P.Area end,  
  P.GPName,  
  dbo.f_RUS_To_Eng(P.GPName),  
  cast(P.Width as varchar(5)),  
  cast(P.Height as varchar(5)),  
  P.Area,  
  P.IsPriceByCount,  
  case P.CamCount when 1 then 'СПО' when 2 then 'СПД' else '' end,  
  P.PriceByM,  
  cast(P.Thickness as varchar(3)),  
  replace(IsNull(P.Commentary, ''), 'Переделка брака!!!', '') + ' ' + IsNull(P.CommentClient, '') + ' ' + IsNull(P.Comment_Film, '') + ' ' + IsNull(P.Comment_Form, ''),  
  P_R.SumNoNDS,
  P_R.SumNDS,
  PD.Name,  
  DSD.Name,  
  DSD.Tel,  
  BC.idUser_SetCombinationReject_Declare,  
  IsNull(M.ManagerName, M.Name),  
  TR.idShip,  
  TR.Num,  
  T.Date,  
  P.ID,  
  case P.CamCount when 0 then '000000001' when 1 then '000000002' else '000000003' end,  
  BC.idBarCode_Reject,  
  BC_R.nSmena,  
  AL.Name,  
  IsNull(Ship.Date, ''),  
  IsNull(US.ManagerName, ''),  
  IsNull(BC.idManufactReason,1),  
  T_R.ID,  
  Team.Name,  
  Team.Num,  
  Tm_BC.Name,  
  IsNull(PG.Name, ''),  
  vCR.NameReject,  
  vCR.NameRejectType,  
  vCR.NameRejectPlace,  
  vCR.idRejectAct,  
  vCR.NameRejectAct,  
  vCR.NameTypeExpense,  
  vCR.CommentReject  
go
