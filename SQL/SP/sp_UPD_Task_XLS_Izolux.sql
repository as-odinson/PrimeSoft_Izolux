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
