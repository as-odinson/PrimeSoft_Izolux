// Расчёт цены Izolux

var  objPrice;

// Справочник продукции          
var  rcProduct      = new ActiveXObject("ADODB.Recordset"),
     rcFormType     = new ActiveXObject("ADODB.Recordset"),
     rcPricePeriod  = new ActiveXObject("ADODB.Recordset"),  // Прайсы
     sFilter        = new String,
     bLoaded        = 0;


// Загрузить справочники
function LoadReference()
{
  try
  {
    if ( bLoaded == 0 )
    {
      // Продукция для всяких нужд
      sSQL = "select P.ID, P.Name, P.idUnit, P.MinWaste, P.nTypeOper, PG.MinWaste MinWasteProdGroup, PG.bUseRealWaste " +
             "from Product P left join ProductGroup PG on P.idProductGroup = PG.ID  order by P.ID";     
      rcProduct = Prog.GetCachedRC(sSQL);

      // Справочник типов фигур  
      sSQL = "select * from FormType order by ID";     
      rcFormType = Prog.GetCachedRC(sSQL);
      
      // Справочник прайсов
      sSQL = "select * from PricePeriod order by ID";
      rcPricePeriod = Prog.GetCachedRC(sSQL);

      
      bLoaded = 1;
    }
  }
  catch (e)
  {
    Prog.SaveError("JS::LoadReference " + e.message, true);
  }
}

// Загрузить справочник продукции 1 раз
function GetFormTypeCoef(idFormType, nCamCount)
{
  var  fCoef = 0.0;
  try
  {
    if ( bLoaded && idFormType > 0 )
    {
      sFilter = "ID = " + idFormType;   
      rcFormType.MoveFirst(); 
      rcFormType.Find(sFilter, 0, 1);
      
      if ( !(rcFormType.BOF && rcFormType.EOF) )
      {
        var  sFieldName    = nCamCount ? "Coef" : "CuttingCoef",
             sFormTypeName = rcFormType.Fields.Item("Name").Value;
        
        fCoef = rcFormType.Fields.Item(sFieldName).Value;
                  
        Prog.AddProtocol("\n Коэф. наценки за тип фигуры (" + sFormTypeName + 
                         ") = " + fCoef.toFixed(2) + 
                         " проц. " + (nCamCount ? "для СП" : "для стекла в нарезку\n"));
      }
    }
  }
  catch (e)
  {
    Prog.SaveError("JS::GetFormTypeCoef " + e.message, true);
  }
  return fCoef;
}   

function Prog::GlassPackCalcPrice()
{
  try
  {
    //Prog.SaveError("Prog::GlassPackCalcPrice() - Begin", false);
    // [ab] Будут ошибки, будет валиться - раскомментировать чтобы узнать где

    if ( !objPrice )
      InitObjPrice();

    var  nCamCount = GP.GetShort("CamCount"),
         iWidth    = GP.GetLong("Thickness"),
         fArea     = GP.GetFloat("Area");

    Prog.Protocol = "";
    Prog.AddProtocol("\nРасчет по клиенту <" + Client.Name + ">  (ID = " + Prog.idClient +  ")" );
    Prog.AddProtocol("\nСП: " + GP.GetString("GPName"));
    Prog.AddProtocol("\n\nКол-во СП: " + GP.GetLong("nCount"));
    Prog.AddProtocol("\nКол-во камер: " + nCamCount);
    Prog.AddProtocol("\nТолщина: " + GP.GetLong("Thickness"));
    Prog.AddProtocol("\nШирина: " + GP.GetLong("Width") + ", Высота: " + GP.GetLong("Height"));
    Prog.AddProtocol("\nПлощадь: " + Math.round(fArea * 1000) / 1000.);

    // Загрузим справочники
    LoadReference();

    if ( objPrice && Client.nTypeCalcPrice != 2 )  // Считать по прайсу?
    {
      GP.IsPriceByCount = 0;    

      var fAddGNS         = 0, // Доплаты за нестандартное стекло или нарезку,
          fAddGNSFixed    = 0, // Доплаты за нестандартное стекло или нарезку если категория площади с фиксированной ценой
          fAddG           = 0, // Доплаты за стекло.
          fAddGFixed      = 0, // Доплаты за стекло если категория площади с фиксированной ценой
          fAddA           = 0, // Доплата за аргон
          fAddP           = 0, // Доплата за пластиковую рамку
          fPriceM2        = 0,
          idG1            = GP.GetLong("idGlass1"),
          idG2            = GP.GetLong("idGlass2"),
          // idG3            = GP.GetLong("idGlass3"),
          idG = 0,
          // idG2            = GP.GetGlassID(GP.GetString("GUID"), 2),
          idG3            = GP.GetGlassID(GP.GetString("GUID"), 3),
          idG4            = GP.GetGlassID(GP.GetString("GUID"), 4),
          idF1            = GP.GetLong("idGlassFrame1"),
          idF2            = GP.GetLong("idGlassFrame2"),
          bFramePlastic1  = GP.GetProductBool(idF1, "bFramePlastic", false),  // Пластиковая рамка
          bFramePlastic2  = GP.GetProductBool(idF2, "bFramePlastic", false),
          idGlassPackType = objPrice.GetGlassPackType(idG1, idF1, idG2, idF2, idG3, bA1, bA2),
          bStructural = GP.GetBool("bStructural"),          // Пакет с зубом?
          bA1             = GP.GetBool("bIsArgon1"),        // Аргон.
          bA2             = GP.GetBool("bIsArgon2"),
          // sG1             = GP.GetProductString(idG1, "Name", ""),
          // sG2             = GP.GetProductString(idG2, "Name", ""),
          // sG3             = GP.GetProductString(idG3, "Name", ""),
          iFilmCount      = GP.GetFilmCount(GP.GetString("GUID")),  // Кол-во пленок.
          fAddFilm        = 0,  // Доплаты за пленки.
          bCalcValues     = 1,  // Надо ли пересчитывать коэф. наценки, брать цену М2 с НДС из прайса?
          fAddArgon       = 0,
          fAddF           = 0,  // Доплата на теплую(TР) рамку.
          fAddFrameRange  = 0,
          DiffFrameCoef   = 1,
          AreaCoef        = 1,
          TemplateCoef    = 1,
          NonStandardCoef = 1,
          nNumFrame       = 0,
          fCoefArea       = 0.,  // Коэф. наценки в процентах за кв.м, зависит от площади и ее категории
          fAddArea        = 0.,  // Надбавка в рублях к цене за кв.м, зависит от площади и ее категории
          fPriceS         = GP.GetFloat("PriceS"),
          idAreaCategory  = 0,
          bPiecePrice     = false, // Штучная цена?
          bFixedPrice     = false, // Фиксированная цена
          bPriceChange    = false, // Цена была изменена с учетом фиксированной площади
          fMaxAreaValue   = 0,     //Максимальная площадь
          fMinAreaValue   = 0,     //Минимальная площадь
          fSideValue      = 0, 
          width          = GP.GetLong("Width"),
          height         = GP.GetLong("Height"),
          sProtocolProcess = "",
          fCoefFormType   = 1,
          bUserGlass_G1   = GetProjectItemBool(1, 5, "bUserGlass"),
          bUserGlass_G2   = GetProjectItemBool(2, 5, "bUserGlass"),
          bUserGlass_G3   = GetProjectItemBool(3, 5, "bUserGlass"),
          bObjectPrice    = 0.0,                                     // Объектовый прайс
          fPriceAdd_Dop     = Prog.rcProject("PriceAddM2_Dop").Value,
          fPriceRebate_Dop  = Prog.rcProject("PriceRebateM2_Dop").Value,
          idProduct         = Prog.rcProject("idProduct").Value,
          idPricePeriod     = Prog.idPricePeriod,
          IsPriceByCount    = GP.IsPriceByCount,
          bNonStandard      = GP.IsNonStandard,
          constSealantDepth = 4.5, // Константное значение глубины заливки герметика.
          nCountProject     = GP.GetProjectCount(),
          bEquallyMinValue  = Prog.Select_Int("select d_iNum from config where Name = 'nTypeDefineAreaGP'", "d_iNum", true);

      // Вытаскиваем id категории площади из таска
      if ( Prog.rcTask && Prog.rcTask.State == 1 && !Prog.rcTask.BOF && !Prog.rcTask.EOF)
        idAreaCategory  = Prog.rcTask("idAreaCategory").Value;

      //Prog.AddProtocol("\r\nidAreaCategory: " + idAreaCategory);

      bPiecePrice   = objPrice.GetGPAreaIsFixedPriceByID(fArea, idAreaCategory, 0, 0, idPricePeriod);
      fMaxAreaValue = objPrice.GetGPAreaMaxValueByID    (fArea, idAreaCategory, 0, 0, idPricePeriod);
      fMinAreaValue = objPrice.GetGPAreaMinValueByID    (fArea, idAreaCategory, width, height, idPricePeriod);
      bFixedPrice   = idProduct > 0 ? false : bPiecePrice;
      //Prog.AddProtocol("idAreaCategory: " + idAreaCategory + "\n");
      //Prog.AddProtocol("idPricePeriod: " + idPricePeriod + "\n");

      /*
      if ( fMinAreaValue != 0 || fMaxAreaValue != 0 )
        Prog.AddProtocol(" (" + fMinAreaValue.toFixed(2) + " < площадь <= " +  fMaxAreaValue.toFixed(2) + ") \n");
      else
        Prog.AddProtocol("Категория наценки для этой площади отсутствует. \n");
      */

      //fCoefArea = objPrice.GetGPAreaCoef(fArea, false, Prog.idPricePeriod);
      //Prog.AddProtocol("fCoefArea: " + fCoefArea + "\n");
      
      // Передадим значения ширины высоты если на выходе будет значение тогда у нас введены параметры сторон
      fSideValue    = objPrice.GetGPAreaMaxValueByID    (fArea, idAreaCategory, width, height, idPricePeriod);

      if ( bFixedPrice ) // Штучная цена, тогда запишем фиксированную площадь
      {
        GP.FixedArea  = fMaxAreaValue;
      
        Prog.AddProtocol("\r\n  Фиксированная цена: ");
        Prog.AddProtocol(bPiecePrice ? "да" : "нет");
        Prog.AddProtocol("\r\n  Максимальная площадь: "          + fMaxAreaValue.toFixed(2));
        Prog.AddProtocol("\r\n  Максимальное значение стороны: " + fSideValue.toFixed(2) + "\r\n");
      } 
      
      // fCoefArea = objPrice.GetGPAreaAndSideCoefByID(fArea, width, height, idAreaCategory, bEquallyMinValue, idPricePeriod);

      if ( GP.ChangedFieldName == "PriceNDS"  ||  GP.ChangedFieldName == "PriceByM"  ||
           GP.ChangedFieldName == "PriceS"    ||  GP.ChangedFieldName == "PriceCoef" )
      {
        if ( GP.ChangedFieldName == "PriceNDS" )
          Prog.AddProtocol("\n\nЦена за М2 с НДС: "  + GP.GetFloat("PriceNDS" ) + " была введена вручную");
        else
        if ( GP.ChangedFieldName == "PriceByM" )
          Prog.AddProtocol("\n\nЦена М2 по прайсу: " + GP.GetFloat("PriceByM" ) + " была введена вручную");
        else
        if ( GP.ChangedFieldName == "PriceS" )
          Prog.AddProtocol("\n\nЦена за раскладку: " + GP.GetFloat("PriceS"   ) + " была введена вручную");
        else
        if ( GP.ChangedFieldName == "PriceCoef" )
          Prog.AddProtocol("\n\nКоэф. наценки: " + GP.GetFloat("PriceCoef") + " был введен вручную");
        bCalcValues = 0;
      }

      if ( GP.ChangedFieldName != "PriceNDS"  &&  fPriceS  &&  GP.ChangedFieldName != "PriceS" )
        Prog.AddProtocol("\nСтоимость раскладки: " + fPriceS.toFixed(2));

      bObjectPrice = GetPricePeriodValue(Prog.idPricePeriod, "bObjectPrice");

      // Возьмём цену по объектовому прайсу, с стандартными изделиями действуем также:
      if ( bObjectPrice || idProduct > 0 )
      {
        var  GPName = GP.GetString("GPName");

        fPriceM2 = objPrice.GetPriceOtherProductByName(Prog.idClient, GPName, Prog.idPricePeriod, Prog.idPricePeriodDiscount, 0, 0);

        if (idProduct > 0)
          Prog.AddProtocol("Цена стандартное изделие за <" + GPName + "> состовляет: " + fPriceM2 + " руб");
        else
          Prog.AddProtocol("Цена за <" + GPName + "> по Объектовому прайсу составляет: " + fPriceM2 + " руб");
        
        // Применим наценку на м2 к цене
        if ( fPriceAdd_Dop )
        {
          fPriceM2 += fPriceAdd_Dop;
          Prog.AddProtocol("\nК цене " + fPriceM2 + " применена наценка на м2: " + fPriceAdd_Dop + "; ");
        }
          
        // Применим скидку на м2 к цене
        if ( fPriceRebate_Dop )
        {
          fPriceM2 -= fPriceRebate_Dop
          Prog.AddProtocol("\nК цене " + fPriceM2 + " применена скидка на м2: " + fPriceRebate_Dop + "; ");
        }

        // Будет примененно только для цены СП, где стоит фиксированная цена и попадает в диапазон минимальной площади
        if ( bFixedPrice )  // Если фиксированная цена, то брать цену как за максимальную площадь диапазона
        {
          Prog.AddProtocol("\nУстановлена фиксированная цена площадь изменена с: " + fArea.toFixed(2) + " на: " + fMaxAreaValue.toFixed(2));
          Prog.AddProtocol("\nЦена = " + fPriceM2  + " * " + fMaxAreaValue.toFixed(2) + "=" + (fPriceM2 * fMaxAreaValue).toFixed(2));
        }

        if ( bPiecePrice  )  //Штучная цена ?
          GP.IsPriceByCount = 1;
      }
      // Не объектовый прайс считаем по обычному алгоритму
      else 
      {        
        // [YK] для стекла в нарезку не надо считать штучную цену

        if ( bCalcValues )
        {
          // наценки на стекла
          for ( numGlass = 1; numGlass <= GP.GetGlassCount(GP.GetString("GUID")); numGlass++)
          {
            var idGlass       = GetProjectItemLong(numGlass, 5, "idProd"),
                idProd        = GetProjectItemLong(numGlass, 8, "idProd"),
                bUserGlass_G  = GetProjectItemBool(numGlass, 5, "bUserGlass"),
                nGlass        = GetProjectItemLong(numGlass, 5, "nGlass"),
                idProjectItem = GetProjectItemLong(numGlass, 5, "ID")
                isTriplexFilm = CheckIsTriplexFilm(nGlass),  // Проверяем возможно стекло триплекс собственного производства
                GPThickness   = GP.GetProductLong(idGlass, "Thickness", 0);

            // Обнуляем значения
            fAddG       = 0;
            fAddGFixed  = 0;
            
            // Если триплекс  - пройдемся по стеклам триплекса
            if ( idGlass == -2 )
            {
              fAddG = GetTripGlassAddPrice(numGlass);
              Prog.AddProtocol("\r\nЦена " + numGlass + " триплексного стекла =" + fAddG);
            }
            // Если  не давальческое  стекло, то считаем цену
            else
            if ( !bUserGlass_G )
            {
              var  curCamCount = nCamCount;

              // Prog.MessageBox("id: " +idProjectItem + "; idProd: " + idProd + "; nGlass: " + nGlass + "; idGlass: " + idGlass);
              // Если триплекс тогда цену необходимо будет брать как за стекло в нарезку
              if ( isTriplexFilm )
                curCamCount = 0;

              fAddG = GetPriceOperationWithoutOperProcessing(numGlass, Prog.idClient, idGlass, idPricePeriod, 0, GP.Area, true);  
              // Наценки за стекла.
              if ( !bPiecePrice )
              {
                // Посмотрим цены обработок, если есть возьмем как основную цену                
                if ( fAddG != 0 )
                  // Если стекло и есть обработка (зак н, зак сп) у которой стоит флаг IsMainPrice выполним замену цены на цену данной обработки
                  Prog.AddProtocol("\nДоплата за замену (idProd: " + idGlass + ")" + numGlass + "-го стекла была заменена на цену обработки: " + fAddG );
                else
                {
                  fAddG = Math.round(objPrice.GetGlassAddPrice(Prog.idClient, idGlass, curCamCount, Prog.idPricePeriod, Prog.idPricePeriodDiscount, bPiecePrice));
                  Prog.AddProtocol("\nДоплата за замену  (idProd: " + idGlass + ")" + numGlass + "-го стекла: " + fAddG);
                }
              }
              else
              {              
                if ( fAddG != 0 )
                  Prog.AddProtocol("\nДоплата за замену " + numGlass + "-го стекла была заменена на цену обработки: " + fAddG );
                else
                {
                  // Флаг штучная цена, выставляется при условии что мы попали в категорию площади с флагом фиксированная цена
                  // А для фиксированной цены, мы должны взять доплату за стекло и добавить к общей сумме поэтому ищем не за штучную цену
                  fAddGFixed = Math.round(objPrice.GetGlassAddPrice(Prog.idClient, idGlass, curCamCount, Prog.idPricePeriod, Prog.idPricePeriodDiscount, false));
                  Prog.AddProtocol("\nДоплата за замену " + numGlass + "-го стекла: " + fAddGFixed);
                }
              }
            }
            // Ну а если это давальческое, то сообщим клиенту
            else
              Prog.AddProtocol("\nДоплата за замену " + numGlass + "-го стекла(давальческого): " + fAddG);
        
            fAddGNS      += fAddG;
            fAddGNSFixed += fAddGFixed;
          }

          if ( fAddGNS > 0 )
            Prog.AddProtocol("\n  Итого доплата за замену стекол: " + fAddGNS + " и " + fAddGNSFixed);


          var rcProjectItem    = Prog.rcProjectItem,
          sFilter              = "guidProject = '" + GP.GetString("GUID") + "'";
          
          rcProjectItem.Filter = sFilter;
          rcProjectItem.Sort   = "Num";

          // Считаем пленки
          for (rcProjectItem.MoveFirst(); !rcProjectItem.EOF; rcProjectItem.MoveNext() )
          {
            var idProd         = rcProjectItem("idProd").Value,
                nType          = rcProjectItem("nType" ).Value;

            // Пленка
            if ( nType == 7 )
              fAddFilm += objPrice.GetMarginFilm(Prog.idClient, idProd, Prog.idPricePeriod, Prog.idPricePeriodDiscount)
          }

          // СЧИТАЕМ РАМКИ
          var  sStr      = new String,
               sTxtSpec3 = new String,
               sTxtSpec4 = new String,
               bCalcTP   = true,
               bNonStandardFrameDetect = false,
               fAddTP    = 0;

          sTxtSpec3 = objPrice.GetTxtSpecOfSpecialMargin(3);  // Достанем аббревиатуру теплой рамки.
          sTxtSpec4 = objPrice.GetTxtSpecOfSpecialMargin(4);  // [YK] Достанем аббревиатуру второй разновидности теплой рамки.
          if ( sTxtSpec3 != "" )
          {
            sStr = GP.GetProductString(idF1, "Name", "");
          
            if ( sStr.toLowerCase().indexOf(sTxtSpec3.toLowerCase()) != -1 )
            {
              bNonStandardFrameDetect = true;
              fAddTP  = Math.round(objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 3, Prog.idPricePeriod, Prog.idPricePeriodDiscount));
              bCalcTP = false;
              fAddF   += fAddTP;  // [YK] Теплая 1-я рамка.
              Prog.AddProtocol("\nДоплата за 1-ю теплую рамку( " + sTxtSpec3 + " ): " + fAddTP);
            }
            sStr = GP.GetProductString(idF2, "Name", "");
            if ( sStr.toLowerCase().indexOf(sTxtSpec3.toLowerCase()) != -1 )
            {
              bNonStandardFrameDetect = true;
              if ( bCalcTP )
                fAddTP = Math.round(objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 3, Prog.idPricePeriod, Prog.idPricePeriodDiscount));
              fAddF += fAddTP  // [YK] Теплая 2-я рамка.
              Prog.AddProtocol("\nДоплата за 2-ю теплую рамку( " + sTxtSpec3 + " ): " + fAddTP);
            }
          }

          bCalcTP = true; //Сбросим флаг

          if ( sTxtSpec4 != "" )
          {
            sStr = GP.GetProductString(idF1, "Name", "");
            if ( sStr.toLowerCase().indexOf(sTxtSpec4.toLowerCase()) != -1 )
            {
              bNonStandardFrameDetect = true;
              fAddTP  = Math.round(objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 4, Prog.idPricePeriod, Prog.idPricePeriodDiscount));
              bCalcTP = false;
              fAddF   = fAddTP;  // Теплая 1-я рамка.
              Prog.AddProtocol("\nДоплата за 1-ю теплую рамку( " + sTxtSpec4 + " ): " + fAddTP);
            }
            sStr = GP.GetProductString(idF2, "Name", "");
            if ( sStr.toLowerCase().indexOf(sTxtSpec4.toLowerCase()) != -1 )
            {
              bNonStandardFrameDetect = true;
              if ( bCalcTP )
                fAddTP = Math.round(objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 4, Prog.idPricePeriod, Prog.idPricePeriodDiscount));
              fAddF += fAddTP;  // Теплая 2-я рамка.
              Prog.AddProtocol("\nДоплата за 2-ю теплую рамку( " + sTxtSpec4 + " ): " + fAddTP);
            }
          }

          // Наценка на пластик
          if ( bFramePlastic1 )
          {
            // Цена за пластиковую рамку
            fAddF  = objPrice.GetPriceAddFrameByPeriod(Prog.idClientParent, idF1, 0, Prog.idPricePeriod, Prog.idPricePeriodDiscount, idGlassPackType, true);
             
            // Доплата за пластиковую рамку
            fAddP  = Math.round(objPrice.GetSpecialMarginByGPType(Prog.idClientParent, 3, Prog.idPricePeriod, Prog.idPricePeriodDiscount, idGlassPackType));
            fAddF += fAddP;  // Пластик 1-я рамка.
           
            Prog.AddProtocol("\r\n Доплата за 1-ю рамку: "  + fAddF.toFixed(2));
             if ( fAddP > 0 )
               Prog.AddProtocol("\r\nДоплата за 1-ю пластиковую рамку: " + fAddP.toFixed(2));
          }

          if ( bFramePlastic2 )
          { 
            // Цена за пластиковую рамку
            fAddF += objPrice.GetPriceAddFrameByPeriod(Prog.idClientParent, 0, idF2, Prog.idPricePeriod, Prog.idPricePeriodDiscount, idGlassPackType, true);
            
            // Доплата за пластиковую рамку
            fAddP += Math.round(objPrice.GetSpecialMarginByGPType(Prog.idClientParent, 3, Prog.idPricePeriod, Prog.idPricePeriodDiscount, idGlassPackType));
            fAddF += fAddP;  // Пластик 2-я рамка.
            
            Prog.AddProtocol("\r\n Доплата за 2-ю рамку: "  + fAddF.toFixed(2));
            if ( fAddP > 0 )
              Prog.AddProtocol("\r\nДоплата за 2-ю пластиковую рамку: " + fAddP.toFixed(2));
          }
        
          if ( fAddF )
            Prog.AddProtocol("\n  Итого доплата за рамки: " + fAddF);


          if ( nCamCount != 0 )  // Стеклопакет?
          { 
            const_chamber_thickness =  // Константные толщины.
                                    //  Для значения с толщиной больше чем у константы добавляется наценка "Увеличение рамки каждые 2мм".
                                    //  Для значения с толщиой меньше чем у константы применяется цена константы
            {
              single_chamber: 24, // для однокамерного СП
              double_chamber: 32  // для двухкамерного СП
            };

            /* 
              - Толщина стеклопакета (СП) определяется только размерами рамок, независимо от толщины стекол.
              - Примеры:
                  - Рамки 10 мм => итоговая толщина СП = 32 мм.
                  - Две рамки по 12 мм => итоговая толщина СП = 34 мм.
              - Даже если стекла имеют другую толщину (например, 6 мм вместо 4 мм), 
                разница в цене уже учтена в стоимости самого стекла, которое используется для замены.
            */
            if ( nCamCount == 3 )
            {
              var constWidthGlass = 8,                                       // Константа для суммарной толщины стандартного стекла в СП. Устанавливаем как для однокамерного пакета (как в, 4-10-4)
                  iWdth1          = GP.GetProductLong(idG1, "Thickness", 0) + GP.GetProductLong(idF1, "Thickness", 0) + GP.GetProductLong(idG2, "Thickness", 0),
                  iWdth2          = GP.GetProductLong(idF1, "Thickness", 0)  // Толщина первой рамки
                                  + constWidthGlass;                          // Толщина стекл в СП

              if (iWdth1 != iWdth2)
              {
                iWdth1 = iWdth2;
                Prog.AddProtocol("\nТолщина СП применена как: " + iWdth1 + " мм ");
                Prog.AddProtocol("\nТрехкамерный пакет, толщина первой однокамерной части: " + iWdth1 + " мм ");
              }
          
              fPriceM2 = Math.round(objPrice.GlassPackPricePeriodForMargin(1, iWdth1, fArea, Prog.idClient, Prog.idPricePeriod, Prog.idPricePeriodDiscount, const_chamber_thickness.single_chamber));
              Prog.AddProtocol("\nСтоимость первой однокамерной части: " + fPriceM2 + " ");

              var fPriceM2_tmp = Math.round(objPrice.GlassPackPricePeriodForMargin(2, iWidth - iWdth1, fArea, Prog.idClient, Prog.idPricePeriod, Prog.idPricePeriodDiscount, const_chamber_thickness.double_chamber));
              Prog.AddProtocol("\nСтоимость второй двухкамерной части: " + fPriceM2_tmp + " "); 
              fPriceM2 += fPriceM2_tmp;

              var fCoefOnThreeCamber = objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 55, Prog.idPricePeriod, Prog.idPricePeriodDiscount);

              fCoefOnThreeCamber = (fCoefOnThreeCamber / 100.);

              if ( fCoefOnThreeCamber != 0 )
              {
                Prog.AddProtocol("\nНаценка на трехкамерный пакет: " + fCoefOnThreeCamber);
                
                NonStandardCoef += fCoefOnThreeCamber; // учтем Коэффициент на площадь
              }
            }
            else if (nCamCount == 2) // Иначе расчет стоимости стеклопакета (СП) с учетом логики толщины рамок
            {
              // Устанавливаем стандартное значение толщины для двухкамерного пакета (как в, 4-10-4-10-4)
              var constWidthGlass = 12;  // Константа для суммарной толщины стандартного стекла в СП.
              
              // Расчет общей толщины СП с учетом толщины стекол и рамок
              var iWdth1 = GP.GetProductLong(idF1, "Thickness", 0) // Толщина первой рамки
                         + GP.GetProductLong(idF2, "Thickness", 0) // Толщина второй рамки
                         + constWidthGlass;                          // Толщина стекл в СП

              // Если толщина не совпадает выведем пользователю информацию
              if (iWdth1 != iWidth)
              {
                iWidth = iWdth1;
                Prog.AddProtocol("\nТолщина СП применена как: " + iWdth1 + " мм ");
              }

              fPriceM2 = Math.round(objPrice.GlassPackPricePeriodForMargin(nCamCount, iWidth, fArea, Prog.idClient, Prog.idPricePeriod, Prog.idPricePeriodDiscount, const_chamber_thickness.double_chamber));
            }
            else
            {
              // Устанавливаем стандартное значение толщины как для однокамерного пакета (как в, 4-10-4)
              var constWidthGlass = 8;  // Константа для суммарной толщины стандартного стекла в СП.
              // Расчет общей толщины СП с учетом толщины стекол и рамок
              var iWdth1 = GP.GetProductLong(idF1, "Thickness", 0) // Толщина первой рамки
                         + constWidthGlass;                        // Толщина стекл в СП

              if (iWdth1 != iWidth)
              {
                iWidth = iWdth1;
                Prog.AddProtocol("\nТолщина СП применена как: " + iWdth1 + " мм ");
              }

              fPriceM2 = Math.round(objPrice.GlassPackPricePeriodForMargin(nCamCount, iWidth, fArea, Prog.idClient, Prog.idPricePeriod, Prog.idPricePeriodDiscount, const_chamber_thickness.single_chamber));
            }
            
            // Применим наценку на м2 к цене
            if ( fPriceAdd_Dop )
            {
              fPriceM2 += fPriceAdd_Dop;
              Prog.AddProtocol("\nК цене " + fPriceM2 + " применена наценка на м2: " + fPriceAdd_Dop + "; ");
            }
          
            // Применим скидку на м2 к цене
            if ( fPriceRebate_Dop )
            {
              fPriceM2 -= fPriceRebate_Dop
              Prog.AddProtocol("\nК цене " + fPriceM2 + " применена скидка на м2: " + fPriceRebate_Dop + "; ");
            }
            
            // Будет примененно только для цены СП, где стоит фиксированная цена и попадает в диапазон минимальной площади
            if ( bFixedPrice )  // Если фиксированная цена, то брать цену как за максимальную площадь диапазона
            {
              Prog.AddProtocol("\nУстановлена фиксированная цена площадь изменена с: " + fArea.toFixed(2) + " на: " + fMaxAreaValue.toFixed(2));
              Prog.AddProtocol("\nЦена = (" + fPriceM2 + " + " + fAddGNS + " + " + fAddFilm + " + " + fAddF+ " + " + fAddGNSFixed + ")" );
              fPriceM2 = fPriceM2 + fAddGNS + fAddFilm + fAddF + fAddGNSFixed;
              Prog.AddProtocol(" = " + fPriceM2 );
              bPriceChange = true;

              // Сбрасываем значения обработок, пленок, рамок если домножаем на фиксированную площадь
              fAddGNS      = 0;
              fAddFilm     = 0;
              fAddF        = 0;
              fAddGNSFixed = 0;
            }

            // if ( !bPriceChange && fSideValue > 0) // Введены параметры сторон
            // {
            //   Prog.AddProtocol("\nСтороны данной позиции попадают в диапазон категории площадей ");
            //   fPriceM2 = (fPriceM2 + fAddGNSFixed) * fSideValue;
            //   bPriceChange = true;
            // }
          }
          else 
          {
            // Нарезка.
            fPriceM2 = fAddGNS;

            // Применим наценку на м2 к цене
            if ( fPriceAdd_Dop )
            {
              fPriceM2 += fPriceAdd_Dop;
              Prog.AddProtocol("\nК цене " + fPriceM2 + " применена наценка на м2: " + fPriceAdd_Dop + "; ");
            }
          
            // Применим скидку на м2 к цене
            if ( fPriceRebate_Dop )
            {
              fPriceM2 -= fPriceRebate_Dop
              Prog.AddProtocol("\nК цене " + fPriceM2 + " применена скидка на м2: " + fPriceRebate_Dop + "; ");
            }

            // Если фиксированная цена, то цена за м2 должна быть умноженна на фиксированную площадь, предварительно умноженное на количество
            var isPriceChange = false,
                nCount         = GP.GetLong("nCount");

            // Будет примененно только для цены СП, где стоит фиксированная цена и попадает в диапазон минимальной площади
            if ( bFixedPrice)  // Если фиксированная цена, то брать цену как за максимальную площадь диапазона.
            {
              Prog.AddProtocol("\nУстановлена фиксированная цена площадь изменена с: " + fArea.toFixed(2) + " на: " + fMaxAreaValue.toFixed(2));
              Prog.AddProtocol("\nЦена = (" + fPriceM2  + " + " + fAddFilm + " + " + fAddGNSFixed + ")" );
              fPriceM2 = fPriceM2 + fAddFilm + fAddGNSFixed;

              // Сбрасываем значения обработок, пленок если домножаем на фиксированную площадь
              fAddFilm     = 0;
              fAddGNSFixed = 0;
            }
          }

          var  bCalcA = true;
          if ( bA1 ) // За аргон.
          {
            fAddArgon = Math.round(objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 8, Prog.idPricePeriod, Prog.idPricePeriodDiscount));
            bCalcA = false;
            fAddA = fAddArgon;
            Prog.AddProtocol("\nДоплата за аргон в 1-й рамке: " + fAddArgon);
          }
          if ( bA2 )
          {
            if ( bCalcA )
              fAddArgon = Math.round(objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 8, Prog.idPricePeriod, Prog.idPricePeriodDiscount));
            fAddA += fAddArgon;
            Prog.AddProtocol("\nДоплата за аргон во 2-й рамке: " + fAddArgon);
          }
          if ( fAddA )
            Prog.AddProtocol("\n  Итого доплата за аргон: " + fAddA);

          // Коэффициент наценки на разнокамерный СП (только если нет шпрос).
          if ( GP.GetFloat("PriceS") == 0  &&  idF1 != 0  &&  idF2 != 0  &&  idF1 != idF2 )
          {
            var  fAddDiffFrameCoef = objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 2, Prog.idPricePeriod, Prog.idPricePeriodDiscount);
            DiffFrameCoef += (fAddDiffFrameCoef / 100.);

            if ( DiffFrameCoef != 1 )
              Prog.AddProtocol("\nКоэф. наценки за ассиметрию: " + DiffFrameCoef);
          }
        
         if ( bPiecePrice  )  //Штучная цена ?
           GP.IsPriceByCount = 1;
        }
      } 
        // Коэффициент на площадь и надбавка за площадь, 
        // Коэффициент на площадь берем при размерах одной из строн больше 2м
        if ( width >= 2000 || height >= 2000 )
         fCoefArea = objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 33, Prog.idPricePeriod, Prog.idPricePeriodDiscount);

        fAddArea  = objPrice.GetGPAreaAddPrice(fArea, false, Prog.idPricePeriod);
        
        AreaCoef = (fCoefArea / 100.);

        if ( AreaCoef != 1 )
          Prog.AddProtocol("\nКоэф. наценки на площадь: " + AreaCoef);
        if ( fAddArea != 0 )
          Prog.AddProtocol("\nНадбавка на площадь: " + fAddArea);

        fPriceM2 += fAddArea;        // учтем надбавку на площадь
        NonStandardCoef += AreaCoef; // учтем Коэффициент на площадь

        // Коэффициент на фигуры( трапеции, треугольники) и сложную форму (многоугольники, круг, арка).
        var  nSegCount = GP.SegCount;       // получим кол-во сегментов
        if ( nSegCount ) // если есть сегменты(значит есть чертеж), для нарезки не расчитываем
        {
          var  nArcSegCount = GP.ArcSegCount,
               bFigure      = 0,
               bPolygon     = 0;

          if ( nArcSegCount == 0 )
          {
            var nRightAngleCount = GP.RightAngleCount;
            if (  nSegCount == 3  ||  ( nSegCount == 4  &&  nRightAngleCount < 4 ) )
              bFigure = true;
            else
            if ( nSegCount > 4 )
              bPolygon = true;
          }

          if ( nArcSegCount > 0 || bPolygon )
          {
            var  fAddFigureArc_or_Polygon = objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 6, Prog.idPricePeriod, Prog.idPricePeriodDiscount);
            fAddFigureArc_or_Polygon /= 100.;
            NonStandardCoef += fAddFigureArc_or_Polygon;
            Prog.AddProtocol("\nКоэф. наценки за арку(круг) или многоугольник: " + fAddFigureArc_or_Polygon);
          }
          else if ( bFigure )
          {
            var  fAddFigure = objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 5, Prog.idPricePeriod, Prog.idPricePeriodDiscount);
            fAddFigure      /= 100.;
            NonStandardCoef += fAddFigure;
            Prog.AddProtocol("\nКоэф. наценки за треуг. или трапецию: " + fAddFigure);
          }
        }

        // Наценка на зуб
        if ( bStructural )
        {
          var fAdd_Struct  = objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 23, Prog.idPricePeriod, Prog.idPricePeriodDiscount);
          fAdd_Struct     /= 100.;
          NonStandardCoef += fAdd_Struct;
          Prog.AddProtocol("\n Коэф. наценки за зуб " + fAdd_Struct); 
        }

        if ( GP.GetBool('bTemplate') )
        {
          var fAddFigure   = objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 7, Prog.idPricePeriod, Prog.idPricePeriodDiscount);
          fAddFigure      /= 100;
          NonStandardCoef += fAddFigure;
          Prog.AddProtocol("\n Коэф. наценки за шаблон: " + fAddFigure); 
        }
        GP.PriceCoef = NonStandardCoef;
      }
      else
        fPriceM2 = GP.GetFloat("PriceByM");
      
      // Признак фигуры из выпадающего списка для позиции заказа
      if ( GP.GetLong("idFormType") > 1 )
        fCoefFormType = GetFormTypeCoef( GP.GetLong("idFormType"), nCamCount);

      if ( GP.ChangedFieldName != "PriceByM" )
      {
        Prog.AddProtocol("\nЦена М2 по прайсу: " + fPriceM2.toFixed(2));

        if ( GP.ChangedFieldName != "PriceCoef" )
          Prog.AddProtocol("\nКоэф. наценки: " + GP.PriceCoef.toFixed(2));
      }

      if ( !fPriceM2 )
        Prog.AddProtocol("\n\nНеобходимо ввести цену на данный диапазон площадей в меню Справочники -> Ценообразование -> Цены на стеклопакеты по толщине и количеству камер...!");

      if ( (bObjectPrice == 0  || bObjectPrice == null) && (idProduct == 0 || idProduct == null) )
      {
        // Здесь  распишем стоимости обработок в протокол
        var rcProjectItem        = Prog.rcProjectItem,
            sFilter              = "guidProject = '" + GP.GetString("GUID") + "'",
            idProd               = 0,
            bHasPriceProceessing = false; // Есть ли обработки
            fPriceProcessing     = 0.0,   // Цена обработок
            fReplacePrice        = 0.0;   // Цена обработки с флагом IsMainPrice для замены цены стекла

        rcProjectItem.Filter = sFilter;
        rcProjectItem.Sort   = "Num";
        
        for (rcProjectItem.MoveFirst(); !rcProjectItem.EOF; rcProjectItem.MoveNext() )
        {
          var idProd         = rcProjectItem("idProd").Value,
              nType          = rcProjectItem("nType" ).Value,
              nTypeOper      = rcProjectItem("nTypeOper" ).Value,
              NumItem        = rcProjectItem("Num"   ).Value,
              nGlassItem     = rcProjectItem("nGlass").Value,
              nCountItemOper = rcProjectItem("CountOper").Value,
              bManualPrice   = rcProjectItem("bManualEditPrice").Value,
              bUserGlass     = rcProjectItem("bUserGlass").Value,
              fManualPrice   = rcProjectItem("Price").Value,
              fCost          = rcProjectItem("Cost").Value || 0,
              idSealant      = rcProjectItem("idSealant").Value,                          // Герметик
              fSealantDepth  = rcProjectItem("SealingDepth").Value  || constSealantDepth,  // Глубина заливки
              sealantUnit    = rcProjectItem("idSealantUnit").Value || 0,                      // 0: герметик по погонным метрам, 1: герметик по кв.м
              fPrice         = 0,
              sTemp          = "", 
              sNameProd      = "";

          if ( fManualPrice == null )
            fManualPrice = 0;

          sFilterProd = "ID = " + idProd;   
          rcProduct.MoveFirst(); 
          rcProduct.Find(sFilterProd, 0, 1);

          if ( !rcProduct.EOF )  // при поиске проверяем чтобы не конец
          {
            sNameProd           = rcProduct.Fields.Item("Name"  ).Value;
            idProdUnit          = rcProduct.Fields.Item("idUnit").Value;
            nTypeOper           = rcProduct.Fields.Item("nTypeOper").Value;
            sNameProd           = "  [" + sNameProd + "]" + " ID = "+ idProd + " ";
          }
          
          // Стекло
          if ( nType == 5 )
            idGlass = idProd;
          // Рамка
          if ( nType == 6 )
          {
            nNumFrame += 1;

            if ( idSealant )
              fPrice = Math.round(objPrice.GetSealantPrice(idSealant));
            
            if ( fPrice > 0)
            {
              sProtocolProcess = sProtocolProcess + "\r\n Герметик ц.м2 по прайсу = " + fPrice.toFixed(2);
              var fDiff        = 0;
              
              if (sealantUnit == 1)
              {
                  fLinearArea = 2 * (width + height) / 1000;
                  fDiff       = fLinearArea;
              }
              else
                  fDiff = bFixedPrice ? fMaxAreaValue : fArea;
              
              // Если глубина заливки больше константного значения 4.5
              if ( fSealantDepth > constSealantDepth )
              {
                var fPriceAdd       = 0,
                    difSealantDepth = fSealantDepth - constSealantDepth,
                    fLinearArea     = 0;

                // Рассчет по погонным метрам
                if ( sealantUnit == 1)
                {
                  fPriceAdd   = Math.round(objPrice.GetSpecialMarginByGPType(Prog.idClient, 53, Prog.idPricePeriod, Prog.idPricePeriodDiscount, idGlassPackType));
                  sProtocolProcess = sProtocolProcess + "; Погонных метров = " + fLinearArea + "; Доплата = " + fPriceAdd;
                }
                // Рассчет по кв.м
                else if ( sealantUnit == 0 )
                {
                  fPriceAdd = Math.round(objPrice.GetSpecialMarginByGPType(Prog.idClient, 54, Prog.idPricePeriod, Prog.idPricePeriodDiscount, idGlassPackType));
                  sProtocolProcess += "; кв.м = " + fDiff.toFixed(2) + "; Доплата = " + fPriceAdd;
                }

                fPriceAdd *= difSealantDepth;
                fPrice    += fPriceAdd;
                
                sProtocolProcess += "; разница глубины заливки = " + difSealantDepth +
                                    "; Доплата составила = "       + fPriceAdd + ";";
              }
              
              if (fDiff)
                sProtocolProcess += "\r\n " + fPriceM2.toFixed(2) + " + " + fPrice.toFixed(3) + " = " + (fPriceM2 + fPrice).toFixed(2);

              fPriceM2 += fPrice;
            }
          }
          else
          // Аргон
          if ( nType == 10 )
          {
            fPrice = Math.round(objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 8, Prog.idPricePeriod, Prog.idPricePeriodDiscount));
            sProtocolProcess = sProtocolProcess + "\r\n Аргон в камере " + nNumFrame + " ц.м2 по прайсу = " + fPrice.toFixed(2);
          }
          else
          // Пленки
          if ( nType == 7 )
          {
            fPrice = objPrice.GetMarginFilm(Prog.idClient, idProd, Prog.idPricePeriod, Prog.idPricePeriodDiscount)
            sProtocolProcess = sProtocolProcess + "\r\n Плёнка " + sNameProd + " на стекле № " + nGlassItem + " по прайсу = " + fPrice.toFixed(2);
          }
          else
          // Обработки
          if ( nType == 8 )
          {
            var fPriceProcessingCurrent = 0;
            
            if ( fReplacePrice == 0 )
            {
              bHasPriceProceessing    = false;
              fPriceProcessingCurrent = objPrice.GetPrice_ClientOperationGlassWithoutOperProcessing(Prog.idClientParent, idProd, idGlass, idPricePeriod, 0, GP.Area, false); // По требованию клиента стоимость обработки будет идти как цена

              // Если свреление и нет цены, выведим стоимость в протокол
              if (nTypeOper == 4 && !fPriceProcessingCurrent)
              {
                sProtocolProcess  = sProtocolProcess + "\r\n Сверления на стекле № " + nGlassItem + ". Стоимость = " + fCost.toFixed(2);
                continue;
              }
              
              // Если цены нет пробуем достать
              if ( !fPriceProcessingCurrent )
                fPriceProcessingCurrent = objPrice.GetMarginFilm(Prog.idClientParent, idProd, idPricePeriod, 0);

              // Если цена есть запротоколируем
              if ( fPriceProcessingCurrent )
              {
                sProtocolProcess  = sProtocolProcess + "\r\n Обработка " + sNameProd + " на стекле № " + nGlassItem + ". Стоимость = " + fPriceProcessingCurrent.toFixed(2);
                
                var totalPrice   = fPriceM2 + fPriceProcessingCurrent;
                sProtocolProcess = sProtocolProcess + "\r\nК цене " + fPriceM2.toFixed(2) + " добавлена стоимость обработки " + fPriceProcessingCurrent.toFixed(2) + ". Стоимость = " + totalPrice.toFixed(2);
                fPriceM2         = totalPrice;
              }
            }
            
          }
        }
        
        // Если  были обработки, то внесем информацию в протокол о них
        if ( sProtocolProcess != "" )
        {
          Prog.AddProtocol("\r\n Стоимости обработок:");
          Prog.AddProtocol(sProtocolProcess);
        }
      }

      var fPriceAdd        = 0,
          fPriceRebate     = 0,
          fRebateVal      = 0, // Скидка в рублях на заказ
          PriceAddVal     = 0, // Наценка в рублях на заказ
          PriceAdd        = 0,
          PriceAdd_NoCoef = GP.GetFloat("PriceAdd_NoCoef"),    // Наценка на позицию
          fRebate         = GP.GetFloat("Rebate");             // Скидка на позицию
          sProtPriceAdd = "", // Протоколируем наценку
          sProtRebate   = ""; // Протоколируем скидку

      if (nCountProject > 0)
      {
        sProtPriceAdd += "Позиций в заказе: " + nCountProject + ";\r\n";

        fRebateVal   = Prog.rcTask("RebateVal").Value;    // Скидка на заказ
        fPriceAddVal = Prog.rcTask("PriceAddVal").Value;  // Наценка на заказ

        // Запишем на позиции, скидку и наценку
        if (fRebateVal)
        {
          var bSkipRebate = Prog.rcProject("SumWithNDS_Discount").Value || 0;
        
          if (bSkipRebate == 1)
          {
            fRebateVal = 0;
            sProtRebate += "\r\nСкидка заказа на позицию не применяется: позиция исключена;";
          }
          else
          {       
            var nCountRebate = GetRebateProjectCount();
        
            if (nCountRebate > 0)
            {
              fRebateVal = Math.round((fRebateVal / nCountRebate) * 100) / 100;
              // Prog.MessageBox(nCountRebate);
            }
            else
            {
              fRebateVal = 0;
              sProtRebate += "\r\nНет позиций для распределения скидки;";
            }
          }
        }
       
        if (fPriceAddVal)
        {
          fPriceAddVal = Math.round((fPriceAddVal / nCountProject) * 100) / 100;
          sProtPriceAdd += " Наценка на заказ = " + fPriceAddVal + ";";
        }

        // Добавим наценку на заказ если она есть
        Prog.rcProject("PriceAddVal").Value = fPriceAddVal;
      }

      // Делим наценку на площадь если не фиксированная ценка
      // Формула: Цена м2 = цена по прайсу + наценка / п
      if ( PriceAdd_NoCoef )
      {
        sProtPriceAdd += "Наценка на позцию = " + PriceAdd_NoCoef;
        if ( !bPiecePrice && fArea != 0 )
        {
          fPriceAdd    += PriceAdd_NoCoef / fArea;
          sProtPriceAdd += " / " + fArea.toFixed(2) + " = " + fPriceAdd.toFixed(2);
        }
        else
          fPriceAdd    += PriceAdd_NoCoef;

        sProtPriceAdd += "; ";
      }

      // Делим скидку на площадь если не фиксированная ценка
      // Формула: Цена м2 = цена по прайсу + скидка  / п
      if ( fRebate )
      {
        sProtRebate += "Скидка на позцию = " + fRebate;
        if ( !bPiecePrice && fArea != 0 )
        {
          fPriceRebate += fRebate / fArea;
          sProtRebate += " / " + fArea.toFixed(2) + " = " + fPriceRebate.toFixed(2);
        }
        else
          fPriceRebate += fRebate;
      
        sProtRebate += "; ";
      }

      // Добавим скидку на заказ если она есть
      if ( fRebateVal )
      {
        sProtRebate   += "Скидка на заказ = " + fRebateVal;
        if ( !bPiecePrice && fArea != 0 )
        {
          fPriceRebate    += fRebateVal / fArea; 
          sProtRebate += " / " + fArea.toFixed(2) + " = " + fPriceRebate.toFixed(2);
        }
        else
          fPriceRebate    += fRebateVal; 
        
        sProtRebate += "; ";
      }

      // Если есть коэффициент нужно поделить на полученную скидку || наценку
      if ( NonStandardCoef != 1 )
      {
        fPriceRebate /= NonStandardCoef;
        if ( sProtRebate != "")
          sProtRebate    += " С коэффициентом " + NonStandardCoef + " = " + fPriceRebate.toFixed(2) + ";";
      }

      // Если наценка есть наценка тогда запишем
      if ( fPriceAdd )
        Prog.rcProject("PriceAdd_NoCoef").Value = fPriceAdd;

      // Если есть скидка тогда запишем
      if ( fPriceRebate )
        Prog.rcProject("Rebate").Value = fPriceRebate;
      
      if ( sProtPriceAdd != "" )
        Prog.AddProtocol("\r\n" + sProtPriceAdd);

      if ( sProtRebate != "" )
        Prog.AddProtocol("\r\n" + sProtRebate);
      
      // Расчет цены М2 с НДС.
      if ( GP.ChangedFieldName != "PriceNDS" )
        Prog.AddProtocol("\n\nФормула расчета: ");
     
      // Объектовый прайс?      
      if ( bObjectPrice )
      {
        GP.PriceM2_WithNDS = Math.round(fPriceM2 * fCoefFormType);
        Prog.AddProtocol("\n[Цена М2] * [Коэф. наценки] * [Коэф. фигуры] / [Площадь]");
        Prog.AddProtocol("\n" + fPriceM2 + " * " + GP.PriceCoef.toFixed(2) + " * " + fCoefFormType + " / " + fArea + " = " + GP.PriceM2_WithNDS.toFixed(2));
      }
      // Стандартный прайс
      else
      if (nCamCount == 0)    // Стекло в нарезку 
      {
        if ( bCalcValues )
        {
          GP.PriceM2_WithNDS = Math.round((fPriceM2 + fAddFilm) * fCoefFormType );
          Prog.AddProtocol("\n([Доплата за нарезку] + [Доплата за пленки]) * [Коэф. фигуры]");
          Prog.AddProtocol("\n(" + fPriceM2 + " + " + fAddFilm + ") * " + fCoefFormType + " = " + GP.PriceM2_WithNDS);
        }
        else
        {
          Prog.AddProtocol("\n[Доплата за нарезку] * [Коэф. наценки] * [Коэф. фигуры]");
          Prog.AddProtocol("\n" + fPriceM2 + " * " + GP.PriceCoef.toFixed(2) + " * " + fCoefFormType + " = " + GP.PriceM2_WithNDS);
        }
      }
      else                  // Стеклопакет
      {
        if ( bCalcValues)
        {        
          GP.PriceM2_WithNDS = Math.round((fPriceM2 * DiffFrameCoef + fAddGNS + fAddFilm + fAddF) * fCoefFormType);
          Prog.AddProtocol("\n([Цена М2] * [Коэф. наценки за ассиметрию] + [Доплата за замену стекол] + [Доплата за пленки] + [Доплата за теплые рамки]) * [Коэф. наценки] * [Коэф. фигуры]");
          Prog.AddProtocol("\n\n(" + fPriceM2.toFixed(2) + " * " + DiffFrameCoef + " + " + fAddGNS + " + " + fAddFilm + ") * " + NonStandardCoef + " * " + fCoefFormType + " = " + GP.PriceM2_WithNDS.toFixed(2));
        }
        else
        {
          Prog.AddProtocol("\n([Цена М2] * [Коэф. наценки] + [Стоимость раскладки]) * [Коэф. фигуры] / [Площадь]");
          Prog.AddProtocol("\n(" + fPriceM2.toFixed(2) + " * " + GP.PriceCoef.toFixed(2) + " + " + fPriceS + ") * " + fCoefFormType + " / " + fArea + " = " + GP.PriceM2_WithNDS.toFixed(2));
        }
      }
      Prog.AddProtocolFull(); // Добавить протокол к позиции.
      Prog.SaveProtocol();


      // Если не фиксированная цена возвращаем скидки наценки до этапа деления на площадь
      Prog.rcProject("PriceAdd_NoCoef").Value = PriceAdd_NoCoef;
      Prog.rcProject("Rebate").Value          = fRebate;

      // Здесь вводим проверки - ПОКА ПУСТО !!!
      var  fAreaMin = 0.09;
      fArea = Math.round(fArea * 1000) / 1000.;
      //Check_Glass_Frame_Area(GP.GetProductLong(idG1, "Thickness", 0),
                             // GP.GetProductLong(idG2, "Thickness", 0),
                             // GP.GetProductLong(idG3, "Thickness", 0),
                             // GP.GetProductLong(idF1, "Thickness", 0),
                             // GP.GetProductLong(idF2, "Thickness", 0), fArea);
  }
  catch (e)
  {
    Prog.SaveError("Prog::GlassPackCalcPrice " + e.stack + e.message, true);
  }
}

function Prog::CalcPriceTask()
{
  Prog.SaveError("Prog::CalcPriceTask - использование метода не предусмотрено", false);
}

function GetRebateProjectCount()
{
  var nCount = 0;
  var rc = null;

  try
  {
    rc = Prog.rcProject.Clone();
    rc.Filter = "";

    if (!(rc.BOF && rc.EOF))
    {
      rc.MoveFirst();

      for (; !rc.EOF; rc.MoveNext())
      {
        var bSkip = rc("SumWithNDS_Discount").Value || 0;
        var nCountPos = rc("nCount").Value || 1;

        if (bSkip != 1)
          nCount += nCountPos;
      }
    }

    try { rc.Close(); } catch(eClose) {}
  }
  catch(e)
  {
    Prog.SaveError("GetRebateProjectCount: " + e.message, true);
    nCount = GP.GetProjectCount();
  }

  return nCount;
}

function CalcRasPrice(ObjGlass)
{
  if ( ObjGlass.Int("CalcPriceMethod") == 2 ) // По погонным метрам.
    ObjGlass.Float("RasPrice") = ObjGlass.Int("RasComplectCount") * (ObjGlass.Float("RasPriceM") * ObjGlass.Float("RasLeng") / 1000. + ObjGlass.Int("nRasIntersect") * ObjGlass.Float("CrossPrice"));
  else                                        // По цене за секцию.
    ObjGlass.Float("RasPrice") = ObjGlass.Int("RasComplectCount") * (ObjGlass.Float("RasPriceSection") * ObjGlass.Int("nCountSection"));
}

function GetRasPriceM(ObjGlass)
{
  var  fRasPrice = Prog.GetRasPrice(ObjGlass, 2);
  return fRasPrice;
}

function GetRasPriceSection(ObjGlass)
{
  var  fRasPrice = Prog.GetRasPrice(ObjGlass, 1);
  return fRasPrice;
}

// Проверка существования шпрос
function CheckRasExist(ObjGlass)
{
  var  ObjRas = Prog.ObjMas.SearchObj_Class("RasVert");
  if ( !ObjRas )
    ObjRas = Prog.ObjMas.SearchObj_Class("RasHoriz");

  if ( ObjRas && ObjGlass.Float("RasPriceSection") == 0 )
    Prog.MessageBox ("На заданный тип шпрос не настроена цена.\nНастройте цену или выберите другой тип шпрос.");
}

// Проверка допусков по таблице слипания.
function Check_Glass_Frame_Area(G1, G2, G3, F1, F2, Area)
{

}

// Цена операции на стекло
function Prog::GlassPriceOperation()
{
  try
  {
    if ( !objPrice )
      InitObjPrice();
    
    Prog.Protocol = "";

    // Загрузим справочники
    LoadReference();

    var bObjectPrice = GetPricePeriodValue(Prog.idPricePeriod, "bObjectPrice"),  // Объектовый прайс
        bA1          = GP.GetBool("bIsArgon1"),
        bA2          = GP.GetBool("bIsArgon2"),
        fPriceM2     = GP.GetFloat("PriceWithNDS_M2"),
        fArea        = GP.GetFloat("Area");

    // Объектовый прайс - цена = 0 по требованию клиента
    if ( bObjectPrice )
      GP.GlassPriceOper = 0;
    // Не объектовый прайс
    else
    if ( objPrice )
    {
      var  idPricePeriod          = 0,
           idPricePeriodDiscount  = 0,
           fCoefArea              = 0.,  // Коэф. наценки в процентах зависит от площади и ее категории
           //fPriceCoef           = GP.PriceCoef,
           fPriceCoef             = GetFormTypeCoef( GP.GetLong("idFormType"), GP.GetLong("CamCount")),
           fPriceOper             = 0.0,
           fPercentDiscount       = 0.0,  // Скидка на обработки
           fAddArgon              = 0.0,  // Доплата за аргон
           SpecPrice              = objPrice.GetPriceOtherProductByName(Prog.idClientParent, GP.GetString("GPName"), Prog.idPricePeriod, Prog.idPricePeriodDiscount, 0, 0),
           bEquallyMinValue       = Prog.Select_Int("select d_iNum from config where Name = 'nTypeDefineAreaGP'", "d_iNum", true);

      // если есть цена в справочнике цен "Готовой продукции"
      if ( SpecPrice )
        GP.GlassPriceOper = GP.ProjectPriceOper = 0;    // Цена обработок для "Готовой продукции" должна быть нулевой
      else
      {
        idPricePeriod          = Prog.idPricePeriod;
        idPricePeriodDiscount  = Prog.idPricePeriodDiscount;
        idDrillDiameter        = GP.idDrillDiameter;
        fCoefArea              = objPrice.GetGPAreaCoef(GP.Area, bEquallyMinValue, Prog.idPricePeriod); // По решению руководства не нужно умножать на коэффициент площадной
        // fPriceOper             = objPrice.GetPrice_ClientOperationGlassWithoutOperProcessing(Prog.idClientParent, GP.idOper, GP.idGlassOper, idPricePeriod, idDrillDiameter, GP.Area, false); // По решению клиента обработки nType = 8 не должны применяться как наценка        
        fPercentDiscount       = objPrice.GetDiscountSpecialMargin(Prog.idClientParent, 12, idPricePeriod, idPricePeriodDiscount);
        fPriceOper             = fPriceOper * ( 1 + fCoefArea / 100.) * ((100 - fPercentDiscount) / 100.) * fPriceCoef;
        Prog.AddProtocol("\n Процент скидки на обработки : " + fPercentDiscount);


        // Обработка аргон?
        if ( GP.nType == 10 && fArea  )
        {
            fAddArgon   = Math.round(objPrice.GlassPackPriceSpecialMargin(Prog.idClient, 8, Prog.idPricePeriod, Prog.idPricePeriodDiscount));
            fPriceOper = fAddArgon;
          }
        GP.GlassPriceOper = fPriceOper; 
      }
    }
  }
  catch (e)
  {
    Prog.SaveError("Prog::GlassPriceOperation " + e.message, true);
  }
}

// Доплата за стекла, замененное на стоимость обработки
function GetPriceOperationWithoutOperProcessing(numGlass, idClient, idGlass, idPricePeriod, idDrillDiameter, area, isMainPrice)
{
  var result = 0;
  
  try
  {
    var rcProjectItem = Prog.rcProjectItem;

    if ( !rcProjectItem )
      return  Result;
    
    var sFilter  = "nOrderRoute = " + numGlass + " and nType = 8 and guidProject = '" + GP.GetString("GUID") + "'" ;   
    rcProjectItem.Filter = sFilter;

    if ( !(rcProjectItem.BOF  &&  rcProjectItem.EOF) )
    for (rcProjectItem.MoveFirst(); !rcProjectItem.EOF; rcProjectItem.MoveNext() )
    {
      var idOper = rcProjectItem("idProd").Value;
      result     = objPrice.GetPrice_ClientOperationGlassWithoutOperProcessing(idClient, idOper, idGlass, idPricePeriod, idDrillDiameter, area, isMainPrice); 
      
      if ( result > 0 )
        break;
    }
      
    rcProjectItem.Filter = "";
  }
  catch (e)
  {
    Prog.SaveError("Prog::GetPriceOperationWithoutOperProcessing " + e.message, true);
  }
      
  return result;
}



function GetCrossPrice (ObjGlass)
{
  var  fRasPrice = ObjGlass.Float ("CrossPrice");
  return fRasPrice;
}

function GetCapPrice (ObjGlass)
{
  var  fRasPrice = ObjGlass.Float ("CapPrice");
  return fRasPrice;
}

// В программе сделали, а в скрипты не вставили
function Prog::ClearCash()
{
  try
  {
    if ( objPrice )
         objPrice.ClearCash();

    bLoaded = 0;  // Если справочник прайсов изменили, то  их  можно тоже пересчитать
  }
  catch (e)
  {
    Prog.SaveError("Prog::ClearCash " + e.message, true);
  }
}

function InitObjPrice()
{
  try
  {
    var  sConn = new String;
    sConn = Prog.ConnectStr;

    objPrice = Prog.CreateObject("DBOper.dll", "NewObject", "ClientPrice");

    if ( objPrice )
    {
      objPrice.OpenDB (sConn);
      objPrice.GlassMarkCovering = GP.GlassMarkCovering;    // Обозначение стороны покрытия: И4#1,2...6
    }
    else
    {
      var  s = "Prog::GlassPackCalcPrice - Невозможно создать объект DBOper.ClientPrice";
      Prog.Protocol = s;
      Prog.SaveError (s, true);
    }
  }
  catch (e){Prog.SaveError("JS_CalcPrice::InitObjPrice" + e.message, true);}
}

function GetTripGlassAddPrice(nGlass)
{
  try
  {
    var AddPrice     = 0.0,
        iGlassCount  = GP.GetNGlassCount(GP.GetString("GUID"), nGlass),  // Кол-во стекол в триплексе
        nCamCount    = GP.GetShort("CamCount"),
        fAddFilm     = 0.0;


    for (var i = 1; i <= iGlassCount; i++)
    {
      var  idGlass     = GP.GetNGlassID(GP.GetString("GUID"), nGlass, i),
           fAddG       = Math.round(objPrice.GetGlassAddPrice(Prog.idClient, idGlass, 0, Prog.idPricePeriod, Prog.idPricePeriodDiscount, 0)),
           bUserGlass  = GetProjectItemBool(nGlass, 5, "bUserGlass");

      // Не давальческое, тогда суммируем
      if ( fAddG && !bUserGlass )
      {
        Prog.AddProtocol("\nТриплекс " + nGlass + " - Доплата за стекло  " + i + ": " + fAddG);
        AddPrice += fAddG;
      }
    }
    
    fAddFilm = GetnGlassFilmAddPrice(nGlass);
    if ( fAddFilm )
    {
      //Prog.AddProtocol("\nТриплекс " + nGlass + " - Доплата за пленку  " + i + ": " + fAddFilm);
      AddPrice += fAddFilm;
    }
    
    if ( AddPrice )
      Prog.AddProtocol("\n  Итого доплаты за стекла и пленки : " + AddPrice);
    return AddPrice;
  }                                                                                            
  catch (e)
  {
    Prog.SaveError("Prog::GetTripGlassAddPrice " + e.message, true);
  }
  return 0.0;
}

// стоимость пленок на каждом из стекол 
function GetnGlassFilmAddPrice(nGlass)
{
  try
  {
    var AddPrice    = 0.0,
        iFilmCount  = GP.GetNGlassFilmCount(GP.GetString("GUID"), nGlass); // Кол-во пленок в триплексе

    for (var i = 1; i <= iFilmCount; i++)
    {
      var  idFilm   = GP.GetNGlassFilmID(GP.GetString("GUID"), i, nGlass),
           fAddFilm = Math.round(objPrice.GetMarginFilm(Prog.idClientParent, idFilm, Prog.idPricePeriod, Prog.idPricePeriodDiscount));

      if ( fAddFilm )
      {
        Prog.AddProtocol("\n Доплата за пленку в " + nGlass + " стекле : " + fAddFilm);
        AddPrice += fAddFilm;
      }
    }
    
    return AddPrice;
  }
  catch (e)
  {
    Prog.SaveError("Prog::GetnGlassFilmAddPrice " + e.message, true);
  }
  return 0.0;
}

function GetProjectItemBool (nGlass, nType, sField)
{
  var Result = false;

  try
  {
    
    var rcProjectItem = Prog.rcProjectItem;
    
    if ( !rcProjectItem )
      return  Result;

    var sFilter  = "nType = " + nType + " and nGlass = " + nGlass + " and guidProject = '" + GP.GetString("GUID") + "'" ;    
    rcProjectItem.Filter = sFilter;

    if ( !(rcProjectItem.BOF  &&  rcProjectItem.EOF) )
      Result = rcProjectItem.Fields.Item(sField).Value;

    rcProjectItem.Filter = "";
  }
  catch (e)    // [ab] Это нужно чтобы возникло понимание что значит "падать"
  {
    Prog.Saverror("JS::GetProjectItemBool " + e.message, true);
  }
  return Result;
}

function GetProjectItemLong(numGlass, nType, sField)
{
  var Result = 0;
  try
  {
    var rcProjectItem = Prog.rcProjectItem;

    if ( !rcProjectItem )
      return  Result;

    var sFilter  = "nOrderRoute = " + numGlass + " and nType = " + nType + " and guidProject = '" + GP.GetString("GUID") + "'" ;    
    rcProjectItem.Filter = sFilter;

    if ( !(rcProjectItem.BOF  &&  rcProjectItem.EOF) )
      Result = rcProjectItem.Fields.Item(sField).Value;

    rcProjectItem.Filter = "";
  }
  catch (e)  
  {
    Prog.Saverror("JS::GetProjectItemBool " + e.message, true);
  }
  return Result;
}

function CheckIsTriplexFilm(numGlass)
{
  var result = false
  try
  {
    var   rcProjectItem = Prog.rcProjectItem;
    if ( !rcProjectItem )
      return result;

    var sFilter = "nType = 7 and nTypeOper = 3 and nGlass = " + numGlass + " and guidProject = '" + GP.GetString("GUID") + "'";
    rcProjectItem.Filter = sFilter;

    if ( !(rcProjectItem.BOF  &&  rcProjectItem.EOF) )
      result = true;

    rcProjectItem.Filter = "";
  }
  catch (e)
  {
    Prog.SaveError("JS::CheckIsTriplex " + e.message, true);
  }

  return result;
}

// Проверка существования продукции определеного типа в конструкторе
function CheckExistTypeProdInProjectItem(nType, nTypeOper)
{
  var Result = false;

  try
  {
    
    var   rcProjectItem = Prog.rcProjectItem;
    if ( !rcProjectItem )
      return  Result;

    var sFilter  = "nType = " + nType + " and nTypeOper = " + nTypeOper + " and guidProject = '" + GP.GetString("GUID") + "'";
    rcProjectItem.Filter = sFilter;

    if ( !(rcProjectItem.BOF  &&  rcProjectItem.EOF) )
      Result = true;

    rcProjectItem.Filter = "";
  }
  catch (e)    // [ab] Это нужно чтобы возникло понимание что значит "падать"
  {
    Prog.Saverror("JS::CheckExistTypeProdInProjectItem " + e.message, true);
  }
  return Result;
}

// Получить значение поля из таблицы PricePeriod по идентификатору прайса
function GetPricePeriodValue( idPricePeriod, sField)
{
  var Result = 0.;
  
  try
  {
    if ( rcPricePeriod && !(rcPricePeriod.BOF && rcPricePeriod.EOF) )
    {
      var sFilter = "ID = " + idPricePeriod;

      rcPricePeriod.MoveFirst(); 
      rcPricePeriod.Find(sFilter, 0, 1);

      if ( !rcPricePeriod.EOF )   // при поиске проверяем чтобы не конец
        Result = rcPricePeriod.Fields.Item(sField).Value;
    }
  }
  catch (e)
  {
    Prog.SaveError("JS::GetPricePeriodValue " + e.message, true);
  }

  return Result;
}
