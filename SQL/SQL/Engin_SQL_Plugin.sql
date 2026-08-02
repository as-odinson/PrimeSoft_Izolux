/*
  Update: Engin_SQL_Plugin
  Generated: 30.07.2026 14:31:04
  Generator: Engine_Auto.vbs
*/

set nocount on
go

/* ============================================================
   Tables
   ============================================================ */


print convert(varchar, getdate(), 20) + ' : start Tables\OperatoGroup.sql'
go

-- ============================================================
-- File: Tables\OperatoGroup.sql
-- ============================================================
if object_id('dbo.OperatorGroup', 'U') is null
begin
    create table OperatorGroup
    (
        ID int identity(1,1) primary key,
        idOperatorBrigadier int null,
        Name nvarchar(100)
    )
end
go

if object_id('dbo.OperatorGroupItem', 'U') is null
begin
    create table OperatorGroupItem
    (
        ID int identity(1,1) primary key,

        idOperatorGroup int not null,
        idOperator int not null,

        Coef float not null
    )
end
go

if col_length('dbo.OperatorGroup', 'idSectorManufact') is null
  alter table dbo.OperatorGroup add idSectorManufact int null
go

if exists (select top 1 idSectorManufact from OperatorGroup order by idSectorManufact desc)
begin
  update OperatorGroup set idSectorManufact = 1 where Name in ('Резка1', 'Резка2')
  update OperatorGroup set idSectorManufact = 4 where Name in ('Закалка1', 'Закалка2')
  update OperatorGroup set idSectorManufact = 6 where Name in ('Лисик', 'Вондек')
end

--insert into OperatorGroup (Name, idOperatorBrigadier)
--values
--('Закалка1', 5),
--('Закалка2', 12),
--('Резка1', 2),
--('Резка2', 23),
--('Рамка', 26),
--('Отгрузка', 8),
--('Вондек', 26),
--('Лисик', 26)



--select *
--from Operator
--where Name like '%Британ%'
--   or Name like '%Абдулазизов%'
--   or Name like '%Азамов%'
--   or Name like '%Ахмадалиев%'

--select * from OperatorGroup
--update OperatorGroup set  idOperatorBrigadier = -11 where ID = 7

--insert into OperatorGroupItem(idOperatorGroup, idOperator, Coef)
--values
--(1, 5, 11.5),
--(1, 16, 10.0),
--(1, 17, 10.0),
--(1, 11, 11.5),

--(2, 6, 10.0),
--(2, 10, 10.0),
--(2, 18, 11.5),
--(2, 12, 11.5),

--(3, 2, 3.9),
--(3, 19, 2.7),
--(3, 20, 2.7),
--(3, 21, 2.7),

--(4, 4, 3.2),
--(4, 22, 2.8),
--(4, 23, 3.2),
--(4, 24, 2.8),

--(5, 25, 1.15),
--(5, 26, 1.2),
--(5, 27, 1.15),

--(6, 7, 3.3),
--(6, 8, 4.0),
--(6, 28, 2.0),
--(6, 29, 2.0),

--(5, -1, 8.0),
--(5, 30, 6.0),
--(5, 31, 6.0),
--(5, 13, 8.0),

--(5, 32, 7.0),
--(5, 33, 6.0),
--(5, 34, 5.0),

--(5, 1, 7.0),
--(5, 35, 5.0),
--(5, 36, 5.0),
--(5, 37, 7.0)

go
print convert(varchar, getdate(), 20) + ' : finish Tables\OperatoGroup.sql'
go

print convert(varchar, getdate(), 20) + ' : start Tables\ScanHistory.sql'
go

-- ============================================================
-- File: Tables\ScanHistory.sql
-- ============================================================
--Types
      --e_type_unknow  = 0, // неизвестный
      --e_type_oper    = 1, // оператор
      --e_type_pyramid = 2, // пирамида
      --e_type_barcode = 3, // СП
      --e_type_ship    = 4 // отгрузка

 if object_id('dbo.ScanHistory', 'U') is null
begin
    create table ScanHistory
    (
      ID bigint identity(1,1) not null,
      idOperator int not null,
      BarCode nvarchar(100) not null,
      Type int not null,
      Message nvarchar(500) null,
      DateScan datetime not null constraint DF_ScanHistory_DateScan default(getdate()),
      constraint PK_ScanHistory primary key clustered (ID)
    )
end
go

go
print convert(varchar, getdate(), 20) + ' : finish Tables\ScanHistory.sql'
go

print convert(varchar, getdate(), 20) + ' : start Tables\UserGroupCatalogueRight.sql'
go

-- ============================================================
-- File: Tables\UserGroupCatalogueRight.sql
-- ============================================================
if object_id('dbo.UserGroupCatalogueRight', 'U') is null
begin
  create table dbo.UserGroupCatalogueRight
  (
    idUserGroup int not null,
    idCatalogue int not null,
    bDenyShow bit null,
    bDenyEdit bit null
  )
end
go

go
print convert(varchar, getdate(), 20) + ' : finish Tables\UserGroupCatalogueRight.sql'
go

print convert(varchar, getdate(), 20) + ' : start Tables\UserGroupPermission.sql'
go

-- ============================================================
-- File: Tables\UserGroupPermission.sql
-- ============================================================
if object_id('dbo.UserGroupPermission', 'U') is null
begin
  create table dbo.UserGroupPermission
  (
    idUserGroup int not null primary key,

    TypeOrder0 bit null,
    TypeOrder1 bit null,
    TypeOrder2 bit null,

    bSecurity bit null,
    bPlanSetter bit null,
    bOptionsEdit bit null,
    bTaskAdd bit null,
    bTaskDelete bit null,
    bTaskProcessedDelete bit null,
    bTaskReopen bit null,
    bPositionEdit bit null,
    bTaskPlan bit null,
    bDateManufactEdit bit null,
    bToSaw bit null,
    bExportGPS bit null,
    bTaskReady bit null,
    bUserEdit bit null,

    bLockedTaskEdit bit null,
    bShippedTaskEdit bit null,
    bCreditEdit bit null,
    bFireClientOverdraftTask bit null,
    bManualMaterEdit bit null,
    bOpenOpenedBySomeoneDoc bit null,
    bAllowEditPaidTaskProperty bit null,
    bPreManufaktTask_Edit bit null,

    bShipLock bit null,
    bShipUnlock bit null,
    bAllowIgnoreDayLimitSP bit null,
    bWagesEdit bit null,
    bSetProcessComplete bit null,
    bClearProcessComplete bit null,

    bSetFactReject bit null,
    bRecalcTimeGlassProcSaw bit null,
    bIgnoreErrorParseFormule bit null,
    bChangeAddDepartment bit null,
    bEnableDelFreeZone bit null,
    bViewAnotherTask bit null,
    bShowAnotherTask bit null,
    bCanSavePlot bit null
  )
end
go


go
print convert(varchar, getdate(), 20) + ' : finish Tables\UserGroupPermission.sql'
go

print convert(varchar, getdate(), 20) + ' : start Tables\UserGroupReportList.sql'
go

-- ============================================================
-- File: Tables\UserGroupReportList.sql
-- ============================================================
if object_id('dbo.UserGroupReportList', 'U') is null
begin
  create table dbo.UserGroupReportList
  (
    idUserGroup int not null,
    idReport int not null,

    ReportStatusDeny bit not null default 0,
  )
end
go

if columnproperty(object_id('UserGroupReportList'), 'ReportStatusGrant', 'IsComputed') is null
begin
  alter table UserGroupReportList add 
   ReportStatusGrant bit not null default 0
end
go


go
print convert(varchar, getdate(), 20) + ' : finish Tables\UserGroupReportList.sql'
go

print convert(varchar, getdate(), 20) + ' : start Tables\UserGroupRestrictColumn.sql'
go

-- ============================================================
-- File: Tables\UserGroupRestrictColumn.sql
-- ============================================================
if object_id('dbo.UserGroupRestrictColumn', 'U') is null
begin
  create table dbo.UserGroupRestrictColumn
  (
    idUserGroup int not null,
    idColumn int not null,

    bVisible bit null,
    bEdit bit null,
    bEdit_ToManufakt bit null,
    CaptionUser varchar(255) null,
    Num int null,
    nFormatCell int null,
  )
end
go

go
print convert(varchar, getdate(), 20) + ' : finish Tables\UserGroupRestrictColumn.sql'
go

print convert(varchar, getdate(), 20) + ' : start Tables\UserGroups.sql'
go

-- ============================================================
-- File: Tables\UserGroups.sql
-- ============================================================
if object_id('dbo.UserGroups', 'U') is null
begin
   create table UserGroups
   (
       ID int identity(1,1) primary key,
       Name varchar(128) not null,
       Commentary varchar(512) null
   )
end
go

go
print convert(varchar, getdate(), 20) + ' : finish Tables\UserGroups.sql'
go

print convert(varchar, getdate(), 20) + ' : start Tables\WorkplaceProduction.sql'
go

-- ============================================================
-- File: Tables\WorkplaceProduction.sql
-- ============================================================
if object_id('dbo.ProductionWorkSession', 'U') is null
begin
  create table dbo.ProductionWorkSession
  (
    ID int identity(1,1) primary key,
    DateWork datetime not null,
    idSectorManufact int not null,
    idOperatorGroup int null,
    idBrigadier int null,
    idOperator int null,
    IsSinglePerson bit not null constraint DF_ProductionWorkSession_IsSinglePerson default(0),
    IsActive bit not null constraint DF_ProductionWorkSession_IsActive default(1),
    CreatedAt datetime not null constraint DF_ProductionWorkSession_CreatedAt default(getdate()),
    HostName varchar(128) null
  )
end
go

if not exists (select 1 from sys.indexes where object_id = object_id('dbo.ProductionWorkSession') and name = 'IX_ProductionWorkSession_Date_Sector_Active')
  create index IX_ProductionWorkSession_Date_Sector_Active
    on dbo.ProductionWorkSession(DateWork, idSectorManufact, IsActive)
go


go
print convert(varchar, getdate(), 20) + ' : finish Tables\WorkplaceProduction.sql'
go

/* ============================================================
   Update
   ============================================================ */


print convert(varchar, getdate(), 20) + ' : start Update\u_Project.sql'
go

-- ============================================================
-- File: Update\u_Project.sql
-- ============================================================
if columnproperty(object_id('Project'), 'bSkipRebate', 'IsComputed') is null
begin
  alter table Project add bSkipRebate bit default 0
end
go

go
print convert(varchar, getdate(), 20) + ' : finish Update\u_Project.sql'
go

print convert(varchar, getdate(), 20) + ' : start Update\u_Users.sql'
go

-- ============================================================
-- File: Update\u_Users.sql
-- ============================================================
if columnproperty(object_id('Users'), 'idUserGroup', 'IsComputed') is null
begin
  alter table Users add idUserGroup int null
end
go

if columnproperty(object_id('Users'), 'bUseGroupPermission', 'IsComputed') is null
begin
  alter table Users add bUseGroupPermission bit not null default 0
end
go

go
print convert(varchar, getdate(), 20) + ' : finish Update\u_Users.sql'
go

/* ============================================================
   View
   ============================================================ */


print convert(varchar, getdate(), 20) + ' : start View\v_Invoice_MXG.sql'
go

-- ============================================================
-- File: View\v_Invoice_MXG.sql
-- ============================================================
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

go
print convert(varchar, getdate(), 20) + ' : finish View\v_Invoice_MXG.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_Invoice_Reject_IZO.sql'
go

-- ============================================================
-- File: View\v_Invoice_Reject_IZO.sql
-- ============================================================
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
  CostPrice.SumNoNDS as SumNoNDS_Reject,
  CostPrice.SumWithNDS as PriceWithNDS_Reject,
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
  
  outer apply
  (
    select
      cast(
        round(
          round(sum(IsNull(WM.MaterUse, 0)), 4) *
          IsNull(max(RegPrice.PriceNDSUnit), 0),
          6
        )
        as decimal(18, 4)
      ) as SumWithNDS,
      
      cast(
        round(
          round(sum(IsNull(WM.MaterUse, 0)), 4) *
          IsNull(max(RegPrice.PriceUnit), 0),
          6
        )
        as decimal(18, 4)
      ) as SumNoNDS
    from Project PR_Calc
      join Task T_Calc on T_Calc.ID = PR_Calc.idTask
      join WriteMater WM on PR_Calc.ID = WM.idProject
      join Material M on M.ID = WM.idMaterial
      join DepName DN on DN.idDepotSubDivision = T_Calc.idDepotSubDivision
                     and DN.nType = 0
      join DepNameList DNL on DN.ID = DNL.idDepName
      join DepList DL on DL.ID = DNL.idDepList
                      and DL.is2 = 1
      outer apply
      (
        select top 1
          DR.PriceUnit,
          DR.PriceNDSUnit,
          DR.Rest
        from DepReg DR
        where DR.idMaterial = M.ID
          and DR.idDepList = DL.ID
          and DR.DocDate <= T.Date
        order by DR.DocDate desc, DR.ID desc
      ) as RegPrice
    where PR_Calc.ID = P.ID
  ) as CostPrice -- себестоимость  
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
  CostPrice.SumWithNDS,
  CostPrice.SumNoNDS,
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
  CostPrice.SumNoNDS as SumNoNDS_Reject,
  CostPrice.SumWithNDS as PriceWithNDS_Reject,
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
  outer apply
  (
    select
      cast(
        round(
          round(sum(IsNull(WM.MaterUse, 0)), 4) *
          IsNull(max(RegPrice.PriceNDSUnit), 0),
          5
        )
        as decimal(18, 4)
      ) as SumWithNDS,
      
      cast(
        round(
          round(sum(IsNull(WM.MaterUse, 0)), 4) *
          IsNull(max(RegPrice.PriceUnit), 0),
          5
        )
        as decimal(18, 4)
      ) as SumNoNDS
    from Project PR_Calc
      join Task T_Calc on T_Calc.ID = PR_Calc.idTask
      join WriteMater WM on PR_Calc.ID = WM.idProject
      join Material M on M.ID = WM.idMaterial
      join DepName DN on DN.idDepotSubDivision = T_Calc.idDepotSubDivision
                     and DN.nType = 0
      join DepNameList DNL on DN.ID = DNL.idDepName
      join DepList DL on DL.ID = DNL.idDepList
                      and DL.is2 = 1
      outer apply
      (
        select top 1
          DR.PriceUnit,
          DR.PriceNDSUnit,
          DR.Rest
        from DepReg DR
        where DR.idMaterial = M.ID
          and DR.idDepList = DL.ID
          and DR.DocDate <= T.Date
        order by DR.DocDate desc, DR.ID desc
      ) as RegPrice
    where PR_Calc.ID = P.ID
  ) as CostPrice  
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
  P_R.ID,
  CostPrice.SumWithNDS,
  CostPrice.SumNoNDS,
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
print convert(varchar, getdate(), 20) + ' : finish View\v_Invoice_Reject_IZO.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_InvoiceUKD.sql'
go

-- ============================================================
-- File: View\v_InvoiceUKD.sql
-- ============================================================
if OBJECT_ID('v_InvoiceUKD', 'V') is not NULL
  drop view dbo.v_InvoiceUKD
go
-- [AO] Вьюха для распечатки корректировочной счет-фактуры и кредит-ноты
create view dbo.v_InvoiceUKD
as
select
  -- Клиент
  IsNull(C.Name,                     '') as ClientName,
  IsNull(C.NameFull, IsNull(C.Name, '')) as ClientNameFull,
  IsNull(C.Adress,                   '') as ClientAdress,
  IsNull(C.Tel,                      '') as ClientTel,
  IsNull(C.OKPO,                     '') as ClientOKPO,
  IsNull(C.UNN,                      '') as ClientUNN,
  IsNull(C.KPP,                      '') as ClientKPP,
  IsNull(CB_C.KS,                    '') as ClientKS,
  IsNull(BK_C.BIC,                   '') as ClientBIC,
  IsNull(C.OKOHX,                    '') as ClientOKOHX,
  IsNull(CB_C.RS,                    '') as ClientRS,
  IsNull(BK_C.Name,                  '') as ClientBank, 
  IsNull(DA.Name, T.AddressDelivery    ) as AddressDelivery,  

  -- Продавец
  IsNull(S.Name,                     '') as SellerName,
  IsNull(S.NameFull,                 '') as SellerNameFull,
  IsNull(S.AlternativeName,          '') as SellerAlternativeName,
  IsNull(S.UNN,                      '') as SellerUNN,
  IsNull(S.City,                     '') as SellerCity,
  IsNull(S.Adress,                   '') as SellerAdress,
  IsNull(CB_S.RS,                    '') as SellerRS,
  IsNull(BK_S.Name,                  '') as SellerBank,
  IsNull(S.Tel,                      '') as SellerTel,
  IsNull(S.Fax,                      '') as SellerFax,
  IsNull(S.eMail,                    '') as SellerEMail,
  IsNull(S.Site,                     '') as SellerSite,
  IsNull(S.OKOHX,                    '') as SellerOKOHX,
  IsNull(S.OKPO,                     '') as SellerOKPO,
  IsNull(S.OGRN,                     '') as SellerOGRN,
  IsNull(CB_S.KS,                    '') as SellerKS,
  IsNull(BK_S.BIC,                   '') as SellerBIC,
  IsNull(S.KPP,                      '') as SellerKPP,
  IsNull(S.CertificateNDS,           '') as SellerCertificateNDS,

  case when IsNull(DSD.bSignatureFromUser, 0) = 1
       then IsNull(U.ManagerName, '')
       else IsNull(S.ChiefName, '')
       end as SellerChiefName,
  case when IsNull(DSD.bSignatureFromUser, 0) = 1
       then IsNull(U.ManagerName, '')
       else IsNull(S.AccountantName, '')
       end as SellerAccountantName,

  T.ID                   as idTask,
  IsNull(T.bWarranty, 0) as bWarranty,
  T_OLD.ID               as idTaskOld,
  IsNull(T.NumCalcFact, T_OLD.NumCalcFact + '-К') as NumCalcFact,
  IsNull(T_OLD.NumCalcFact, '') as NumCalcFactOld,
  IsNull(T.AccountNum,      '') as AccountNum,
  IsNull(T_OLD.AccountNum,  '') as AccountNumOld,
  IsNull(T.Date,            '') as TaskDate,
  IsNull(T_OLD.Date,        '') as TaskDateOld,
  IsNull(T.ForAccountNum, ''       ) as ForAccountNum,
  IsNull(T_OLD.ForAccountNum, ''   ) as ForAccountNum_OLD,
 
  dbo.f_GetDateComplite_Correct(T.DateComplite, T.Date, IsNull(CF.d_iNum, 0))    as DateComplete,
  dbo.f_GetDateComplite_Correct(T_OLD.DateComplite, T_OLD.Date, IsNull(CF.d_iNum, 0)) as DateCompleteOld,
  
  P.Num as PrjNum,
  P.PriceS,    -- цена за шпросы
  case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNDS/P.Area   else P.PriceNDS   end as PriceM2WithNDS,
  case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNoNDS/P.Area else P.PriceNoNDS end as PriceOfUnit,
  P.SumWithNDS      as PriceWithNDS,
  P.SumNDS          as NDS,
  P.SumNoNDS,
  P.PriceByMNoNDS,
  P.PriceNoNDS_M2,
  case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNDS/P.Area   else P.PriceNDS   end as PriceNDS,
  P.Mass * P.nCount as Mass,
  P.nCount          as nCount,
  P.Area,
  P.nCount * P.Area as nCountArea,

  P_OLD.Num as PrjNum_OLD,
  P_OLD.PriceS              as PriceS_Old,    -- цена за шпросы
  case when IsNull(P_OLD.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P_OLD.Area, 0) > 0 then P_OLD.PriceNDS/P_OLD.Area   else P_OLD.PriceNDS   end as PriceM2WithNDS_Old,
  case when IsNull(P_OLD.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P_OLD.Area, 0) > 0 then P_OLD.PriceNoNDS/P_OLD.Area else P_OLD.PriceNoNDS end as PriceOfUnit_Old,
  P_OLD.SumWithNDS          as PriceWithNDS_Old,
  P_OLD.SumNDS              as NDS_Old,
  P_OLD.SumNoNDS            as SumNoNDS_Old,
  P_OLD.PriceByMNoNDS       as PriceByMNoNDS_Old,
  P_OLD.PriceNoNDS_M2       as PriceNoNDS_M2_Old,
  case when IsNull(P_OLD.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P_OLD.Area, 0) > 0 then P_OLD.PriceNDS/P_OLD.Area   else P_OLD.PriceNDS   end as PriceNDS_Old,
  P_OLD.Mass * P_OLD.nCount as Mass_Old,
  P_OLD.nCount              as nCount_Old,
  P_OLD.Area                as Area_Old,
  P_OLD.nCount * P_OLD.Area as nCountArea_Old,

  dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name, P.GPName, P.CamCount, P.Thickness, P.Width, P.Height, IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), P.ID, P.Num, 0) as GPName,
  dbo.f_RUS_To_Eng(P.GPName) as GPNameEng,

  case when isNull(Nds.Name,'') = '' then cast(NDS.NDS as varchar(2)) else Nds.Name end as Tax_rate,
  NDS.Name as NameNDS,
  IsNull(T.CreditNoteNum, '') as CreditNoteNum,
  IsNull(T.CreditNoteDate, 0) as CreditNoteDate,
  IsNull(T.CreditNoteDescription, '') as CreditNoteDescription,
  IsNull(T.KSF_NumCalcFact, '') as KSF_NumCalcFact,
  case when P_OLD.CamCount = 0 then 'Стекло ' else 'Стеклопакет ' end +
  case when P_OLD.CamCount > 0 then ''        else ''             end +
    P_OLD.GPName + ' ' + ltrim(str(P_OLD.Width)) + ' x ' +  ltrim(str(P_OLD.Height)) +
  case when P_OLD.bShpros <> 0 then ' ' + dbo.f_GetGPRasInfo(P_OLD.ID, P_OLD.bShpros) + 
                                ' ' + ltrim(str((select sum(LengReal) from RasShrink where idProject = P_OLD.ID))) + 'мм' 
  else '' 
  end
    + ', ' + ltrim(str(P_OLD.nCount)) + ' шт.' as GPNameStr
from Task T
  inner join Project P       on P.idTask    = T.ID
  inner join Product PD      on PD.ID       = P.idProd
  left  join BarCode B       on B.idProject = P.ID
  inner join Task T_OLD      on T_OLD.ID    = T.idTask_Parent
  inner join Project P_OLD   on T_OLD.ID    = P_OLD.idTask and P_OLD.Num = P.Num
  left  join BarCode B_OLD   on P_OLD.ID    = B_OLD.idProject
  left  join Config CF       on CF.Name     = 'FormatTypeOfGPName'
  left  join Config CPU      on CPU.Name    = 'bPriceUnitInCalcFact'
  left  join Config CGC      on CGC.Name    = 'nGlassMarkCovering'   -- тип маркировки покрытия
  left  join NDS             on NDS.ID      = T_OLD.idNDS
  left  join Client C        on C.ID        = T.idClient
  left  join Client S        on S.ID        = T.idSeller
  left  join ClientBank CB_C on CB_C.ID     = T.idClientBank_Client
  left  join Bank BK_C       on BK_C.ID     = CB_C.idBank          
  left  join ClientBank CB_S on CB_S.ID     = T.idClientBank_Seller
  left  join Bank BK_S       on BK_S.ID     = CB_S.idBank          
  left  join DeliveryAddress DA   on DA.ID  = T.idDeliveryAddress
  left  join DepotSubDivision DSD on DSD.ID = T.idDepotSubDivision
  left  join Users U              on lower(U.Name) = lower(SYSTEM_USER)  
where 
  T.idTask_Parent           is not null
group by
  C.Name,
  P.bShpros,
  C.NameFull,
  C.Adress,
  C.Tel,
  C.OKPO,
  C.UNN,
  C.KPP,
  CB_C.KS,
  BK_C.BIC,
  C.OKOHX,
  CB_C.RS,
  BK_C.Name,
  DA.Name,
  T.AddressDelivery,

  S.Name,
  S.NameFull,
  S.AlternativeName,
  S.UNN,
  S.City,
  S.Adress,
  CB_S.RS,
  BK_S.Name,
  S.Tel,
  S.Fax,
  S.eMail,
  S.Site,
  S.OKOHX,
  S.OKPO,
  S.OGRN,
  CB_S.KS,
  BK_S.BIC,
  S.KPP,
  S.CertificateNDS,
  DSD.bSignatureFromUser,
  U.ManagerName,
  S.ChiefName,
  S.AccountantName,

  T.ID,
  T.bWarranty,
  T.NumCalcFact,
  T.AccountNum,
  T.ForAccountNum, 
  T.Date,
  T.DateComplite,

  T_OLD.ID,
  T_OLD.NumCalcFact,
  T_OLD.AccountNum,
  T_OLD.ForAccountNum, 
  T_OLD.Date,
  T_OLD.DateComplite,

  CF.d_iNum,

  P.Num,
  P.PriceS,
  P.IsPriceByCount,
  CPU.d_iNum,
  P.Area,
  P.PriceNDS,
  P.PriceNoNDS,
  P.SumWithNDS,
  P.SumNDS,
  P.SumNoNDS,
  P.PriceByMNoNDS,
  P.PriceNoNDS_M2,
  P.Mass,
  P.nCount,
  P.Width,
  P.Height,
  P.Thickness,
  P.GPName,
  P.CamCount,
  P.ComplexText,
  P.CommentClient,
  P.ID,

  P_OLD.ID,
  P_OLD.Num,
  P_OLD.PriceS,
  P_OLD.IsPriceByCount,
  P_OLD.Area,
  P_OLD.PriceNDS,
  P_OLD.PriceNoNDS,
  P_OLD.SumWithNDS,
  P_OLD.SumNDS,
  P_OLD.SumNoNDS,
  P_OLD.PriceByMNoNDS,
  P_OLD.PriceNoNDS_M2,
  P_OLD.Mass,
  P_OLD.nCount,
  P_OLD.CamCount,
  P_OLD.GPName,
  P_OLD.Width,
  P_OLD.Height,
  P_OLD.bShpros,

  PD.Name,
  Nds.Name,
  NDS.NDS,
  T.CreditNoteNum,
  T.CreditNoteDate,
  T.CreditNoteDescription,
  T.KSF_NumCalcFact
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_InvoiceUKD.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_ManagerReport.sql'
go

-- ============================================================
-- File: View\v_ManagerReport.sql
-- ============================================================
if OBJECT_ID('v_ManagerReport', 'V') is not NULL
  drop view dbo.v_ManagerReport
go

--[RP] вью для отчета по менеджерам, упущенным возможностям и др.  
create view v_ManagerReport  
as  
  
with TaskDepTrans as (  
  select  
    idTask,  
    Sum(Price_NDSSum) as SumDepTransAggregated  
  from  
    DepTrans  
  where  
    idDepDocType = 2 AND is2 = 1  
  group by  
    idTask  
)  
  
select  
  DSD.Name                        as DepotName,  
  DSD.ID                          as idDepotSubDivision,  
  U.ID                            as ManagerID,  
  U.ManagerName,  
  C.ID                            as ClientID,  
  C.Name                          as ClientName,  
  C.City                          as ClientCity,  
  CamC.SPSum,  
  Sum(P.nCount)                   as SumPos,  
  Sum(P.Area * P.nCount)          as SumArea,  
  Sum(P.SumWithNDS)               as SumPrice,  
  T.ID                            as idTask,  
  T.Date,  
  T.DateComplite,  
  T.Num,  
  FORMAT(T.Date, 'MMMM', 'ru-RU') as Month,  
  Month(T.Date)                   as MonthNum,  
  Year(T.Date)                    as Year,  
  case   
    when (T.nState & 4) = 0 then 1   
    else 0   
  end                             as bNotSaw,  
  TDT.SumDepTransAggregated       as SumDepTrans,  
  T.nState,  
  case  
    when T.AccountNum like 'П%' or T.AccountNum like 'В%'or T.AccountNum like 'Р%' then 1   
    else 0  
  end as bRemake  
from Task T  
  inner join Project            P on P.idTask   = T.ID  
  left  join Client             C on C.ID       = T.idClient  
  left  join Users              U on U.ID       = C.idUsers_Primarymanager  
  left  join DepotSubDivision DSD on DSD.ID     = T.idDepotSubDivision  
  left  join TaskDepTrans     TDT on TDT.idTask = T.ID   
  left  join (select  
                P_Cam.idTask,  
                Sum(P_Cam.nCount) as SPSum  
              from  
                Project as P_Cam  
              where  
                P_Cam.CamCount != 0  
              group by  
                P_Cam.idTask)CamC on CamC.idTask = T.ID  
group by  
  DSD.Name,  
  DSD.ID,  
  U.ID,  
  U.ManagerName,  
  C.ID,  
  C.Name,  
  C.City,  
  T.ID,  
  T.Date,  
  T.DateComplite,  
  CamC.SPSum,  
  T.Num,  
  T.nState,  
  T.AccountNum,  
  TDT.SumDepTransAggregated  
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_ManagerReport.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_OperatorBrigadierMap.sql'
go

-- ============================================================
-- File: View\v_OperatorBrigadierMap.sql
-- ============================================================
if object_id(N'dbo.v_OperatorBrigadierMap', N'V') is not null
  drop view dbo.v_OperatorBrigadierMap
go

create view dbo.v_OperatorBrigadierMap
as

-- Сам бригадир
select
  OG.idOperatorBrigadier as idOperator,
  OG.idOperatorBrigadier,
  OG.ID as idOperatorGroup,
  OG.idSectorManufact,
  cast(1 as bit) as bBrigadier
from OperatorGroup OG

union all

-- Подчинённые
select
  OGI.idOperator,
  OG.idOperatorBrigadier,
  OG.ID as idOperatorGroup,
  OG.idSectorManufact,
  cast(0 as bit) as bBrigadier
from OperatorGroupItem OGI
inner join OperatorGroup OG on OG.ID = OGI.idOperatorGroup
where OGI.idOperator <> OG.idOperatorBrigadier
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_OperatorBrigadierMap.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_Report_GlassWasteBySawTask.sql'
go

-- ============================================================
-- File: View\v_Report_GlassWasteBySawTask.sql
-- ============================================================
/*
    Базовая VIEW для отчёта:
    "Средний процент отхода по видам стекла за период
     в разрезе подразделений".

    Одна строка VIEW = один SawTaskMain + один вид стекла.

    ВАЖНО:
    Процент сначала считается по суммарным площадям всех основных
    раскроев данного вида стекла внутри одного SawTaskMain.
    Только после этого отчёт берёт AVG за период.

    Это защищает расчёт от размножения строк через
    GlassDetails -> GlassProcessing.
*/

if object_id(N'dbo.v_Report_GlassWasteBySawTask', 'V') is not null
    drop view dbo.v_Report_GlassWasteBySawTask;
go

create view dbo.v_Report_GlassWasteBySawTask
as
with GlassArea as
(
    select
        GD.idCutting,
        sum(GD.Width * GD.Height) as SumAreaDetail
    from GlassDetails GD
    where GD.idCutting is not null
    group by
      GD.idCutting
),
BilletRestArea as
(
    -- Суммарная площадь сохранённых остатков по раскрою
    select
      BR.idCutting_Source,
      sum(BR.Width * BR.Height) as SumAreaRest
    from BilletRest BR
    where BR.idCutting_Source is not null
    group by
      BR.idCutting_Source
),
CuttingBase as
(
    -- Одна строка на один основной раскрой
    select
      C.ID as idCutting,
      C.idSawTaskMain,
      C.idGlass,

     isnull(C.SheetSquare_NoMargin, 0) as SheetSquare_NoMargin,
     isnull(C.SheetSquare, 0) as SheetSquare,
     isnull(BR.SumAreaRest, 0) as SumAreaRest,

     case when isnull(C.SquareUsed, 0) > 0
       then C.SquareUsed
       else isnull(GD.SumAreaDetail, 0)
     end
     as UsedArea

    from Cutting C
        left join GlassArea GD on GD.idCutting = C.ID
        left join BilletRestArea BR on BR.idCutting_Source = C.ID
    where C.bMain = 1
),
SawTaskGlass as
(
    /*
        Собираем все основные раскрои одного вида стекла
        внутри одного SawTaskMain.
    */
    select
      CB.idSawTaskMain,
      CB.idGlass,

      count_big(*) as CuttingCount,

      sum(CB.SheetSquare_NoMargin) as SheetSquare_NoMargin,
      sum(CB.SumAreaRest)          as SumAreaRest,
      sum(CB.UsedArea)             as UsedArea,

      sum
      (
        CB.SheetSquare_NoMargin -
        CB.SumAreaRest
      ) as SheetArea

    from CuttingBase CB
    group by
        CB.idSawTaskMain,
        CB.idGlass
)
select
  STM.ID                       as idSawTaskMain,
  STM.Data                     as SawTaskDate,

  STM.idDepotSubDivision,
  DSD.Name                     as DepotSubDivisionName,
  P.ID                         as idProduct,
  P.Name                       as ProductName,
  P.Type                       as ProductType,

  S.CuttingCount,
  S.SheetSquare_NoMargin,
  S.SumAreaRest,
  S.UsedArea,
  S.SheetArea,

  -- Аналог WastePct из v_SawTask_Statistics:
  -- 1 - использованная площадь / (площадь листов без кромки - сохранённые остатки)
  case
    when isnull(S.SheetSquare_NoMargin, 0) <= 0
      then 0

    when isnull(S.SumAreaRest, 0) >= isnull(S.SheetSquare_NoMargin, 0)
      then 0

    when isnull(S.SheetArea, 0) <= 0
      then 0

    when isnull(S.UsedArea, 0) > isnull(S.SheetArea, 0)
      then 0

    else round
    (
      ( 1 - (S.UsedArea / nullif(S.SheetArea, 0) ) ) * 100.0,
      2
    )
  end as WastePct,

  /*
      Аналог WastePctReal из v_SawTask_Statistics.
      Оставлен для проверки и возможного второго показателя.
  */
  case
    when isnull(S.SheetSquare_NoMargin, 0) <= 0
      then 0

    when isnull(S.SumAreaRest, 0) >= isnull(S.SheetSquare_NoMargin, 0)
      then 0

    when isnull(S.UsedArea, 0) > isnull(S.SheetArea, 0)
      then 0

    else round
    (
      ( S.SheetSquare_NoMargin - (S.SumAreaRest + S.UsedArea) ) * 100.0 / nullif(S.SheetSquare_NoMargin, 0),
      2
    )
  end as WastePctReal

from SawTaskGlass S
    inner join SawTaskMain STM on STM.ID = S.idSawTaskMain
    inner join Product P on P.ID = S.idGlass
                     and P.Type in (5, 105)
    left join DepotSubDivision DSD on DSD.ID = STM.idDepotSubDivision;
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_Report_GlassWasteBySawTask.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_SawItemSelect_Task.sql'
go

-- ============================================================
-- File: View\v_SawItemSelect_Task.sql
-- ============================================================
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
  case when BSum.CamCount = 0 then '' else 'СП ' end + IsNull(T.ListGlass,     '') + ' ' + IsNull(T.ComplexText,     '') as ComplexTextShow,    
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
  IsNull(BSum.CamCount, 0) as CamCount,
  convert(varchar(2), IsNull(BSum.CamCount, 0)) as CamCountStr,
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
  case when lower(IsNull(T.Commentary, '')) like '%брак%'    
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
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_SawItemSelect_Task.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_SawTask_Statistics.sql'
go

-- ============================================================
-- File: View\v_SawTask_Statistics.sql
-- ============================================================
if object_id('v_SawTask_Statistics', 'V') is not null
    drop view v_SawTask_Statistics
go 

create view v_SawTask_Statistics as  
with cte as
(
    select
        STM.ID as idSawTaskMain,
        STM.Data,
        STM.Name as SawTaskMainName,
        STM.SawedOnlyGP_nCount,
        STM.idAssemblyLine,

        T.ID as idTask,
        T.AccountNum,
        T.DateComplite,

        C.ID as idClient,
        C.Name as ClientName,

        SM.ID as idSectorManufact,
        SM.nType as SectorType,
        SM.Name as SectorName,

        case
            when SM.nType = 1
            then GD.Width * GD.Height / 1000000.0
            else 0
        end as AreaTable,

        case
            when SM.nType = 1
            then 1
            else 0
        end as CountTable,

        case
            when SM.nType in (6, 8, 13)
            then GD.Width * GD.Height / 1000000.0
            else 0
        end as AreaVertmax,

        case
            when SM.nType in (6, 8, 13)
            then 1
            else 0
        end as CountVertmax,

        case
            when SM.nType = 4
            then GD.Width * GD.Height / 1000000.0
            else 0
        end as AreaTriplex,

        case
            when SM.nType = 3
            then GD.Width * GD.Height / 1000000.0
            else 0
        end as AreaFurnace,


        case
            when exists
            (
                select 1
                from GlassDetails GD2
                    inner join GlassProcessing GP2
                        on GP2.idGlassDetails = GD2.ID
                    inner join SectorManufact SM2
                        on SM2.ID = GP2.idSectorManufact
                where GD2.ID = GD.ID
                  and SM2.nType = 3
            )
            then 1
            else 0
        end as IsHardering,

        P.CamCount,
        P.ID as idProject,
        P.nCount,
        P.bShpros,

        B.ID as idBarCode,

        PROD.Name as ProductName,
        PROD.ID   as idProduct,

        GD.ID as idGlassDetails,

        AL.Name as AssemblyLineName,
        AL.Num as AssemblyLineNum,

        TC.Name as TeamCutName,

        case
            when SM.nType = 3
            then TH.Name 
            else ''
        end as TeamHarderingName
        

    from SawTaskMain STM
        inner join GlassDetails GD
            on GD.idSawTaskMain = STM.ID

        inner join GlassProcessing GP
            on GP.idGlassDetails = GD.ID

        inner join SectorManufact SM
            on GP.idSectorManufact = SM.ID

        inner join Barcode B
            on GD.idBarCode = B.ID

        inner join Project P
            on B.idProject = P.ID

        inner join Task T
            on P.idTask = T.ID

        inner join Product PROD
            on GD.idGlass = PROD.ID

        left join Client C
            on T.idClient = C.ID

        left join AssemblyLine AL
            on STM.idAssemblyLine = AL.ID

        left join Team TC
            on STM.idTeam_Cutter = TC.ID

        left join SheduleOperator SO
            on GP.idSheduleOperator = SO.ID

        left join Operator O
            on SO.idOperator = O.ID

        left join Team TH
            on TH.idOperator = O.ID
),
WasteStat as
(
    select
    idGlass,
    idSawTaskMain,

    case
        when SheetArea = 0 then 0
        else round((1 - UsedArea / SheetArea) * 100.0, 2)
    end as WastePct,

    round(
        ((SheetSquare_NoMargin - (IsNull(SumAreaRest, 0) + UsedArea)) * 100.0)
        / SheetSquare_NoMargin,
        2
    ) as WastePctReal

    from
    (
        select
            C.ID,
            C.idGlass,
            C.idSawTaskMain,

            C.SheetSquare_NoMargin,

            BR.SumAreaRest,

            -- ПЛОЩАДЬ С ОТСТУПОМ
            C.SheetSquare_NoMargin - isnull(BR.SumAreaRest, 0) as SheetArea,
            -- ИСПОЛЬЗОВАННАЯ ПЛОЩАДЬ
            case
                when isnull(C.SquareUsed, 0) > 0
                    then C.SquareUsed
                else isnull(GD.SumAreaDetail, 0)
            end as UsedArea

        from Cutting C
        left join
        (
            select
                idCutting,
                isnull(idDecor, 0) as idDecor,
                sum(Width * Height) as SumAreaDetail
            from GlassDetails
            group by idCutting, isnull(idDecor, 0)
        ) GD on GD.idCutting = C.ID

        left join
        (
            select
                idCutting_Source,
                sum(Width * Height) as SumAreaRest
            from BilletRest
            group by idCutting_Source
        ) BR on BR.idCutting_Source = C.ID

        where C.bMain = 1
    ) Waste
)
select
    WS.WastePct,
    WS.WastePctReal,
    C.*
from cte C
left join WasteStat WS
    on WS.idSawTaskMain = C.idSawTaskMain and
       WS.idGlass = C.idProduct


go
print convert(varchar, getdate(), 20) + ' : finish View\v_SawTask_Statistics.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_SawTaskUE_Period_Detail_Assembly_IZO.sql'
go

-- ============================================================
-- File: View\v_SawTaskUE_Period_Detail_Assembly_IZO.sql
-- ============================================================
if object_id(N'dbo.v_SawTaskUE_Period_Detail_Assembly_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Detail_Assembly_IZO
go

create view dbo.v_SawTaskUE_Period_Detail_Assembly_IZO
as

with OperatorMap as
(
  select
    idOperator,
    idSectorManufact,
    min(idOperatorBrigadier) as idOperatorBrigadier
  from dbo.v_OperatorBrigadierMap
  group by idOperator, idSectorManufact
  having count(distinct idOperatorBrigadier) = 1
),

PlanCalendarOne as
(
  select
    max(ID) as ID,
    Data,
    nSmena
  from PlanCalendar
  where nSmena in (1, 2)
  group by Data, nSmena
),

SheduleOperatorOne as
(
  select
    max(ID) as ID,
    idPlanCalendar,
    idOperator,
    idSectorManufact,
    idTeam
  from SheduleOperator
  group by
    idPlanCalendar,
    idOperator,
    idSectorManufact,
    idTeam
),

BrigadierScheduleCandidate as
(
  select
    SO.ID as idSheduleOperator,
    SO.idPlanCalendar,
    SO.idTeam,
    SO.idOperator as idOperatorBrigadier,

    case
      when exists
      (
        select 1
        from ShedulePersonnel SP
        where SP.idSheduleOperator = SO.ID
      ) then 0
      else 1
    end as PersonnelPriority

  from SheduleOperator SO
  where isnull(SO.idTeam, 0) <> 0
    and exists
    (
      select 1
      from OperatorGroup OG
      where OG.idOperatorBrigadier = SO.idOperator
    )
),

BrigadierScheduleRanked as
(
  select
    idSheduleOperator,
    idPlanCalendar,
    idTeam,
    idOperatorBrigadier,

    row_number() over
    (
      partition by idPlanCalendar, idTeam
      order by PersonnelPriority, idSheduleOperator desc
    ) as RowNum

  from BrigadierScheduleCandidate
),

GlassBase as
(
  select
    GD.ID as idGlassDetails,
    GD.idGlass,
    GD.idProject,

    coalesce
    (
      nullif(GD.idSawTaskMain, 0),
      nullif(GP.idSawTaskMain, 0)
    ) as idSawTaskMain,

    GD.Width,
    GD.Height,

    GP.idSectorManufact,
    GP.idSawLimit,
    GP.idSheduleOperator as idSheduleOperatorSource,
    GP.TimeMarkManufact,

    STM.idTeam,
    STM.idAssemblyLine,

    case
      when datepart(hour, GP.TimeMarkManufact) < 8 then
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact) - 1, 0)
      else
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact), 0)
    end as DateComplete,

    case
      when datepart(hour, GP.TimeMarkManufact) >= 8
       and datepart(hour, GP.TimeMarkManufact) < 20 then 1
      else 2
    end as nSmena

  from GlassDetails GD
  inner join GlassProcessing GP on GP.idGlassDetails = GD.ID
  inner join SectorManufact SM on SM.ID = GP.idSectorManufact

  inner join SawTaskMain STM
    on STM.ID = coalesce
    (
      nullif(GD.idSawTaskMain, 0),
      nullif(GP.idSawTaskMain, 0)
    )

  where SM.nType = 2
    and GP.TimeMarkManufact is not null
),

ResolvedBase as
(
  select
    GB.idGlassDetails,
    GB.idGlass,
    GB.idProject,
    GB.idSawTaskMain,
    GB.Width,
    GB.Height,

    GB.idSectorManufact,
    GB.idSawLimit,
    GB.TimeMarkManufact,

    CalendarResolved.idPlanCalendar,
    TeamResolved.idTeam,
    GB.idAssemblyLine,

    GB.DateComplete,
    GB.nSmena,

    ResolvedOperator.idOperatorBrigadier,

    coalesce
    (
      BS.idSheduleOperator,
      ResolvedSOExact.ID,
      ResolvedSONull.ID,

      case
        when SourceValid.bValid = 1
         and SourceSO.idOperator = ResolvedOperator.idOperatorBrigadier then
          SourceSO.ID
      end
    ) as idSheduleOperatorBrigadier,

    case
      when SourceValid.bValid = 1
       and SourceSO.idOperator = ResolvedOperator.idOperatorBrigadier then 1

      when SourceValid.bValid = 1
       and OM.idOperatorBrigadier is not null then 2

      when BS.idOperatorBrigadier is not null then 3

      else 0
    end as BrigadierResolveType

  from GlassBase GB

  left join SheduleOperator SourceSO
    on SourceSO.ID = nullif(GB.idSheduleOperatorSource, 0)

  left join PlanCalendarOne PC
    on PC.Data = GB.DateComplete
   and PC.nSmena = GB.nSmena

  cross apply
  (
    select
      coalesce(PC.ID, SourceSO.idPlanCalendar) as idPlanCalendar
  ) CalendarResolved

  cross apply
  (
    select
      coalesce
      (
        nullif(GB.idTeam, 0),
        nullif(SourceSO.idTeam, 0)
      ) as idTeam
  ) TeamResolved

  cross apply
  (
    select
      case
        when SourceSO.ID is not null
         and nullif(SourceSO.idTeam, 0) = TeamResolved.idTeam then 1
        else 0
      end as bValid
  ) SourceValid

  left join OperatorMap OM
    on OM.idOperator = SourceSO.idOperator
   and OM.idSectorManufact = GB.idSectorManufact
   and SourceValid.bValid = 1

  left join BrigadierScheduleRanked BS
    on BS.idPlanCalendar = CalendarResolved.idPlanCalendar
   and BS.idTeam = TeamResolved.idTeam
   and BS.RowNum = 1

  cross apply
  (
    select
      case
        when SourceValid.bValid = 1
         and OM.idOperatorBrigadier is not null then
          OM.idOperatorBrigadier

        when BS.idOperatorBrigadier is not null then
          BS.idOperatorBrigadier

        when SourceValid.bValid = 1
         and exists
         (
           select 1
           from OperatorGroup OG
           where OG.idOperatorBrigadier = SourceSO.idOperator
         ) then
          SourceSO.idOperator

        else null
      end as idOperatorBrigadier
  ) ResolvedOperator

  left join SheduleOperatorOne ResolvedSOExact
    on ResolvedSOExact.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSOExact.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSOExact.idSectorManufact = GB.idSectorManufact
   and ResolvedSOExact.idTeam = TeamResolved.idTeam

  left join SheduleOperatorOne ResolvedSONull
    on ResolvedSONull.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSONull.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSONull.idSectorManufact is null
   and ResolvedSONull.idTeam = TeamResolved.idTeam
)

select
  Task.ID as idTask,
  Task.AccountNum,

  SawTaskMain.ID as idSawTask,
  SawTaskMain.Name as SawTaskName,

  RB.idTeam,
  RB.idAssemblyLine,

  RB.DateComplete,
  RB.nSmena,
  RB.idPlanCalendar,

  Product.ID as idGlass,
  Product.Name as GlassName,

  FinalSO.ID as idSheduleOperatorBrigadier,
  RB.idOperatorBrigadier,
  RB.BrigadierResolveType,

  count(1) as nCountDetails,
  Project.GPName,

  cast
  (
    sum(dbo.f_GetUE_ForAssemblyPlastica(Project.ID))
    as decimal(18, 6)
  ) as SumUE

from ResolvedBase RB
inner join Product on Product.ID = RB.idGlass
inner join SawTaskMain on SawTaskMain.ID = RB.idSawTaskMain
inner join Project on Project.ID = RB.idProject
inner join Task on Task.ID = Project.idTask

left join SheduleOperator FinalSO
  on FinalSO.ID = RB.idSheduleOperatorBrigadier

group by
  Task.ID, Task.AccountNum,
  SawTaskMain.ID, SawTaskMain.Name,

  RB.idTeam,
  RB.idAssemblyLine,

  RB.DateComplete,
  RB.nSmena,
  RB.idPlanCalendar,

  Product.ID,
  Product.Name,

  FinalSO.ID,
  RB.idOperatorBrigadier,
  RB.BrigadierResolveType,

  Project.GPName
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_SawTaskUE_Period_Detail_Assembly_IZO.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_SawTaskUE_Period_Detail_Cut_IZO.sql'
go

-- ============================================================
-- File: View\v_SawTaskUE_Period_Detail_Cut_IZO.sql
-- ============================================================
if object_id(N'dbo.v_SawTaskUE_Period_Detail_Cut_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Detail_Cut_IZO
go

create view dbo.v_SawTaskUE_Period_Detail_Cut_IZO
as

select
  Task.ID as idTask,
  Task.AccountNum,
  SawTaskMain.ID as idSawTask,
  SawTaskMain.Name as SawTaskName,
  CuttingTable.Name as CuttingTableName,

  CalendarResolved.DateComplete,
  CalendarResolved.nSmena,
  CalendarResolved.idPlanCalendar,

  Product.ID as idGlass,
  Product.Name as GlassName,

  BrigadierSO.ID as idSheduleOperatorBrigadier,
  ResolvedBrigadier.idOperatorBrigadier,
  coalesce(BrigadierSO.idTeam, SheduleOperatorSource.idTeam) as idTeam,

  case
    when DirectBrigadier.idOperatorBrigadier = SheduleOperatorSource.idOperator then 1
    when DirectBrigadier.idOperatorBrigadier is not null then 2
    when InferredBrigadier.BrigadierCount = 1 then 3
    else 0
  end as BrigadierResolveType,

  count(1) as nCountDetails,

  cast
  (
    sum(1.0 * GlassDetails.Width * GlassDetails.Height) / 1000000.0
    as decimal(18,6)
  ) as SumArea,

  cast
  (
    sum((GlassDetails.Width * GlassDetails.Height) / 1000000.0)
    as decimal(18,6)
  ) as SumAreaUZM,

  cast
  (
    isnull(UGA.WasteArea, 0) /
    nullif(count(*) over(partition by SawTaskMain.ID, Product.ID), 0)
    as decimal(18,6)
  ) as SumWasteArea,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 0 then 1
    else 0
  end as bTripNoCoat,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 1 then 1
    else 0
  end as bTripCoat

from GlassDetails
inner join Product on Product.ID = GlassDetails.idGlass
inner join GlassProcessing on GlassProcessing.idGlassDetails = GlassDetails.ID
inner join SectorManufact on SectorManufact.ID = GlassProcessing.idSectorManufact
inner join SawTaskMain on SawTaskMain.ID = GlassDetails.idSawTaskMain
inner join Project on Project.ID = GlassDetails.idProject
inner join Task on Task.ID = Project.idTask

left join SheduleOperator SheduleOperatorSource  on SheduleOperatorSource.ID = nullif(GlassProcessing.idSheduleOperator, 0)
left join PlanCalendar PlanCalendarSource        on PlanCalendarSource.ID = SheduleOperatorSource.idPlanCalendar

left join Cutting on Cutting.idSawTaskMain = SawTaskMain.ID
                       and Cutting.idGlass = Product.ID
                         and Cutting.bMain = 1

left join CuttingTable on CuttingTable.ID = Cutting.idCuttingTable

left join
(
  select
    UG.idSawTask,
    UG.idGlass,

    cast
    (
      sum
      (
        case
          when UG.Width < 0 then
            UG.Width * UG.BilletHeight * UG.nCount -
            (UG.Width - P.MarginLeft - P.MarginRight - P.MarginInner) *
            (UG.BilletHeight - P.MarginBottom - P.MarginInner) * UG.nCount
          else
            UG.BilletWidth * UG.BilletHeight * UG.nCount -
            (UG.BilletWidth - P.MarginLeft) *
            (UG.BilletHeight - P.MarginBottom - P.MarginInner) * UG.nCount
        end
      ) / 1000000.0
      as decimal(18, 6)
    ) as WasteArea

  from UsedGlass UG
  inner join Product P on P.ID = UG.idGlass
  group by UG.idSawTask, UG.idGlass
) UGA
  on UGA.idSawTask = SawTaskMain.ID
 and UGA.idGlass = Product.ID

/*
  Определяем производственную дату и смену по TimeMarkManufact.

  1 смена: 08:00–20:00.
  2 смена: 20:00–08:00 следующего дня.
*/
cross apply
(
  select
    case
      when datepart(hour, GlassProcessing.TimeMarkManufact) < 8 then
        dateadd(day, datediff(day, 0, GlassProcessing.TimeMarkManufact) - 1, 0)
      else
        dateadd(day, datediff(day, 0, GlassProcessing.TimeMarkManufact), 0)
    end as DateComplete,

    case
      when datepart(hour, GlassProcessing.TimeMarkManufact) >= 8
       and datepart(hour, GlassProcessing.TimeMarkManufact) < 20 then 1
      else 2
    end as nSmena
) ShiftInfo

/*
  По рассчитанным дате и смене находим настоящую строку PlanCalendar.
  TOP 1 не даст размножить детали, если там внезапно есть дубли.
*/
outer apply
(
  select top 1
    PC.ID,
    PC.Data,
    PC.nSmena
  from PlanCalendar PC
  where PC.Data = ShiftInfo.DateComplete
    and PC.nSmena = ShiftInfo.nSmena
  order by PC.ID desc
) PlanCalendarByTime

/*
  Сначала используем PlanCalendar, найденный по TimeMarkManufact.
  Старый PlanCalendar от idSheduleOperator — только запасной вариант.
*/
cross apply
(
  select
    coalesce(PlanCalendarByTime.ID, PlanCalendarSource.ID) as idPlanCalendar,
    coalesce(PlanCalendarByTime.Data, PlanCalendarSource.Data, ShiftInfo.DateComplete) as DateComplete,
    coalesce(PlanCalendarByTime.nSmena, PlanCalendarSource.nSmena, ShiftInfo.nSmena) as nSmena
) CalendarResolved

-- Если в старом SheduleOperator записан подчинённый, получаем его бригадира.
outer apply
(
  select top 1
    OBM.idOperatorBrigadier
  from dbo.v_OperatorBrigadierMap OBM
  where OBM.idOperator = SheduleOperatorSource.idOperator
  order by
    case
      when OBM.idOperator = OBM.idOperatorBrigadier then 0
      else 1
    end,
    OBM.idOperatorGroup
) DirectBrigadier

/*
  Если исходного SheduleOperator нет, ищем бригадира
  среди расписаний этого участка, даты и смены.

  Используем только если найден один уникальный бригадир.
*/
outer apply
(
  select
    count(distinct SO2.idOperator) as BrigadierCount,
    min(SO2.idOperator) as idOperatorBrigadier
  from SheduleOperator SO2
  where SO2.idSectorManufact = GlassProcessing.idSectorManufact
    and
    (
      SO2.idPlanCalendar = CalendarResolved.idPlanCalendar
      or
      (
        CalendarResolved.idPlanCalendar is null
        and GlassProcessing.TimeMarkManufact >= SO2.dtBegin
        and GlassProcessing.TimeMarkManufact < SO2.dtEnd
      )
    )
    and exists
    (
      select 1
      from dbo.v_OperatorBrigadierMap OBM2
      where OBM2.idOperator = SO2.idOperator
        and OBM2.idOperatorBrigadier = SO2.idOperator
    )
) InferredBrigadier

cross apply
(
  select
    coalesce
    (
      DirectBrigadier.idOperatorBrigadier,
      case
        when InferredBrigadier.BrigadierCount = 1 then
          InferredBrigadier.idOperatorBrigadier
        else null
      end
    ) as idOperatorBrigadier
) ResolvedBrigadier

-- Получаем уже конкретную строку SheduleOperator именно бригадира.
outer apply
(
  select top 1
    SO3.ID,
    SO3.idPlanCalendar,
    SO3.idOperator,
    SO3.idTeam
  from SheduleOperator SO3
  where SO3.idOperator = ResolvedBrigadier.idOperatorBrigadier
    and SO3.idSectorManufact = GlassProcessing.idSectorManufact
    and
    (
      SO3.idPlanCalendar = CalendarResolved.idPlanCalendar
      or
      (
        CalendarResolved.idPlanCalendar is null
        and GlassProcessing.TimeMarkManufact >= SO3.dtBegin
        and GlassProcessing.TimeMarkManufact < SO3.dtEnd
      )
    )
  order by
    case
      when SO3.idPlanCalendar = CalendarResolved.idPlanCalendar then 0
      else 1
    end,
    SO3.ID desc
) BrigadierSO

where SectorManufact.nType = 1
  and GlassProcessing.TimeMarkManufact is not null

group by
  Task.ID, Task.AccountNum,
  SawTaskMain.ID, SawTaskMain.Name,
  CuttingTable.Name,
  CalendarResolved.DateComplete, CalendarResolved.nSmena,
  CalendarResolved.idPlanCalendar,
  Product.ID, Product.Name,
  BrigadierSO.ID,
  ResolvedBrigadier.idOperatorBrigadier,
  coalesce(BrigadierSO.idTeam, SheduleOperatorSource.idTeam),

  case
    when DirectBrigadier.idOperatorBrigadier = SheduleOperatorSource.idOperator then 1
    when DirectBrigadier.idOperatorBrigadier is not null then 2
    when InferredBrigadier.BrigadierCount = 1 then 3
    else 0
  end,

  UGA.WasteArea,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 0 then 1
    else 0
  end,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 1 then 1
    else 0
  end
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_SawTaskUE_Period_Detail_Cut_IZO.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_SawTaskUE_Period_Detail_ZAK_IZO.sql'
go

-- ============================================================
-- File: View\v_SawTaskUE_Period_Detail_ZAK_IZO.sql
-- ============================================================
if object_id(N'dbo.v_SawTaskUE_Period_Detail_ZAK_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Detail_ZAK_IZO
go

create view dbo.v_SawTaskUE_Period_Detail_ZAK_IZO
as

with OperatorMap as
(
  select
    idOperator,
    idSectorManufact,
    min(idOperatorBrigadier) as idOperatorBrigadier
  from dbo.v_OperatorBrigadierMap
  group by idOperator, idSectorManufact
  having count(distinct idOperatorBrigadier) = 1
),

PlanCalendarOne as
(
  select
    max(ID) as ID,
    Data,
    nSmena
  from PlanCalendar
  where nSmena in (1, 2)
  group by Data, nSmena
),

SheduleOperatorOne as
(
  select
    max(ID) as ID,
    idPlanCalendar,
    idOperator,
    idSectorManufact
  from SheduleOperator
  group by idPlanCalendar, idOperator, idSectorManufact
),

BrigadierScheduleCandidate as
(
  select distinct
    SO.ID as idSheduleOperator,
    SO.idPlanCalendar,
    SO.idOperator as idOperatorBrigadier,
    OG.idSectorManufact,

    case
      when SO.idSectorManufact = OG.idSectorManufact then 0
      when SO.idSectorManufact is null then 1
      else 2
    end as Priority

  from SheduleOperator SO
  inner join OperatorGroup OG on OG.idOperatorBrigadier = SO.idOperator

  where SO.idSectorManufact = OG.idSectorManufact
     or SO.idSectorManufact is null
),

BrigadierScheduleRanked as
(
  select
    idSheduleOperator,
    idPlanCalendar,
    idOperatorBrigadier,
    idSectorManufact,

    row_number() over
    (
      partition by idPlanCalendar, idSectorManufact
      order by Priority, idSheduleOperator desc
    ) as RowNum

  from BrigadierScheduleCandidate
),

ZakOperation as
(
  select
    idProject,
    nGlass,
    nGlassTriplex,
    idProd
  from ProjectItem
  where isnull(nTypeOper, 0) = 2
    and nType = 8
),

GlassBase as
(
  select
    GD.ID as idGlassDetails,
    GD.idGlass,
    GD.idProject,
    GD.idProjectItem,
    GD.idSawTaskMain,
    GD.Width,
    GD.Height,

    GP.idSectorManufact,
    GP.idSheduleOperator as idSheduleOperatorSource,
    GP.TimeMarkManufact,

    case
      when datepart(hour, GP.TimeMarkManufact) < 8 then
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact) - 1, 0)
      else
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact), 0)
    end as DateComplete,

    case
      when datepart(hour, GP.TimeMarkManufact) >= 8
       and datepart(hour, GP.TimeMarkManufact) < 20 then 1
      else 2
    end as nSmena

  from GlassDetails GD
  inner join GlassProcessing GP on GP.idGlassDetails = GD.ID
  inner join SectorManufact SM on SM.ID = GP.idSectorManufact

  where SM.nType = 3
    and GP.TimeMarkManufact is not null
),

ResolvedBase as
(
  select
    GB.idGlassDetails,
    GB.idGlass,
    GB.idProject,
    GB.idProjectItem,
    GB.idSawTaskMain,
    GB.Width,
    GB.Height,
    GB.idSectorManufact,
    GB.TimeMarkManufact,

    CalendarResolved.idPlanCalendar,
    GB.DateComplete,
    GB.nSmena,

    ResolvedOperator.idOperatorBrigadier,

    coalesce
    (
      ResolvedSOExact.ID,
      ResolvedSONull.ID,

      case
        when SourceSO.idOperator = ResolvedOperator.idOperatorBrigadier then
          SourceSO.ID
      end,

      BS.idSheduleOperator
    ) as idSheduleOperatorBrigadier,

    case
      when OM.idOperatorBrigadier = SourceSO.idOperator then 1
      when OM.idOperatorBrigadier is not null then 2
      when SourceSO.ID is null
       and BS.idOperatorBrigadier is not null then 3
      when SourceSO.ID is not null then 4
      else 0
    end as BrigadierResolveType

  from GlassBase GB

  left join SheduleOperator SourceSO
    on SourceSO.ID = nullif(GB.idSheduleOperatorSource, 0)

  left join PlanCalendarOne PC
    on PC.Data = GB.DateComplete
   and PC.nSmena = GB.nSmena

  cross apply
  (
    select
      coalesce(PC.ID, SourceSO.idPlanCalendar) as idPlanCalendar
  ) CalendarResolved

  left join OperatorMap OM
    on OM.idOperator = SourceSO.idOperator
   and OM.idSectorManufact = GB.idSectorManufact

  left join BrigadierScheduleRanked BS
    on BS.idPlanCalendar = CalendarResolved.idPlanCalendar
   and BS.idSectorManufact = GB.idSectorManufact
   and BS.RowNum = 1

  cross apply
  (
    select
      case
        when OM.idOperatorBrigadier is not null then
          OM.idOperatorBrigadier

        when SourceSO.ID is not null then
          SourceSO.idOperator

        else
          BS.idOperatorBrigadier
      end as idOperatorBrigadier
  ) ResolvedOperator

  left join SheduleOperatorOne ResolvedSOExact
    on ResolvedSOExact.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSOExact.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSOExact.idSectorManufact = GB.idSectorManufact

  left join SheduleOperatorOne ResolvedSONull
    on ResolvedSONull.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSONull.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSONull.idSectorManufact is null
)

select
  Task.ID as idTask,
  Task.AccountNum,

  SawTaskMain.ID as idSawTask,
  SawTaskMain.Name as SawTaskName,

  RB.DateComplete,
  RB.nSmena,
  RB.idPlanCalendar,

  Product.ID as idGlass,
  Product.Name as GlassName,

  FinalSO.ID as idSheduleOperatorBrigadier,
  RB.idOperatorBrigadier,
  FinalSO.idTeam,
  RB.BrigadierResolveType,

  case
    when isnull(GlassWorkAdd.dCoefUZM, 0) = 0 then
      Product.dCoefUZM
    else
      GlassWorkAdd.dCoefUZM
  end as dCoefUZM,

  count(1) as nCountDetails,

  cast
  (
    sum(1.0 * RB.Width * RB.Height) / 1000000.0
    as decimal(18, 6)
  ) as SumArea,

  cast
  (
    sum
    (
      1.0 * RB.Width * RB.Height / 1000000.0 *
      case
        when isnull(GlassWorkAdd.dCoefUZM, 0) = 0 then
          Product.dCoefUZM
        else
          GlassWorkAdd.dCoefUZM
      end
    )
    as decimal(18, 6)
  ) as SumAreaUZM

from ResolvedBase RB
inner join Product on Product.ID = RB.idGlass
inner join SawTaskMain on SawTaskMain.ID = RB.idSawTaskMain
inner join Project on Project.ID = RB.idProject
inner join Task on Task.ID = Project.idTask

inner join ProjectItem
  on ProjectItem.ID = RB.idProjectItem

inner join ZakOperation ZAK
  on ZAK.idProject = ProjectItem.idProject
 and ZAK.nGlass = ProjectItem.nGlass
 and ZAK.nGlassTriplex = ProjectItem.nGlassTriplex

left join GlassWorkAdd
  on GlassWorkAdd.idProduct_Glass = Product.ID
 and GlassWorkAdd.idProduct_Work = ZAK.idProd

left join SheduleOperator FinalSO
  on FinalSO.ID = RB.idSheduleOperatorBrigadier

where isnull(Product.dCoefUZM, 0) > 0

group by
  Task.ID,
  Task.AccountNum,

  SawTaskMain.ID,
  SawTaskMain.Name,

  RB.DateComplete,
  RB.nSmena,
  RB.idPlanCalendar,

  Product.ID,
  Product.Name,
  Product.dCoefUZM,
  GlassWorkAdd.dCoefUZM,

  FinalSO.ID,
  FinalSO.idTeam,
  RB.idOperatorBrigadier,
  RB.BrigadierResolveType
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_SawTaskUE_Period_Detail_ZAK_IZO.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_SawTaskUE_Period_Operator_Assembly_IZO.sql'
go

-- ============================================================
-- File: View\v_SawTaskUE_Period_Operator_Assembly_IZO.sql
-- ============================================================
if object_id(N'dbo.v_SawTaskUE_Period_Operator_Assembly_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Operator_Assembly_IZO
go

create view dbo.v_SawTaskUE_Period_Operator_Assembly_IZO
as

with OperatorMap as
(
  select
    idOperator,
    idSectorManufact,
    min(idOperatorBrigadier) as idOperatorBrigadier
  from dbo.v_OperatorBrigadierMap
  group by idOperator, idSectorManufact
  having count(distinct idOperatorBrigadier) = 1
),

PlanCalendarOne as
(
  select
    max(ID) as ID,
    Data,
    nSmena
  from PlanCalendar
  where nSmena in (1, 2)
  group by Data, nSmena
),

SheduleOperatorOne as
(
  select
    max(ID) as ID,
    idPlanCalendar,
    idOperator,
    idSectorManufact,
    idTeam
  from SheduleOperator
  group by
    idPlanCalendar,
    idOperator,
    idSectorManufact,
    idTeam
),

BrigadierScheduleCandidate as
(
  select
    SO.ID as idSheduleOperator,
    SO.idPlanCalendar,
    SO.idTeam,
    SO.idOperator as idOperatorBrigadier,

    case
      when exists
      (
        select 1
        from ShedulePersonnel SP
        where SP.idSheduleOperator = SO.ID
      ) then 0
      else 1
    end as PersonnelPriority

  from SheduleOperator SO
  where isnull(SO.idTeam, 0) <> 0
    and exists
    (
      select 1
      from OperatorGroup OG
      where OG.idOperatorBrigadier = SO.idOperator
    )
),

BrigadierScheduleRanked as
(
  select
    idSheduleOperator,
    idPlanCalendar,
    idTeam,
    idOperatorBrigadier,

    row_number() over
    (
      partition by idPlanCalendar, idTeam
      order by PersonnelPriority, idSheduleOperator desc
    ) as RowNum

  from BrigadierScheduleCandidate
),

GlassBase as
(
  select
    GD.ID as idGlassDetails,
    GD.idGlass,
    GD.idProject,

    coalesce
    (
      nullif(GD.idSawTaskMain, 0),
      nullif(GP.idSawTaskMain, 0)
    ) as idSawTaskMain,

    GD.Width,
    GD.Height,

    GP.idSectorManufact,
    GP.idSawLimit,
    GP.idSheduleOperator as idSheduleOperatorSource,
    GP.TimeMarkManufact,

    STM.idTeam,
    STM.idAssemblyLine,

    case
      when datepart(hour, GP.TimeMarkManufact) < 8 then
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact) - 1, 0)
      else
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact), 0)
    end as DateComplete,

    case
      when datepart(hour, GP.TimeMarkManufact) >= 8
       and datepart(hour, GP.TimeMarkManufact) < 20 then 1
      else 2
    end as nSmena

  from GlassDetails GD
  inner join GlassProcessing GP on GP.idGlassDetails = GD.ID
  inner join SectorManufact SM on SM.ID = GP.idSectorManufact

  inner join SawTaskMain STM
    on STM.ID = coalesce
    (
      nullif(GD.idSawTaskMain, 0),
      nullif(GP.idSawTaskMain, 0)
    )

  where SM.nType = 2
    and GP.TimeMarkManufact is not null
),

ResolvedBase as
(
  select
    GB.idGlassDetails,
    GB.idGlass,
    GB.idProject,
    GB.idSawTaskMain,
    GB.Width,
    GB.Height,

    GB.idSectorManufact,
    GB.idSawLimit,
    GB.TimeMarkManufact,

    CalendarResolved.idPlanCalendar,
    TeamResolved.idTeam,
    GB.idAssemblyLine,

    GB.DateComplete,
    GB.nSmena,

    ResolvedOperator.idOperatorBrigadier,

    coalesce
    (
      BS.idSheduleOperator,
      ResolvedSOExact.ID,
      ResolvedSONull.ID,

      case
        when SourceValid.bValid = 1
         and SourceSO.idOperator = ResolvedOperator.idOperatorBrigadier then
          SourceSO.ID
      end
    ) as idSheduleOperator

  from GlassBase GB

  left join SheduleOperator SourceSO
    on SourceSO.ID = nullif(GB.idSheduleOperatorSource, 0)

  left join PlanCalendarOne PC
    on PC.Data = GB.DateComplete
   and PC.nSmena = GB.nSmena

  cross apply
  (
    select
      coalesce(PC.ID, SourceSO.idPlanCalendar) as idPlanCalendar
  ) CalendarResolved

  cross apply
  (
    select
      coalesce
      (
        nullif(GB.idTeam, 0),
        nullif(SourceSO.idTeam, 0)
      ) as idTeam
  ) TeamResolved

  cross apply
  (
    select
      case
        when SourceSO.ID is not null
         and nullif(SourceSO.idTeam, 0) = TeamResolved.idTeam then 1
        else 0
      end as bValid
  ) SourceValid

  left join OperatorMap OM
    on OM.idOperator = SourceSO.idOperator
   and OM.idSectorManufact = GB.idSectorManufact
   and SourceValid.bValid = 1

  left join BrigadierScheduleRanked BS
    on BS.idPlanCalendar = CalendarResolved.idPlanCalendar
   and BS.idTeam = TeamResolved.idTeam
   and BS.RowNum = 1

  cross apply
  (
    select
      case
        when SourceValid.bValid = 1
         and OM.idOperatorBrigadier is not null then
          OM.idOperatorBrigadier

        when BS.idOperatorBrigadier is not null then
          BS.idOperatorBrigadier

        when SourceValid.bValid = 1
         and exists
         (
           select 1
           from OperatorGroup OG
           where OG.idOperatorBrigadier = SourceSO.idOperator
         ) then
          SourceSO.idOperator

        else null
      end as idOperatorBrigadier
  ) ResolvedOperator

  left join SheduleOperatorOne ResolvedSOExact
    on ResolvedSOExact.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSOExact.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSOExact.idSectorManufact = GB.idSectorManufact
   and ResolvedSOExact.idTeam = TeamResolved.idTeam

  left join SheduleOperatorOne ResolvedSONull
    on ResolvedSONull.idPlanCalendar = CalendarResolved.idPlanCalendar
   and ResolvedSONull.idOperator = ResolvedOperator.idOperatorBrigadier
   and ResolvedSONull.idSectorManufact is null
   and ResolvedSONull.idTeam = TeamResolved.idTeam
)

select
  Personnel.ID,
  Personnel.Name,

  SawTaskMain.ID as idSawTask,
  SawTaskMain.Name as SawTaskName,
  SawLimit.Name as SawLimitName,

  RB.idTeam,
  RB.idAssemblyLine,

  FinalSO.ID as idSheduleOperator,
  RB.idOperatorBrigadier,

  ShedulePersonnel.KTU,
  KTU.SumKTU,

  RB.DateComplete,
  RB.nSmena,

  SectorManufact.dPriceOfUnitProd,

  count(1) as nCountDetails,

  cast
  (
    sum(dbo.f_GetUE_ForAssemblyPlastica(Project.ID)) *
    ShedulePersonnel.KTU /
    nullif(KTU.SumKTU, 0)

    as decimal(18, 6)
  ) as SumUE

from ResolvedBase RB
inner join SectorManufact on SectorManufact.ID = RB.idSectorManufact
inner join Project on Project.ID = RB.idProject
inner join SawTaskMain on SawTaskMain.ID = RB.idSawTaskMain

left join SawLimit on SawLimit.ID = RB.idSawLimit

inner join SheduleOperator FinalSO
  on FinalSO.ID = RB.idSheduleOperator

inner join
(
  select
    idSheduleOperator,
    sum(KTU) as SumKTU
  from ShedulePersonnel
  group by idSheduleOperator
) KTU on KTU.idSheduleOperator = FinalSO.ID

left join ShedulePersonnel
  on ShedulePersonnel.idSheduleOperator = FinalSO.ID

left join Personnel
  on Personnel.ID = ShedulePersonnel.idPersonnel

group by
  Personnel.ID,
  Personnel.Name,

  SawTaskMain.ID,
  SawTaskMain.Name,
  SawLimit.Name,

  RB.idTeam,
  RB.idAssemblyLine,

  FinalSO.ID,
  RB.idOperatorBrigadier,

  ShedulePersonnel.KTU,
  KTU.SumKTU,

  RB.DateComplete,
  RB.nSmena,

  SectorManufact.dPriceOfUnitProd
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_SawTaskUE_Period_Operator_Assembly_IZO.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_SawTaskUE_Period_Operator_Cut_IZO.sql'
go

-- ============================================================
-- File: View\v_SawTaskUE_Period_Operator_Cut_IZO.sql
-- ============================================================
if object_id(N'dbo.v_SawTaskUE_Period_Operator_Cut_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Operator_Cut_IZO
go

create view dbo.v_SawTaskUE_Period_Operator_Cut_IZO
as

with OperatorMap as
(
  select
    idOperator,
    idSectorManufact,
    min(idOperatorBrigadier) as idOperatorBrigadier
  from dbo.v_OperatorBrigadierMap
  group by idOperator, idSectorManufact
  having count(distinct idOperatorBrigadier) = 1
),

SheduleOperatorOne as
(
  select
    max(ID) as ID,
    idPlanCalendar,
    idOperator,
    idSectorManufact
  from SheduleOperator
  group by idPlanCalendar, idOperator, idSectorManufact
),

BrigadierScheduleCandidate as
(
  select
    SO.ID as idSheduleOperator,
    SO.idPlanCalendar,
    SO.idOperator as idOperatorBrigadier,
    OG.idSectorManufact,

    case
      when SO.idSectorManufact = OG.idSectorManufact then 0
      when SO.idSectorManufact is null then 1
      else 2
    end as Priority

  from SheduleOperator SO
  inner join OperatorGroup OG on OG.idOperatorBrigadier = SO.idOperator

  where SO.idSectorManufact = OG.idSectorManufact
     or SO.idSectorManufact is null
),

BrigadierScheduleRanked as
(
  select
    idSheduleOperator,
    idPlanCalendar,
    idOperatorBrigadier,
    idSectorManufact,

    row_number() over
    (
      partition by idPlanCalendar, idSectorManufact
      order by Priority, idSheduleOperator desc
    ) as RowNum

  from BrigadierScheduleCandidate
),
Base as
(
  /*
    Основной путь — для строк, где idSheduleOperator есть.
  */
  select
    GD.idGlass,
    GD.idProject,
    GD.idSawTaskMain,
    GD.Width,
    GD.Height,
    GP.idSectorManufact,

    case
      when OM.idOperatorBrigadier is null then SourceSO.ID
      else coalesce(BrigadierSOExact.ID, BrigadierSONull.ID)
    end as idSheduleOperator,

    PC.Data as DateComplete,
    GP.TimeMarkManufact,
    PC.nSmena

  from GlassDetails GD
  inner join GlassProcessing GP on GP.idGlassDetails = GD.ID
  inner join SectorManufact SM on SM.ID = GP.idSectorManufact
  inner join SheduleOperator SourceSO on SourceSO.ID = GP.idSheduleOperator
  inner join PlanCalendar PC on PC.ID = SourceSO.idPlanCalendar

  left join OperatorMap OM on OM.idOperator = SourceSO.idOperator
                          and OM.idSectorManufact = GP.idSectorManufact

  left join SheduleOperatorOne BrigadierSOExact
    on BrigadierSOExact.idPlanCalendar = PC.ID
   and BrigadierSOExact.idOperator = OM.idOperatorBrigadier
   and BrigadierSOExact.idSectorManufact = GP.idSectorManufact

  left join SheduleOperatorOne BrigadierSONull
    on BrigadierSONull.idPlanCalendar = PC.ID
   and BrigadierSONull.idOperator = OM.idOperatorBrigadier
   and BrigadierSONull.idSectorManufact is null

  where SM.nType = 1

  union all

  /*
    Запасной путь — для строк без idSheduleOperator.
    Бригадир определяется по календарю смены и участку.
  */
  select
    GD.idGlass,
    GD.idProject,
    GD.idSawTaskMain,
    GD.Width,
    GD.Height,
    GP.idSectorManufact,

    BS.idSheduleOperator,

    PC.Data as DateComplete,
    GP.TimeMarkManufact,
    PC.nSmena

  from GlassDetails GD
  inner join GlassProcessing GP on GP.idGlassDetails = GD.ID
  inner join SectorManufact SM on SM.ID = GP.idSectorManufact

  left join SheduleOperator SourceSO on SourceSO.ID = nullif(GP.idSheduleOperator, 0)

  inner join PlanCalendar PC
    on PC.Data = dateadd
    (
      day,
      datediff(day, 0, dateadd(hour, -8, GP.TimeMarkManufact)),
      0
    )
   and PC.nSmena =
    case
      when datepart(hour, GP.TimeMarkManufact) >= 8
       and datepart(hour, GP.TimeMarkManufact) < 20 then 1
      else 2
    end

  inner join BrigadierScheduleRanked BS
    on BS.idPlanCalendar = PC.ID
   and BS.idSectorManufact = GP.idSectorManufact
   and BS.RowNum = 1

  where SM.nType = 1
    and SourceSO.ID is null
    and GP.TimeMarkManufact is not null
)

select
  Personnel.ID,
  Personnel.Name,
  FinalSO.ID as idSheduleOperator,
  ShedulePersonnel.KTU,
  KTU.SumKTU,

  PriceChina.DataCalc as PriceChina,
  PriceLisec.DataCalc as PriceLisec,

  CuttingTable.Name as CuttingTableName,
  Base.DateComplete,
  Base.nSmena,

  SectorManufact.dPriceOfUnitProd,

  count(1) as nCountDetails,
  round(sum((Base.Width * Base.Height) / 1000000.0), 2) as SumArea,
  round(sum((Base.Width * Base.Height) / 1000000.0), 2) as SumAreaUZM,

  round
  (
    sum((Base.Width * Base.Height) / 1000000.0) *
    ShedulePersonnel.KTU * SectorManufact.dPriceOfUnitProd / KTU.SumKTU,
    2
  ) as SumUE,

  round
  (
    sum((Base.Width * Base.Height) / 1000000.0) *
    ShedulePersonnel.KTU * PriceChina.DataCalc / KTU.SumKTU,
    2
  ) as SumUEChina,

  round
  (
    (
      sum((Base.Width * Base.Height) / 1000000.0) +
      sum(isnull(UGA.WasteArea, 0) / TaskStats.TotalCount)
    ) *
    ShedulePersonnel.KTU * PriceLisec.DataCalc / KTU.SumKTU,
    2
  ) as SumUELisec,

  round(sum(isnull(UGA.WasteArea, 0) / TaskStats.TotalCount), 2) as SumWasteArea,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 0 then 1
    else 0
  end as bTripNoCoat,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 1 then 1
    else 0
  end as bTripCoat,

  isnull(Product.IsTriplex, 0) as bTriplex

from Base
inner join Product on Product.ID = Base.idGlass
inner join SectorManufact on SectorManufact.ID = Base.idSectorManufact
inner join Project on Project.ID = Base.idProject
inner join SheduleOperator FinalSO on FinalSO.ID = Base.idSheduleOperator

inner join
(
  select
    idSheduleOperator,
    sum(KTU) as SumKTU
  from ShedulePersonnel
  group by idSheduleOperator
) KTU on KTU.idSheduleOperator = FinalSO.ID

left join ShedulePersonnel on ShedulePersonnel.idSheduleOperator = FinalSO.ID
left join Personnel on Personnel.ID = ShedulePersonnel.idPersonnel

inner join SawTaskMain on SawTaskMain.ID = Base.idSawTaskMain

left join Cutting on Cutting.idSawTaskMain = SawTaskMain.ID
                       and Cutting.idGlass = Product.ID
                       and Cutting.bMain = 1

inner join
(
  select
    idSawTaskMain,
    idGlass,
    count(idGlass) as TotalCount
  from GlassDetails
  group by idSawTaskMain, idGlass
) TaskStats on TaskStats.idSawTaskMain = SawTaskMain.ID
           and TaskStats.idGlass = Product.ID

left join CuttingTable on CuttingTable.ID = Cutting.idCuttingTable
left join Config PriceChina on PriceChina.Name = 'dPriceUEChina'
left join Config PriceLisec on PriceLisec.Name = 'dPriceUELisec'

left join
(
  select
    UG.idSawTask,
    UG.idGlass,

    round
    (
      sum
      (
        case
          when UG.Width < 0 then
            UG.Width * UG.BilletHeight * UG.nCount -
            (UG.Width - P.MarginLeft - P.MarginRight - P.MarginInner) *
            (UG.BilletHeight - P.MarginBottom - P.MarginInner) * UG.nCount
          else
            UG.BilletWidth * UG.BilletHeight * UG.nCount -
            (UG.BilletWidth - P.MarginLeft) *
            (UG.BilletHeight - P.MarginBottom - P.MarginInner) * UG.nCount
        end
      ) / 1000000.0,
      4
    ) as WasteArea

  from UsedGlass UG
  inner join Product P on P.ID = UG.idGlass
  group by UG.idSawTask, UG.idGlass
) UGA on UGA.idSawTask = SawTaskMain.ID
     and UGA.idGlass = Product.ID

where Base.idSheduleOperator is not null

group by
  Personnel.ID, Personnel.Name,
  FinalSO.ID,
  ShedulePersonnel.KTU,
  KTU.SumKTU,
  PriceChina.DataCalc, PriceLisec.DataCalc,
  CuttingTable.Name,
  Base.DateComplete, Base.nSmena,
  SectorManufact.dPriceOfUnitProd,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 0 then 1
    else 0
  end,

  case
    when isnull(Product.IsTriplex, 0) = 1
     and isnull(Product.bCoating, 0) = 1 then 1
    else 0
  end,

  isnull(Product.IsTriplex, 0)
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_SawTaskUE_Period_Operator_Cut_IZO.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_SawTaskUE_Period_Operator_ZAK_IZO.sql'
go

-- ============================================================
-- File: View\v_SawTaskUE_Period_Operator_ZAK_IZO.sql
-- ============================================================
if object_id(N'dbo.v_SawTaskUE_Period_Operator_ZAK_IZO', N'V') is not null
  drop view dbo.v_SawTaskUE_Period_Operator_ZAK_IZO
go

create view dbo.v_SawTaskUE_Period_Operator_ZAK_IZO
as

with OperatorMap as
(
  select
    idOperator,
    idSectorManufact,
    min(idOperatorBrigadier) as idOperatorBrigadier
  from dbo.v_OperatorBrigadierMap
  group by idOperator, idSectorManufact
  having count(distinct idOperatorBrigadier) = 1
),

PlanCalendarOne as
(
  select
    max(ID) as ID,
    Data,
    nSmena
  from PlanCalendar
  where nSmena in (1, 2)
  group by Data, nSmena
),

SheduleOperatorOne as
(
  select
    max(ID) as ID,
    idPlanCalendar,
    idOperator,
    idSectorManufact
  from SheduleOperator
  group by idPlanCalendar, idOperator, idSectorManufact
),

BrigadierScheduleCandidate as
(
  select distinct
    SO.ID as idSheduleOperator,
    SO.idPlanCalendar,
    SO.idOperator as idOperatorBrigadier,
    OG.idSectorManufact,

    case
      when SO.idSectorManufact = OG.idSectorManufact then 0
      when SO.idSectorManufact is null then 1
      else 2
    end as Priority

  from SheduleOperator SO
  inner join OperatorGroup OG on OG.idOperatorBrigadier = SO.idOperator

  where SO.idSectorManufact = OG.idSectorManufact
     or SO.idSectorManufact is null
),

BrigadierScheduleRanked as
(
  select
    idSheduleOperator,
    idPlanCalendar,
    idOperatorBrigadier,
    idSectorManufact,

    row_number() over
    (
      partition by idPlanCalendar, idSectorManufact
      order by Priority, idSheduleOperator desc
    ) as RowNum

  from BrigadierScheduleCandidate
),

ZakOperation as
(
  select
    idProject,
    nGlass,
    nGlassTriplex,
    idProd
  from ProjectItem
  where isnull(nTypeOper, 0) = 2
    and nType = 8
),

GlassBase as
(
  select
    GD.ID as idGlassDetails,
    GD.idGlass,
    GD.idProject,
    GD.idProjectItem,
    GD.idSawTaskMain,
    GD.Width,
    GD.Height,

    GP.idSectorManufact,
    GP.idSheduleOperator as idSheduleOperatorSource,
    GP.TimeMarkManufact,

    case
      when datepart(hour, GP.TimeMarkManufact) < 8 then
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact) - 1, 0)
      else
        dateadd(day, datediff(day, 0, GP.TimeMarkManufact), 0)
    end as DateComplete,

    case
      when datepart(hour, GP.TimeMarkManufact) >= 8
       and datepart(hour, GP.TimeMarkManufact) < 20 then 1
      else 2
    end as nSmena

  from GlassDetails GD
  inner join GlassProcessing GP on GP.idGlassDetails = GD.ID
  inner join SectorManufact SM on SM.ID = GP.idSectorManufact

  where SM.nType = 3
    and GP.TimeMarkManufact is not null
),

ResolvedBase as
(
  select
    GB.idGlassDetails,
    GB.idGlass,
    GB.idProject,
    GB.idProjectItem,
    GB.idSawTaskMain,
    GB.Width,
    GB.Height,
    GB.idSectorManufact,
    GB.TimeMarkManufact,

    CalendarResolved.idPlanCalendar,
    GB.DateComplete,
    GB.nSmena,

    ResolvedOperator.idOperatorBrigadier,

    coalesce
    (
      ResolvedSOExact.ID,
      ResolvedSONull.ID,

      case
        when SourceSO.idOperator = ResolvedOperator.idOperatorBrigadier then
          SourceSO.ID
      end,

      BS.idSheduleOperator
    ) as idSheduleOperator

  from GlassBase GB

  left join SheduleOperator SourceSO on SourceSO.ID = nullif(GB.idSheduleOperatorSource, 0)

  left join PlanCalendarOne PC on PC.Data = GB.DateComplete
                            and PC.nSmena = GB.nSmena

  cross apply
  (
    select
      coalesce(PC.ID, SourceSO.idPlanCalendar) as idPlanCalendar
  ) CalendarResolved

  left join OperatorMap OM
    on OM.idOperator = SourceSO.idOperator
   and OM.idSectorManufact = GB.idSectorManufact

  left join BrigadierScheduleRanked BS
    on BS.idPlanCalendar = CalendarResolved.idPlanCalendar
   and BS.idSectorManufact = GB.idSectorManufact
   and BS.RowNum = 1

  cross apply
  (
    select
      case
        when OM.idOperatorBrigadier is not null then
          OM.idOperatorBrigadier

        when SourceSO.ID is not null then
          SourceSO.idOperator

        else
          BS.idOperatorBrigadier
      end as idOperatorBrigadier
  ) ResolvedOperator

  left join SheduleOperatorOne ResolvedSOExact on ResolvedSOExact.idPlanCalendar = CalendarResolved.idPlanCalendar
                                            and ResolvedSOExact.idOperator       = ResolvedOperator.idOperatorBrigadier
                                            and ResolvedSOExact.idSectorManufact = GB.idSectorManufact

  left join SheduleOperatorOne ResolvedSONull on ResolvedSONull.idPlanCalendar = CalendarResolved.idPlanCalendar
                                                 and ResolvedSONull.idOperator = ResolvedOperator.idOperatorBrigadier
                                                 and ResolvedSONull.idSectorManufact is null
)

select
  Personnel.ID,
  Personnel.Name,

  FinalSO.ID as idSheduleOperator,
  FinalSO.idOperator as idOperatorBrigadier,
  FinalSO.idTeam,

  ShedulePersonnel.KTU,
  KTU.SumKTU,

  RB.DateComplete,
  RB.nSmena,

  SectorManufact.dPriceOfUnitProd,

  count(1) as nCountDetails,

  cast
  (
    sum(1.0 * RB.Width * RB.Height) / 1000000.0
    as decimal(18, 6)
  ) as SumArea,

  cast
  (
    sum
    (
      1.0 * RB.Width * RB.Height / 1000000.0 *
      case
        when isnull(GlassWorkAdd.dCoefUZM, 0) = 0 then
          Product.dCoefUZM
        else
          GlassWorkAdd.dCoefUZM
      end
    )
    as decimal(18, 6)
  ) as SumAreaUZM,

  cast
  (
    sum
    (
      1.0 * RB.Width * RB.Height / 1000000.0 *
      case
        when isnull(GlassWorkAdd.dCoefUZM, 0) = 0 then
          Product.dCoefUZM
        else
          GlassWorkAdd.dCoefUZM
      end
    ) *
    ShedulePersonnel.KTU *
    SectorManufact.dPriceOfUnitProd /
    nullif(KTU.SumKTU, 0)

    as decimal(18, 6)
  ) as SumUE

from ResolvedBase RB
inner join Product on Product.ID = RB.idGlass
inner join SectorManufact on SectorManufact.ID = RB.idSectorManufact
inner join Project on Project.ID = RB.idProject

inner join ProjectItem on ProjectItem.ID = RB.idProjectItem

inner join ZakOperation ZAK on ZAK.idProject = ProjectItem.idProject
                              and ZAK.nGlass = ProjectItem.nGlass
                       and ZAK.nGlassTriplex = ProjectItem.nGlassTriplex

left join GlassWorkAdd on GlassWorkAdd.idProduct_Glass = Product.ID
                       and GlassWorkAdd.idProduct_Work = ZAK.idProd

inner join SheduleOperator FinalSO on FinalSO.ID = RB.idSheduleOperator

inner join
(
  select
    idSheduleOperator,
    sum(KTU) as SumKTU
  from ShedulePersonnel
  group by idSheduleOperator
) KTU on KTU.idSheduleOperator = FinalSO.ID

left join ShedulePersonnel
  on ShedulePersonnel.idSheduleOperator = FinalSO.ID

left join Personnel
  on Personnel.ID = ShedulePersonnel.idPersonnel

where isnull(Product.dCoefUZM, 0) > 0

group by
  Personnel.ID,
  Personnel.Name,

  FinalSO.ID,
  FinalSO.idOperator,
  FinalSO.idTeam,

  ShedulePersonnel.KTU,
  KTU.SumKTU,

  RB.DateComplete,
  RB.nSmena,

  SectorManufact.dPriceOfUnitProd
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_SawTaskUE_Period_Operator_ZAK_IZO.sql'
go

print convert(varchar, getdate(), 20) + ' : start View\v_Volume_Money_SubDivision.sql'
go

-- ============================================================
-- File: View\v_Volume_Money_SubDivision.sql
-- ============================================================
if object_id('v_Volume_Money_SubDivision', 'V') is not null
    drop view dbo.v_Volume_Money_SubDivision
go 
      
create view dbo.v_Volume_Money_SubDivision  
as  
select   
  Sum(IsNull(ProjectPrice, 0)) as SumPrice,  
  Sum(IsNull(Task.Area, 0))   as SumArea,  
  Sum(SPCount.nCount)         as SumPosCount,  
  Task.idClient,  
  Task.DateComplite           as Date,  
  Task.TypeOrder,  
  case Task.TypeOrder   
    when 0 then 'Безнал'  
    when 1 then 'Нал'  
    when 2 then 'ОБ'  
  end                         as TypeOrderName,  
  Client.Name                 as ClientName,  
  IsNull(DepotSubDivision.name, 'Цех 1') as SubDivisionName  
from   
  Task   
  inner join Client           on Task.idClient = Client.ID  
  left  join DepotSubDivision on Task.idDepotSubDivision = DepotSubDivision.ID  
  left  join  
  (  
    select  
      Project.idTask,  
      sum(Project.nCount)                            as nCount,  
      sum(IsNull(Project.SumWithNDS, 0))          as ProjectPrice,  
      sum(IsNull(Project.Area,  0) * Project.nCount) as ProjectArea  
    from   
      Project  
    group by   
      Project.idTask  
  ) SPCount on Task.ID = SPCount.idTask  
where  
  dbo.f_GetTaskState_ForReport(Task.ID) = 1 and  
  dbo.f_GetExistsRejectFromTask(Task.ID) = 0  
group by   
  Task.DateComplite,  
  Task.TypeOrder,  
  Task.idClient,  
  Client.Name,  
  IsNull(DepotSubDivision.name, 'Цех 1')  
go

go
print convert(varchar, getdate(), 20) + ' : finish View\v_Volume_Money_SubDivision.sql'
go

/* ============================================================
   Function
   ============================================================ */


print convert(varchar, getdate(), 20) + ' : start Function\f_GetNextAccountNum_BW.sql'
go

-- ============================================================
-- File: Function\f_GetNextAccountNum_BW.sql
-- ============================================================
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_GetNextAccountNum_BW]') and xtype in (N'FN', N'IF', N'TF'))
drop function dbo.f_GetNextAccountNum_BW
go

create function dbo.f_GetNextAccountNum_BW (@idClient int, @TypeOrder int, @idTaskExlude int) returns varchar(100)
as
begin
  declare @num                  varchar(100),
          @TypeOrder1           int,
          @TypeOrder2           int,
          @ShortDate            datetime,
          @TaskAccountNum_Type  int,
          @sTaskPrefix          varchar(10)

  -- Префикс заказа, например "С"
  select @sTaskPrefix = d_string
  from Config
  where Name = 'AccountNumPrefix'

  set @sTaskPrefix = isnull(@sTaskPrefix, '')

  -- 0 - нумерация отдельно по клиентам
  -- 1 - сквозная нумерация
  select @TaskAccountNum_Type = d_iNum
  from Config
  where Name = 'TaskAccountNum'

  set @TaskAccountNum_Type = isnull(@TaskAccountNum_Type, 0)

  -- Смотрим заказы только с начала текущего года
  set @ShortDate = convert(datetime, cast(year(getdate()) as varchar(4)) + '-01-01', 20)

  -- Для TypeOrder = 1 общая серия для типов 1 и 2
  if @TypeOrder = 1
  begin
    set @TypeOrder1 = 1
    set @TypeOrder2 = 2
  end
  else
  begin
    set @TypeOrder1 = 0
    set @TypeOrder2 = 0
  end

  if @TypeOrder != 1
  begin
    -- Для TypeOrder 0 ищем только номера, начинающиеся с "С0"
    -- Например: С099, С0100, С0101, С0103
    select top 1
      @num = T.AccountNum
    from
      Task T
    where
      (T.idClient = @idClient or @TaskAccountNum_Type = 1) and
      T.ID <> @idTaskExlude and
      (T.TypeOrder = @TypeOrder1 or T.TypeOrder = @TypeOrder2 or @TaskAccountNum_Type = 1) and
      T.Date >= @ShortDate and

      -- Номер обязательно должен начинаться с С0
      left(T.AccountNum, len(@sTaskPrefix) + 1) = @sTaskPrefix + '0' and

      -- После удаления С должны остаться цифры
      try_cast(stuff(T.AccountNum, 1, len(@sTaskPrefix), '') as int) is not null and

      -- ВРЕМЕННО этот заказ у клиента московские окна не смотрим
      not
      (
        T.idClient = 1269 and
        T.AccountNum = 'С0411'
      ) 

    order by
      try_cast(stuff(T.AccountNum, 1, len(@sTaskPrefix), '') as int) desc

    -- С0103 -> убираем С -> 0103 -> 103 + 1 = 104
    set @num = cast(isnull(try_cast(stuff(isnull(@num, ''), 1, len(@sTaskPrefix), '') as int), 0 ) + 1 as varchar(100))

    -- Добавляем С0 -> получаем С0104
    set @num = @sTaskPrefix + '0' + @num
  end
  else
  begin
    -- Для остальных типов ищем любые номера с префиксом С
    select top 1
      @num = T.AccountNum
    from
      Task T
    where
      (T.idClient = @idClient or @TaskAccountNum_Type = 1) and
      T.ID <> @idTaskExlude and
      (T.TypeOrder = @TypeOrder1 or T.TypeOrder = @TypeOrder2 or @TaskAccountNum_Type = 1) and
      T.Date >= @ShortDate and

      -- Номер должен начинаться с С
      left(T.AccountNum, len(@sTaskPrefix)) = @sTaskPrefix and

      -- После удаления С должны остаться цифры
      try_cast(stuff(T.AccountNum, 1, len(@sTaskPrefix), '') as int) is not null
    order by
      try_cast(stuff(T.AccountNum, 1, len(@sTaskPrefix), '') as int) desc

    -- С0411 -> убираем С -> 0411 -> 411 + 1 = 412
    set @num = cast(
      isnull(
        try_cast(stuff(isnull(@num, ''), 1, len(@sTaskPrefix), '') as int),
        0
      ) + 1
      as varchar(100)
    )

    -- Добавляем С -> получаем С412
    set @num = @sTaskPrefix + @num
  end

  return @num
end
go

go
print convert(varchar, getdate(), 20) + ' : finish Function\f_GetNextAccountNum_BW.sql'
go

print convert(varchar, getdate(), 20) + ' : start Function\f_SawTaskUE_Period_Detail_Shipment.sql'
go

-- ============================================================
-- File: Function\f_SawTaskUE_Period_Detail_Shipment.sql
-- ============================================================
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

go
print convert(varchar, getdate(), 20) + ' : finish Function\f_SawTaskUE_Period_Detail_Shipment.sql'
go

print convert(varchar, getdate(), 20) + ' : start Function\f_SawTaskUE_Period_Operator_Shipment.sql'
go

-- ============================================================
-- File: Function\f_SawTaskUE_Period_Operator_Shipment.sql
-- ============================================================
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

go
print convert(varchar, getdate(), 20) + ' : finish Function\f_SawTaskUE_Period_Operator_Shipment.sql'
go

/* ============================================================
   SP
   ============================================================ */


print convert(varchar, getdate(), 20) + ' : start SP\sp_CreateSheduleOperator_IZO.sql'
go

-- ============================================================
-- File: SP\sp_CreateSheduleOperator_IZO.sql
-- ============================================================
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_CreateSheduleOperator_IZO]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_CreateSheduleOperator]
GO

-- [ao] создать оператора    
create procedure sp_CreateSheduleOperator_IZO @idOperator int, @date datetime, @idSheduleOperatorNew int output    
as    
begin    
  set nocount on    
    
  set @idSheduleOperatorNew = null    
    
  -- Ищем есть ли такой, чтобы не двоить    
  select     
    @idSheduleOperatorNew = ID     
  from     
    SheduleOperator    
  where    
    idOperator = @idOperator and    
    @date >= dtBegin         and    
    @date <  dtEnd    
    
  if @idSheduleOperatorNew is not null    
    return    
    
  -- 2. Пытаемся создать    
  declare     
    @idPlanCalendar int,    
    @nSmena         int,    
    @DatePC         datetime         
      
  select    
    @idPlanCalendar = ID,    
    @nSmena         = nSmena,    
    @DatePC         = Data    
  from    
    PlanCalendar    
  where    
    dbo.f_GetSmenaBeg(Data, nSmena) <= @date and    
    dbo.f_GetSmenaEnd(Data, nSmena) >  @date    
    
  if @idPlanCalendar is null    
  begin    
    -- Не заполнен план-календарь - надо создать PlanCalendar    
    exec sp_PlanCalendarMake @date, @date    
     
    -- И еще раз прочитаем данные     
    select    
      @idPlanCalendar = ID,    
      @nSmena         = nSmena,    
      @DatePC         = Data    
    from    
      PlanCalendar    
    where    
      dbo.f_GetSmenaBeg(Data, nSmena) <= @date and    
      dbo.f_GetSmenaEnd(Data, nSmena) >  @date    
    -- return    
  end     
    
  insert into SheduleOperator    
  (    
    idPlanCalendar,    
    idOperator,    
    dtBegin,    
    dtEnd    
  )    
  select    
    @idPlanCalendar,    
    @idOperator,    
    dbo.f_GetSmenaBeg(@DatePC, @nSmena),    
    dbo.f_GetSmenaEnd(@DatePC, @nSmena)    
      
  select @idSheduleOperatorNew = scope_identity()    
    
  -- Добавляем состав бригады из 1 чел этого оператора    
  insert into ShedulePersonnel    
  (    
    idSheduleOperator,    
    idPersonnel,    
    KTU    
  )    
  select    
    @idSheduleOperatorNew,    
    Operator.idPersonnel,    
    1.0    
  from    
    Operator     
  where    
    ID = @idOperator            
          
  return    
end 

go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_CreateSheduleOperator_IZO.sql'
go

print convert(varchar, getdate(), 20) + ' : start SP\sp_DepCalcReg_Add_Group.sql'
go

-- ============================================================
-- File: SP\sp_DepCalcReg_Add_Group.sql
-- ============================================================
if exists (select * from dbo.sysobjects where id = OBJECT_ID(N'[dbo].[sp_DepCalcReg_Add_Group]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
  drop procedure [dbo].[sp_DepCalcReg_Add_Group]
go

create procedure sp_DepCalcReg_Add_Group @idDepTransList varchar(max)
as
begin
  set nocount on

  print 'sp_DepCalcReg_Add_Group'

  declare  @DocDate   datetime,
           @StartDate datetime,
           @SQL       varchar(max),
           @nCount    int,
           @MinDate   datetime

  if exists(select 1 from Config where Name = 'ProceedRecalc')
  begin
    print 'Идёт пересчёт склада Config where Name = ProceedRecalc'
    return
  end

  select @StartDate = DataCalc from Config where Name = 'DepRecalc_StartDate'

  set @StartDate = IsNull(@StartDate, '01.01.2000')  -- предохранитель

  create table #DelInputInfo
  (
    ID      int,
    DocDate datetime
  )

  set @SQL = 'select ID, DocDate from DepTrans where ID in ('+ @idDepTransList +') ' +
             'and DocDate >= ''' + cast(@StartDate as varchar(20)) + '''' -- Возможно это и не надо, подумать головой

  print 'Пересчёт документов: ' + @SQL

  insert into #DelInputInfo
  exec(@SQL)

  select
    @nCount  = count(1),
    @MinDate = min(DocDate)
  from
    #DelInputInfo

  -- нечего выводить из регистров - не выводим
  if IsNull(@nCount, 0) = 0
    return

  -- финальная дата пересчета
  if IsNull(@MinDate, '01.01.2000') > @StartDate
    set @StartDate = IsNull(@MinDate, '01.01.2000')

  update DT  set bWrite = 2 from #DelInputInfo DII inner join DepTrans      DT  on DT.ID          = DII.ID where IsNull(DT.bWrite,  0) != 2  -- пометили на запись
  update DTM set bWrite = 1 from #DelInputInfo DII inner join DepTransMater DTM on DTM.idDepTrans = DII.ID where IsNull(DTM.bWrite, 0) != 1  -- пометили на запись

  drop table #DelInputInfo

  -- Вот здесь: здесь через , введены idDepTrans надо как-то вызывать на основе того что я тебе дал exec sp_GetNextDepTransNumInvoice @idDepDocType, @NumCalcFact, @NumInvoice output
  
  declare @bNeedRecalcNumCalcFact int
  select @bNeedRecalcNumCalcFact = d_iNum from Config where Name = 'bNeedEqual_DepTransNumInvoice_To_TaskNumCalcFact'

  if @bNeedRecalcNumCalcFact = 1
  begin
     update DepTrans
     set
        NumInvoice = 'РН-' + T.NumCalcFact
     from DepTrans DT
     left join Task T on T.ID = DT.idTask
     where  
     DT.idDepDocType = 2 and
     DT.ID in (@idDepTransList)
  end

  exec sp_AddProtocol_DepTrans_List 0, @idDepTransList -- запись в протокол ("0" - добовление док. в регистр)

  exec sp_depResetBase     @StartDate
  exec sp_depRecalcFromDay @StartDate   -- посчитали день целиком

  set nocount off
end
go

go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_DepCalcReg_Add_Group.sql'
go

print convert(varchar, getdate(), 20) + ' : start SP\sp_GetMaterialsWithDateGap.sql'
go

-- ============================================================
-- File: SP\sp_GetMaterialsWithDateGap.sql
-- ============================================================
if object_id('dbo.sp_GetMaterialsWithDateGap', 'P') is not null
  drop procedure dbo.sp_GetMaterialsWithDateGap
go

create procedure dbo.sp_GetMaterialsWithDateGap @DateBegin datetime, @DateEnd   datetime
as
begin
  set nocount on

  declare @DateBeginDay datetime
  declare @DateEndDay   datetime
  declare @DateEndNext  datetime

  /*
    Нормализуем входные даты.

    Например:
      @DateBegin = 01.06.2026
      @DateEnd   = 30.06.2026

    Интервал ParentDT:
      >= 01.06.2026 00:00
      <  01.07.2026 00:00
  */
  set @DateBeginDay = dateadd(day, datediff(day, 0, @DateBegin), 0)
  set @DateEndDay   = dateadd(day, datediff(day, 0, @DateEnd),   0)
  set @DateEndNext  = dateadd(day, 1, @DateEndDay)

  if @DateBeginDay > @DateEndDay
  begin
    raiserror('Дата начала интервала не может быть больше даты окончания.', 16, 1)

    return
  end


  ;with ParentDocs
  as
  (
    /*
      Берём родительские бухгалтерские документы,
      которые входят в выбранный интервал.
    */
    select
      ParentDT.ID
    from DepTrans ParentDT
    where
          ParentDT.DocDate >= @DateBeginDay
      and ParentDT.DocDate <  @DateEndNext
  ),

  DT0
  as
  (
    /*
      Склад 0.

      Берём только документы, которые находятся
      ПОСЛЕ даты разделения.

      Сразу группируем по:
        - родительскому документу;
        - подразделению;
        - материалу.

      Это защищает от перемножения строк при JOIN со складом 2.
    */
    select
      D0.idParent,
      DN0.Name                       as DepName,
      DTM0.idMaterial,

      sum(isnull(DTM0.dCount, 0))     as dCount0,
      sum(isnull(DTM0.PriceSum, 0))   as PriceSum0,
      sum(isnull(DTM0.NDSSum, 0))     as NDSSum0,
      sum(isnull(DTM0.PriceNDSSum, 0)) as PriceNDSSum0

    from ParentDocs P
    inner join DepTrans D0 on D0.idParent = P.ID
    inner join DepTransMater DTM0 on DTM0.idDepTrans = D0.ID
    inner join DepNameList DNL0 on DNL0.idDepName = D0.idDepName_Debet
    inner join DepName DN0 on DN0.ID = DNL0.idDepName
    inner join DepList DL0 on  DL0.ID  = DNL0.idDepList
                           and DL0.is1 = 1 
    inner join Task T0 on T0.ID = D0.idTask
    where
      T0.DateComplite > @DateEndNext and
      D0.is1 = 1

    group by
      D0.idParent,
      DN0.Name,
      DTM0.idMaterial
  ),

  DT2
  as
  (
    /*
      Склад 2.

      Берём только документы, которые находятся
      ДО даты разделения.

      Вся дата @DateEnd включительно.
    */
    select
      D2.idParent,
      DTM2.idMaterial,

      sum(isnull(DTM2.dCount, 0))      as dCount2,
      sum(isnull(DTM2.PriceSum, 0))    as PriceSum2,
      sum(isnull(DTM2.NDSSum, 0))      as NDSSum2,
      sum(isnull(DTM2.PriceNDSSum, 0)) as PriceNDSSum2

    from ParentDocs P
    inner join DepTrans D2 on D2.idParent = P.ID
    inner join DepTransMater DTM2 on DTM2.idDepTrans = D2.ID
    inner join DepNameList DNL2 on DNL2.idDepName = D2.idDepName_Debet
    inner join DepList DL2 on  DL2.ID  = DNL2.idDepList
                           and DL2.is2 = 1
    inner join Task T2 on T2.ID = D2.idTask
    where
      T2.DateCompliteGP <= @DateEndDay and
      D2.is2 = 1

    group by
      D2.idParent,
      DTM2.idMaterial
  ),

  MaterialsByDocument
  as
  (
    /*
      Соединяем уже просчитанные данные складов.

      Здесь получается одна строка материала
      на родительский документ и подразделение.
    */
    select
      DT0.DepName,
      DT0.idMaterial,

      DT0.dCount0,
      DT0.PriceSum0,
      DT0.NDSSum0,
      DT0.PriceNDSSum0,

      DT2.dCount2,
      DT2.PriceSum2,
      DT2.NDSSum2,
      DT2.PriceNDSSum2

    from DT0

    inner join DT2 on  DT2.idParent   = DT0.idParent
                   and DT2.idMaterial = DT0.idMaterial
  )

  /*
    Итоговая группировка.

    Одна строка результата:
      подразделение + материал.

    Никакой группировки по:
      - дате;
      - заказу;
      - накладной;
      - родительскому документу.
  */
  select
    @DateBeginDay                 as DateBegin,
    @DateEndDay                   as DateEnd,
    @DateEndDay                   as DateGap,

    MDB.DepName,

    M.ID                          as idMaterial,
    M.Name                        as MaterialName,

    sum(MDB.dCount0)              as dCount0,
    sum(MDB.dCount2)              as dCount2,

    sum(MDB.PriceSum0)            as PriceSum0,
    sum(MDB.PriceSum2)            as PriceSum2,

    sum(MDB.NDSSum0)              as NDSSum0,
    sum(MDB.NDSSum2)              as NDSSum2,

    sum(MDB.PriceNDSSum0)         as PriceNDSSum0,
    sum(MDB.PriceNDSSum2)         as PriceNDSSum2

  from MaterialsByDocument MDB

  inner join Material M on M.ID = MDB.idMaterial

  group by
    MDB.DepName,
    M.ID,
    M.Name

  order by
    M.Name,
    MDB.DepName

  set nocount off
end
go

go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_GetMaterialsWithDateGap.sql'
go

print convert(varchar, getdate(), 20) + ' : start SP\sp_GetPendingDepTrans.sql'
go

-- ============================================================
-- File: SP\sp_GetPendingDepTrans.sql
-- ============================================================
if OBJECT_ID('sp_GetPendingDepTrans', 'P') is not NULL
  drop procedure dbo.sp_GetPendingDepTrans
go

-- Для отчета не списанные заказы на дату    
create procedure dbo.sp_GetPendingDepTrans @BegDate datetime, @EndDate datetime, @idSubDivision int    
as    
begin    
with cte as  
(  
  select    
    @BegDate            as BegDate,    
    @EndDate            as EndDate,    
    DT.DateInvoice,    
    DT.DocDate,    
    DT.NumInvoice,    
    DT.DepNum,    
    DT.idParent,    
    DT.ID,    
    DT.idDepDocType,    
    IsNull(DT.iDep, 1) as iDep,    
    T.AccountNum,    
    T.DateComplite,    
    C.Name              as ClientName,    
        
    DepotSubDivision.ID as idDepotSubDivision,    
    DT.bWrite,    
    case     
      when isnull(DT.idParent, 0) != 0 then    
      case    
        when exists     
        (    
          select 1    
          from DepTransMater DTM    
          where DTM.idDepTrans = DT.ID and isnull(DTM.PriceSum, 0) = 0    
        )                                                     then 'Позиции с нулевой ценой'    
        when DT.bWrite = 0                                    then 'Накладная не проведена'    
        when IsNull(DT.bWrite, 0) = 2 and DT.idDepDocType = 1 then 'Нет списания'    
        else ''    
       end    
      else 'Нет списаний'    
    end as strState    
  from Task T    
  inner join DepotSubDivision   on T.idDepotSubDivision = DepotSubDivision.ID    
  left  join Client  C          on T.idClient           = C.ID                                            
  outer apply    
  (     
    select     
      DateInvoice,    
      DocDate,    
      NumInvoice,    
      Num as DepNum,    
      idParent,    
      ID,    
      idDepDocType,    
      bWrite,    
      bCheck,
      nType,
      case     
        when IsNull(is1, 0) = 1 then 1    
        when IsNull(is2, 0) = 1 then 2    
      end iDep    
    from DepTrans    
    where DepTrans.idTask = T.ID    
  )  DT    
  where     
    (    
      (
        IsNull(DT.bWrite, 0) != 2 and
        IsNull(DT.nType, 0)  != 4
      ) or
      (   
        DT.idDepDocType = 1 and    
        not exists     
        (    
          select 1    
          from DepTrans    
          where idParent = DT.ID    
        )    
      )    
    ) and    
    T.DateComplite >= @BegDate and    
    T.DateComplite <= @EndDate and    
    DepotSubDivision.ID = @idSubDivision    
)  
-- Забираем все данные  
select * from cte  
union all -- если idParent = 0 тогда списания для склада 2 также нет  
  select    
    BegDate,   
    EndDate,   
    DateInvoice,   
    DocDate,  
    NumInvoice,   
    DepNum,   
    idParent,   
    ID,   
    idDepDocType,    
    2 as iDep,       -- склад 2  
    AccountNum,   
    DateComplite,   
    ClientName,   
    idDepotSubDivision,   
    bWrite,  
    strState  
  from cte  
  where idParent = 0  
  order by DateComplite    
end  


go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_GetPendingDepTrans.sql'
go

print convert(varchar, getdate(), 20) + ' : start SP\sp_GetRest_AllDepList.sql'
go

-- ============================================================
-- File: SP\sp_GetRest_AllDepList.sql
-- ============================================================
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

go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_GetRest_AllDepList.sql'
go

print convert(varchar, getdate(), 20) + ' : start SP\sp_GetTaskTreeLogistic.sql'
go

-- ============================================================
-- File: SP\sp_GetTaskTreeLogistic.sql
-- ============================================================
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

go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_GetTaskTreeLogistic.sql'
go

print convert(varchar, getdate(), 20) + ' : start SP\sp_Invoice_IZO_Ship_Only.sql'
go

-- ============================================================
-- File: SP\sp_Invoice_IZO_Ship_Only.sql
-- ============================================================
if OBJECT_ID('sp_Invoice_IZO_Ship_Only', 'P') is not null
  drop procedure sp_Invoice_IZO_Ship_Only
go

-- Для распечатки счетов-фактур, накладных и т.п. только на отгружаемую часть.  
-- STIS 2015-09-04 добавлены из таблицы транспорт num,DeliveryNum номера Расходной накладной и счёта фактуры  
-- @bUnionRejectWithFather если 1  - то В случае отгрузки с переделкой выписывать счёт из отгрузки на первоначальный заказ, но включать в него переделку из отгрузки.  
  
create procedure sp_Invoice_IZO_Ship_Only @idShip int, @idTask int, @bOtherProduction int = 0, @bUnionRejectWithFather int = 0  
as  
begin  
  set nocount on  
  
  if OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP Table #Temp  
    
  /* временная таблица будет создавться во время выполнения запроса  
     это нужно чтобы избежать проблем с размером текстовых полей  
  create table #Temp  
  (  
    forCount int,  
    idTask int,  
    idProject int,  
    idTaskType int,  
    TaskTypeName varchar(32),  
    TaskNum varchar(150) collate Cyrillic_General_CI_AS,  
    AccountNum varchar(150) collate Cyrillic_General_CI_AS,  
    TaskDate datetime,  
    ClientNum varchar(100) collate Cyrillic_General_CI_AS,  
    NumCalcFact varchar(150) collate Cyrillic_General_CI_AS,  
    NumCalcFact_Dealer varchar(150) collate Cyrillic_General_CI_AS,  
    DateComplete datetime,  
    Komission varchar(250) collate Cyrillic_General_CI_AS,  
    DatePayDoc datetime,  
    ClientName varchar(255) collate Cyrillic_General_CI_AS,  
    ClientNameFull varchar(255) collate Cyrillic_General_CI_AS,  
    ClientAdress varchar(255) collate Cyrillic_General_CI_AS,  
    AdressSubDiv varchar(255) collate Cyrillic_General_CI_AS,  
    ClientTel varchar(150) collate Cyrillic_General_CI_AS,  
    ClientOKPO varchar(100) collate Cyrillic_General_CI_AS,  
    ClientUNN varchar(20) collate Cyrillic_General_CI_AS,  
    ClientKPP varchar(50) collate Cyrillic_General_CI_AS,  
    ClientKS varchar(32) collate Cyrillic_General_CI_AS,  
    ClientBIC varchar(32) collate Cyrillic_General_CI_AS,  
    ClientOKOHX varchar(100) collate Cyrillic_General_CI_AS,  
    ClientRS varchar(32) collate Cyrillic_General_CI_AS,  
    ClientBank varchar(255) collate Cyrillic_General_CI_AS,  
    guidClient uniqueidentifier,  
    SellerName varchar(255) collate Cyrillic_General_CI_AS,  
    SellerNameFull varchar(255) collate Cyrillic_General_CI_AS,  
    SellerAlternativeName varchar(255) collate Cyrillic_General_CI_AS,  
    SellerUNN varchar(20) collate Cyrillic_General_CI_AS,  
    SellerAdress varchar(255) collate Cyrillic_General_CI_AS,  
    SellerRS varchar(32) collate Cyrillic_General_CI_AS,  
    SellerBank varchar(255) collate Cyrillic_General_CI_AS,  
    SellerTel varchar(150) collate Cyrillic_General_CI_AS,  
    SellerFax varchar(150) collate Cyrillic_General_CI_AS,  
    SellerEMail varchar(50) collate Cyrillic_General_CI_AS,  
    SellerSite varchar(50) collate Cyrillic_General_CI_AS,  
    SellerOKOHX varchar(100) collate Cyrillic_General_CI_AS,  
    SellerOKPO varchar(100) collate Cyrillic_General_CI_AS,  
    SellerOGRN varchar(64) collate Cyrillic_General_CI_AS,  
    SellerKS varchar(32) collate Cyrillic_General_CI_AS,  
    SellerBIC varchar(32) collate Cyrillic_General_CI_AS,  
    SellerKPP varchar(50) collate Cyrillic_General_CI_AS,  
    SellerAccountantName varchar(64) collate Cyrillic_General_CI_AS,  
    SellerChiefName varchar(64) collate Cyrillic_General_CI_AS,  
    SellerCertificateNDS varchar(255) collate Cyrillic_General_CI_AS,  
    ShipperName varchar(255) collate Cyrillic_General_CI_AS,  
    ShipperChiefName varchar(255) collate Cyrillic_General_CI_AS,  
    -- Тех.компания  
    TechCompanyName            varchar(255) collate Cyrillic_General_CI_AS,  
    TechCompanyNameFull        varchar(255) collate Cyrillic_General_CI_AS,  
    TechCompanyAlternativeName varchar(255) collate Cyrillic_General_CI_AS,  
    TechCompanyUNN             varchar(20)  collate Cyrillic_General_CI_AS,  
    TechCompanyCity            varchar(255) collate Cyrillic_General_CI_AS,  
    TechCompanyAdress          varchar(255) collate Cyrillic_General_CI_AS,  
    TechCompanyAdressSubDiv    varchar(255) collate Cyrillic_General_CI_AS,  
    TechCompanyRS              varchar(32)  collate Cyrillic_General_CI_AS,  
    TechCompanyBank            varchar(255) collate Cyrillic_General_CI_AS,  
    TechCompanyTel             varchar(150) collate Cyrillic_General_CI_AS,  
    TechCompanyFax             varchar(150) collate Cyrillic_General_CI_AS,  
    TechCompanyEMail           varchar(50)  collate Cyrillic_General_CI_AS,  
    TechCompanySite            varchar(50)  collate Cyrillic_General_CI_AS,  
    TechCompanyOKOHX           varchar(100) collate Cyrillic_General_CI_AS,  
    TechCompanyOKPO            varchar(100) collate Cyrillic_General_CI_AS,  
    TechCompanyOGRN            varchar(64)  collate Cyrillic_General_CI_AS,  
    TechCompanyKS              varchar(32)  collate Cyrillic_General_CI_AS,  
    TechCompanyBIC             varchar(32)  collate Cyrillic_General_CI_AS,  
    TechCompanyKPP             varchar(50)  collate Cyrillic_General_CI_AS,  
  
    ShiperName varchar(128) collate Cyrillic_General_CI_AS,  
    SubDivisionAddress varchar(255) collate Cyrillic_General_CI_AS,  
    ConsigneeNameFull varchar(255) collate Cyrillic_General_CI_AS,  
    ConsigneeAdress   varchar(255) collate Cyrillic_General_CI_AS,  
    ConsigneeUNN      varchar(20)  collate Cyrillic_General_CI_AS,  
    PriceS         decimal(13, 2),  
    PriceM2WithNDS decimal(13, 2),  
    PriceOfUnit    decimal(13, 2),                         -- Цена без НДС  
    PriceWithNDS   decimal(13, 2),                         -- Сумма по позиции с НДС  
    NDS            decimal(13, 2),  
    SumNoNDS       decimal(13, 2),                         -- Сумма без НДС  
    PriceNDS       decimal(13, 2),  
    bShpros bit,  
    Mass float,  
    MassSum float,  
    Num     int,  
    Unit varchar(5) collate Cyrillic_General_CI_AS,  
    Tax_rate varchar(2) collate Cyrillic_General_CI_AS,  
    nCount         int,  
    nCountPos      int,  
    nCountArea     float,                                     -- Количество / площадь по накладной в зависимости от вида измерения позиции накладной  
    nCountAreaOriginal  float,  
    GPName         varchar(255) collate Cyrillic_General_CI_AS,  
    GPNameMark     varchar(255) collate Cyrillic_General_CI_AS,  
    GPNameEng      varchar(255) collate Cyrillic_General_CI_AS,  
    GPName_FromFieldProject varchar(255) collate Cyrillic_General_CI_AS,  
    GPName_Common           varchar(255) collate Cyrillic_General_CI_AS,  
    Width  varchar(8) collate Cyrillic_General_CI_AS,  
    Height varchar(8) collate Cyrillic_General_CI_AS,  
    Area float,  
    IsPriceByCount bit,  
    CamCountStr varchar(3) collate Cyrillic_General_CI_AS,  
    Name varchar(32) collate Cyrillic_General_CI_AS,  
    Pricekvm decimal(13, 2),  
    Thickness varchar(3) collate Cyrillic_General_CI_AS,  
    Commentary varchar(255) collate Cyrillic_General_CI_AS,  
    ProductName varchar(50) collate Cyrillic_General_CI_AS,  
    DepotName varchar(100) collate Cyrillic_General_CI_AS,  
    DepotSubDivisionTel varchar(150) collate Cyrillic_General_CI_AS,  
    ManagerName varchar(50) collate Cyrillic_General_CI_AS,  
    SubDivisionManagerName varchar(50) collate Cyrillic_General_CI_AS,  
    AddTo_NumInvoice       varchar(16) collate Cyrillic_General_CI_AS,  
    OrderToSign            varchar(128) collate Cyrillic_General_CI_AS,  
    CurSaldo float,  
    sign_CurSaldo float,  
    Code    varchar(11)  collate Cyrillic_General_CI_AS,   -- STIS 2015-09-11 c 9 на 11  
    Manager varchar(128) collate Cyrillic_General_CI_AS,  
    Tel     varchar(64)  collate Cyrillic_General_CI_AS,  
    CamCount tinyint,  
    TypeOper int,  
    idShip int,  
    HeaderTN varchar(512) collate Cyrillic_General_CI_AS,  
    Signature_ShiperPost varchar(64) collate Cyrillic_General_CI_AS,  
    ProductType int,  
    ProductType_Project int,  
    guidProduct_Project uniqueidentifier,  
    ContractName varchar(128) collate Cyrillic_General_CI_AS,  
    ContractNum  varchar(32)  collate Cyrillic_General_CI_AS,  
    ContractDate datetime,  
    CommentClient varchar(128) collate Cyrillic_General_CI_AS,  
    NumInvoice    varchar(50)  collate Cyrillic_General_CI_AS,  
    TransportDate datetime,  
    idTransport   int,  
    guidTransport uniqueidentifier,  
    RasInfoText varchar(128) collate Cyrillic_General_CI_AS,  
    RasLength float,  
    Unit_Code_OKEI varchar(50) collate Cyrillic_General_CI_AS,  
    PriceNoNDS decimal(13, 2),  
    TaskCommentary varchar(255) collate Cyrillic_General_CI_AS,  
    FormTypeName varchar(255) collate Cyrillic_General_CI_AS,  
    idFormType   int,  
    NamePlot varchar(255) collate Cyrillic_General_CI_AS,  
    NameTemplate varchar(255) collate Cyrillic_General_CI_AS,  
    SellerShiperName varchar(255) collate Cyrillic_General_CI_AS,  
    SellerShiperPost     varchar(255) collate Cyrillic_General_CI_AS,  
    DriverFromShip       varchar(255) collate Cyrillic_General_CI_AS,  
    BarCodeClient        varchar(64)  collate Cyrillic_General_CI_AS,  
  
    CarDriver            varchar(255) collate Cyrillic_General_CI_AS,  
    CarName              varchar(255) collate Cyrillic_General_CI_AS,  
    CarGosNumber         varchar(255) collate Cyrillic_General_CI_AS,  
    CarLicense           varchar(255) collate Cyrillic_General_CI_AS,  
      
    LogistFromShip           varchar(128) collate Cyrillic_General_CI_AS,  
    ClientDriverName         varchar(64)  collate Cyrillic_General_CI_AS,  
    ClientTransportGosNumber varchar(32)  collate Cyrillic_General_CI_AS  
  )  
*/  
  -- Загрузим все СП, которые лежат в отгрузке.  
  --insert into #Temp  
  select  
    1 as forCount,  
  
--    T.ID as idTask,  
  case when @bUnionRejectWithFather = 0  
      then T.ID   
      else isnull(P_F.idTask, T.ID)  
    end as idTask,  
  
    P.ID as idProject,  
    IsNull(T.idTaskType, 1) as idTaskType,  
    IsNull(TT.Name, '')     as TaskTypeName,  
    T.Num as TaskNum,  
    T.AccountNum,  
    T.Date as TaskDate,  
    IsNull(T.ClientNum, '') as ClientNum,  
    case when Len(IsNull(TR.Num, '')) > 0  
         then IsNull(TR.Num, '')  
         else IsNull(T.NumCalcFact, '')  
         end as NumCalcFact,  
    case when Len(IsNull(TR.Num_Dealer, '')) > 0  
         then IsNull(TR.Num_Dealer, '')  
         else IsNull(T.NumCalcFact_Dealer, '')  
         end as NumCalcFact_Dealer,  
    SH.Date as DateComplete,  
    IsNull(T.Komission, '') as Komission,  
    T.DatePayDoc,  
    IsNull(C.Name, '') as ClientName,  
    IsNull(C.NameFull, '') as ClientNameFull,  
    IsNull(C.Adress, '') as ClientAdress,  
    IsNull(C.AdressSubDiv, '') as AdressSubDiv,  
    IsNull(C.Tel, '') as ClientTel,  
    IsNull(C.OKPO, '') as ClientOKPO,  
    IsNull(C.UNN, '') as ClientUNN,  
    IsNull(C.KPP, '') as ClientKPP,  
    IsNull(CB_C.KS, '') as ClientKS,  
    IsNull(BK_C.BIC, '') as ClientBIC,  
    IsNull(C.OKOHX, '') as ClientOKOHX,  
    IsNull(CB_C.RS, '') as ClientRS,  
    IsNull(BK_C.Name, '') as ClientBank,  
    C.GUID                as guidClient,  
    IsNull(S.Name, '') as SellerName,  
    IsNull(S.NameFull, '') as SellerNameFull,  
    IsNull(S.AlternativeName, '') as SellerAlternativeName,  
    IsNull(S.UNN, '') as SellerUNN,  
    IsNull(S.Adress, '') as SellerAdress,  
    IsNull(CB_S.RS, '') as SellerRS,  
    IsNull(BK_S.Name, '') as SellerBank,  
    IsNull(S.Tel, '') as SellerTel,  
    IsNull(S.Fax, '') as SellerFax,  
    IsNull(S.eMail, '') as SellerEMail,  
    IsNull(S.Site, '')  as SellerSite,  
    IsNull(S.OKOHX, '') as SellerOKOHX,  
    IsNull(S.OKPO, '') as SellerOKPO,  
    IsNull(S.OGRN, '') as SellerOGRN,  
    IsNull(CB_S.KS, '') as SellerKS,  
    IsNull(BK_S.BIC, '') as SellerBIC,  
    IsNull(S.KPP, '') as SellerKPP,  
    case when IsNull(DSD.bSignatureFromUser, 0) = 1  
         then U.ManagerName  
         else S.AccountantName  
         end as SellerAccountantName,  
    case when IsNull(DSD.bSignatureFromUser, 0) = 1  
         then U.ManagerName  
         else S.ChiefName  
         end as SellerChiefName,  
    S.CertificateNDS as SellerCertificateNDS,  
    Shipper.Name               as ShipperName,  
    Shipper.ChiefName          as ShipperChiefName,  
    Shipper.Adress             as ShipperAdress,  
  
    -- Тех.компания  
    IsNull(TC.Name,            '')  as TechCompanyName,  
    IsNull(TC.NameFull,        '')  as TechCompanyNameFull,  
    IsNull(TC.AlternativeName, '')  as TechCompanyAlternativeName,  
    IsNull(TC.UNN,             '')  as TechCompanyUNN,  
    IsNull(TC.City,            '')  as TechCompanyCity,  
    IsNull(TC.Adress,          '')  as TechCompanyAdress,  
    IsNull(TC.AdressSubDiv,    '')  as TechCompanyAdressSubDiv,  
  ( select top 1 IsNull(RS, '') from ClientBank where bDef = 1 and TC.ID = idClient )   
                                    as TechCompanyRS,  
  ( select top 1 IsNull(Name, '')   
    from Bank   
      inner join ClientBank on Bank.ID = ClientBank.idBank  
    where bDef = 1 and TC.ID = idClient   
  )                                 as TechCompanyBank,  
    IsNull(TC.Tel,             '')  as TechCompanyTel,  
    IsNull(TC.Fax,             '')  as TechCompanyFax,  
    IsNull(TC.eMail,           '')  as TechCompanyEMail,  
    IsNull(TC.Site,            '')  as TechCompanySite,  
    IsNull(TC.OKOHX,           '')  as TechCompanyOKOHX,  
    IsNull(TC.OKPO,            '')  as TechCompanyOKPO,  
    IsNull(TC.OGRN,            '')  as TechCompanyOGRN,  
  ( select top 1 IsNull(KS, '') from ClientBank where bDef = 1 and TC.ID = idClient )   
                                    as TechCompanyKS,  
  ( select top 1 IsNull(BIC, '')   
    from Bank   
      inner join ClientBank on Bank.ID = ClientBank.idBank  
    where bDef = 1 and TC.ID = idClient   
  )                                 as TechCompanyBIC,  
    IsNull(TC.KPP,             '')  as TechCompanyKPP,  
  
    S.ShiperName,  
    IsNull(S.AdressSubDiv, '') as SubDivisionAddress,  
    IsNull(CSG.NameFull, CSG.Name) as ConsigneeNameFull,  
    --IsNull(CSG.Adress, C.Adress)   as ConsigneeAdress,  
    case  
      when isNull(T.AddressDelivery, '') != '' then T.AddressDelivery  
      when isNull(DA.Name, '')           != '' then DA.Name  
      when isNull(CSG.AdressSubDiv, '')  != '' then CSG.AdressSubDiv  
      when isNull(CSG.Adress, ''  )      != '' then CSG.Adress  
      else null  
    end as ConsigneeAdress,  
    IsNull(CSG.UNN, '')            as ConsigneeUNN,  
    cast(P.PriceS as decimal(13, 2)) as PriceS,                                        -- цена за шпросы  
  
    cast(  
  case when @bUnionRejectWithFather = 0  
   then   
      case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNDS/P.Area   else P.PriceNDS   end  
   else   
      case when IsNull(isnull(P_F.IsPriceByCount, P.IsPriceByCount), 0) = 1 and CPU.d_iNum = 0 and ISNULL(isnull(P_F.Area, P.Area), 0) > 0   
       then isnull(P_F.PriceNDS, P.PriceNDS)/isnull(P_F.Area, P.Area)   
       else isnull(P_F.PriceNDS, P.PriceNDS)     
     end  
    end as decimal(13, 2)) as PriceM2WithNDS,    
  
    cast(  
  case when @bUnionRejectWithFather = 0  
   then   
      case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNoNDS/P.Area else P.PriceNoNDS end   
   else   
      case when IsNull(isnull(P_F.IsPriceByCount, P.IsPriceByCount), 0) = 1 and CPU.d_iNum = 0 and ISNULL(isnull(P_F.Area, P.Area), 0) > 0   
        then  isnull(P_F.PriceNoNDS, P.PriceNoNDS)/isnull(P_F.Area, P.Area)  
         else isnull(P_F.PriceNoNDS, P.PriceNoNDS)  
    end   
  end as decimal(13, 2)) as PriceOfUnit,   -- В 11 графе выводим цену за М2 без НДС.  
  
    cast(  
  case when @bUnionRejectWithFather = 0  
   then   
      sum(P.SumWithNDS / case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end)   
   else  
      sum(isnull(P_F.SumWithNDS, P.SumWithNDS) / case IsNull( isnull(P_F.nCount, P.nCount), 0) when 0 then 1 else isnull(P_F.nCount, P.nCount) end)   
  end as decimal(13, 2)) as PriceWithNDS,  
  
    cast(  
  case when @bUnionRejectWithFather = 0  
   then   
    sum(P.SumNDS /     case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end)  
   else  
    sum(isnull(P_F.SumNDS, P.SumNDS) / case isnull(isnull(P_F.nCount, P.nCount) , 0) when 0 then 1 else isnull(P_F.nCount, P.nCount) end)  
  end as decimal(13, 2)) as NDS,  
  
    cast(  
  case when @bUnionRejectWithFather = 0  
   then    
    sum(P.SumNoNDS /   case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end)   
   else  
    sum(isnull(P_F.SumNoNDS, P.SumNoNDS) / case IsNull(isnull(P_F.nCount, P.nCount), 0) when 0 then 1 else  isnull(P_F.nCount, P.nCount) end)   
  end as decimal(13, 2)) as SumNoNDS,  
  
    cast(  
  case when @bUnionRejectWithFather = 0  
   then   
        case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNDS/P.Area   else P.PriceNDS   end   
   else  
     case when IsNull(isnull(P_F.IsPriceByCount, P.IsPriceByCount), 0) = 1 and CPU.d_iNum = 0 and ISNULL(isnull(P_F.Area, P.Area), 0) > 0   
      then isnull(P_F.PriceNDS, P.PriceNDS) / isnull(P_F.Area, P.Area)  
      else isnull(P_F.PriceNDS, P.PriceNDS)     
     end   
  end  
  as decimal(13, 2)) as PriceNDS,  
  
  
    IsNull(P.bShpros, 0) as bShpros,  
    sum(P.Mass) as Mass,  
    sum(P.Mass)          as MassSum, -- Для совместимости с w_Transport.  
    P.Num,  
    case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 1  
         then 'шт'  
         else 'м2' -- TODO: Взять из БД  
    end as Unit,  
    NDS.NDS as Tax_rate,  
    count(*) as nCount,  
    count(*) as nCountPos, -- Для совместимости с w_Transport.  
    case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 1  
         then count(*)  
         else sum(P.Area)  
    end as nCountArea,  
    sum(P.Area) as nCountAreaOriginal,  
    case  
      when PD.Type != 1  
       then PD.Name + P.GPName  
      else dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name,   
                                       dbo.f_SupressCoveringMark(P.GPName, CCover.d_iNum),  
                                       P.CamCount, P.Thickness, P.Width, P.Height,  
                                       IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), P.ID, P.Num, 0)  
    end as GPName,  
    dbo.f_GetGPFormulaByMark(P.ID, 0, '+', '-') as GPNameMark,  
    left(dbo.f_RUS_To_Eng(P.GPName), 128)  as GPNameEng,  
    P.GPName                               as GPName_FromFieldProject,  
    dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name,   
                                       dbo.f_SupressCoveringMark(P.GPName, CCover.d_iNum),  
                                       P.CamCount, P.Thickness, P.Width, P.Height,  
                                       IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), P.ID, P.Num, 0) as GPName_Common,  
    cast(P.Width  as varchar(8)) as Width,  
    cast(P.Height as varchar(8)) as Height,  
    P.Area as Area,  
    IsNull(P.IsPriceByCount, 0) as IsPriceByCount,  
    case P.CamCount  
         when 1 then 'СПО'  
         when 2 then 'СПД'  
         else ''  
    end as CamCountStr,  
    case P.CamCount  
         when 1 then 'Стеклопакет однокамерный'  
         when 2 then 'Стеклопакет двухкамерный'  
         else 'Стекло в нарезку'  
    end                                        as Name,       -- Для совместимости с w_Invoice_4  
    P.PriceByM                                 as Pricekvm,   -- В отчете "Счет-договор" (Task_Agreement_Common_2.rpt) используется поле Pricekvm (цена за 1 кв. м.), которого нет. Добавляю.  
    cast(IsNull(P.Thickness, 0) as varchar(3)) as Thickness,  
    IsNull(P.Commentary, '') as Commentary,  
    PD.Name as ProductName,  
    IsNull(DSD.Name, '') as DepotName,  
    IsNull(DSD.Tel, '') as DepotSubDivisionTel,  
    IsNull(DSD.ManagerName,      '') as ManagerName,            -- Для обратной совместимости (напр. с v_InvoiceGroupByGPName)  
    IsNull(DSD.ManagerName, '') as SubDivisionManagerName,  
    IsNull(DSD.AddTo_NumInvoice, '') as AddTo_NumInvoice,  
    IsNull(USA.OrderToSign, USign.OrderToSign) as OrderToSign,  
    0 as CurSaldo,  
    0 as sign_CurSaldo,  
    case P.CamCount  
      when 0 then '00000000037'  -- STIS 2015-09-10   
      when 1 then '00000000038'  
      when 2 then '00000000039'  
      else        ''  
    end as Code,  
    IsNull(U.ManagerName, '') as Manager,  
    IsNull(U.Tel, '') as Tel,  
    P.CamCount,  
    case when P.CamCount > 0 then 0  -- СП  
    else   
      case when IsNull(P.Complex, 0) & 524288 = 524288 then 4 -- Триплекс собственного производства  
           when IsNull(P.Complex, 0) & 1024   = 1024   then 1 -- Триплекс  
           when IsNull(P.Complex, 0) & 8192   = 8192   then 2 -- Эмалит  
           when IsNull(P.Complex, 0) & 16     = 16     then 3 -- Закалка  
           else -1                                            -- Нарезка без обработки и услуги  
      end  
    end as TypeOper,  -- Для определения типа в паспорте качества(расширенный) в Остек    
    TR.idShip,  
    IsNull(DSD.HeaderTN, '') as HeaderTN,  
    IsNull(U.Post, '') as Signature_ShiperPost,  
    PD.Type              as ProductType,  
    IsNull(PDP.Type, 0)  as ProductType_Project,  
    PDP.GUID             as guidProduct_Project,  
    IsNull(CC.Name, '')         as ContractName,  
    IsNull(CC.ContractNum, '')  as ContractNum,  
    IsNull(CC.Date, '')         as ContractDate,  
    IsNull(P.CommentClient, '') as CommentClient,  
    TR.Num as NumInvoice,  
    TR.TransportDate,  
    TR.ID                        as idTransport,  
    TR.GUID                      as guidTransport,  
    dbo.f_GetGPRasInfo(P.ID, P.bShpros) as RasInfoText,  
    (select sum(LengReal) from RasShrink where idProject = P.ID) as RasLength,  
    case   
      when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 1 or P.Area = 0  
      then UCount.Code_OKEI  
      else UArea.Code_OKEI  
    end as Unit_Code_OKEI,  
    cast(P.PriceNoNDS as decimal(13, 2)) as PriceNoNDS,  
    IsNull(T.Commentary, '') as TaskCommentary,  
    IsNull(FT.Name, '') as FormTypeName,  
    FT.ID               as idFormType,  
    case when IsNull(P.bPlot, 0) = 0  
      then ''  
      else 'Черт'  
    end as NamePlot,  
    case when IsNull(P.bTemplate, 0) = 0  
      then ''  
      else 'Шабл'  
    end as NameTemplate,  
    case   
      when S.idPersonnel_Shipper is not null  
      then (select Name from Personnel where ID = S.idPersonnel_Shipper)  
      else IsNull(S.ShiperName, '')  
    end as SellerShiperName,  
  
    case   
      when S.idPersonnel_Shipper is not null  
      then (select top 1 PersonnelPost.Name   
            from PersonnelPost  
            inner join Personnel on Personnel.idPersonnelPost = PersonnelPost.ID  
           where Personnel.ID = S.idPersonnel_Shipper)  
      else 'Ответственный за погрузку'  
    end as SellerShiperPost,  
    IsNull(SD.Name, '') as DriverFromShip,  
    P.BarCodeClient,  
  
    TripTransport.Driver                    as CarDriver,  
    TripTransport.Name                      as CarName,  
    TripTransport.GosNumber                 as CarGosNumber,  
    TripTransport.License                   as CarLicense,  
    IsNull(SL.Name, '')                     as LogistFromShip,  
    IsNull(SH.ClientDriverName, '')         as ClientDriverName,  
    IsNull(SH.ClientTransportGosNumber, '') as ClientTransportGosNumber,  
    IsNull(PO.BarCode, '')                  as PyramidName  
  -- вставим во временную таблицу  
  into #Temp  
  from Transport TR                                             -- Заголовок части или целовго заказа в отгрузке  
    inner join Ship SH               on SH.ID    = TR.idShip     -- Заголовок отгрузки  
    inner join BarCode B             on B.idTransport = TR.ID  
    inner join Project P             on P.ID     = B.idProject  
    inner join Task T                on T.ID     = P.idTask  
    inner join Product PD            on PD.ID    = P.idProd  
    left  join Product PDP           on PDP.ID   = P.idProduct  
    left  join TaskType TT           on TT.ID    = T.idTaskType  
    left  join FormType FT           on FT.ID    = P.idFormType  
    left  join NDS on NDS.ID   = T.idNDS  
    left  join DeliveryAddress DA    on DA.ID    = T.idDeliveryAddress  
    left  join ClientContract CC     on CC.ID    = T.idClientContract  
    left  join Client C              on C.ID     = T.idClient  
    left  join Client S              on S.ID     = T.idSeller  
    left  join Client TC             on TC.nClientSubType = 1  
    left  join Client Shipper        on Shipper.ID = T.idShipper  
    left  join Client CSG            on CSG.ID   = T.idConsignee  
    left  join ClientBank CB_C       on CB_C.ID  = T.idClientBank_Client  
    left  join Bank BK_C             on BK_C.ID  = CB_C.idBank  
    left  join ClientBank CB_S       on CB_S.ID  = T.idClientBank_Seller  
    left  join Bank BK_S             on BK_S.ID  = CB_S.idBank  
    left  join DepotSubDivision DSD  on DSD.ID   = T.idDepotSubDivision  
    left  join Users U               on U.ID     = TR.idUsers  
    left  join Users USign           on lower(USign.Name) = lower(SYSTEM_USER)    -- Пользователь, который подписывает  
    left  join UsersSignAutority USA on USign.GUID = USA.guidUsers and  
                                        SH.Date   >= USA.DateBegin and  
                                        SH.Date   <= USA.DateEnd  
    left  join Config CF             on CF.Name  = 'FormatTypeOfGPName'  
    --left  join Config CF1           on CF1.Name = 'bCalcFactNumUniqueForShipedTask'  
    left  join Config CPU            on CPU.Name = 'bPriceUnitInCalcFact'  
    left  join Config CCover         on CCover.Name  = 'nGlassMarkCovering'   -- тип маркировки покрытия  
    left  join (select top 1 * from Unit where nTypeUnit = 1) UArea  on UArea.nTypeUnit  = 1  
    left  join (select top 1 * from Unit where nTypeUnit = 2) UCount on UCount.nTypeUnit = 2  
    left  join TripTransport         on TripTransport.ID = SH.idTripTransport  
    left  join Personnel SD          on SD.ID            = SH.idDriver  
    left  join Personnel SL          on SL.ID            = SH.idPersonnel  
  
  left join BarCode B_F on B_F.ID = B.idBarCode_Reject_Father  
    left join Project P_F on P_F.ID = B_F.idProject  
    left join PyramidCompleted PC on PC.ID = B.idPyramidCompleted  
    left join PyramidOut       PO on PO.ID = PC.idPyramidOut  
  
  where  
    TR.idShip = @idShip  
    and PD.Type = case when @bOtherProduction = 1 then PD.Type else 1       end  
    and T.ID    = case when @idTask           = 0 then T.ID    else @idTask end  
  group by  
--    T.ID,  
    case when @bUnionRejectWithFather = 0  
      then T.ID   
      else isnull(P_F.idTask, T.ID )  
    end,  
  
    Shipper.Adress,  
    IsNull(T.idTaskType, 1),  
    IsNull(TT.Name, ''),  
    T.Num,  
    T.AccountNum,  
    T.Date,  
    case when Len(IsNull(TR.Num, '')) > 0  
         then IsNull(TR.Num, '')  
         else IsNull(T.NumCalcFact, '')  
         end,  
    case when Len(IsNull(TR.Num_Dealer, '')) > 0  
         then IsNull(TR.Num_Dealer, '')  
         else IsNull(T.NumCalcFact_Dealer, '')  
         end,  
    IsNull(T.ClientNum, ''),  
    --T.DateComplite,  
    SH.Date,  
    IsNull(T.Komission, ''),  
    T.DatePayDoc,  
    IsNull(C.Name, ''),  
    IsNull(C.NameFull, ''),  
    IsNull(C.Adress, ''),  
    IsNull(C.AdressSubDiv, ''),  
    IsNull(C.Tel, ''),  
    IsNull(C.OKPO, ''),  
    IsNull(C.UNN, ''),  
    IsNull(C.KPP, ''),  
    IsNull(CB_C.KS, ''),  
    IsNull(BK_C.BIC, ''),  
    IsNull(C.OKOHX, ''),  
    T.AddressDelivery,  
    DA.Name,  
    CSG.AdressSubDiv,  
    CSG.Adress,  
    IsNull(CB_C.RS, ''),  
    IsNull(BK_C.Name, ''),  
    C.GUID,  
    IsNull(S.Name, ''),  
    IsNull(S.NameFull, ''),  
    IsNull(S.AlternativeName, ''),  
    IsNull(S.UNN, ''),  
    IsNull(S.Adress, ''),  
    IsNull(CB_S.RS, ''),  
    IsNull(BK_S.Name, ''),  
    IsNull(S.Tel, ''),  
    IsNull(S.Fax, ''),  
    IsNull(S.eMail, ''),  
    IsNull(S.Site, ''),  
    IsNull(S.OKOHX, ''),  
    IsNull(S.OKPO, ''),  
    IsNull(S.OGRN, ''),  
    IsNull(CB_S.KS, ''),  
    IsNull(BK_S.BIC, ''),  
    IsNull(S.KPP, ''),  
    S.CertificateNDS,  
    Shipper.Name,  
    Shipper.ChiefName,  
    TC.ID,  
    TC.Name,             
    TC.NameFull,         
    TC.AlternativeName,  
    TC.UNN,              
    TC.City,             
    TC.Adress,           
    TC.AdressSubDiv,     
    TC.Tel,              
    TC.Fax,              
    TC.eMail,            
    TC.Site,             
    TC.OKOHX,            
    TC.OKPO,             
    TC.OGRN,             
    TC.KPP,              
    case when IsNull(DSD.bSignatureFromUser, 0) = 1  
         then U.ManagerName  
         else S.AccountantName  
         end,  
    case when IsNull(DSD.bSignatureFromUser, 0) = 1  
         then U.ManagerName  
         else S.ChiefName  
         end,  
    S.ShiperName,  
    IsNull(S.AdressSubDiv, ''),  
    IsNull(CSG.NameFull, CSG.Name),  
    IsNull(CSG.Adress, C.Adress),  
    IsNull(CSG.UNN, ''),  
    P.Num,  
    P.ID,  
    P.PriceS,  
    P.PriceNDS,  
    P.bShpros,  
    P.PriceNoNDS,  
    P.GPName,  
    case when PD.Type != 1  
       then PD.Name + P.GPName  
       else left(dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name, P.GPName, P.CamCount, P.Thickness, P.Width, P.Height, IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), P.ID, P.Num, 0), 128)  
       end,  
    cast(P.Width  as varchar(8)),  
    cast(P.Height as varchar(8)),  
    P.Area,  
  
    IsNull(P.IsPriceByCount, 0),  
  isnull(isnull(P_F.IsPriceByCount, P.IsPriceByCount), 0) ,  
   isnull(P_F.Area, P.Area) ,  
   isnull(P_F.PriceNDS, P.PriceNDS),  
  isnull(P_F.PriceNoNDS, P.PriceNoNDS),  
  
    P.PriceByM,  
    cast(IsNull(P.Thickness, 0) as varchar(3)),  
    IsNull(P.Commentary, ''),  
    PD.Name,  
    IsNull(DSD.Name, ''),  
    IsNull(DSD.Tel, ''),  
    IsNull(DSD.ManagerName, ''),  
    IsNull(DSD.AddTo_NumInvoice, ''),  
    IsNull(USA.OrderToSign, USign.OrderToSign),  
    IsNull(U.ManagerName, ''),  
    IsNull(U.Tel, ''),  
    P.CamCount,  
    P.Thickness,  
    P.Width,  
    P.Height,  
    TR.idShip,  
    C.ID,  
    left(dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name, P.GPName, P.CamCount, P.Thickness, P.Width, P.Height, IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), P.ID, P.Num, 0), 128),  
    IsNull(DSD.HeaderTN, ''),  
    IsNull(U.Post, ''),  
    PD.Type,  
    IsNull(PDP.Type, 0),  
    PDP.GUID,  
    IsNull(CC.Name, ''),  
    IsNull(CC.ContractNum, ''),  
    CC.Date,  
    NDS.NDS,  
    CF.d_iNum,  
    CPU.d_iNum,  
    CCover.d_iNum,  
    IsNull(P.CommentClient, ''),  
    P.ComplexText,  
    P.Complex,  
    TR.Num,  
    TR.TransportDate,  
    TR.ID,  
    TR.GUID,  
    UCount.Code_OKEI,  
    UArea.Code_OKEI,  
    IsNull(T.Commentary, ''),  
    IsNull(FT.Name, ''),  
    FT.ID,  
    case when IsNull(P.bPlot, 0) = 0  
      then ''  
      else 'Черт'  
    end,  
    case when IsNull(P.bTemplate, 0) = 0  
      then ''  
      else 'Шабл'  
    end,  
    S.idPersonnel_Shipper,  
    IsNull(SD.Name, ''),  
    P.BarCodeClient,  
  
    TripTransport.Driver,  
    TripTransport.Name,  
    TripTransport.GosNumber,  
    TripTransport.License,  
    IsNull(SL.Name, ''),  
    IsNull(SH.ClientDriverName, ''),  
    IsNull(SH.ClientTransportGosNumber, ''),  
    PO.BarCode  
  
  
  create table #TaskProp  
  (  
    idTask         int,  
    TaskPrice      decimal(18, 2),                             -- Сумма по отгрузке  
    MassPhraseTonn varchar(64) collate Cyrillic_General_CI_AS,  -- [SB] От этого поля можно отказаться, если отчеты перевести в стимул. TTN_1T.mrt обходится без него.  
    MassPhraseKg   varchar(64) collate Cyrillic_General_CI_AS   -- [SB] От этого поля можно отказаться, если отчеты перевести в стимул. TTN_1T.mrt обходится без него.  
  )    
  
  insert into #TaskProp  
  select  
    idTask,  
    sum(round(PriceWithNDS, 2)) as TaskPrice,  
    dbo.MassPhrase(round(sum(Mass),        0), 0) as MassPhraseTonn,  
    dbo.MassPhrase(round(sum(Mass * 1000), 0), 1) as MassPhraseKg  
  from #Temp  
  group by  
    idTask  
      
  -- STIS 2015-09-04 добавлены из таблицы транспорт num,DeliveryNum номера Расходной накладной и счёта фактуры  
select  
    T.*,  
    TP.TaskPrice,  
    TP.MassPhraseKg,  
    TP.MassPhraseTonn,  
    TR.Num         as RashodnayaNakladnaya,  
    TR.DeliveryNum as SchetFaktura,  
    dbo.f_GetShipPyrNameListByPos(T.idProject) as PyrNameList  
  from #Temp T  
    inner join #TaskProp TP   on TP.idTask = T.idTask  
    left  join Transport TR    on TR.idTask = T.idTask  --[SE] Если заказ в нескольких отгрузках, то множатся позиции  
  where  
    IsNull(TR.idShip, @idShip) = @idShip             --[ab]->[se] Может быть так надо было ошибку исправить?  
  
  drop table #TaskProp  
  drop table #Temp  
  
  set nocount off  
end  

go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_Invoice_IZO_Ship_Only.sql'
go

print convert(varchar, getdate(), 20) + ' : start SP\sp_RTB_ProjectCopy.sql'
go

-- ============================================================
-- File: SP\sp_RTB_ProjectCopy.sql
-- ============================================================
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

go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_RTB_ProjectCopy.sql'
go

print convert(varchar, getdate(), 20) + ' : start SP\sp_TTN_Task_MXG_Multi.sql'
go

-- ============================================================
-- File: SP\sp_TTN_Task_MXG_Multi.sql
-- ============================================================
if object_id('dbo.sp_TTN_Task_MXG_Multi', 'P') is not null
  drop procedure dbo.sp_TTN_Task_MXG_Multi
go

create procedure dbo.sp_TTN_Task_MXG_Multi
  @idShip  int,          -- оставлен для совместимости, пока не используется
  @idTasks varchar(max)  -- пример: '22042,22043,22044'
as
begin
  set nocount on

  ---------------------------------------------------------------------------
  -- Разбираем список заказов
  ---------------------------------------------------------------------------
  create table #SelectedTasks
  (
    idTask int not null primary key
  )

  declare
    @TaskList varchar(max),
    @Position int,
    @TaskIDText varchar(50),
    @TaskID int

  set @TaskList = replace(replace(isNull(@idTasks, ''), ';', ','), ' ', '') + ','

  while len(@TaskList) > 0
  begin
    set @Position = charindex(',', @TaskList)

    if @Position = 0
      break

    set @TaskIDText = left(@TaskList, @Position - 1)
    set @TaskList = substring(@TaskList, @Position + 1, len(@TaskList))

    if isNull(@TaskIDText, '') <> ''
    begin
      if @TaskIDText like '%[^0-9]%'
      begin
        raiserror('В списке заказов (idTask) обнаружено некорректное значение: %s', 16, 1, @TaskIDText)
        return
      end

      set @TaskID = cast(@TaskIDText as int)

      if not exists
      (
        select 1
        from #SelectedTasks
        where idTask = @TaskID
      )
      begin
        insert into #SelectedTasks(idTask)
        values(@TaskID)
      end
    end
  end

  if not exists(select 1 from #SelectedTasks)
  begin
    raiserror('Не передано ни одного заказа', 16, 1)
    return
  end

  ---------------------------------------------------------------------------
  -- Основные данные
  ---------------------------------------------------------------------------
  select
    isNull(T.NumCalcFact, '') as TN_Num,
    DSD.AddTo_NumInvoice,
    T.ID as idTask,
    T.idClient,
    T.Date as DateCreate,
    T.DateComplite as DateShiping,
    T.AccountNum,

    -- Продавец
    isNull(S.Name, '') as SellerNameShort,
    isNull(S.NameFull, S.Name) as SellerName,
    S.AdressSubDiv as SellerAddress,
    S.Tel as SellerTel,
    S.ShiperName as SellerShiperName,
    S.UNN as SellerUNN,
    S.OKPO as SellerOKPO,
    CB_S.RS as SellerRS,
    BK_S.Name as SellerBank,
    CB_S.KS as SellerKS,

    -- Клиент
    isNull(C.NameFull, C.Name) as ClientName,
    isNull(C.Adress, '') as ClientAddress,
    C.Tel as ClientTel,
    C.ShiperName as ClientShiperName,
    C.UNN as ClientUNN,

    case
      when T.AddressDelivery is not null
       and T.AddressDelivery <> ''
        then T.AddressDelivery

      when DAC.Name is not null
       and DAC.Name <> ''
        then DAC.Name

      when CSG.AdressSubDiv is not null
       and CSG.AdressSubDiv <> ''
        then CSG.AdressSubDiv

      when CSG.Adress is not null
       and CSG.Adress <> ''
        then CSG.Adress

      else null
    end as ClientAddressDelivery,

    -- Грузоотправитель
    isNull(SHP.NameFull, SHP.Name) as ShiperName,
    isNull(DSD.Address, '') as ShiperAddress,
    isNull(DSD_Ship.Address, '') as SubDivisionAddress_Ship,
    SHP.Tel as ShiperTel,
    SHP.ShiperName as ShiperShiperName,
    SHP.Name as ShiperNameSmall,

    -- Грузополучатель
    isNull(CSG.NameFull, CSG.Name) as ConsigneeName,
    isNull(DAC.Name, CSG.AdressSubDiv) as ConsigneeAddress,
    CSG.Tel as ConsigneeTel,

    P.CamCount,

    case P.CamCount
      when 1 then 'Стеклопакет однокамерный'
      when 2 then 'Стеклопакет двухкамерный'
      else        'Стекло в нарезку'
    end as ProductionName,

    count(*) as nCount,
    sum(P.Mass) as SumMass,
    T.Area as TotalArea,

    sum
    (
      P.PriceNoNDS * NDS.NDS / 100.0 +
      P.PriceNoNDS
    ) as PriceWithNDS,

    U.ManagerName as TTN_SignatureName,

    isNull
    (
      SLA.Address,
      isNull(S.Adress, '')
    ) as Address,

    isNull(Autor.ManagerName, UT.ManagerName) as TaskAutor,
    isNull(Autor.Tel, UT.Tel) as AutorTel,

    USA.InvoiceResponsName_1,
    USA.InvoiceOrderPost_1,
    USA.InvoiceOrderNum_1,
    USA.InvoiceOrderDate_1,

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

    DSD.Tel as DepotSubDivisionTel

  into #tmp

  from BarCode B
    left join Transport TR on TR.ID = B.idTransport
    inner join Project P on P.ID = B.idProject
    inner join Task T on T.ID = P.idTask
    inner join #SelectedTasks ST on ST.idTask = T.ID
    inner join Product PD on PD.ID = P.idProd
    left join Ship SH on SH.ID = TR.idShip
    left join NDS on NDS.ID = T.idNDS
    left join Client C on C.ID = T.idClient
    left join DeliveryAddress DAC on DAC.ID = T.idDeliveryAddress
    left join Client S on S.ID = T.idSeller
    left join ClientBank CB_S on CB_S.ID = T.idClientBank_Seller
    left join Bank BK_S on BK_S.ID = CB_S.idBank
    left join Client SHP on SHP.ID = T.idShipper
    left join Client CSG on CSG.ID = T.idConsignee
    left join DepotSubDivision DSD on DSD.ID = T.idDepotSubDivision
    left join DepotSubDivision DSD_Ship on DSD_Ship.ID = T.idDepotSubDivision_Shipper
    outer apply
    (
      select top 1
        USAA.InvoiceResponsName_1,
        USAA.InvoiceOrderPost_1,
        USAA.InvoiceOrderNum_1,
        USAA.InvoiceOrderDate_1,

        USAA.InvoiceResponsName_2,
        USAA.InvoiceOrderPost_2,
        USAA.InvoiceOrderNum_2,
        USAA.InvoiceOrderDate_2,

        USAA.InvoiceResponsName_3,
        USAA.InvoiceOrderPost_3,
        USAA.InvoiceOrderNum_3,
        USAA.InvoiceOrderDate_3,

        USAA.InvoiceResponsName_4,
        USAA.InvoiceOrderPost_4,
        USAA.InvoiceOrderNum_4,
        USAA.InvoiceOrderDate_4

      from UsersSignAutority USAA

      where
        USAA.guidDepotSubDivision = DSD.GUID
        and T.DateComplite >= USAA.DateBegin
        and
        (
          T.DateComplite <= USAA.DateEnd
          or USAA.DateEnd is null
        )
    ) USA

    left join Users U on U.ID = TR.idUsers
    left join Users UT on UT.ID = T.idUsers
    left join Users Autor on Autor.ID = C.idUsers_PrimaryManager
    left join Config CF on CF.Name = 'FormatTypeOfGPName'
    left join ClientLegalAddress SLA on SLA.idClient = T.idSeller
                                 and T.DateComplite >= SLA.DateBegin
     and
     (
       T.DateComplite <= SLA.DateEnd
       or SLA.DateEnd is null
     )
  where PD.Type in (1, 2)
  group by
    TR.Num,
    T.NumCalcFact,
    T.ID,
    T.idClient,
    T.Date,
    SH.Date,
    T.DateComplite,
    T.AccountNum,

    S.Name,
    isNull(S.NameFull, S.Name),
    S.AdressSubDiv,
    S.Tel,
    S.ShiperName,
    S.UNN,
    S.OKPO,

    CB_S.RS,
    BK_S.Name,
    CB_S.KS,

    isNull(C.NameFull, C.Name),
    isNull(C.Adress, ''),
    C.Tel,
    C.ShiperName,
    C.UNN,

    CSG.Adress,
    CSG.AdressSubDiv,
    DAC.Name,
    T.AddressDelivery,

    isNull(SHP.NameFull, SHP.Name),
    SHP.AdressSubDiv,
    SHP.Tel,
    SHP.ShiperName,
    SHP.Name,

    isNull(CSG.NameFull, CSG.Name),
    isNull(DAC.Name, CSG.AdressSubDiv),
    CSG.Tel,

    T.Area,
    P.CamCount,
    U.ManagerName,

    isNull(Autor.ManagerName, UT.ManagerName),
    isNull(Autor.Tel, UT.Tel),

    NDS.NDS,

    isNull(SLA.Address, isNull(S.Adress, '')),

    DSD.AddTo_NumInvoice,

    USA.InvoiceResponsName_1,
    USA.InvoiceOrderPost_1,
    USA.InvoiceOrderNum_1,
    USA.InvoiceOrderDate_1,

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

    DSD.Tel,
    isNull(DSD.Address, ''),
    isNull(DSD_Ship.Address, '')

  ---------------------------------------------------------------------------
  -- Список позиций отдельно для каждого заказа
  ---------------------------------------------------------------------------
  create table #ProductPositions
  (
    idTask int,
    ProductDescription varchar(max) collate Cyrillic_General_CI_AS
  )

  declare
    @idTask_Cur int,
    @productDesc varchar(max)

  declare curProductPositions cursor local fast_forward for
    select distinct idTask
    from #tmp
    order by idTask

  open curProductPositions

  fetch next from curProductPositions into @idTask_Cur

  while @@fetch_status = 0
  begin
    set @productDesc = null

    select
      @productDesc =
        coalesce(@productDesc + '; ', '') +
        case
          when P.CamCount = 0 then 'Стекло '
          else 'Стеклопакет '
        end +
        P.GPName + ' ' +
        ltrim(str(P.Width)) + ' x ' +
        ltrim(str(P.Height)) +

        case
          when P.bShpros <> 0
            then
              ' ' +
              dbo.f_GetGPRasInfo(P.ID, P.bShpros) +
              ' ' +
              ltrim
              (
                str
                (
                  (
                    select sum(RS.LengReal)
                    from RasShrink RS
                    where RS.idProject = P.ID
                  )
                )
              ) +
              'мм'
          else ''
        end +

        ', ' +
        ltrim(str(P.nCount)) +
        ' шт.'

    from Project P

    where P.idTask = @idTask_Cur

    order by P.ID

    insert into #ProductPositions
    (
      idTask,
      ProductDescription
    )
    values
    (
      @idTask_Cur,
      @productDesc
    )

    fetch next from curProductPositions into @idTask_Cur
  end

  close curProductPositions
  deallocate curProductPositions

  ---------------------------------------------------------------------------
  -- Общее наименование продукции для каждого заказа
  ---------------------------------------------------------------------------
  create table #TaskProp
  (
    idTask int,
    ProductionName varchar(128) collate Cyrillic_General_CI_AS
  )

  declare @sProductionName varchar(128)

  declare curTask cursor local fast_forward for
    select distinct idTask
    from #tmp
    order by idTask

  open curTask

  fetch next from curTask into @idTask_Cur

  while @@fetch_status = 0
  begin
    set @sProductionName = ''

    select
      @sProductionName =
        @sProductionName + ', ' + ProductionName

    from
    (
      select distinct
        ProductionName,
        CamCount

      from #tmp

      where idTask = @idTask_Cur
    ) X

    order by CamCount

    if len(@sProductionName) > 1
    begin
      set @sProductionName =
        right
        (
          rtrim(@sProductionName),
          len(rtrim(@sProductionName)) - 1
        )
    end

    insert into #TaskProp
    (
      idTask,
      ProductionName
    )
    values
    (
      @idTask_Cur,
      @sProductionName
    )

    fetch next from curTask into @idTask_Cur
  end

  close curTask
  deallocate curTask

  ---------------------------------------------------------------------------
  -- Итог отчёта
  ---------------------------------------------------------------------------
  select
    TN_Num,
    AddTo_NumInvoice,

    T.idTask,
    T.idClient,

    DateCreate,
    DateShiping,
    AccountNum,

    SellerNameShort,
    SellerName,
    SellerAddress,
    SellerTel,
    SellerShiperName,
    SellerUNN,
    SellerOKPO,
    SellerRS,
    SellerBank,
    SellerKS,

    ClientName,
    ClientAddress,
    ClientTel,
    ClientShiperName,
    ClientAddressDelivery,
    ClientUNN,

    ShiperName,
    ShiperAddress,
    SubDivisionAddress_Ship,
    ShiperTel,
    ShiperShiperName,
    ShiperNameSmall,

    ConsigneeName,
    ConsigneeAddress,
    ConsigneeTel,

    TP.ProductionName,
    PP.ProductDescription as ProductPositions,

    sum(nCount) as nCount,
    sum(SumMass) as SumMass,

    TotalArea,

    sum(PriceWithNDS) as PriceWithNDS,

    TTN_SignatureName,
    TaskAutor,
    AutorTel,

    dbo.RubPhrase
    (
      sum(PriceWithNDS)
    ) as PricePhrase,

    dbo.MassPhrase
    (
      round(sum(SumMass), 0),
      0
    ) as MassPhraseTonn,

    dbo.MassPhrase
    (
      round(sum(SumMass * 1000), 0),
      1
    ) as MassPhraseKg,

    replace
    (
      dbo.MassPhrase
      (
        round(sum(SumMass), 0) * 1000,
        1
      ),
      ' 0 г',
      ''
    ) as MassPhraseKgOnly,

    Address,

    InvoiceResponsName_1,
    InvoiceOrderPost_1,
    InvoiceOrderNum_1,
    InvoiceOrderDate_1,

    InvoiceResponsName_2,
    InvoiceOrderPost_2,
    InvoiceOrderNum_2,
    InvoiceOrderDate_2,

    InvoiceResponsName_3,
    InvoiceOrderPost_3,
    InvoiceOrderNum_3,
    InvoiceOrderDate_3,

    InvoiceResponsName_4,
    InvoiceOrderPost_4,
    InvoiceOrderNum_4,
    InvoiceOrderDate_4,

    DepotSubDivisionTel

  from #tmp T
    inner join #TaskProp TP on TP.idTask = T.idTask
    left join #ProductPositions PP on PP.idTask = T.idTask

  group by
    TN_Num,
    AddTo_NumInvoice,

    T.idTask,
    T.idClient,

    DateCreate,
    DateShiping,
    AccountNum,

    SellerNameShort,
    SellerName,
    SellerAddress,
    SellerTel,
    SellerShiperName,
    SellerUNN,
    SellerOKPO,
    SellerRS,
    SellerBank,
    SellerKS,

    ClientName,
    ClientAddress,
    ClientTel,
    ClientShiperName,
    ClientAddressDelivery,
    ClientUNN,

    ShiperName,
    ShiperAddress,
    SubDivisionAddress_Ship,
    ShiperTel,
    ShiperShiperName,
    ShiperNameSmall,

    ConsigneeName,
    ConsigneeAddress,
    ConsigneeTel,

    TP.ProductionName,
    PP.ProductDescription,

    TotalArea,

    TTN_SignatureName,
    TaskAutor,
    AutorTel,
    Address,

    InvoiceResponsName_1,
    InvoiceOrderPost_1,
    InvoiceOrderNum_1,
    InvoiceOrderDate_1,

    InvoiceResponsName_2,
    InvoiceOrderPost_2,
    InvoiceOrderNum_2,
    InvoiceOrderDate_2,

    InvoiceResponsName_3,
    InvoiceOrderPost_3,
    InvoiceOrderNum_3,
    InvoiceOrderDate_3,

    InvoiceResponsName_4,
    InvoiceOrderPost_4,
    InvoiceOrderNum_4,
    InvoiceOrderDate_4,

    DepotSubDivisionTel

  order by
    T.idTask

  drop table #TaskProp
  drop table #tmp
  drop table #ProductPositions
  drop table #SelectedTasks

  set nocount off
end
go

go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_TTN_Task_MXG_Multi.sql'
go

print convert(varchar, getdate(), 20) + ' : start SP\sp_UPD_Task_XLS_Izolux.sql'
go

-- ============================================================
-- File: SP\sp_UPD_Task_XLS_Izolux.sql
-- ============================================================
if OBJECT_ID('sp_UPD_Task_XLS_Izolux_Export', 'P') is not NULL
  drop procedure dbo.sp_UPD_Task_XLS_Izolux_Export
go

create procedure dbo.sp_UPD_Task_XLS_Izolux_Export @idTask int,  
                                                   @idUserSignAuthority int,
                                                   @bOtherProduction int = 0, 
                                                   @bCalcNDS  int = 1
as
begin
  set nocount on

  create table #Temp
  (
    forCount              int,
    idTask                int,
    ProjectNum            int,
    idTaskType            int,
    TaskNum               varchar(150) collate Cyrillic_General_CI_AS,
    AccountNum            varchar(150) collate Cyrillic_General_CI_AS,
    ForAccountNum         varchar(150) collate Cyrillic_General_CI_AS,
    A_NumCalcFact         varchar(150) collate Cyrillic_General_CI_AS,
    DatePayDoc            datetime,
    TaskDate              datetime,
    TaskGUID              uniqueidentifier, 
    TotalArea             float,
    ClientNum             varchar(100) collate Cyrillic_General_CI_AS,
    NumCalcFact           varchar(150) collate Cyrillic_General_CI_AS,
    NumCalcFact_Dealer    varchar(150) collate Cyrillic_General_CI_AS,
    ForNumCalcFact        varchar(150) collate Cyrillic_General_CI_AS,
    ForNumCalcFact_Dealer varchar(150) collate Cyrillic_General_CI_AS,
    DateComplete          datetime,
    Komission             varchar(250) collate Cyrillic_General_CI_AS,
    ClientName            varchar(255) collate Cyrillic_General_CI_AS,
    ClientNameFull        varchar(255) collate Cyrillic_General_CI_AS,
    ClientAdress          varchar(255) collate Cyrillic_General_CI_AS,
    ClientAdressSubDiv    varchar(255) collate Cyrillic_General_CI_AS,
    --AdressSubDiv        varchar(255) collate Cyrillic_General_CI_AS,
    ClientTel             varchar(150) collate Cyrillic_General_CI_AS,
    ClientOKPO            varchar(100) collate Cyrillic_General_CI_AS,
    ClientUNN             varchar(20)  collate Cyrillic_General_CI_AS,
    ClientKPP             varchar(50)  collate Cyrillic_General_CI_AS,
    ClientKS              varchar(32)  collate Cyrillic_General_CI_AS,
    ClientBIC             varchar(32)  collate Cyrillic_General_CI_AS,
    ClientOKOHX           varchar(100) collate Cyrillic_General_CI_AS,
    ClientRS              varchar(32)  collate Cyrillic_General_CI_AS,
    ClientBank            varchar(255) collate Cyrillic_General_CI_AS,
    ClientChiefName       varchar(64)  collate Cyrillic_General_CI_AS,
    ClientAccountantName  varchar(64)  collate Cyrillic_General_CI_AS,
    ClientSendEmailName   varchar(64)  collate Cyrillic_General_CI_AS,
    ClientEmail           varchar(256) collate Cyrillic_General_CI_AS,
    ClientCargoReciever   varchar(255) collate Cyrillic_General_CI_AS,
    bGPNameClientToCSV    bit,
    
    SellerName            varchar(255) collate Cyrillic_General_CI_AS,
    SellerNameFull        varchar(255) collate Cyrillic_General_CI_AS,
    SellerAlternativeName varchar(255) collate Cyrillic_General_CI_AS,
    SellerUNN             varchar(20)  collate Cyrillic_General_CI_AS,
    SellerAdress          varchar(255) collate Cyrillic_General_CI_AS,
    SellerRS              varchar(32)  collate Cyrillic_General_CI_AS,
    SellerBank            varchar(255) collate Cyrillic_General_CI_AS,
    SellerTel             varchar(150) collate Cyrillic_General_CI_AS,
    SellerFax             varchar(150) collate Cyrillic_General_CI_AS,
    SellerEMail           varchar(50)  collate Cyrillic_General_CI_AS,
    SellerSite            varchar(50)  collate Cyrillic_General_CI_AS,
    SellerOKOHX           varchar(100) collate Cyrillic_General_CI_AS,
    SellerOKPO            varchar(100) collate Cyrillic_General_CI_AS,
    SellerOGRN            varchar(64)  collate Cyrillic_General_CI_AS,
    SellerKS              varchar(32)  collate Cyrillic_General_CI_AS,
    SellerBIC             varchar(32)  collate Cyrillic_General_CI_AS,
    SellerKPP             varchar(50)  collate Cyrillic_General_CI_AS,
    SellerAccountantName  varchar(64)  collate Cyrillic_General_CI_AS,
    SellerChiefName       varchar(64)  collate Cyrillic_General_CI_AS,
    SellerRealAccountantName   varchar(64)  collate Cyrillic_General_CI_AS,
    SellerRealChiefName        varchar(64)  collate Cyrillic_General_CI_AS,
    SellerCertificateNDS       varchar(255) collate Cyrillic_General_CI_AS,
    ShipperName                varchar(255) collate Cyrillic_General_CI_AS,
    ShipperAdress              varchar(255) collate Cyrillic_General_CI_AS,
    ShipperAdressSubDiv        varchar(255) collate Cyrillic_General_CI_AS,
    ShipperChiefName           varchar(255) collate Cyrillic_General_CI_AS,
    -- Тех.компания
    TechCompanyName            varchar(255) collate Cyrillic_General_CI_AS,
    TechCompanyNameFull        varchar(255) collate Cyrillic_General_CI_AS,
    TechCompanyAlternativeName varchar(255) collate Cyrillic_General_CI_AS,
    TechCompanyUNN             varchar(20)  collate Cyrillic_General_CI_AS,
    TechCompanyCity            varchar(255) collate Cyrillic_General_CI_AS,
    TechCompanyAdress          varchar(255) collate Cyrillic_General_CI_AS,
    TechCompanyAdressSubDiv    varchar(255) collate Cyrillic_General_CI_AS,
    TechCompanyRS              varchar(32)  collate Cyrillic_General_CI_AS,
    TechCompanyBank            varchar(255) collate Cyrillic_General_CI_AS,
    TechCompanyTel             varchar(150) collate Cyrillic_General_CI_AS,
    TechCompanyFax             varchar(150) collate Cyrillic_General_CI_AS,
    TechCompanyEMail           varchar(50)  collate Cyrillic_General_CI_AS,
    TechCompanySite            varchar(50)  collate Cyrillic_General_CI_AS,
    TechCompanyOKOHX           varchar(100) collate Cyrillic_General_CI_AS,
    TechCompanyOKPO            varchar(100) collate Cyrillic_General_CI_AS,
    TechCompanyOGRN            varchar(64)  collate Cyrillic_General_CI_AS,
    TechCompanyKS              varchar(32)  collate Cyrillic_General_CI_AS,
    TechCompanyBIC             varchar(32)  collate Cyrillic_General_CI_AS,
    TechCompanyKPP             varchar(50)  collate Cyrillic_General_CI_AS,
    TechCompanyAccountantName  varchar(64)  collate Cyrillic_General_CI_AS,
    TechCompanyChiefName       varchar(64)  collate Cyrillic_General_CI_AS,

    ShiperName         varchar(128) collate Cyrillic_General_CI_AS,
    SubDivisionAddress varchar(255) collate Cyrillic_General_CI_AS,
    SubDivisionAddress_Ship varchar(255) collate Cyrillic_General_CI_AS,
    SellerCountry      varchar(255) collate Cyrillic_General_CI_AS,
    ConsigneeName      varchar(255) collate Cyrillic_General_CI_AS,
    ConsigneeNameFull  varchar(255) collate Cyrillic_General_CI_AS,
    ConsigneeAdress    varchar(255) collate Cyrillic_General_CI_AS,
    ConsigneeAdressSubDiv varchar(255) collate Cyrillic_General_CI_AS,
    ConsigneeUNN       varchar(20)  collate Cyrillic_General_CI_AS,
    PriceS         decimal(13, 2),
    PriceM2WithNDS decimal(13, 2),
    PriceOfUnit    decimal(13, 2),                         -- Цена без НДС
    --PriceWithNDS   decimal(13, 2),                         -- Сумма по позиции с НДС
    --NDS            decimal(13, 2),
    --SumNoNDS       decimal(13, 2),                         -- Сумма без НДС
    PriceNDS       decimal(13, 2),
    bShpros        bit,
    Mass           float,
    MassSum        float,
    Unit           varchar(5) collate Cyrillic_General_CI_AS,
    Tax_rate       varchar(7) collate Cyrillic_General_CI_AS,
    nCount         int,
    nCountPos      int,
    nCountArea     float,                                     -- Количество / площадь по накладной в зависимости от вида измерения позиции накладной
    GPName         varchar(128) collate Cyrillic_General_CI_AS,
    GPName_Common  varchar(128) collate Cyrillic_General_CI_AS,
    GPNameClient   varchar(128) collate Cyrillic_General_CI_AS,
    GPNameEng      varchar(128) collate Cyrillic_General_CI_AS,
    Width          varchar(  5) collate Cyrillic_General_CI_AS,
    Height         varchar(  5) collate Cyrillic_General_CI_AS,
    Area float,
    IsPriceByCount bit,
    CamCountStr varchar(3) collate Cyrillic_General_CI_AS,
    Name varchar(32) collate Cyrillic_General_CI_AS,
    Pricekvm decimal(13, 2),
    Thickness varchar(3) collate Cyrillic_General_CI_AS,
    Commentary varchar(255) collate Cyrillic_General_CI_AS,
    ProductName varchar(50) collate Cyrillic_General_CI_AS,
    DepotName varchar(100) collate Cyrillic_General_CI_AS,
    DepotSubDivisionTel varchar(150) collate Cyrillic_General_CI_AS,
    ManagerName varchar(50) collate Cyrillic_General_CI_AS,
    SubDivisionManagerName varchar(50) collate Cyrillic_General_CI_AS,

    SubDivisionKPP  varchar(50) collate Cyrillic_General_CI_AS,

    AddTo_NumInvoice       varchar(16) collate Cyrillic_General_CI_AS,
    OrderToSign            varchar(128) collate Cyrillic_General_CI_AS,
    CurSaldo float,
    sign_CurSaldo float,
    Code    varchar(11)  collate Cyrillic_General_CI_AS,   -- STIS 2015-09-11 c 9 на 11
    Manager varchar(128) collate Cyrillic_General_CI_AS,
    Tel     varchar(64)  collate Cyrillic_General_CI_AS,
    CamCount tinyint,
    idShip int,
    HeaderTN varchar(512) collate Cyrillic_General_CI_AS,
    Signature_ShiperPost varchar(64) collate Cyrillic_General_CI_AS,
    ProductType int,
    ContractName varchar(128) collate Cyrillic_General_CI_AS,
    ContractNum  varchar(32)  collate Cyrillic_General_CI_AS,
    ContractDate datetime,
    CommentClient varchar(128) collate Cyrillic_General_CI_AS,
    NumInvoice    varchar(50)  collate Cyrillic_General_CI_AS,
    TransportDate datetime,
    RasInfoText varchar(128) collate Cyrillic_General_CI_AS,
    RasLength float,
    Unit_Code_OKEI varchar(50) collate Cyrillic_General_CI_AS,
    PriceNoNDS decimal(13, 2),
    TaskCommentary varchar(255) collate Cyrillic_General_CI_AS,

    CarDriver            varchar(255) collate Cyrillic_General_CI_AS,
    CarName              varchar(255) collate Cyrillic_General_CI_AS,
    CarGosNumber         varchar(255) collate Cyrillic_General_CI_AS,
    CarLicense           varchar(255) collate Cyrillic_General_CI_AS,
    TaskAutor            varchar(255) collate Cyrillic_General_CI_AS,
    idDepotSubDivision   int,
    idProject            int,
    TransportPosNum      int,

    AdressSubDiv         varchar(255) collate Cyrillic_General_CI_AS,
    SubDivCountry        varchar(255) collate Cyrillic_General_CI_AS,
    ClientCountry        varchar(255) collate Cyrillic_General_CI_AS,
    idDefaultAdress      int,
    SumNDS               decimal(18, 2),  
    TaskSumNoNDS         decimal(18, 2),
    Price                decimal(18, 2)
  )

  declare @idNDSTask  int,
          @Tax_rate   int,
          @DateSearch datetime

  select @DateSearch = DateComplite, @idNDSTask = idNDS from Task where ID = @idTask

  -- Берем по ID а не дате
  select @Tax_rate = NDS from NDS where ID = @idNDSTask 
  set @Tax_rate = isnull(@Tax_rate, 22) -- 01.01.2026 стало 22% так что по умолчанию выбираем именно это значение

  -- Загрузим все СП, которые лежат в отгрузке.
  insert into #Temp
  select
    1                       as forCount,
    T.ID                    as idTask,
    P.Num                   as ProjectNum,
    IsNull(T.idTaskType, 1) as idTaskType,
    T.Num                   as TaskNum,
    T.AccountNum,
    T.ForAccountNum,
    T.A_NumCalcFact,
    T.DatePayDoc,   
    T.Date                  as TaskDate,
    T.GUID                  as TaskGUID,
    T.Area                  as TotalArea,

    IsNull(T.ClientNum, '') as ClientNum,
    IsNull(T.NumCalcFact, '') as NumCalcFact,

    IsNull(T.NumCalcFact_Dealer, '') as NumCalcFact_Dealer,

    --T.DateComplite as DateComplete,
    case when Len(IsNull(T.ForAccountNum, '')) > 0
         then ( select top 1
                  case when Len(IsNull(Transport.Num, '')) > 0
                       then IsNull(Transport.Num, '')
                       else IsNull(Task.NumCalcFact, '') end
                from Transport
                  inner join BarCode on BarCode.idTransport = Transport.ID
                  inner join Project on Project.ID          = BarCode.idProject
                  inner join Task    on Task.ID             = Project.idTask
                where Task.AccountNum = T.ForAccountNum
              )
         else '' end as ForNumCalcFact,
    case when Len(IsNull(T.ForAccountNum, '')) > 0
         then ( select top 1
                  case when Len(IsNull(Transport.Num_Dealer, '')) > 0
                       then IsNull(Transport.Num_Dealer, '')
                       else IsNull(Task.NumCalcFact_Dealer, '') end
                from Transport
                  inner join BarCode on BarCode.idTransport = Transport.ID
                  inner join Project on Project.ID          = BarCode.idProject
                  inner join Task    on Task.ID             = Project.idTask
                where Task.AccountNum = T.ForAccountNum
              )
         else '' end as ForNumCalcFact_Dealer,
    T.DateComplite             as DateComplete,
    IsNull(T.Komission, '')    as Komission,
    IsNull(C.Name, '')         as ClientName,
    IsNull(C.NameFull, IsNull(C.Name, '')) as ClientNameFull,
    --isnull(C.NameFull, '')     as ClientNameFull,
    IsNull(C.Adress, '')       as ClientAdress,
    isnull(C.AdressSubDiv, '') as ClientAdressSubDiv,
    IsNull(C.Tel, '')          as ClientTel,
    IsNull(C.OKPO, '')         as ClientOKPO,
    IsNull(C.UNN, '') as ClientUNN,
    IsNull(C.KPP, '') as ClientKPP,
    IsNull(CB_C.KS, '') as ClientKS,
    IsNull(BK_C.BIC, '') as ClientBIC,
    IsNull(C.OKOHX, '') as ClientOKOHX,
    IsNull(CB_C.RS, '') as ClientRS,
    IsNull(BK_C.Name, '') as ClientBank,
    case 
        when charindex('ИП', IsNull(C.Name, '')) > 0 
             or charindex('ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ', upper(IsNull(C.Name, ''))) > 0
        then ltrim(replace(replace(replace(
                ltrim(IsNull(C.Name, '')), 
                'ИНДИВИДУАЛЬНЫЙ ПРЕДПРИНИМАТЕЛЬ ', ''
            ), 'ИП ', ''), 'ИП', ''))
        else IsNull(C.ChiefName, '')  -- Или ФИО руководителя для юр. лиц
    end as ClientChiefName,
    IsNull(C.AccountantName, '')  as ClientAccountantName,
    IsNull(C.SendEmailName, '')  as ClientSendEmailName,    
    IsNull(C.eMail, '') as ClientEmail,  
    IsNull(C.CargoReciever, '') as ClientCargoReciever,  
    C.bGPNameClientToCSV,
    
    IsNull(S.Name, '') as SellerName,
    IsNull(S.NameFull, '') as SellerNameFull,
    IsNull(S.AlternativeName, '') as SellerAlternativeName,
    IsNull(S.UNN, '') as SellerUNN,
    IsNull(S.Adress, '') as SellerAdress,
    IsNull(CB_S.RS, '') as SellerRS,
    IsNull(BK_S.Name, '') as SellerBank,
    IsNull(S.Tel, '') as SellerTel,
    IsNull(S.Fax, '') as SellerFax,
    IsNull(S.eMail, '') as SellerEMail,
    IsNull(S.Site, '')  as SellerSite,
    IsNull(S.OKOHX, '') as SellerOKOHX,
    IsNull(S.OKPO, '') as SellerOKPO,
    IsNull(S.OGRN, '') as SellerOGRN,
    IsNull(CB_S.KS, '') as SellerKS,
    IsNull(BK_S.BIC, '') as SellerBIC,
    IsNull(S.KPP, '') as SellerKPP,
    IsNull(S.AccountantName, '')  as SellerAccountantName,
    IsNull(S.ChiefName, '')       as SellerChiefName,
    IsNull(S.AccountantName, '') as SellerRealAccountantName,
    IsNull(S.ChiefName, '')      as SellerChiefName,
    S.CertificateNDS as SellerCertificateNDS,

    ''               as ShipperName,
    ''             as ShipperAdress,
    ''       as ShipperAdressSubDiv,
    ''          as ShipperChiefName,

    -- Тех.компания
    IsNull(TC.Name,            '')  as TechCompanyName,
    IsNull(TC.NameFull,        '')  as TechCompanyNameFull,
    IsNull(TC.AlternativeName, '')  as TechCompanyAlternativeName,
    IsNull(TC.UNN,             '')  as TechCompanyUNN,
    IsNull(TC.City,            '')  as TechCompanyCity,
    IsNull(TC.Adress,          '')  as TechCompanyAdress,
    IsNull(TC.AdressSubDiv,    '')  as TechCompanyAdressSubDiv,
  ( select top 1 IsNull(RS, '') from ClientBank where bDef = 1 and TC.ID = idClient ) 
                                    as TechCompanyRS,
  ( select top 1 IsNull(Name, '') 
    from Bank 
      inner join ClientBank on Bank.ID = ClientBank.idBank
    where bDef = 1 and TC.ID = idClient 
  )                                 as TechCompanyBank,
    IsNull(TC.Tel,             '')  as TechCompanyTel,
    IsNull(TC.Fax,             '')  as TechCompanyFax,
    IsNull(TC.eMail,           '')  as TechCompanyEMail,
    IsNull(TC.Site,            '')  as TechCompanySite,
    IsNull(TC.OKOHX,           '')  as TechCompanyOKOHX,
    IsNull(TC.OKPO,            '')  as TechCompanyOKPO,
    IsNull(TC.OGRN,            '')  as TechCompanyOGRN,
  ( select top 1 IsNull(KS, '') from ClientBank where bDef = 1 and TC.ID = idClient ) 
                                    as TechCompanyKS,
  ( select top 1 IsNull(BIC, '') 
    from Bank 
      inner join ClientBank on Bank.ID = ClientBank.idBank
    where bDef = 1 and TC.ID = idClient 
  )                                 as TechCompanyBIC,
    IsNull(TC.KPP,             '')  as TechCompanyKPP,
    IsNull(TC.AccountantName, '')   as TechCompanyAccountantName,
    IsNull(TC.ChiefName, '')        as TechCompanyChiefName,

    S.ShiperName,
    IsNull(DSD.Address, '')     as SubDivisionAddress,
    IsNull(DSD_Ship.Address, '')   as SubDivisionAddress_Ship,
    IsNull(S.Country, 'Российская Федерация')    as SellerCountry,
    IsNull(CSG.Name, '')           as ConsigneeName,
    IsNull(CSG.NameFull, CSG.Name) as ConsigneeNameFull,
    IsNull(CSG.Adress, C.Adress)   as ConsigneeAdress,
    IsNull(CSG.AdressSubDiv, '')   as ConsigneeAdressSubDiv,
    IsNull(CSG.UNN, '')            as ConsigneeUNN,
    P.PriceS,                                             -- цена за шпросы
    case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNDS/P.Area   else P.PriceNDS   end as PriceM2WithNDS,
    case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNoNDS/P.Area else P.PriceNoNDS end as PriceOfUnit,   -- В 11 графе выводим цену за М2 без НДС.
    /*
    case T.CalcType when 3
      then Round(Round(SUM(P.Area)*P.PriceNoNDS,2)*1.18,2)
      else sum(P.SumWithNDS / case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end)
    end as PriceWithNDS,
    */
    /*
    case T.CalcType when 3
      then Round(Round(SUM(P.Area)*P.PriceNoNDS,2)*1.18,2) - Round(SUM(P.Area)*P.PriceNoNDS,2)
      else sum(P.SumNDS / case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end)
    end as NDS,
    
    case T.CalcType when 3
      then Round(SUM(P.Area)*P.PriceNoNDS,2)
      else sum(P.SumNoNDS / case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end)
    end as SumNoNDS,
    */
    case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 0 and ISNULL(P.Area, 0) > 0 then P.PriceNDS/P.Area   else P.PriceNDS   end as PriceNDS,
    IsNull(P.bShpros, 0) as bShpros,
    sum(P.Mass) as Mass,
    sum(P.Mass) as MassSum,                                       -- Для совместимости с w_Transport.
    case when IsNull(P.IsPriceByCount, 0) = 1 and CPU.d_iNum = 1
         then 'шт'
         else 'м2'                                                -- TODO: Взять из БД
    end as Unit,
    --NDS.NDS as Tax_rate,
    --@Tax_rate as Tax_rate,

    case when isNull(Nds.Name,'') = '' then cast(NDS.NDS as varchar(2)) + '%' else Nds.Name end as Tax_rate,

    count(*) as nCount,
    count(*) as nCountPos,                                        -- Для совместимости с w_Transport.
    sum(P.Area) as nCountArea,

    case
      when PD.Type != 1
       then PD.Name
      else dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name, 
                                       dbo.f_SupressCoveringMark(P.GPName, CCover.d_iNum),
                                       P.CamCount, P.Thickness, P.Width, P.Height,
                                       IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), null, null, 0)
    end as GPName,
   dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name, 
                                       dbo.f_SupressCoveringMark(P.GPName, CCover.d_iNum),
                                       P.CamCount, P.Thickness, P.Width, P.Height,
                                       IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), P.ID, P.Num, 0) as GPName_Common,
    isNull(P.GPNameClient,'')  as GPNameClient,
    
    left(dbo.f_RUS_To_Eng(P.GPName), 128) as GPNameEng,
    cast(floor(P.Width)  as varchar(5))   as Width,
    cast(floor(P.Height) as varchar(5))   as Height,
    P.Area                                as Area,
    IsNull(P.IsPriceByCount, 0)           as IsPriceByCount,
    case P.CamCount
         when 1 then 'СПО'
         when 2 then 'СПД'
         else ''
    end                                   as CamCountStr,
    case P.CamCount
         when 1 then 'Стеклопакет однокамерный'
         when 2 then 'Стеклопакет двухкамерный'
         else 'Стекло в нарезку'
    end                                        as Name,       -- Для совместимости с w_Invoice_4
    P.PriceByM                                 as Pricekvm,   -- В отчете "Счет-договор" (Task_Agreement_Common_2.rpt) используется поле Pricekvm (цена за 1 кв. м.), которого нет. Добавляю.
    cast(IsNull(P.Thickness, 0) as varchar(3)) as Thickness,
    IsNull(P.Commentary, '')                   as Commentary,
    PD.Name                                    as ProductName,
    IsNull(DSD.Name, '')                       as DepotName,
    IsNull(DSD.Tel, '')                        as DepotSubDivisionTel,
    IsNull(DSD.ManagerName, '')                as ManagerName,             -- Для обратной совместимости (напр. с v_InvoiceGroupByGPName)
    IsNull(DSD.ManagerName, '')                as SubDivisionManagerName,

    IsNull(DSD.KPP, '')                        as SubDivisionKPP,

    IsNull(DSD.AddTo_NumInvoice, '')           as AddTo_NumInvoice,
    IsNull(USign.OrderToSign, '')              as OrderToSign,
    0 as CurSaldo,
    0 as sign_CurSaldo,
    case P.CamCount
      when 0 then '00000000037'  -- STIS 2015-09-10 
      when 1 then '00000000038'
      when 2 then '00000000039'
      else        ''
    end as Code,
    '' as Manager,
    '' as Tel,
    P.CamCount,
    null as idShip,
    '' as HeaderTN,
    '' as Signature_ShiperPost,
    PD.Type as ProductType,
    IsNull(CC.Name,         '') as ContractName,
    IsNull(CC.ContractNum,  '') as ContractNum,
    CC.Date                     as ContractDate,
    IsNull(P.CommentClient, '') as CommentClient,
    T.Num as NumInvoice,
    T.DateComplite as TransportDate,
    dbo.f_GetGPRasInfo(P.ID, P.bShpros)                          as RasInfoText,
    (select sum(LengReal) from RasShrink where idProject = P.ID) as RasLength,
    UArea.Code_OKEI as Unit_Code_OKEI,
    P.PriceNoNDS,
    IsNull(T.Commentary, '') as TaskCommentary,

    ''                                                as CarDriver,
    ''                                                as CarName,
    ''                                                as CarGosNumber,
    ''                                                as CarLicense,
    UT.Name                                           as TaskAutor,
    T.idDepotSubDivision,
    P.ID,
    NULL as TransportPosNum,

    case
      when isNull(T.AddressDelivery, '') != '' then T.AddressDelivery
      when isNull(DA.Name, '')           != '' then DA.Name
      when isNull(CSG.AdressSubDiv, '')  != '' then CSG.AdressSubDiv
      when isNull(CSG.Adress, '')        != '' then CSG.Adress
      else null
    end as AdressSubDiv,
    IsNull(CSG.Country, 'Российская Федерация') as SubDivCountry,
    IsNull(C.Country, 'Российская Федерация')   as ClientCountry,
    IsNull(C.idDefaultAdress, 3)                as idDefaultAdress,
    T.SumNDS, 
    T.SumNoNDS,
    T.Price
  from 
    BarCode B 
    inner join Project P             on P.ID     = B.idProject
    inner join Task T                on T.ID     = P.idTask
    inner join Product PD            on PD.ID    = P.idProd
    --left  join NDS                   on NDS.ID   = T.idNDS
    left  join ClientContract CC     on CC.ID    = T.idClientContract
    left  join Client C              on C.ID     = T.idClient
    left  join Client S              on S.ID     = T.idSeller
    left  join Client TC             on ( TC.nClientSubType = 1 and T.Date < 42877 /*'2017-05-24 00:00:00.000'*/ or 
                                         -- До 24.05.2017 один тип клиента
                                         TC.nClientSubType = 2 and T.Date >= 42877 -- '2017-05-24 00:00:00.000'
                                         -- После 24.05.2017 другой тип клиента
                                         )
    --left  join Client Shipper        on Shipper.ID = SH.idCarrier                    -- Теперь это перевозчик из реквизитов отгрузки
    left  join Client CSG            on CSG.ID   = T.idConsignee
    left  join ClientBank CB_C       on CB_C.ID  = T.idClientBank_Client
    left  join Bank BK_C             on BK_C.ID  = CB_C.idBank
    left  join ClientBank CB_S       on CB_S.ID  = T.idClientBank_Seller
    left  join Bank BK_S             on BK_S.ID  = CB_S.idBank
    left  join DepotSubDivision DSD  on DSD.ID   = T.idDepotSubDivision
    left  join DepotSubDivision DSD_Ship  on DSD_Ship.ID   = T.idDepotSubDivision_Shipper
    --left  join Users U               on U.ID     = TR.idUsers
    left  join Users USign           on lower(USign.Name) = lower(SYSTEM_USER)    -- Пользователь, который подписывает
    --left  join UsersSignAutority USA on USign.GUID  = USA.guidUsers and
    --                                    SH.Date    >= USA.DateBegin and
    --                                    SH.Date    <= USA.DateEnd
    left  join Users UT              on UT.ID     = T.idUsers
    left  join Config CF             on CF.Name  = 'FormatTypeOfGPName'
    --left  join Config CF1           on CF1.Name = 'bCalcFactNumUniqueForShipedTask'
    left  join Config CPU            on CPU.Name = 'bPriceUnitInCalcFact'
    left  join Config CCover         on CCover.Name  = 'nGlassMarkCovering'   -- тип маркировки покрытия
    left  join (select top 1 * from Unit where nTypeUnit = 1) UArea  on UArea.nTypeUnit  = 1
    left  join (select top 1 * from Unit where nTypeUnit = 2) UCount on UCount.nTypeUnit = 2
    --left  join TripTransport        on TripTransport.ID = SH.idTripTransport
    left  join DeliveryAddress DA   on DA.ID  = T.idDeliveryAddress
    left  join NDS                  on NDS.ID   = T.idNDS
  where
    --TR.idShip = @idShip
    T.ID = @idTask
    --and Len(IsNull(T.NumCalcFact, '')) = 0
    and PD.Type = case when @bOtherProduction = 1 then PD.Type else 1       end
    --and T.ID    = case when @idTask           = 0 then T.ID    else @idTask end
  group by
    T.ID,
    IsNull(T.idTaskType, 1),
    T.Num,
    T.AccountNum,
    T.ForAccountNum,
    T.A_NumCalcFact,
    T.DatePayDoc,
    T.NumCalcFact,
    T.NumCalcFact_Dealer,
    T.AddressDelivery,
    T.Date,
    T.GUID,
    T.Area,
    IsNull(T.ClientNum, ''),
    T.DateComplite,
    IsNull(T.Komission, ''),
    T.CalcType,
    C.Name,
    C.NameFull,
    IsNull(C.Adress, ''),
    C.AdressSubDiv,
    IsNull(C.Country, 'Российская Федерация'),
    IsNull(C.Tel, ''),
    IsNull(C.OKPO, ''),
    IsNull(C.UNN, ''),
    IsNull(C.KPP, ''),
    IsNull(CB_C.KS, ''),
    IsNull(BK_C.BIC, ''),
    IsNull(C.OKOHX, ''),
    IsNull(CB_C.RS, ''),
    IsNull(BK_C.Name, ''),
    IsNull(C.ChiefName, ''),
    IsNull(C.AccountantName, ''),
    IsNull(C.SendEmailName, ''),
    IsNull(C.eMail, ''),
    IsNull(C.CargoReciever, ''),
    C.bGPNameClientToCSV,
    IsNull(C.idDefaultAdress, 3),
    
    IsNull(S.Name, ''),
    IsNull(S.NameFull, ''),
    IsNull(S.AlternativeName, ''),
    IsNull(S.UNN, ''),
    IsNull(S.Adress, ''),
    IsNull(CB_S.RS, ''),
    IsNull(BK_S.Name, ''),
    IsNull(S.Tel, ''),
    IsNull(S.Fax, ''),
    IsNull(S.eMail, ''),
    IsNull(S.Site, ''),
    IsNull(S.OKOHX, ''),
    IsNull(S.OKPO, ''),
    IsNull(S.OGRN, ''),
    IsNull(CB_S.KS, ''),
    IsNull(BK_S.BIC, ''),
    IsNull(S.KPP, ''),
    S.CertificateNDS,
    --Shipper.Name,
    --Shipper.Adress,
    --Shipper.AdressSubDiv,
    --Shipper.ChiefName,
    TC.ID,
    TC.Name,
    TC.NameFull,
    TC.AlternativeName,
    TC.UNN,
    TC.City,
    TC.Adress,
    TC.AdressSubDiv,
    TC.Tel,
    TC.Fax,
    TC.eMail,
    TC.Site,
    TC.OKOHX,
    TC.OKPO,
    TC.OGRN,
    TC.KPP,
    IsNull(TC.AccountantName, ''),
    IsNull(TC.ChiefName, ''),
    case when IsNull(DSD.bSignatureFromUser, 0) = 1
         then S.AccountantName
         else S.AccountantName
         end,
    case when IsNull(DSD.bSignatureFromUser, 0) = 1
         then S.AccountantName
         else S.ChiefName
         end,
    IsNull(S.AccountantName, ''),
    IsNull(S.ChiefName, ''),
    S.ShiperName,
    IsNull(DSD.Address, ''),
    IsNull(DSD_Ship.Address, ''),
    IsNull(S.Country, 'Российская Федерация'),
    IsNull(CSG.Name, ''),
    IsNull(CSG.NameFull, CSG.Name),
    IsNull(CSG.Adress, C.Adress),
    CSG.AdressSubDiv,
    IsNull(CSG.UNN, ''),
    P.Num,
    P.ID,
    P.PriceS,
    P.PriceNDS,
    P.bShpros,
    P.PriceNoNDS,
    P.GPName,
    P.GPNameClient,
    case when PD.Type != 1
       then PD.Name
       else left(dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name, P.GPName, P.CamCount, P.Thickness, P.Width, P.Height, IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), P.ID, P.Num, 0), 128)
       end,
    cast(floor(P.Width)  as varchar(5)),
    cast(floor(P.Height) as varchar(5)),
    P.Area,
    IsNull(P.IsPriceByCount, 0),
    P.PriceByM,
    cast(IsNull(P.Thickness, 0) as varchar(3)),
    IsNull(P.Commentary, ''),
    PD.Name,
    IsNull(DSD.Name, ''),
    IsNull(DSD.Tel, ''),
    IsNull(DSD.ManagerName, ''),
    IsNull(DSD.AddTo_NumInvoice, ''),
    DSD.KPP,
    IsNull(USign.OrderToSign, ''),
    --P.ID,
    P.CamCount,
    P.Thickness,
    P.Width,
    P.Height,
    C.ID,
    left(dbo.f_GetSpecialProductName(IsNull(CF.d_iNum, 0), PD.Name, P.GPName, P.CamCount, P.Thickness, P.Width, P.Height, IsNull(P.ComplexText, ''), IsNull(P.CommentClient, ''), P.ID, P.Num, 0), 128),
    IsNull(DSD.HeaderTN, ''),
    PD.Type,
    IsNull(CC.Name, ''),
    IsNull(CC.ContractNum, ''),
    CC.Date,
    --NDS.NDS,
    CF.d_iNum,
    CPU.d_iNum,
    CCover.d_iNum,
    IsNull(P.CommentClient, ''),
    P.ComplexText,
    UCount.Code_OKEI,
    UArea.Code_OKEI,
    IsNull(T.Commentary, ''),
    UT.Name,
    T.idDepotSubDivision,
    DA.Name,
    CSG.AdressSubDiv,
    IsNull(CSG.Country, 'Российская Федерация'),
    CSG.Adress,
    NDS.NDS,
    NDS.Name,
    T.SumNDS, 
    T.SumNoNDS,
    T.Price
    
  create table #ProjectPrice             -- Позиции накладной по заказу
  (
    idProject           int,
    idTask              int,
    nCalcType           int,
    SumPrice_Ship_NDS   decimal(18, 2),  -- Сумма по отгрузке с НДС
    SumPrice_Pos_NDS    decimal(18, 2),  -- Сумма по позиции  С НДС

    PriceNoNDS_M2       decimal(18, 2),  -- Цена за м2 без НДС
    PriceWithNDS_M2     decimal(18, 2),  -- Цена за м2 с НДС
    
    SumPrice_Ship_NoNDS decimal(18, 2),  -- сумма по отгрузке без НДС
    SumPrice_Pos_NoNDS  decimal(18, 2),  -- сумма по позиции  без НДС

    NDS_Ship            decimal(18, 2)   -- Су      мма НДС по позиции
  )    
    
  insert into #ProjectPrice
  (
    idProject,
    idTask,
    nCalcType,

    SumPrice_Ship_NDS,
    SumPrice_Pos_NDS,

    PriceNoNDS_M2,
    PriceWithNDS_M2,

    SumPrice_Ship_NoNDS,
    SumPrice_Pos_NoNDS
  )
  select 
    P.ID,  
    T.ID,
    T.CalcType,

    case T.CalcType when 3
      then Round(Round(Cast(Sum(P.Area) * P.PriceNoNDS as decimal(18,4)), 2) * ((100 + @Tax_rate)/100), 2)  -- Ставка НДС 20%
      else sum(P.SumWithNDS / case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end)
    end as PriceWithNDS,                                       -- цена ед. продукции с НДС
                                                               -- Сумма по позиции делённая на количество штук в позиции
    P.SumWithNDS,                                              -- стоимость позиции С НДС
    P.PriceNoNDS_M2 * case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end as PriceNoNDS_M2,
    P.PriceWithNDS_M2 * case IsNull(P.nCount, 0) when 0 then 1 else P.nCount end as PriceWithNDS_M2,
    Round(Cast(SUM(P.Area)*P.PriceNoNDS as decimal(18,4)),2),  -- цена без НДС ед. продукции
    P.SumNoNds                                                 -- сумма без НДС по позиции  
  from
    BarCode B
	  inner join Project    P on P.ID  = B.idProject
    inner join Task       T on T.ID  = P.idTask
    left  join Transport TR on TR.ID = B.idTransport

  where
    P.ID in (select distinct idProject from #Temp) 
  group by 
    P.ID,  
    P.SumWithNDS,
    P.SumNoNds,
    T.ID,
    T.CalcType,
    P.PriceNoNDS,
    P.PriceNoNDS_M2,
    P.PriceWithNDS_M2,
    nCount

  --select * from #ProjectPrice

  -- Корректировка сумм по позициям:

  update #ProjectPrice set 
    #ProjectPrice.SumPrice_Ship_NDS   = #ProjectPrice.SumPrice_Ship_NDS   + (Remain.SumPrice_Pos_NDS   - Remain.SumPrice_NDS),
    #ProjectPrice.SumPrice_Ship_NoNDS = #ProjectPrice.SumPrice_Ship_NoNDS + (Remain.SumPrice_Pos_NoNDS - Remain.SumPrice_NoNDS)
  from 
    #ProjectPrice inner join
    (      
      select 
        idProject,
        max(idTask)              as idTask_Max,
        
        sum(SumPrice_Ship_NDS)   as SumPrice_NDS,
        SumPrice_Pos_NDS,

        sum(SumPrice_Ship_NoNDS) as SumPrice_NoNDS,
        SumPrice_Pos_NoNDS

      from   
        #ProjectPrice
      group by
        idProject,   
        SumPrice_Pos_NDS, 
        SumPrice_Pos_NoNDS
    ) Remain on #ProjectPrice.idProject = Remain.idProject  and 
                #ProjectPrice.idTask    = Remain.idTask_Max 
  where
    isNull(nCalcType, 0 )	 <> 3

  -- Счёт с НДС 
  -- Записали, округлили              
  if @bCalcNDS = 1
  begin
    update #ProjectPrice set 
      NDS_Ship = SumPrice_Ship_NDS * @Tax_rate/(100 + @Tax_rate)             -- 1. Сумма НДС по позиции, Ставка НДС 20%
    where
     isNull(nCalcType, 0) <> 3

    -- Грамотно вычли
    update #ProjectPrice set 
      SumPrice_Ship_NoNDS = SumPrice_Ship_NDS - NDS_Ship     -- 2. Сумма без НДС
    where
      isNull(nCalcType, 0) <> 3
    -- конец счёта с НДС

    -- Счёт без НДС   
    update #ProjectPrice set 
      SumPrice_Ship_NDS = SumPrice_Ship_NoNDS * (100 + @Tax_rate)/100.0  -- 3. Сумма с НДС, Ставка НДС 20%
    where
      isNull(nCalcType, 0) = 3
   
    -- Грамотно вычли
    update #ProjectPrice set 
      NDS_Ship = SumPrice_Ship_NDS - SumPrice_Ship_NoNDS     -- 4. Сумма НДС
    where
      isNull(nCalcType, 0) = 3
    -- конец счёта без НДС
  end
  --select * from #ProjectPrice

  create table #TaskProp                                         -- Суммирующие данные по заказу в данной отгрузке, по одному заказу будет одна строка
  (
    idTask         int,
    TaskPrice      decimal(18, 2),                               -- Сумма по отгрузке
    PricePhrase    varchar(128) collate Cyrillic_General_CI_AS,  -- От этого поля можно отказаться, если отчеты перевести в стимул. TTN_1T.mrt обходится без него.
    MassPhraseTonn varchar(64)  collate Cyrillic_General_CI_AS,  -- От этого поля можно отказаться, если отчеты перевести в стимул. TTN_1T.mrt обходится без него.
    MassPhraseKg   varchar(64)  collate Cyrillic_General_CI_AS,  -- От этого поля можно отказаться, если отчеты перевести в стимул. TTN_1T.mrt обходится без него.
    nCountPyramid  int,
    PyramidList    varchar(1024)
  )  

  insert into #TaskProp
  select
    #Temp.idTask,
    sum(               round(#ProjectPrice.SumPrice_Ship_NDS, 2))  as TaskPrice,
    dbo.RubPhrase (sum(round(#ProjectPrice.SumPrice_Ship_NDS, 2))) as PricePhrase,
    dbo.MassPhrase(round(sum(Mass),        0), 0)                  as MassPhraseTonn,
    dbo.MassPhrase(round(sum(Mass * 1000), 0), 1)                  as MassPhraseKg,
    0        as nCountPyramid,
    ''       as PyramidList
  from 
    #Temp inner join #ProjectPrice on #ProjectPrice.idProject = #Temp.idProject and #ProjectPrice.idTask = @idTask
  group by
    #Temp.idTask

  declare @BarCodePrefix varchar(32)

  select @BarCodePrefix = d_string from Config where name = 'NumCalcFact_BarCodePrefix'

  declare @nLineCount  int

  select @nLineCount = count(1) from #Temp

  select @nLineCount = isnull(@nLineCount, 0)

  -- Сумма по заказу для отладки:
  --select * from #TaskProp

  declare
    @usaName      varchar(128),
    @usaOrderNum  varchar(128),
    @usaOrderDate varchar(128),
    @usaOrderPost varchar(128)

  select 
    @usaName      = InvoiceResponsName_1,
    @usaOrderNum  = InvoiceOrderNum_1,
    @usaOrderDate = convert(varchar(64), InvoiceOrderDate_1, 104),
    @usaOrderPost = InvoiceOrderPost_1
  from
    UsersSignAutority
  where
    ID = @idUserSignAuthority

  -- STIS 2015-09-04 добавлены из таблицы транспорт num,DeliveryNum номера Расходной накладной и счёта фактуры
  -- Позиции накладной:
  select
    T.*,
    TP.TaskPrice,
    TP.PricePhrase,
    TP.MassPhraseKg,
    TP.MassPhraseTonn,
    T.TaskNum                         as RashodnayaNakladnaya,
    T.TaskNum                         as SchetFaktura,
    Consignor.Name                    as ConsignorName,
    Consignor.NameFull                as ConsignorNameFull,
    Consignor.Adress                  as ConsignorAdress,
    Consignor.UNN                     as ConsignorUNN,
    Consignor.KPP                     as ConsignorKPP,
    Consignor.AdressSubDiv            as ConsignorAdressSubDiv,
    TP.nCountPyramid,
    TP.PyramidList,
    #ProjectPrice.SumPrice_Ship_NDS   as PriceWithNDS,
    #ProjectPrice.PriceNoNDS_M2,
    #ProjectPrice.PriceWithNDS_M2,
    #ProjectPrice.NDS_Ship            as NDS,
    #ProjectPrice.SumPrice_Ship_NoNDS as SumNoNDS,
    'Счет №' + T.TaskNum + ' от ' + dbo.f_FormatDate(T.TaskDate, 'DD.MM.YY') + ', ' +
    'предварительный расчет-заказ №' + T.AccountNum + ' от ' + dbo.f_FormatDate(T.TaskDate, 'DD.MM.YY') as Base,
    'Квадратный метр'as UnitName,
    ''               as UnitCode,
    ''               as ViewPack,
    ''               as nCountVM,
    @Tax_rate        as NDSTax,     -- Ставка НДС 20%
    
    -- Доп.поля для XLS
    convert(varchar(64), T.DateComplete, 104) as InvoiceDateStr,
    convert(varchar(64), dbo.f_TruncDate(getdate()), 104) as TodayDateStr,
    

    case when #ProjectPrice.NDS_Ship > 0 then 1 else 2 end as UPD_State,
    case when T.idTaskType = 1 then T.NumCalcFact_Dealer else T.NumCalcFact end as NumClacFact_Show,
    convert(varchar(64), T.DateComplete, 104) as DateCompleteStr,

    --case when T.idTaskType = 1 then T.TechCompanyNameFull else T.SellerName end as SellerName_Show,
--    T.SellerNameFull + '(' +  T.SellerName + ')'  as SellerName_Show,
    T.SellerNameFull  as SellerName_Show,
    
    case when T.idTaskType = 1 then T.TechCompanyAdress   else T.SellerAdress end as SellerAdress_Show,

    /*
    case when T.idTaskType = 1 
         then T.TechCompanyUNN + ' / ' + T.TechCompanyKPP  
         else T.SellerUNN + ' / ' + T.SellerKPP 
    end as UNN_KPP_Show,*/

    T.SellerUNN + '/' + T.SubDivisionKPP  as UNN_KPP_Show,

    case when T.idTaskType = 1 
         then T.TechCompanyNameFull + ' ИНН/КПП ' + T.TechCompanyUNN + ' / ' + T.TechCompanyKPP  
         else T.SellerName + ' ИНН/КПП ' + T.SellerUNN + ' / ' + T.SellerKPP 
    end as SellerName_UNN_KPP_Show,


    T.SellerName + ' ИНН ' + T.SellerUNN as SellerName_UNN_Show,

    /*
    case when T.GPName = 'Доставка' 
         then ''
         else T.TechCompanyNameFull + ' ' + T.TechCompanyAdressSubDiv 
    end as Shipper_Info,
    */

    T.SellerName + ' ' + T.SubDivisionAddress as Shipper_Info,
    T.ConsigneeNameFull + ' ' + T.AdressSubDiv as Consignee_Info,

    /*case when T.GPName = 'Доставка' 
         then ''
         else T.ConsigneeNameFull + ' ' + 
              case when isnull(T.ConsigneeAdress, '') <> '' then T.ConsigneeAdress else T.ClientAdress end
    end as Consignee_Info,*/

    case when isnull(T.DatePayDoc, '') = '' then '' else convert(varchar(64), T.DatePayDoc, 104) end as DatePayDocStr,

    T.ClientUNN + ' / ' + T.ClientKPP as Client_UNN_KPP,

    '*' + isnull(@BarCodePrefix, '') + ltrim(str(T.NumCalcFact)) + '*' as BC_NumCalcFact,

    case 
      when T.ProductType = 3 
      then replace(
             replace(T.GPName, 'Доставка', 'Транспортные услуги по перевозке стеклопакетов'),
             'Шаблон', 'Услуга по замеру и изготовлению шаблона')
      else case when T.CamCount = 0 then 'Стекло ' else 'Стеклопакет ' end +
           case when T.CamCount > 0 then '' else '' end  +
           T.GPName + ' ' + ltrim(str(T.Width)) + ' x ' +  ltrim(str(T.Height)) +
           case when T.bShpros <> 0 then ' ' + T.RasInfoText + ' ' + ltrim(str(T.RasLength)) + 'мм' else '' end
    end + ', ' + ltrim(str(T.nCount)) + ' шт.' as GPNameStr,

    case when #ProjectPrice.NDS_Ship = 0 then 'Без НДС' else ltrim(cast(#ProjectPrice.NDS_Ship as varchar(20))) end as NDS_Str,

    #ProjectPrice.NDS_Ship as NDS_Num,

    --isnull(T.OrderToSign, T.SellerChiefName) as OrderToSign_Str,
    isnull(T.OrderToSign, T.SellerAccountantName) as SellerAccountantName_Str,

    case when len(T.SellerUNN) > 10 then T.SellerChiefName else '' end as SellerChiefName_Str,
    case when len(T.SellerUNN) > 10 then T.SellerCertificateNDS else '' end as SellerCertificateNDS_Str,

    /*
    case when isnull(T.ContractName, '') = '' or lower(T.ContractName) = 'без основного договора'
         then '' 
         else 'Договор' + 
              case when isnull(T.ContractNum, '') = '' 
                   then ''
                   else ' № ' + T.ContractNum +
                   case when T.ContractDate is null then '' else convert(varchar(64), T.ContractDate, 104) end
              end +
              case when isnull(T.ClientNum, '') = ''
                   then ''
                   else 
                   case when left(lower(T.ClientNum), 6) = 'заявка'
                        then ' ' + T.ClientNum
                        else ' Заявка: ' + T.ClientNum
                   end
              end
    end +
    case when isnull(T.TaskNum, '') <> ''
         then ' Счёт № ' + T.TaskNum + ' от ' + convert(varchar(64), T.TaskDate, 104)
    end
    as ClientContract_Str,
    */

    'Счёт на оплату № ' + T.TaskNum + ' от ' + convert(varchar(64), T.TaskDate, 104) + 
    ' (задание № ' + T.AccountNum + ') Заявка ' + T.ClientNum as ClientContract_Str,

     convert(varchar(64), T.TaskDate, 104) as TaskDateStr,

    /*
    case when isnull(T.ShipperName, '') = '' or T.ShipperName = T.SellerName
         then 'Товарно-транспортная накладная и (или) транспортная накладная № ' + T.NumCalcFact + 
              ' от ' + convert(varchar(64), T.DateComplete, 104) + ' г.; итого отгружено ' + ltrim(str(SumTask.SumCountArea)) + ' м2'
         else 'транспортная накладная №' + case when T.GPName = 'Доставка' then T.ForNumCalcFact else T.NumCalcFact end + 
              ' ' + T.AddTo_NumInvoice + ' от ' + convert(varchar(64), T.DateComplete, 104)
    end as TTN_Str,
    */

    'транспортная накладная № '+ T.NumCalcFact + T.AddTo_NumInvoice+ ' от ' + convert(varchar(64), T.DateComplete, 104) as TTN_Str,

    convert(varchar(64), T.DateComplete, 104) as DateComplete_Str,

    T.NumCalcFact + '' + T.AddTo_NumInvoice as NumCalcFactAdd,

    '№ п/п 1-' + ltrim(str(@nLineCount)) +' №' as LineCountStr,

    '№ п/п 1-' + ltrim(str(@nLineCount))       as LineCountStr1,

    @usaName      as SignPerson,
    @usaOrderNum  as IONum,
    @usaOrderDate as IODate,
    @usaOrderPost as IOPost,

    @usaOrderNum + ' от ' + @usaOrderDate as IONumDate,

    @usaName + 'по приказу ' + @usaOrderNum + ' от ' + @usaOrderDate as OrderToSign_Str,

    CF.d_string as TTN_Chief_F,
    CI.d_string as TTN_Chief_I,
    CO.d_string as TTN_Chief_O

  from 
    #Temp T inner join #ProjectPrice    on #ProjectPrice.idProject = T.idProject and #ProjectPrice.idTask = @idTask
            inner join #TaskProp TP     on TP.idTask = T.idTask
            left  join DepotSubDivision on T.idDepotSubDivision                = DepotSubDivision.ID 
            left  join Client Consignor on DepotSubDivision.idClient_Consignor = Consignor.ID
            left join 
            (
              select  
                TMP.idTask,
                round(sum(nCountArea), 3) as SumCountArea
              from
                #Temp TMP
              group by
                TMP.idTask
            ) SumTask on T.idTask = SumTask.idTask

            left  join Config CF on CF.Name = 'TTN_ChiefFamily'
            left  join Config CI on CI.Name = 'TTN_ChiefName'
            left  join Config CO on CO.Name = 'TTN_ChiefO'
  where
    T.idTask = @idTask                           

  drop table #TaskProp
  drop table #Temp
  drop table #ProjectPrice

  set nocount off
end
go

go
print convert(varchar, getdate(), 20) + ' : finish SP\sp_UPD_Task_XLS_Izolux.sql'
go

/* ============================================================
   Trigger
   ============================================================ */


print convert(varchar, getdate(), 20) + ' : start Trigger\t_DepTrans_insert_NumInovice.sql'
go

-- ============================================================
-- File: Trigger\t_DepTrans_insert_NumInovice.sql
-- ============================================================
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_DepTrans_insert_NumInovice]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[t_DepTrans_insert_NumInovice]
go

create trigger dbo.t_DepTrans_insert_NumInovice on DepTrans  after insert 
as
begin
  
  declare 
    @idDepTrans       int = 0,
    @idDepDocType     int,
    @idUsers          int,
    @NumInvoice       varchar(10),
    @NumCalcFact      varchar(64)

  select @idUsers = ID from Users where Name = SYSTEM_USER
  
  select top 1 
    @idDepTrans       = I.ID,
    @idDepDocType     = I.idDepDocType,
    @NumCalcFact      = T.NumCalcFact
  from 
    Inserted I
  inner join DepName DN on DN.ID = I.idDepName_Credit or
                           DN.ID = I.idDepName_Debet
  left join Task T on T.ID = I.idTask
  where DN.nType = 0
   
  if @idDepTrans != 0
  begin
    exec sp_GetNextDepTransNumInvoice @idDepDocType, @NumCalcFact, @NumInvoice output

    update DepTrans set
      idUsers    = isNull(@idUsers, 0),
      NumInvoice = @NumInvoice
    from 
      Inserted inner join DepTrans on DepTrans.ID = Inserted.ID
  end
end
go

go
print convert(varchar, getdate(), 20) + ' : finish Trigger\t_DepTrans_insert_NumInovice.sql'
go

print convert(varchar, getdate(), 20) + ' : start Trigger\trg_GlassProcessing_SetTimeMarkManufact.sql'
go

-- ============================================================
-- File: Trigger\trg_GlassProcessing_SetTimeMarkManufact.sql
-- ============================================================
if object_id(N'dbo.trg_GlassProcessing_SetTimeMarkManufact', N'TR') is not null
    drop trigger dbo.trg_GlassProcessing_SetTimeMarkManufact
go

-- Гарантия что установим TimeManufact после того как проставим готовность
create trigger dbo.trg_GlassProcessing_SetTimeMarkManufact
on dbo.GlassProcessing
after insert, update
as
begin
    set nocount on

    -- Защита от повторного входа после update внутри триггера
    if trigger_nestlevel() > 1
        return

    update GP
    set
        GP.TimeMarkManufact =
            case
                -- Готовность только что поставили
                when isnull(I.bFinished, 0) = 1
                 and isnull(D.bFinished, 0) = 0
                then
                    case
                        -- Новая запись, дата уже передана приложением
                        when D.ID is null 
                         and I.TimeMarkManufact is not null
                            then I.TimeMarkManufact

                        -- При обновлении приложение передало новую дату
                        when D.ID is not null
                         and I.TimeMarkManufact is not null
                         and
                         (
                             D.TimeMarkManufact is null
                             or I.TimeMarkManufact <> D.TimeMarkManufact
                         )
                            then I.TimeMarkManufact

                        -- Когда в диалге ИзоГласс просто поставили галку готовности, а дату не передали
                        else getdate()
                    end

                -- Готовность сняли
                when isnull(I.bFinished, 0) = 0
                 and isnull(D.bFinished, 0) = 1
                    then null

                else GP.TimeMarkManufact
            end
    from dbo.GlassProcessing GP
    inner join inserted I on I.ID = GP.ID
    left join deleted D on D.ID = I.ID
    where
        (
            isnull(I.bFinished, 0) = 1
            and isnull(D.bFinished, 0) = 0
        )
        or
        (
            isnull(I.bFinished, 0) = 0
            and isnull(D.bFinished, 0) = 1
        )
end
go

go
print convert(varchar, getdate(), 20) + ' : finish Trigger\trg_GlassProcessing_SetTimeMarkManufact.sql'
go

print convert(varchar, getdate(), 20) + ' : update script finished'
go
