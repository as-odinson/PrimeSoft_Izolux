if object_id(N'dbo.w_Invoice_4_IZO', N'V') is not null
  drop view dbo.w_Invoice_4_IZO
go

create view dbo.w_Invoice_4_IZO  
-- Вьюха для распечатки счетов-фактур, оптимизированная для больших таблиц и выборок на одну накладную  
-- вариант от 01.11.06  
-- вариант от 08.11.06  
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
--Временные  
--    1 as idTransport,  
--Task  
  Task.ID                  as TaskID,  
  Task.ID                  as idTask,  
  Task.Num                 as TaskNum,  
  Task.AccountNum          as TaskAccountNum,  
  Task.Date                as TaskDate,  
  Task.NumCalcFact,  
  dbo.f_LeaveOnlyDigits(Task.NumCalcFact,0) as NumCalcFact_OnlyDigits,  
  Task.DateComplite,  
  Task.Commentary          as CommentTask,  
  LastShip.idShip,
  LastShip.DateShip,
--Client  
  case when IsNull(Client.NameFull, '') != '' then Client.NameFull else IsNull(Client.Name, '') end as ClientName,  
  Client.NameFull          as ClientNameFull,  
  Client.DNum              as DNum,  
  Client.Adress            as ClientAdress,  
  Client.AdressSubDiv      as ClientAdressSubDiv,  
  Client.AdressDeliv       as ClientAdressDeliv,  
  CB_C.RS                  as ClientRS,  
  BK_C.Name                as ClientBank,  
  Client.UNN               as ClientUNN,  
  BK_C.BIC                 as ClientBIC,  
  CB_C.KS                  as ClientKS,  
  Client.Tel               as ClientTEL,  
  Client.KPP               as ClientKPP,  
  Client.OKOHX             as ClientOKOHX,  
  Client.OKPO              as ClientOKPO,  
  CC.ContractNum           as ClinetDogNum,  
  CC.Date                  as ClinetAgreementDate,  
  Client.CertificateNDS    as ClinetCertNDS,  
  
--Seller  
  CB_S.KS                  as SellerKS,  
  Seller.UNN               as SellerUNN,  
  BK_S.BIC                 as SellerBIC,  
  Seller.Name              as SellerName,  
  Seller.NameFull          as SellerNameFull,  
  Seller.Adress            as SellerAdress,  
  Seller.City              as SellerCity,  
  CB_S.RS                  as SellerRS,  
  BK_S.Name                as SellerBank,  
  Seller.Tel               as SellerTel,  
  Seller.KPP               as SellerKPP,  
  Seller.OKOHX             as SellerOKOHX,  
  Seller.OKPO              as SellerOKPO,  
  Seller.AccountantName    as SellerAccountantName,  
  Seller.ChiefName         as SellerChiefName,  
  Seller.CertificateNDS    as SellerCertNDS,  
  
--Shipper  
  CB_SH.KS                 as ShipperKS,  
  Shipper.UNN              as ShipperUNN,  
  BK_SH.BIC                as ShipperBIC,  
  Shipper.Name             as ShipperName,  
  Shipper.NameFull         as ShipperNameFull,  
  Shipper.Adress           as ShipperAdress,  
  Shipper.City             as ShipperCity,  
  CB_SH.RS                 as ShipperRS,  
  BK_SH.Name               as ShipperBank,  
  Shipper.Tel              as ShipperTel,  
  Shipper.KPP              as ShipperKPP,  
  Shipper.OKOHX            as ShipperOKOHX,  
  Shipper.OKPO             as ShipperOKPO,  
  Shipper.AccountantName   as ShipperAccountantName,  
  Shipper.ChiefName        as ShipperChiefName,  
  Shipper.CertificateNDS   as ShipperCertNDS,  
--Consignee  
  CB_CO.KS                 as ConsigneeKS,  
  Consignee.UNN            as ConsigneeUNN,  
  BK_CO.BIC                as ConsigneeBIC,  
  Consignee.Name           as ConsigneeName,  
  Consignee.NameFull       as ConsigneeNameFull,  
  Consignee.Adress         as ConsigneeAdress,  
  Consignee.City           as ConsigneeCity,  
  CB_CO.RS                 as ConsigneeRS,  
  BK_CO.Name               as ConsigneeBank,  
  Consignee.Tel            as ConsigneeTel,  
  Consignee.KPP            as ConsigneeKPP,  
  Consignee.OKOHX          as ConsigneeOKOHX,  
  Consignee.OKPO           as ConsigneeOKPO,  
  Consignee.AccountantName as ConsigneeAccountantName,  
  Consignee.ChiefName      as ConsigneeChiefName,  
  Consignee.CertificateNDS as ConsigneeCertNDS,  
  Consignee.AdressSubDiv   as ConsigneeAdressSubDiv,  
--Project  
  ProjectGroup.PriceOfUnit,  
  ProjectGroup.Num,  
  ProjectGroup.PriceAll,      -- Сумма без НДС  
  ProjectGroup.NDS,           -- Сумма НДС  
  ProjectGroup.PriceWithNDS,  -- Всего с НДС  
  ProjectGroup.PriceByM,  
  ProjectGroup.PriceNoNDS_M2,  
  ProjectGroup.PriceWithNDS_M2,  
  
  CAST ( ProjectGroup.MassSum AS decimal( 15,3 )) as MassSum,  
  ProjectGroup.nCountPos,  
  ProjectGroup.nCount      as nCountSum,  
  ProjectGroup.Width,  
  ProjectGroup.Height,  
  ProjectGroup.AreaSum,  
  ProjectGroup.Type,  
  ProjectGroup.idGlass1,  
  ProjectGroup.idGlassFrame1,  
  ProjectGroup.idGlass2,  
  ProjectGroup.idGlassFrame2,  
  ProjectGroup.idGlass3,  
  ProjectGroup.bIsArgon1,  
  ProjectGroup.bIsArgon2,  
  ProjectGroup.Glass1Name,  
  ProjectGroup.GlassFrame1Name,  
  ProjectGroup.Glass2Name,  
  ProjectGroup.GlassFrame2Name,  
  ProjectGroup.Glass3Name,  
  ProjectGroup.GlassFrame3Name,  
  ProjectGroup.Glass4Name,  
  ProjectGroup.Commentary     as ProjComment,  
  ProjectGroup.CommentClient  as Mark,  
  ProjectGroup.CamCount,  
  
  ES.IsEnergySafe,  
  
  case   
    when ProjectGroup.CamCount = 0                         then 'Стекло в нарезку'  
    when ProjectGroup.CamCount = 1 and ES.IsEnergySafe = 1 then 'Однокамерный энергосберегающий стеклопакет'  
    when ProjectGroup.CamCount = 2 and ES.IsEnergySafe = 1 then 'Двухкамерный энергосберегающий стеклопакет'  
    when ProjectGroup.CamCount = 1                         then 'Однокамерный стеклопакет'  
    when ProjectGroup.CamCount = 2                         then 'Двухкамерный стеклопакет'  
  end as CamCountDescription,  
    
  case   
    when ProjectGroup.CamCount = 0                         then 80.00  
    when ProjectGroup.CamCount = 1 and ES.IsEnergySafe = 1 then 75.00  
    when ProjectGroup.CamCount = 2 and ES.IsEnergySafe = 1 then 65.00  
    when ProjectGroup.CamCount = 1                         then 80.00  
    when ProjectGroup.CamCount = 2                         then 72.00  
  end as LightTransmissionCoefficient,  
   
  case   
    when ProjectGroup.CamCount = 0                         then 0.32  
    when ProjectGroup.CamCount = 1 and ES.IsEnergySafe = 1 then 0.58  
    when ProjectGroup.CamCount = 2 and ES.IsEnergySafe = 1 then 0.72  
    when ProjectGroup.CamCount = 1                         then 0.32  
    when ProjectGroup.CamCount = 2                         then 0.44  
  end as HeatResistance,  
  
  case   
    when ProjectGroup.CamCount = 0                         then -45.00  
    when ProjectGroup.CamCount = 1 and ES.IsEnergySafe = 1 then -45.00  
    when ProjectGroup.CamCount = 2 and ES.IsEnergySafe = 1 then -45.00  
    when ProjectGroup.CamCount = 1                         then -45.00  
    when ProjectGroup.CamCount = 2                         then -45.00  
  end as DewPoint,  
  
  case   
    when ProjectGroup.CamCount = 0                         then 25.00  
    when ProjectGroup.CamCount = 1 and ES.IsEnergySafe = 1 then 26.00  
    when ProjectGroup.CamCount = 2 and ES.IsEnergySafe = 1 then 28.00  
    when ProjectGroup.CamCount = 1                         then 25.00  
    when ProjectGroup.CamCount = 2                         then 27.00  
  end as SoundInsulation,  
  
--Прочие  
  DepotSubDivision.Name  as DepotName,  
  DepotSubDivision.ManagerName,  
  DepotSubDivision.Tel   as DepotSubDivisionTel,  
  DepotSubDivision.KPP   as DepotSubDivisionKPP,  
  DepotSubDivision.InvoiceChiefName ,  
  DepotSubDivision.InvoiceAccountantName,  
  DepotSubDivision.AddTo_NumInvoice,  
  DepotSubDivision.InvoiceResponsName_1,  
  DepotSubDivision.InvoiceResponsName_2,  
  DepotSubDivision.InvoiceOrderNum_1,  
  DepotSubDivision.InvoiceOrderNum_2,  
  DepotSubDivision.InvoiceOrderDate_1,  
  DepotSubDivision.InvoiceOrderDate_2,  
  case  when IsPriceByCount = 1  
        then 'шт.'  
        else 'кв.м.'  
  end                    as UnitName,  
  case  when IsPriceByCount = 1  
        then 'шт.'  
        else 'кв.м.'  
  end                    as Unit,  
  G1.Name                as GlassFrame1,  
--Расчетные  
  convert(varchar(2), NDS.NDS) + ' %' as tax_rate,  
  1                      as Row,  
  
  case  when IsPriceByCount = 1  
        then ProjectGroup.nCount  
        else ProjectGroup.AreaSum  
  end   as CountUnit,  
  
  case  when IsPriceByCount = 1  
        then ProjectGroup.nCount  
        else ProjectGroup.AreaSum  
  end   as kvo,              -- для совместимости с аксцесом  
  
  -- Имя для счёт-фактуры:  
  cast(ProjectGroup.Num as varchar) + '.' +  
   case when IsNull(Product.Type, 0) = 4  
        then ProjectGroup.GPName  
        when IsNull(Product.Type, 0) > 1  
        then Product.Name  
  else  
  
  --case when IsNull(G2.Name, '') = '' then 'Стекло ' else 'Стеклопакет ' end +  
  ProjectGroup.CamCountText  + ' ' +  
  
  ProjectGroup.GPName  
  + ' , '  
  + cast(ProjectGroup.Width  as varchar) + 'x'  
  + cast(ProjectGroup.Height as varchar) + ', '  
  + cast(ProjectGroup.nCount as varchar) + 'шт.'  
  + ProjectGroup.RasInfoText  
  /*+ IsNull (case ProjectGroup.Val  
              when 0 then '.'  
              else ',' + cast(ProjectGroup.Val as varchar) + 'шпр.секц.'  
            end, '.'  
           )   */  
  end as naim,  
  
  -- Имя для счёт-фактуры:  
  case when IsNull(Product.Type, 0) = 4  
       then ProjectGroup.GPName  
       when IsNull(Product.Type, 0) > 1  
       then Product.Name  
       else ProjectGroup.CamCountText  
         /*  
         case when IsNull(G2.Name, '') = ''  
         then 'Стекло '  
         else 'Стеклопакет '  
         end  
         */  
  
  +  ProjectGroup.GPNameNoM1  
  + ' , '  
  + cast(ProjectGroup.Width  as varchar) + 'x'  
  + cast(ProjectGroup.Height as varchar) + ', '  
  + cast(ProjectGroup.nCount as varchar) + 'шт.'  
  + ProjectGroup.RasInfoText   
  /*IsNull (case ProjectGroup.Val  
              when 0 then '.'  
              else ',' + cast(ProjectGroup.Val as varchar) + 'шпр.секц.'  
            end, '.'  
           )*/   
  end as [Name],  
      
  -- 28.03.2014 [YK] Наименование без порядкового номера (попросил МаксГласс).  
  case when IsNull(Product.Type, 0) = 4 then ProjectGroup.GPName  
       when IsNull(Product.Type, 0) > 1 then Product.Name  
       else ProjectGroup.CamCountText  
         /*   
         case when IsNull(G2.Name, '') = ''  
         then 'Стекло '  
         else 'Стеклопакет '  
         end   
         */  
  + ProjectGroup.GPName  
  + ' , '  
  + cast(ProjectGroup.Width  as varchar) + 'x'  
  + cast(ProjectGroup.Height as varchar) + ', '  
  + cast(ProjectGroup.nCount as varchar) + 'шт.'  
  + ProjectGroup.RasInfoText   
  --IsNull(case ProjectGroup.Val when 0 then '.' else ',' + cast(ProjectGroup.Val as varchar) + 'шпр.секц.' end, '.')   
    
  end as naim_without_num,  
    
-- второй вариант имени  
  cast(ProjectGroup.Num as varchar) + '.' +  
  case when IsNull(Product.Type, 0) = 4  
       then ProjectGroup.GPName  
       when IsNull(Product.Type, 0) > 1  
       then Product.Name  
  else ProjectGroup.CamCountText  
   /*  
   case when IsNull(G2.Name, '') = ''  
   then 'Стекло '  
   else 'Стеклопакет '  
   end   
   */  
  + ProjectGroup.GPName  
  + ' , '  
  + cast(ProjectGroup.Width  as varchar) + 'x'  
  + cast(ProjectGroup.Height as varchar) + ', '  
  + cast(ProjectGroup.AreaSum / case ProjectGroup.nCount when 0 then 1 else ProjectGroup.nCount end as varchar) + ' кв.м.'  
  + ProjectGroup.RasInfoText   
  --IsNull(case ProjectGroup.Val when 0 then '.' else ',' + cast(ProjectGroup.Val as varchar) + 'шпр.секц.' end, '.')   
    
  end as naim2,  
  
  --[SE] Третий вариант имени  
 cast(ProjectGroup.Num as varchar) + '.' +  
  case when IsNull(Product.Type, 0) = 4  
       then ProjectGroup.GPName  
       when IsNull(Product.Type, 0) > 1  
       then Product.Name  
  else  
   case when IsNull(G2.Name, '') = ''  
        then 'Стекло '  
        when IsNull(G3.Name, '') = ''  
        then 'СПО '  
   else 'СПД '  
   end +  
  
  ProjectGroup.GPName  
  + ' , '  
  + cast(ProjectGroup.Width  as varchar) + 'x'  
  + cast(ProjectGroup.Height as varchar) + ', '  
  + cast(ProjectGroup.nCount as varchar) + 'шт.'  
  + ProjectGroup.RasInfoText  
  --IsNull (case ProjectGroup.Val when 0 then '.' else ',' + cast(ProjectGroup.Val as varchar) + 'шпр.секц.'  end, '.' )   
    
  end as naim3,  
  
  ProjectGroup.GPName as Name_M1,  
  
  IsNull(DepotSubDivision.Address, IsNull(Seller.AdressSubDiv, Seller.Adress)) as SubDivisionAddress,  
  
  IsNull(DepotSubDivision.KPP, Seller.KPP)     as SubDivisionKPP,  
  Task.Komission,  
  Task.DatePayDoc,  
  ProjectGroup.Num         as PrjNum,  
  Task.Price               as PriceTask,  
  
  -- Вид стеклопакета:  
  
  ProjectGroup.ProjGPName as ProjGPName,  
  ProjectGroup.GPName as GPName,  
  ProjectGroup.GPName  
  + ','  
  + cast(ProjectGroup.Width  as varchar) + 'x'  
  + cast(ProjectGroup.Height as varchar) as GPNameSize,  
  ProjectGroup.idProd,  
  CVC.d_iNum                             as bVisibleProjComment,  
  ProjectGroup.RasInfoText,  
  ProjectGroup.GPNameStr,  
  NDS.Name                               as NDSOutName,  
  Product.Type                           as ProductType,  
  IsNull(TDT.SumDepTransAggregated, 0) as SumDepTrans  
from  
  Task  
  inner join Client Seller     on Seller.ID    = Task.idSeller  
  inner join Client            on Client.ID    = Task.idClient  
  inner join NDS               on NDS.ID       = Task.idNDS  
  left  join ClientContract CC on CC.ID        = Task.idClientContract  
  left  join Client Shipper    on Shipper.ID   = Task.idShipper  
  left  join Client Consignee  on Consignee.ID = Task.idConsignee  
  left  join ClientBank CB_C   on CB_C.ID      = Task.idClientBank_Client    -- 111222 [SB] Теперь KS   и RS  лежат тут.  
  left  join Bank BK_C         on BK_C.ID      = CB_C.idBank                 -- 111222 [SB] Теперь Bank и BIC лежат тут.  
  left  join ClientBank CB_S   on CB_S.ID      = Task.idClientBank_Seller    -- 111222 [SB] Теперь KS   и RS  лежат тут.  
  left  join Bank BK_S         on BK_S.ID      = CB_S.idBank                 -- 111222 [SB] Теперь Bank и BIC лежат тут.  
  left  join ClientBank CB_SH  on CB_SH.ID     = Task.idClientBank_Shipper   -- 111222 [SB] Теперь KS   и RS  лежат тут.  
  left  join Bank BK_SH        on BK_SH.ID     = CB_SH.idBank                -- 111222 [SB] Теперь Bank и BIC лежат тут.  
  left  join ClientBank CB_CO  on CB_CO.ID     = Task.idClientBank_Consignee -- 111222 [SB] Теперь KS   и RS  лежат тут.  
  left  join Bank BK_CO        on BK_CO.ID     = CB_CO.idBank                -- 111222 [SB] Теперь Bank и BIC лежат тут.  
  inner join (  
                    select  
                      Project.ID,  
                      Project.idTask,  
                      Project.idProd,  
                      Project.Num,  
                      Project.Width,  
                      Project.Height,  
                      dbo.f_GetGPFormula(Project.ID, 'M1', 0, 0) as GPName,  
                      dbo.f_GetGPFormula(Project.ID, '',   0, 0) as GPNameNoM1,  
                      Project.GPName                         as ProjGPName,  
                      Project.PriceNoNds                     as PriceOfUnit,  
                      Project.PriceByM                       as PriceByM,  
                      Project.PriceNoNDS_M2,  
                      Project.PriceWithNDS_M2,  
                      sum(Project.SumNoNDS           )       as PriceAll,      -- Сумма без НДС  
                      sum(Project.SumNDS             )       as NDS,           -- Сумма НДС  
                      sum(Project.SumWithNDS         )       as PriceWithNDS,  -- Всего с НДС  
                      sum(Project.Mass * Project.nCount)     as MassSum,  
                      sum(Project.nCount             )       as nCountPos,  
                      sum(Project.nCount             )       as nCount,  
                      sum(Project.Area*Project.nCount)       as AreaSum,  
                      sum(w_propObjectAll_nCountSection.Val) as Val,  
                      Project.Type,  
                      Project.idGlass1,  
                      Project.idGlassFrame1,  
                      Project.idGlass2,  
                      Project.idGlassFrame2,  
                      Project.idGlass3,  
                      Project.bIsArgon1,  
                      Project.bIsArgon2,  
                      dbo.f_GetGPItemInfo(Project.ID, 1, 5)                as Glass1Name,  
                      dbo.f_GetGPItemInfo(Project.ID, 1, 6)                as GlassFrame1Name,  
                      dbo.f_GetGPItemInfo(Project.ID, 2, 5)                as Glass2Name,  
                      dbo.f_GetGPItemInfo(Project.ID, 2, 6)                as GlassFrame2Name,  
                      dbo.f_GetGPItemInfo(Project.ID, 3, 5)                as Glass3Name,  
                      dbo.f_GetGPItemInfo(Project.ID, 3, 6)                as GlassFrame3Name,  
                      dbo.f_GetGPItemInfo(Project.ID, 4, 5)                as Glass4Name,  
                      Project.IsPriceByCount,  
                      Project.Commentary,  
                      Project.CommentClient,  
                      case   
                        when Project.CamCount = 0 then 'Стекло'  
                        when Project.CamCount = 1 then 'СПО'  
                        else 'СПД'  
                      end as CamCountText,  
                      Project.CamCount,  
                      dbo.f_GetGPRasInfo(Project.ID, Project.bShpros) as RasInfoText,  
                        
                      case when Project.CamCount = 0 then 'Стекло ' else 'Стеклопакет ' end +  
                      case when Project.CamCount > 0 then ''        else ''             end +  
                      Project.GPName + ' ' + ltrim(str(Project.Width)) + ' x ' +  ltrim(str(Project.Height)) +  
                      case when Project.bShpros <> 0 then ' ' + dbo.f_GetGPRasInfo(Project.ID, Project.bShpros) +   
                                                          ' ' + ltrim(str((select sum(LengReal) from RasShrink where idProject = Project.ID))) +   
                                                          'мм'   
                      else ''   
                      end as GPNameStr  
                    from  
                      Project left outer join w_propObjectAll_nCountSection on Project.ID = w_propObjectAll_nCountSection.idProject  
                    group by  
                      Project.idTask,  
                      Project.idProd,  
                      Project.IsPriceByCount,  
                      Project.Height,  
                      Project.Width,  
                      Project.GPName,  
                      Project.ID,  
                      Project.idGlass1,  
                      Project.idGlassFrame1,  
                      Project.idGlass2,  
                      Project.idGlassFrame2,  
                      Project.idGlass3,  
                      Project.Num,  
                      Project.bIsArgon1,  
                      Project.bIsArgon2,  
                      Project.PriceNoNDS,  
                      Project.PriceByM,  
                      Project.PriceNoNDS_M2,  
                      Project.PriceWithNDS_M2,  
                      Project.Type,  
                      Project.IsPriceByCount,  
                      Project.Commentary,  
                      Project.CommentClient,  
                      case  
                        when Project.IsPriceByCount = 1 then convert(decimal(9, 2), Project.Price / (case Project.nCount when 0 then 1   else Project.nCount end))  
                        when Project.IsPriceByCount = 0 then convert(decimal(9, 2), Project.Price / (case Project.Area   when 0 then 0.1 else Project.Area   end))  
                      end,  
                      dbo.f_GetGPFormula(Project.ID, 'M1', 0, 0),  
                      dbo.f_GetGPFormula(Project.ID, '',   0, 0),  
                      dbo.f_GetGPRasInfo(Project.ID, Project.bShpros),  
                      Project.CamCount,  
                      Project.bShpros,  
                      Project.nCount  
                   )  as ProjectGroup                 on ProjectGroup.idTask = Task.ID  
  outer apply (
    select top (1)
        Tr1.idShip,
        S1.Date as DateShip
    from Transport Tr1
    left join Ship S1 on S1.ID = Tr1.idShip
    where Tr1.idTask = Task.ID
    order by S1.Date desc, Tr1.idShip desc
  ) LastShip
  left outer join (  
                    select  
                        P.ID as ProjectID,  
                        CASE  
                            WHEN G1_e.IsEnergySafe = 1 OR G2_e.IsEnergySafe = 1 OR G3_e.IsEnergySafe = 1 THEN 1  
                            ELSE 0  
                        END AS IsEnergySafe  
                    from Project P  
                    left outer join Product G1_e on G1_e.ID = P.idGlass1  
                    left outer join Product G2_e on G2_e.ID = P.idGlass2  
                    left outer join Product G3_e on G3_e.ID = P.idGlass3  
                  ) as ES on ES.ProjectID = ProjectGroup.ID   
  left  outer join DepotSubDivision                   on DepotSubDivision.ID = Task.idDepotSubDivision  
  left  outer join Product                            on Product.ID          = ProjectGroup.idProd  
  left  outer join Product G1                         on G1.ID               = ProjectGroup.idGlass1  
  left  outer join Product F1                         on F1.ID               = ProjectGroup.idGlassFrame1  
  left  outer join Product G2                         on G2.ID               = ProjectGroup.idGlass2  
  left  outer join Product F2                         on F2.ID               = ProjectGroup.idGlassFrame2  
  left  outer join Product G3                         on G3.ID               = ProjectGroup.idGlass3  
  left  outer join Unit                               on Unit.ID             = Product.idUnit  
  left  outer join Config  CVC                        on CVC.Name            = 'bVisibleProjCommentForTN'  
  left  join TaskDepTrans  TDT                        on TDT.idTask   = Task.ID  
where  
  Task.CalcType in(0, 1, 4, 5)  
  