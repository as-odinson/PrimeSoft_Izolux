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