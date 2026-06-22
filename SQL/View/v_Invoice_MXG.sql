if OBJECT_ID('v_Invoice_MXG', 'V') is not NULL
  drop view dbo.v_Invoice_MXG
go

-- [OK] Источник для максгласа - сделан 17.03.2015 по приказу А.Бабченко
--              T.DateComplite - может быть равным нуллу, в отличие от других 
--              CamCountStr    - Имеет свой формат
-- [ab] Запрос в МаксГлассе уже не используется. 
--      Т.к. МаксГласс перешёл на множество записей в UserSignAuthority, 
--      при которых данный запрос будет размножать позиции накладной.
--      Для МакГласса был создан новый запрос v_Invoice_MXG_NoSign.
--      Данный запрос продолжает использоваться в других компаниях, у которых только одна запись в UserSignAuthority.

create view dbo.v_Invoice_MXG
as
select
  1                              as forCount,
  T.ID                           as idTask,
  T.Num                          as TaskNum,
  T.AccountNum,
  T.ClientNum,
  T.Date                         as TaskDate,
  IsNull(T.NumCalcFact,  ''    ) as NumCalcFact,
  IsNull(T.ForAccountNum, ''   ) as ForAccountNum,
  T.DateComplite                 as DateComplete,

  T.Price                        as TaskPrice,
  T.SumNDS                       as SumNDSTask,
  T.SumNoNDS                     as SumNoNDSTask,
  T.Komission,
  T.DatePayDoc,
  T.TypeOrder,
  IsNull(T.Commentary,   '')     as TaskCommentary,
  C.ID                           as idClient,
  IsNull(C.Name,         '')     as ClientName,
  IsNull(C.NameFull, IsNull(C.Name, '')) as ClientNameFull,
  IsNull(C.Adress,       '')     as ClientAdress,
  IsNull(C.AdressSubDiv, '')     as ClientAdressSubDiv,
  case
    when isNull(T.AddressDelivery, '') != '' then T.AddressDelivery
    when isNull(DA.Name, '')           != '' then DA.Name
    when isNull(CSG.AdressSubDiv, '')  != '' then CSG.AdressSubDiv
    when isNull(CSG.Adress, '')        != '' then CSG.Adress
    else null
  end as AdressSubDiv,
  IsNull(C.Tel,          '')     as ClientTel,
  IsNull(C.OKPO,         '')     as ClientOKPO,
  IsNull(C.UNN,          '')     as ClientUNN,
  IsNull(C.KPP,          '')     as ClientKPP,
  IsNull(CB_C.KS,        '')     as ClientKS,
  IsNull(BK_C.BIC,       '')     as ClientBIC,
  IsNull(C.OKOHX,        '')     as ClientOKOHX,
  IsNull(CB_C.RS,        '')     as ClientRS,
  IsNull(BK_C.Name,      '')     as ClientBank,   

  IsNull(S.Name,            '')  as SellerName,
  IsNull(S.NameFull,        '')  as SellerNameFull,
  IsNull(S.AlternativeName, '')  as SellerAlternativeName,
  IsNull(S.UNN,             '')  as SellerUNN,
  IsNull(S.City,            '')  as SellerCity,
  IsNull(SLA.Address, IsNull(S.Adress, '')) as SellerAdress,
  IsNull(CB_S.RS,           '')  as SellerRS,
  IsNull(BK_S.Name,         '')  as SellerBank,
  IsNull(S.Tel,             '')  as SellerTel,
  IsNull(S.Fax,             '')  as SellerFax,
  IsNull(S.eMail,           '')  as SellerEMail,
  IsNull(S.Site,            '')  as SellerSite,
  IsNull(S.OKOHX,           '')  as SellerOKOHX,
  IsNull(S.OKPO,            '')  as SellerOKPO,
  IsNull(S.OGRN,            '')  as SellerOGRN,
  IsNull(CB_S.KS,           '')  as SellerKS,
  IsNull(BK_S.BIC,          '')  as SellerBIC,
  IsNull(S.KPP,             '')  as SellerKPP,
  IsNull(S.ShiperName,      '')  as SellerShiperName, 
  'Ответственный за погрузку'    as SellerShiperPost, 

  --Shipper
  CB_SH.KS                   as ShipperKS,
  Shipper.UNN                as ShipperUNN,
  BK_SH.BIC                  as ShipperBIC,
  Shipper.Name               as ShipperName,
  Shipper.NameFull           as ShipperNameFull,
  isNull(Shipper.Adress, '') as ShipperAdress,
  Shipper.City               as ShipperCity,
  CB_SH.RS                   as ShipperRS,
  BK_SH.Name                 as ShipperBank,
  Shipper.Tel                as ShipperTel,
  Shipper.KPP                as ShipperKPP,
  Shipper.OKOHX              as ShipperOKOHX,
  Shipper.OKPO               as ShipperOKPO,
  Shipper.AccountantName     as ShipperAccountantName,
  Shipper.ChiefName          as ShipperChiefName,
  Shipper.CertificateNDS     as ShipperCertNDS,

  case when IsNull(DSD.bSignatureFromUser, 0) = 1
       then IsNull(U.ManagerName, '')
       else IsNull(S.AccountantName, '')
       end as SellerAccountantName,
  case when IsNull(DSD.bSignatureFromUser, 0) = 1
       then IsNull(U.ManagerName, '')
       else IsNull(S.ChiefName, '')
       end as SellerChiefName,
  --S.AccountantName as SellerAccountantName,
  --S.ChiefName as SellerChiefName,
  S.ShiperName,
  IsNull(S.Commentary, '') as SellerCommentary,
  --IsNull(DSD.Address,  '') as SubDivisionAddress,

  IsNull(DSD.KPP,      '') as SubDivisionKPP,
  IsNull(CSG.NameFull, IsNull(C.Name, '')) as ConsigneeNameFull,
  IsNull(CSG.Adress, C.Adress) as ConsigneeAdress,
  P.Num,
  P.PriceS,    -- цена за шпросы
  case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNDS/P.Area   else P.PriceNDS   end as PriceM2WithNDS,
  case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNoNDS/P.Area else P.PriceNoNDS end as PriceOfUnit,
  P.SumWithNDS as PriceWithNDS,
  P.SumNDS as NDS,
  P.SumNoNDS,
  P.PriceByMNoNDS,
  P.PriceNoNDS_M2,
  case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNDS/P.Area   else P.PriceNDS   end as PriceNDS,
  P.Mass * P.nCount as Mass,
  
  case 
    when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 1
    then UCount.Name
    else UArea.Name
  end as Unit,
  
  case 
    when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 1
    then UCount.Code_OKEI
    else UArea.Code_OKEI
  end as Unit_Code_OKEI,
  
  case when isNull(Nds.Name,'') = '' then cast(NDS.NDS as varchar(2)) else Nds.Name end as Tax_rate,
  P.nCount as nCount,
  case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 1
       then P.nCount
       else P.nCount * P.Area
  end as nCountArea,
  dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name, P.GPName, P.CamCount, P.Thickness, P.Width, P.Height, IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), P.ID, P.Num, 0) as  GPName,
  dbo.f_RUS_To_Eng(P.GPName) as GPNameEng,
  cast(P.Width   as varchar(5)) as Width,
  cast(P.Height  as varchar(5)) as Height,
  P.Area,
  IsNull(P.IsPriceByCount, 0) as IsPriceByCount,
  
  dbo.f_GetCamCountStr(P.CamCount,  IsNull(CF.d_iNum, 0)) as CamCountStr,
  
  P.PriceByM                                 as Pricekvm,     -- В отчете "Счет-договор" (Task_Agreement_Common_2.rpt) используется поле Pricekvm (цена за 1 кв. м.), которого нет. Добавляю.
  cast(IsNull(P.Thickness, 0) as varchar(3)) as Thickness,
  IsNull(P.Commentary, '')                   as Commentary,
  PD.Name as ProductName,
  IsNull(DSD.Name, '')                       as DepotName,
  DSD.Address                                as SubDivisionAddress,
  IsNull(DSD_Ship.Address, '')               as SubDivisionAddress_Ship,
  IsNull(DSD.Tel, '')                        as DepotSubDivisionTel,
  --DSD.KPP as SubDivisionKPP,
  IsNull(DSD.ManagerName, '') as ManagerName,            -- Для обратной совместимости (напр. с v_InvoiceGroupByGPName)
  IsNull(DSD.ManagerName, '') as SubDivisionManagerName,
  dbo.MassPhrase((select round(sum(Mass * nCount),        0) from Project where idTask = T.ID), 0) as MassPhraseTonn,
  dbo.MassPhrase((select round(sum(Mass * nCount * 1000), 0) from Project where idTask = T.ID), 1) as MassPhraseKg,
  0 as CurSaldo,
  0 as sign_CurSaldo,
  P.ID as idProject,
  case P.CamCount
       when 0 then '000000001'
       when 1 then '000000002'
       else        '000000003'
  end as Code,
  IsNull(U.ManagerName, '')     as Manager,
  IsNull(U.Tel, '')             as Tel,
  P.CamCount,
  IsNull(DSD.HeaderTN, '')      as HeaderTN,
  IsNull(U.Post, '')            as Signature_ShiperPost,
  IsNull(CC.Name, '')           as ContractName,
  IsNull(CC.ContractNum, '')    as ContractNum,
  IsNull(CC.Date, '')           as ContractDate,
  PD.Type                       as ProductType,
  IsNull(Autor.Post, '')        as PrimaryManagerPost,
  IsNull(Autor.ManagerName, '') as PrimaryManagerName,
  IsNull(P.CommentClient, '')   as CommentClient,
  ''                            as NumInvoice,
  null                          as TransportDate,
  
  DSD.AddTo_NumInvoice,
  USA.InvoiceResponsName_1,                                -- расшифровка подписи
  USA.InvoiceOrderPost_1,                                  -- должность
  USA.InvoiceOrderNum_1,                                   -- приказ
  USA.InvoiceOrderDate_1,                                  -- дата приказа
  USA.InvoiceResponsName_2,
  USA.InvoiceOrderPost_2,
  USA.InvoiceOrderNum_2,
  USA.InvoiceOrderDate_2,
  USA.InvoiceResponsName_3,
  USA.InvoiceOrderPost_3,
  USA.InvoiceOrderNum_3,
  USA.InvoiceOrderDate_3,
  USA.InvoiceResponsName_4,
  USA.InvoiceOrderPost_4,
  USA.InvoiceOrderNum_4,
  USA.InvoiceOrderDate_4,
  IsNull(DA.Name, T.AddressDelivery)  as AddressDelivery,
  DSD.KPP                             as DepotSubDivisionKPP,
  dbo.f_GetGPRasInfo(P.ID, P.bShpros) as RasInfoText,

  case when P.CamCount = 0 then 'Стекло ' else 'Стеклопакет ' end +  
  case when P.CamCount > 0 then ''        else ''             end +  
  P.GPName + ' ' + ltrim(str(P.Width)) + ' x ' +  ltrim(str(P.Height)) +  
  case when P.bShpros <> 0 then ' ' + dbo.f_GetGPRasInfo(P.ID, P.bShpros) +   
                                ' ' + ltrim(str((select sum(LengReal) from RasShrink where idProject = P.ID))) + 'мм'   
    else ''   
  end  
    + ', ' + ltrim(str(P.nCount)) + ' шт.' as GPNameStr,  

  IsNull(C.idDefaultAdress, 3)             as idDefaultAdress, 
  T.A_NumCalcFact
from
  Task T
  inner join Project P            on P.idTask = T.ID
  inner join Product PD           on PD.ID    = P.idProd
  left  join NDS                  on NDS.ID   = T.idNDS
  left  join ClientContract CC    on CC.ID    = T.idClientContract
  left  join Client C             on C.ID     = T.idClient
  left  join Client S             on S.ID     = T.idSeller
  left  join Client Shipper       on Shipper.ID = T.idShipper
  left  join Client CSG           on CSG.ID   = T.idConsignee
  left  join ClientBank CB_C      on CB_C.ID  = T.idClientBank_Client   -- Теперь KS   и RS  лежат тут.
  left  join Bank BK_C            on BK_C.ID  = CB_C.idBank             -- Теперь Bank и BIC лежат тут.
  left  join ClientBank CB_S      on CB_S.ID  = T.idClientBank_Seller   -- Теперь KS   и RS  лежат тут.
  left  join Bank BK_S            on BK_S.ID  = CB_S.idBank             -- Теперь Bank и BIC лежат тут.
  left  join ClientBank CB_SH  on CB_SH.ID    = T.idClientBank_Shipper  -- Теперь KS   и RS  лежат тут.
  left  join Bank BK_SH        on BK_SH.ID    = CB_SH.idBank            -- Теперь Bank и BIC лежат тут.
  
  left  join DepotSubDivision  DSD on DSD.ID   = T.idDepotSubDivision
  left  join DepotSubDivision DSD_Ship  on DSD_Ship.ID   = T.idDepotSubDivision_Shipper

  left  join UsersSignAutority USA on USA.guidDepotSubDivision = DSD.guid and  -- не добавлять в UsersSignAutority более одной записей, которые подходят по условию
                                      (T.DateComplite >= USA.DateBegin    and  -- т.к. записи будут задваиваться
                                       T.DateComplite <= USA.DateEnd      or 
                                       T.DateComplite >= USA.DateBegin    and
                                       USA.DateEnd is null)
  left  join Users U              on lower(U.Name) = lower(SYSTEM_USER)
  left  join Config CF            on CF.Name  = 'FormatTypeOfGPName'
  left  join Config CPU           on CPU.Name = 'bPriceUnitInCalcFact'
  left  join Users Autor          on Autor.ID = C.idUsers_PrimaryManager
  left  join DeliveryAddress DA   on DA.ID  = T.idDeliveryAddress
  
  left  join (select top 1 * from Unit where nTypeUnit = 1) UArea  on UArea.nTypeUnit  = 1
  left  join (select top 1 * from Unit where nTypeUnit = 2) UCount on UCount.nTypeUnit = 2
  left  join ClientLegalAddress SLA on SLA.idClient = T.idSeller and
                                      (T.DateComplite >= SLA.DateBegin and
                                       T.DateComplite <= SLA.DateEnd or 
                                       T.DateComplite >= SLA.DateBegin and
                                       SLA.DateEnd is null)
go
