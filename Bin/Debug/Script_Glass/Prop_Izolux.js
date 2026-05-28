var
  nClass_Glass        =  1,    // Стеклопакеты
  nClass_Dim_Vert     =  4,
  nClass_Dim_Horiz    =  5,
  nClass_Dim_Rad      =  6,
  nClass_Drill        =  7,    // Отверстие
  nClass_Notch        =  8,    // Вырез  
  nClass_Grind        =  9,    // Зона шлифовки
  nClass_Grind_Track  = 10,    // путь шлифовки  
  nClass_Chess        = 20,    // Окна
  nClass_Transom      = 21,
  nClass_Leaf         = 22,
  nClass_Connect_Prof = 40,    // Доп.элементы - соединительный профиль
  nClass_Sub_Prof     = 41,    //              - подставочный   профиль

  nClass_Cutout       = 56,    // вырез в контуре изделия             

  nClass_Contur       = 60;    // Служебные

// [ss] Изменил TaskPropShow - ускорил отображение
// [af] Добавил в свойства заказа отображение и редактирование Task.idDeliveryAddress.
// [af] Добавил в свойства заказа отображение и редактирование Task.idTripDirect.
// [af] Добавил в свойства заказа отображение и редактирование Task.DeliveryTimeIndex.
// Закомментировал недоступные св-ва: OwnCourse, DatePayDoc, Rebate, CommentaryEnd, CommentaryDeliv.
// [af] Добавил Prog.TripPropShow().
// [af] Добавил Prog.TripPropEdit().
// Добавил Prog.PlanPropShow() и Prog.PlanPropEdit().
// [AF] Теперь в свойствах заказа используются только правила отгрузки. Типов отгрузки больше нет.

//Prog.SaveError("Prop.js загружен", false);  // [ab] Проверка web-версии

//////////////////////////////////////////////////////////////////////////
// Отобразить свойства Выбранного заказа

function Prog::TaskPropShow()
{
  //Prog.SaveError("Prog::TaskPropShow()", false);  // [ab] Проверка web-версии

  Prop.Clear();

  var
    lStore = Prop.InsertStore ("Задание"),
    lCat = Prop.InsertCategory (lStore, "Реквизиты", "Основные реквизиты задания");

  Prop.Editable = false;
  Prop.bCash    = true;
  //Prop.InsertProperty_ComboBox(lCat, "Тип заказа", "Тип заказа",     "idTaskType",
  //                             "select ID, Name from TaskType", 0);
  Prop.InsertProperty_String(lCat, "Задание №",      "Задание №",      "AccountNum",  0);
  Prop.InsertProperty_String(lCat, "№ Заявки клиента", "№ Заявки клиента из Excel-файла", "ClientNum",               0);
  Prop.InsertProperty_String(lCat, "Счёт №",         "Счёт №",         "Num",         0);
  Prop.InsertProperty_String(lCat, "Услуга к счёту №","Услуга к счёту №","ForAccountNum",0);
  Prop.Editable = true;
  Prop.InsertProperty_String(lCat, "Счёт-Фактура №", "Счёт-Фактура №", "NumCalcFact", 0);
  Prop.InsertProperty_String(lCat, "ИГК", "ИКГ", "ForAccountNum", 0); 
  Prop.Editable = false;
  Prop.InsertProperty_String(lCat, "СФ от дилера №", "Счёт-Фактура от дилера №", "NumCalcFact_Dealer", 0);

  Prop.InsertProperty_String(lCat, "Валюта",         "Заказ в валюте", "ValuteName",         0);
  Prop.InsertProperty_String(lCat, "НДС,%",          "Ставка НДС",     "NDS",                0);
  //Prop.InsertProperty_Float (lCat, "Курс",          "Курс",           "OwnCourse",         0);
  Prop.InsertProperty_String(lCat, "Продавец",       "Продавец",       "SellerName",         0);
  Prop.InsertProperty_String(lCat, "Грузоотправитель","Грузоотправитель", "ShipperName",     0);
  //[SE] Закрываем данного потребителя
  //Prop.InsertProperty_String(lCat, "Потребитель",   "Потребитель",    "ConsumerName",      0);
  Prop.InsertProperty_String(lCat, "Клиент",           "Клиент заказа",                   "ClientName",              0);
  Prop.InsertProperty_String(lCat, "Заказ основание",  "Заказ основание",                 "TaskParentName",          0);
  Prop.InsertProperty_String(lCat, "Цех клиента",      "Цех клиента",                     "ClientManufactory_Name",  0); 
  Prop.InsertProperty_String(lCat, "Грузополучатель",  "Грузополучатель",                 "ConsigneeName",           0);
  Prop.InsertProperty_String(lCat, "Подразделение",    "Подразделение",                   "DepotSubDivisionName",    0);
  Prop.InsertProperty_String(lCat, "Статус",           "Статус",                          "TypeOrderText",           0);
  Prop.InsertProperty_String(lCat, "Тип расчёта",      "Тип расчёта",                     "CalcTypeText",            0);
  // [YK] скрыто по указанию АБ, проверено Task.nTypeCalcPrice - не используется, используется Client.nTypeCalcPrice
  //Prop.InsertProperty_String(lCat, "Расчет цены",      "Метод расчета цены",              "nTypeCalcPriceText",      0);
  /* [YK] в списке заказов не нужно
  Prop.InsertProperty_String(lCat, "Тип прайса",       "Тип прайса",                      "PricePeriodText",         0);
  Prop.InsertProperty_String(lCat, "Прайс скидок",     "Прайс скидок",                    "PricePeriodDiscountText", 0);
  */
  lCat = Prop.InsertCategory (lStore, "Даты", "Даты");

  if ( Internal_GetIntOption("bShortDateCreate") ) 
    Prop.InsertProperty_Date(lCat, "Приём", "Дата приема заказа", "Date", 0);
  else
    Prop.InsertProperty_DateTime(lCat, "Приём", "Дата приема заказа", "Date", 0);

  Prop.Editable = true;
  Prop.InsertProperty_Date(lCat, "Подтверждение",       "Дата подтверждения заказа", "DateConfirm", 0);
  Prop.InsertProperty_Date(lCat, "Раскрой под плёнку", "Дата раскроя под плёнку",  "DateSawForFilm", 0);
  Prop.InsertProperty_Date(lCat, "Производство",       "Дата начала производства", "DateGiveManufact", 0);

  if ( Internal_GetIntOption("bShortDateComplete") ) 
    Prop.InsertProperty_Date    (lCat, "Отгрузка",     "Дата отгрузки заказа",        "DateComplite",     0);
  else
    Prop.InsertProperty_DateTime(lCat, "Отгрузка",     "Дата отгрузки заказа",        "DateComplite",     0);

  Prop.InsertProperty_Date  (lCat, "Доставка", "Дата доставки", "DateDelivery", 0);
  Prop.InsertProperty_String(lCat, "Плат.Расч.Док №",     "Плат.Расч.Док №",       "Komission",        0);
  Prop.InsertProperty_Date(lCat, "Дата Плат.Расч.Док.", "Дата Плат.Расч.Док.",  "DatePayDoc",       0);
  Prop.InsertProperty_String(lCat, "Асчф №",     "Асчф №",      "A_NumCalcFact",        0);

  Prop.Editable = false;

  lCat = Prop.InsertCategory (lStore, "Параметры", "Параметры");

  Prop.InsertProperty_Bool (lCat, "Гибочник",    "Гибочник",    "bCurve", true, "", "", 0);
  
  Prop.InsertProperty_String (lCat, "Герметик",        "Герметик", "SealantName", 0);

  Prop.InsertProperty_Float(lCat, "Кол-во СП",   "Кол-во СП",   "PosCount", 0);
  Prop.InsertProperty_Float(lCat, "Площадь",     "Площадь",     "Area",   0);

  Prop.InsertProperty_Float(lCat, "Скидка, %",   "Скидка, %",     "RebatePercent", 0);
  Prop.InsertProperty_Float(lCat, "Скидка, руб", "Скидка, руб",   "RebateVal", 0);
  Prop.InsertProperty_Float(lCat, "Наценка, %",  "Наценка, %",    "PriceAddPercent", 0);
  Prop.InsertProperty_Float(lCat, "Наценка, руб", "Наценка, руб", "PriceAddVal", 0);

  Prop.InsertProperty_Double(lCat, "Стоимость",   "Стоимость",   "Price",   0);
  Prop.InsertProperty_Double(lCat, "Оплачено",    "Оплачено",    "Paid",    0);
  Prop.InsertProperty_String(lCat, "Форма оплаты", "Форма оплаты (наличный/без наличный/сложная оплата)", "TypeOplText", 0);

  lCat = Prop.InsertCategory (lStore, "Прочее", "Прочее");

  Prop.InsertProperty_String    (lCat, "Очередность",         "Очередность",      "QueryCode",        0);
  Prop.InsertProperty_String    (lCat, "Комментарий",         "Комментарий",      "Commentary",       0);
  Prop.InsertProperty_String    (lCat, "Коммент.Цех",           "Комментарий Цеху",      "CommentaryEnd",    0);
  Prop.InsertProperty_String    (lCat, "Комм.Этикетки",       "Комм.Этикетки",    "CommentaryLabel",  0);
  //Prop.InsertProperty_String    (lCat, "Коммент.Цех",         "Коммент.Цех",        "CommentaryEnd",    0);
  //Prop.InsertProperty_String    (lCat, "Коммент.Доставка",    "Коммент.Доставка",   "CommentaryDeliv",  0);
  Prop.InsertProperty_String    (lCat, "Адрес доставки(ручн.)", "Адрес доставки(ручн.)", "AddressDelivery",  0);
  //Prop.bCash = false; - [ab] Кэшируем:
  Prop.InsertProperty_ComboBox  (lCat, "Адрес доставки",      "Адрес доставки",     "idDeliveryAddress",
    "select ID, Name from DeliveryAddress where idClient = " + Prog.idClient + " union " +
    "select 0 as ID, '(Не выбран)' as Name", 0);
  //Prop.bCash = true;

  Prop.InsertProperty_ComboBox  (lCat, "Направление вывоза",  "Направление вывоза", "idTripDirect",
    "select ID, Name from TripDirect union select 0 as ID, '(Не выбрано)' as Name order by Name", 0);

  Prop.InsertProperty_Int       (lCat, "Приоритет",           "Приоритет",          "Priority",         0);
  Prop.InsertProperty_Bool      (lCat, "Самовывоз",           "Самовывоз",          "bSelfDelivery",    true, "", "", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Правило отгрузки",    "Правило отгрузки",   "idPackingSettings",
    "select 0 as ID, '(Не выбрано)' as Name union select ID, Name from PackingSettings", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Время доставки",      "Время доставки",     "DeliveryTimeIndex",
    "select 0 as ID, '(Не выбрано)' as Name union " +
    "select 1 as ID, 'Утро' as Name union " +
    "select 2 as ID, 'День' as Name union " +
    "select 3 as ID, 'Вечер' as Name",
    0);
  Prop.InsertProperty_Int  (lCat, "N сборочной линии",   "N сборочной линии",   "nAssemblyLine",    0);
  Prop.InsertProperty_Bool (lCat, "Не кроить",           "Не кроить",           "bDontSaw",             true, "", "", 0);
  Prop.InsertProperty_Bool (lCat, "Упаковка в ящик",     "Упаковка в ящик",     "bPackingBox",          true, "", "", 0);
  Prop.InsertProperty_Bool (lCat, "Импорт в 1С",         "Импорт в 1С",         "b1CMustImport",        true, "", "", 0);
  Prop.Editable = true;
  Prop.InsertProperty_String (lCat, "Комментарий план",  "Доп. комментарий",    "CommentPlan",          0);  
  Prop.InsertProperty_Bool (lCat, "Вторичная продукция", "Вторичная продукция", "bSecondaryProduction", true, "", "", 0);
  Prop.InsertProperty_Bool (lCat, "Переделка по гарантии", "Переделка по гарантии (Наш брак и пакеты возвращены)", "bWarranty", true, "", "", 0);
  Prop.InsertProperty_Bool (lCat, "В работу по плат.пор.", "При оплате плат.поруч. заказ считается оплаченным и на него не действуют ограничения по кредиту клиента при запуске в производство.",
                                  "bManufByPayMessage", true, "", "", 0);
  Prop.Editable = false;
  Prop.InsertProperty_String (lCat,   "Менеджер клиента",  "Менеджер клиента",       "ManagerFromClient",      0);
  Prop.bCash = false;
}

//////////////////////////////////////////////////////////////////////////
// Редактировать свойства Выбранного заказ 

function Prog::TaskPropEdit()
{
  Prop.Clear();

  var  lStore = Prop.InsertStore ("Задание"),
       lCat   = Prop.InsertCategory (lStore, "Реквизиты", "Основные реквизиты задания");

  Prop.Editable = true;
  Prop.bCash = true;
  //Prop.InsertProperty_ComboBox  (lCat, "Тип заказа",     "Тип заказа",     "idTaskType",
  //                               "select ID, Name from TaskType", 0);
  Prop.InsertProperty_String    (lCat, "Задание №",    "Задание №",      "AccountNum",  0);
  Prop.InsertProperty_String    (lCat, "№ Заявки клиента", "№ Заявки клиента из Excel-файла", "ClientNum", 0);
  Prop.InsertProperty_String    (lCat, "Счёт №",           "Счёт №",         "Num",         0);
  Prop.InsertProperty_String    (lCat, "Услуга к счёту №", "Услуга к счёту №","ForAccountNum",0);
  Prop.InsertProperty_String    (lCat, "Счёт-Фактура №",   "Счёт-Фактура №", "NumCalcFact", 0);

  // Идентификатор государственного контракта
  Prop.InsertProperty_String    (lCat, "ИГК", "ИКГ", "ForAccountNum", 0); 

  Prop.InsertProperty_String    (lCat, "СФ от дилера №",   "Счёт-Фактура от дилера №", "NumCalcFact_Dealer", 0);

  Prop.InsertProperty_ComboBox  (lCat, "Валюта", "Заказ в валюте", "idValute", "select ID, Name from Valute order by Name", 0);
  Prop.InsertProperty_ComboBox  (lCat, "НДС,%",  "Ставка НДС", "idNDS", "select ID, cast(NDS as varchar(2)) as Name from NDS order by NDS", 0);
  Prop.bCash = false;
  //Prop.InsertProperty_Float     (lCat, "Курс", "Курс", "OwnCourse", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Продавец",         "Продавец",         "idSeller",            "select ID, case when Len(IsNull(NameInterface, '')) = 0 then Name else NameInterface end as Name from Client where Type = 1 order by NameInterface", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Банк продавца",    "Банк продавца",    "idClientBank_Seller", "select CB.ID, BK.Name from ClientBank CB inner join Bank BK on BK.ID = CB.idBank where CB.idClient = " + (Prog.idSeller? Prog.idSeller : 0) + " order by BK.Name", 0);
  Prop.InsertProperty_Button    (lCat, "Грузоотправитель", "Грузоотправитель", "idShipper", "ShipperName", "select ID, case when Len(IsNull(NameInterface, '')) = 0 then Name else NameInterface end as Name, UNN, Credit, Priority, Direct, LoadType, bDef, Debt0, Debt1, Debt2, Cred0, Cred1, Cred2, idCalcPriceMethod, nGroup, GUID from v_ClientDebt order by Name", 0);
  //Prop.InsertProperty_ComboBox  (lCat, "Грузоотправитель", "Грузоотправитель", "idShipper",           "select ID, NameInterface as Name from Client where Type = 1 order by NameInterface", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Банк грузоотправителя",    "Банк грузоотправителя",    "idClientBank_Shipper", "select CB.ID, BK.Name from ClientBank CB inner join Bank BK on BK.ID = CB.idBank where CB.idClient = " + (Prog.idShipper? Prog.idShipper : 0) + " order by BK.Name", 0);
 //[SE] Закрываем данного потребителя 
 //Prop.InsertProperty_Button    (lCat, "Потребитель", "Потребитель",   "idConsumer", "ConsumerName", "SELECT ID, Name FROM Client WHERE Type = 8 ORDER BY Name", 0); 
  Prop.InsertProperty_Button    (lCat, "Клиент",      "Клиент заказа", "idClient",   "ClientName",         "select ID, case when Len(IsNull(NameInterface, '')) = 0 then Name else NameInterface end as Name, UNN, Credit, Priority, Direct, LoadType, bDef, Debt0, Debt1, Debt2, Cred0, Cred1, Cred2, idCalcPriceMethod, nGroup, GUID from v_ClientDebt where Type = 4 order by Name", 0);
  
  // [ao] Информация, что заказ является корректирующим на основании выбранного заказа
  Prop.Editable = false;
  Prop.InsertProperty_String    (lCat, "Заказ основание",  "Заказ основание", "TaskParentName", 0);
  Prop.Editable = true;

  Prop.InsertProperty_ComboBox  (lCat, "Цех клиента",  "Цех клиента",    "idClientManufactory", "select ID, Name from ClientManufactory where idClient = " + (Prog.idClient? Prog.idClient : 0) + " order by Name", 0);

  Prop.InsertProperty_ComboBox  (lCat, "Банк клиента",    "Банк клиента",    "idClientBank_Client", "select CB.ID, BK.Name from ClientBank CB inner join Bank BK on BK.ID = CB.idBank where CB.idClient = " + (Prog.idClient? Prog.idClient : 0) + " order by BK.Name", 0);
  Prop.InsertProperty_ComboBox  (lCat, "№ Договора",  "№ Договора",    "idClientContract", "select ID, Name from ClientContract where idClient = " + (Prog.idClient? Prog.idClient : 0) + " order by Name", 0);
  Prop.InsertProperty_Button    (lCat, "Грузополучатель","Грузополучатель", "idConsignee", "ConsigneeName", "select ID, case when Len(IsNull(NameInterface, '')) = 0 then Name else NameInterface end as Name, UNN, Credit, Priority, Direct, LoadType, bDef, Debt0, Debt1, Debt2, Cred0, Cred1, Cred2, idCalcPriceMethod, nGroup, GUID from v_ClientDebt where Type = 4 order by Name", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Банк грузополучателя",    "Банк грузополучателя",    "idClientBank_Consignee", "select CB.ID, BK.Name from ClientBank CB inner join Bank BK on BK.ID = CB.idBank where CB.idClient = " + (Prog.idConsignee? Prog.idConsignee : 0) + " order by BK.Name", 0);

  Prop.Editable = (CheckTaskInReplic() == 1 ? false : true);
  Prop.InsertProperty_ComboBox  (lCat, "Подразделение", "Подразделение", "idDepotSubDivision", "select ID, Name from DepotSubDivision order by Name", 0);
  Prop.Editable = true;
  
  Prop.InsertProperty_ComboBox  (lCat, "Подразделение грузотпр.", "Подразделение грузотпр.", "idDepotSubDivision_Shipper", "select 0 as ID, 'Не выбрано' as Name union select ID, Name from DepotSubDivision order by Name", 0);
  
  Prop.bCash = true;
  Prop.InsertProperty_ComboBox  (lCat, "Статус", "Статус", "TypeOrder", 
    "select idRes as ID, Val as Name from TypeValues inner join PropType on PropType.ID = TypeValues.idPropType where PropType.Name = 'TaskWhite'",
    0);
  Prop.InsertProperty_ComboBox  (lCat, "Тип расчёта", "Тип расчёта", "CalcType", 
    "select idRes as ID, Val as Name from TypeValues inner join PropType on PropType.ID = TypeValues.idPropType where PropType.Name = 'CalcType'",
    0);
/* [YK] скрыто по указанию АБ, проверено Task.nTypeCalcPrice - не используется, используется Client.nTypeCalcPrice
  Prop.InsertProperty_ComboBox  (lCat, "Расчет цены", "Метод расчета цены", "nTypeCalcPrice",
    "select 1 as ID, 'по Прайсу'        as Name union " +
    "select 3 as ID, 'Прайс Допл.без Коэф' as Name union " +
    "select 2 as ID, 'по Себестоимости' as Name", 0);
*/
  Prop.InsertProperty_ComboBox  (lCat, "Тип прайса", "Тип прайса", "idPricePeriod",
    "select 0 as ID, '-Базовый-' as Name , 0 as nOrder "               +
    "union "                                                           +
    "select "                                                          +
    "  PP.ID, PP.PeriodName as Name, 1 as nOrder "                     +
    "from PricePeriod PP "                                             +
    "  inner join ClientPricePeriod CPP on CPP.idPricePeriod = PP.ID " +
    "where CPP.idClient = " + Prog.idClient + " and IsNull(PP.bDiscount, 0) = 0 " +
    "order by "                                                        +
    "  nOrder, Name", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Прайс скидок", "Прайс скидок", "idPricePeriodDiscount",
    "select 0 as ID, '-Без скидок-' as Name , 0 as nOrder "            +
    "union "                                                           +
    "select "                                                          +
    "  PP.ID, PP.PeriodName as Name, 1 as nOrder "                     +
    "from PricePeriod PP "                                             +
    "  inner join ClientPricePeriod CPP on CPP.idPricePeriod = PP.ID " +
    "where CPP.idClient = " + Prog.idClient + " and IsNull(PP.bDiscount, 0) = 1 " +
    "order by "                                                        +
    "  nOrder, Name", 0);

  lCat = Prop.InsertCategory (lStore, "Даты", "Даты");

  if ( Internal_GetIntOption("bShortDateCreate") )  
    Prop.InsertProperty_Date      (lCat, "Приём",        "Дата приема заказа",          "Date",             0);
  else
    Prop.InsertProperty_DateTime   (lCat, "Приём",        "Дата приема заказа",          "Date",             0);

  Prop.InsertProperty_Date(lCat, "Подтверждение", "Дата подтверждения заказа", "DateConfirm", 0);
  Prop.InsertProperty_Date(lCat, "Раскрой под плёнку", "Дата раскроя под плёнку", "DateSawForFilm", 0);
  Prop.InsertProperty_Date(lCat, "Производство", "Дата начала производства",    "DateGiveManufact", 0);

  // У раскроенных заказов нельзя менять дату отгрузки
  Prop.Editable = (CheckTaskInSaw()? false : true);
  if ( Internal_GetIntOption("bShortDateComplete") )  
    Prop.InsertProperty_Date    (lCat, "Отгрузка",     "Дата отгрузки заказа",        "DateComplite",     0);
  else
    Prop.InsertProperty_DateTime(lCat, "Отгрузка",     "Дата отгрузки заказа",        "DateComplite",     0);
  Prop.Editable = true;

  Prop.InsertProperty_Date      (lCat, "Доставка",        "Дата доставки",          "DateDelivery",             0);
  Prop.InsertProperty_String    (lCat, "Плат.Расч.Док №",     "Плат.Расч.Док №",      "Komission",        0);
  Prop.InsertProperty_Date      (lCat, "Дата Плат.Расч.Док.", "Дата Плат.Расч.Док.",  "DatePayDoc", 0);
  Prop.InsertProperty_String    (lCat, "Асчф №",     "Асчф №",      "A_NumCalcFact",        0);

  lCat = Prop.InsertCategory (lStore, "Параметры", "Параметры");

  Prop.InsertProperty_Bool      (lCat, "Гибочник",        "Заказ производить из гибкой рамки на Гибочнике?", "bCurve",        true, "", "", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Категория Площади","Категория площади", "idAreaCategory",
                                       "select 0 as ID, '(Не выбрано)' as Name union select ID, Name from AreaCategory", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Герметик",        "Герметик", "idSealant",
                                       "select 0 as ID, '(Не выбрано)' as Name union select ID, Name from Sealant", 0);
  Prop.InsertProperty_Bool      (lCat, "Печать на рамке", "Печатать на рамке на рамочном принтере?",         "bPrintOnFrame", true, "", "", 0);
  
  Prop.InsertProperty_Float     (lCat, "Кол-во СП",   "Кол-во СП",   "PosCount", 0);
  Prop.InsertProperty_Float     (lCat, "Площадь",     "Площадь",     "Area",   0);

  Prop.InsertProperty_Float     (lCat, "Скидка, %",    "Скидка, %",    "RebatePercent",   0);
  Prop.InsertProperty_Float     (lCat, "Скидка, руб",  "Скидка, руб",  "RebateVal",       0);
  Prop.InsertProperty_Float     (lCat, "Наценка, %",   "Наценка, %",   "PriceAddPercent", 0);
  Prop.InsertProperty_Float     (lCat, "Наценка, руб", "Наценка, руб", "PriceAddVal",     0);

  Prop.InsertProperty_Float     (lCat, "Стоимость",   "Стоимость",   "Price",  0);
  Prop.InsertProperty_Float     (lCat, "Оплачено",    "Оплачено",    "Paid",   0);
  Prop.InsertProperty_ComboBox  (lCat, "Форма оплаты", "Форма оплаты (наличный/без наличный/сложная оплата)", "TypeOpl",
   "Select idRes as ID, Val as Name from TypeValues TV inner join PropType PT on PT.ID = TV.idPropType where PT.Name = 'TypeOpl'", 0);
  Prop.InsertProperty_Bool      (lCat, "Цена доставки в кв.м", "Включать цену доставки в кв.м изделия?", "bPriceDeliveryToM2", true, "", "", 0);
  Prop.InsertProperty_Float     (lCat, "Цена доставки", "Цена доставки за кв.м изделия", "PriceDelivery", 0);

  lCat = Prop.InsertCategory (lStore, "Прочее", "Прочее");

  Prop.InsertProperty_String    (lCat, "Очередность",       "Очередность",      "QueryCode",        0);
  Prop.InsertProperty_String    (lCat, "Комментарий",       "Комментарий",      "Commentary",       0);
  Prop.InsertProperty_String    (lCat, "Коммент.Цех",           "Комментарий Цеху",      "CommentaryEnd",    0);
  Prop.InsertProperty_String    (lCat, "Комм.Этикетки",     "Комм.Этикетки",    "CommentaryLabel",  0);
  /*Prop.InsertProperty_Int       (lCat, "Тип этикетки",          "Тип этикетки",          "nLabelSubType",    0);*/

  Prop.InsertProperty_ComboBox  (lCat, "Тип этикетки", "Тип этикетки", "nLabelSubType",
    "select nSubType as ID, Code as Name from LabelSubType where idClient = " + Prog.idClient + " order by nSubType", 0);

  /* код этикетки без разбора по клиенту    
  Prop.InsertProperty_ComboBox  (lCat, "Тип этикетки", "Тип этикетки", "nLabelSubType",
    "select nSubType as ID, Code as Name from LabelSubType order by nSubType", 0);
  */
  //Prop.InsertProperty_String    (lCat, "Коммент.Доставка",  "Коммент.Доставка", "CommentaryDeliv",  0);
  Prop.InsertProperty_String    (lCat, "Адрес доставки(ручн.)", "Адрес доставки(ручн.)",   "AddressDelivery",  0);
  //Prop.bCash = false; - [ab] Кэшируем:
  Prop.InsertProperty_ComboBox  (lCat, "Адрес доставки",    "Адрес доставки",   "idDeliveryAddress",
    "select ID, Name from DeliveryAddress where idClient = " + Prog.idClient + " union " +
    "select 0 as ID, '(Не выбран)' as Name order by Name",
    0);
  //Prop.bCash = true;

  Prop.InsertProperty_ComboBox  (lCat, "Направление вывоза",  "Направление вывоза", "idTripDirect",
    "select ID, Name from TripDirect union select 0 as ID, '(Не выбрано)' as Name order by Name", 0);

  Prop.InsertProperty_Int       (lCat, "Приоритет",           "Приоритет",          "Priority",     0);
  Prop.InsertProperty_Bool      (lCat, "Самовывоз",           "Самовывоз",          "bSelfDelivery", true, "", "", 0);
  Prop.InsertProperty_ComboBox  (lCat, "Правило отгрузки",    "Правило отгрузки",   "idPackingSettings",
    "select 0 as ID, '(Не выбрано)' as Name union select ID, Name from PackingSettings", 0);

  Prop.InsertProperty_ComboBox  (lCat, "Время доставки",      "Время доставки",     "DeliveryTimeIndex",
    "select 0 as ID, '(Не выбрано)' as Name union " +
    "select 1 as ID, 'Утро' as Name union " +
    "select 2 as ID, 'День' as Name union " +
    "select 3 as ID, 'Вечер' as Name",
    0);
  Prop.InsertProperty_Int  (lCat, "N сборочной линии",        "N сборочной линии",             "nAssemblyLine",    0);
  Prop.InsertProperty_Bool (lCat, "Не кроить",                "Не кроить",                     "bDontSaw",        true, "", "", 0);
  Prop.InsertProperty_Bool (lCat, "Упаковка в ящик",          "Упаковка в ящик",               "bPackingBox",     true, "", "", 0);
  Prop.InsertProperty_Float(lCat, "Цена упаковки",            "Цена упаковки за кв.м изделия", "PricePacking", 0);

  Prop.InsertProperty_Bool (lCat, "Вторичная продукция",      "Вторичная продукция",      "bSecondaryProduction", true, "", "", 0);
  Prop.InsertProperty_Bool (lCat, "Автом.Расчет Материалов",  "Автом.Расчет Материалов",  "bAutoCalcMaterial",    true, "", "", 0); // проверяется в sp_TaskCheckComplex
  Prop.InsertProperty_Bool (lCat, "Импорт в 1С",              "Импорт в 1С",              "b1CMustImport",        true, "", "", 0);
  
  Prop.Editable = true;
  Prop.InsertProperty_Bool(lCat, "Переделка по гарантии", "Переделка по гарантии (Наш брак и пакеты возвращены)", "bWarranty", true, "", "", 0);
  Prop.InsertProperty_Bool (lCat, "В работу по плат.пор.", "При оплате плат.поруч. заказ считается оплаченным и на него не действуют ограничения по кредиту клиента при запуске в производство.",
                                  "bManufByPayMessage", true, "", "", 0);
  Prop.InsertProperty_String (lCat,   "Менеджер клиента",    "Менеджер клиента",       "ManagerFromClient",      0);
  Prop.Editable = false;
  
  sSQL = "select case when MAX(ISNULL(BarCode.idBarCode_Reject,0)) > 0 then 1 else 0 end as bRemakeReject " +
         "from Project left join BarCode on Project.ID = BarCode.idProject where Project.idTask = " + Prog.idTask;
  bRemakeReject = Prog.Select_Int(sSQL, "bRemakeReject", true);
  if ( bRemakeReject == 1 )
  {
  Prop.Editable = true;
    Prop.InsertProperty_Button(lCat, "Ответственные лица", "Ответственные лица", "ID", " ", " ", 0);
    // [MR] Информация для кредит-ноты
    lCat = Prop.InsertCategory (lStore, "Кредит-нота / КСФ", "Кредит-нота / КСФ");
    Prop.InsertProperty_String (lCat,   "Изм.№ СФ для КСФ",  "Номер кредит-ноты",      "KSF_NumCalcFact",       0);
    Prop.InsertProperty_String (lCat,   "Номер",             "Номер кредит-ноты",      "CreditNoteNum",         0);
    Prop.InsertProperty_Date   (lCat,   "Дата",              "Дата кредит-ноты",       "CreditNoteDate",        0);
    Prop.InsertProperty_String (lCat,   "Описание",          "Описание кредит-ноты",   "CreditNoteDescription", 0);
  Prop.Editable = false;
  }
  Prop.bCash = false;
}

//////////////////////////////////////////////////////////////////////////
// Показать свойства выбранного маршрута.

function Prog::TripPropShow()
{
  Prop.Clear();

  var
    lStore  = Prop.InsertStore("Маршрут"),
    lCat    = Prop.InsertCategory(lStore, "Маршрут", "Реквизиты маршрута");

  Prop.Editable = false;
  Prop.bCash = true;
  Prop.InsertProperty_Date    (lCat, "Отгрузка",      "Отгрузка",       "DateCompliteShow",   0);
  Prop.InsertProperty_ComboBox(lCat, "Направление",   "Направление",    "idTripDirect",
    "select ID, Name from TripDirect union select 0 as ID, '(Не выбрано)' as Name order by Name", 0);
  
  Prop.InsertProperty_ComboBox(lCat, "Машина",        "Машина",         "idTripTransport",
    "select ID, Name + ' - ' + IsNull(GosNumber, '') as Name from TripTransport union select 0 as ID, '-' as Name", 0);
  Prop.bCash    = false;
  Prop.Editable = false;

  Prop.InsertProperty_Int     (lCat, "Очередь",       "Очередь",        "TripOrder",          0);

  Prop.Editable = true;
  Prop.InsertProperty_Bool    (lCat, "Вдоль?", "Расположение пирамиды вдоль машины?",  "bAlong", true, "Вдоль", "Поперёк", 0);
  Prop.InsertProperty_Int     (lCat, "Уровень", "Уровень на борту расположения вдоль", "nLevel", 0);
  
  Prop.Editable = false;
  Prop.InsertProperty_String  (lCat, "Клиент",        "Клиент",         "ClientName",         0);
 
  // если включена настройка ручной сброс нумерации пирамид
  if ( Prog.Select_Int("select case d_iNum when 2 then 1 else 0 end as bManualReset from Config where Name = 'TripPyramidOrder'", "bManualReset", true) == 1 )
  {
    Prop.Editable = true;
    lCat    = Prop.InsertCategory(lStore, "Нумерация", "Нумерация пирамид");
    Prop.InsertProperty_Int     (lCat, "След. № пирамиды", "Следующий номер упаковочной пирамиды.\nДля сброса нумерации введите \"1\"!", "TripPyramid_NextNum", 0);
    Prop.Editable = false;
  }
}

//////////////////////////////////////////////////////////////////////////
// Редактировать свойства выбранного маршрута.

function Prog::TripPropEdit()
{
  Prop.Clear();

  var
    lStore = Prop.InsertStore ("Маршрут"),
    lCat = Prop.InsertCategory(lStore, "Маршрут", "Реквизиты маршрута");

  Prop.Editable = true;
  Prop.bCash    = true;
  Prop.InsertProperty_Date    (lCat, "Отгрузка",    "Отгрузка",    "DateBegin",  0);
  Prop.InsertProperty_ComboBox(lCat, "Направление", "Направление", "idTripDirect",
    "select ID, Name from TripDirect union select 0 as ID, '(Не выбрано)' as Name order by Name",         0);
  Prop.InsertProperty_ComboBox(lCat, "Машина",      "Машина",      "idTripTransport",
    "select ID, Name + ' - ' + IsNull(GosNumber, '') as Name from TripTransport union select 0 as ID, '-' as Name",      0);
  Prop.bCash    = false;
  Prop.Editable = false;

  Prop.InsertProperty_Int     (lCat, "Очередь",     "Очередь",     "TripOrder",  0);
  Prop.InsertProperty_String  (lCat, "Клиент",      "Клиент",      "ClientName", 0);

  // если включена настройка ручной сброс нумерации пирамид
  if ( Prog.Select_Int("select case d_iNum when 2 then 1 else 0 end as bManualReset from Config where Name = 'TripPyramidOrder'", "bManualReset", true) == 1 )
  {
    Prop.Editable = true;
    lCat    = Prop.InsertCategory(lStore, "Нумерация", "Нумерация пирамид");
    Prop.InsertProperty_Int     (lCat, "След. № пирамиды", "Следующий номер упаковочной пирамиды.\nДля сброса нумерации введите \"1\"!", "TripPyramid_NextNum", 0);
    Prop.Editable = false;
  }
}

//////////////////////////////////////////////////////////////////////////
// Редактировать свойства Выбранного Раскроя

function Prog::SawTaskProp()
{
  Prop.Clear();

  var  lStore = Prop.InsertStore ("Задание"),
       lCat = Prop.InsertCategory (lStore, "Реквизиты", "Основные реквизиты задания");

  Prop.Editable = true;
  Prop.bCash    = true;
  Prop.InsertProperty_String  (lCat, "Задание №",     "Задание №",    "Name", 0);
  Prop.InsertProperty_Date    (lCat, "Дата",          "Дата",         "Data", 0);
  Prop.InsertProperty_ComboBox(lCat, "Подразд.",      "Подразд.",     "idDepot", "select NULL as ID, '-' as Name union select ID, Name from DepotSubDivision order by Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Цех",           "Цех",          "idWorkShop",     "select NULL as ID, '-' as Name union select ID, Name from WorkShop order by Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Линия",         "Линия",        "idAssemblyLine", "select NULL as ID, '-' as Name union select ID, Name from AssemblyLine order by Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Бригада",       "Бригада",      "idTeam",         "select NULL as ID, '-' as Name union select ID, Name from Team where IsNull(bHide, 0) = 0 and IsNull(nType, 0) = 0  order by Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Бригада рез.",  "Бригада рез.", "idTeam_Cutter",  "select NULL as ID, '-' as Name union select ID, Name from Team where IsNull(bHide, 0) = 0 and IsNull(nType, 0) = 1 order by Name", 0);
  Prop.InsertProperty_Bool    (lCat, "Гибочник",      "Гибочник",     "bCurve", true, "", "", 0);
  Prop.InsertProperty_String  (lCat, "Комментарий",   "Комментарий",  "Comment", 0);
  Prop.InsertProperty_Float   (lCat, "Листов",        "Листов",       "nUsedGlass", 0);
  Prop.InsertProperty_ComboBox(lCat, "Маркировка",    "Маркировка",   "nMarkType", "select 0 as ID, 'Пир/яч' as Name union select 1 as ID, 'Зак/поз' as Name order by ID", 0);
  Prop.InsertProperty_Bool    (lCat, "Выгружен",      "Выгружен",     "bMaked", true, "", "", 0);
  //Prop.InsertProperty_Bool    (lCat, "Зак./Поз.?",  "Зак./Поз.?",   "bTaskPos", true, "", "", 0);
  Prop.InsertProperty_Bool    (lCat, "Обратная сортировка",    "Обратная сортировка",     "bSortDesc", true, "", "", 0);
  Prop.Editable = false;
  Prop.InsertProperty_Int     (lCat, "К раскрою СП",          "К раскрою СП",     "OnSawCount", 0);
  Prop.InsertProperty_Int     (lCat, "К раскрою стекол",      "К раскрою стекол", "GlassCount", 0);
  Prop.InsertProperty_Float   (lCat, "К раскрою, м2",         "К раскрою, м2",    "OnSawArea",  0);
  //Prop.InsertProperty_Float   (lCat, "Всего для бригады СП",  "Количество запланированных СП для бригады на день", "OnGPCoutDayTeam", 0);
  //Prop.InsertProperty_Float   (lCat, "Из них 1 кам. шт.",     "Количество запланированных 1 кам. СП для бригады на день", "OnGP1CountDayTeam", 0);
  //Prop.InsertProperty_Float   (lCat, "Из них 2 кам. шт.",     "Количество запланированных 2 кам. СП для бригады на день", "OnGP2CountDayTeam", 0);
  //Prop.InsertProperty_Float   (lCat, "Всего для бригады м2",  "Площадь запланированных СП для бригады на день", "OnGPAreaDayTeam", 0);
  Prop.InsertProperty_Float   (lCat, "Остаток",               "Количество стеклопакетов не распланированных по раскроям", "OnGPCountNotSaw", 0);
  Prop.InsertProperty_String  (lCat, "Состояние",             "Состояние упаковки", "PackingStateText", 0);
  Prop.InsertProperty_Bool    (lCat, "Списан по складу",      "Раскрой проведен по скаладу", "bWriteMater", true, "", "", 0);
  Prop.bCash = false;

  //lStore = Prop.InsertStore   ("Арфа-пирамиды"),
  lCat = Prop.InsertCategory  (lStore, "Ограничения", "Ограничения для арфа-пирамид");
  Prop.Editable = true;
  Prop.InsertProperty_Int     (lCat, "Ширина",           "Ширина",           "nMaxArfaWidth",       0);
  Prop.InsertProperty_Int     (lCat, "Высота",           "Высота",           "nMaxArfaHeight",      0);
  Prop.InsertProperty_Float   (lCat, "Вес стеклины",     "Вес стеклины",     "nMaxArfaWeight",      0);
  Prop.InsertProperty_Float   (lCat, "Толщина стеклины", "Толщина стеклины", "nMaxArfaThickness",   0);
  Prop.InsertProperty_Int     (lCat, "Шт.в позиции",     "Шт.в позиции",     "nMaxArfaSerialCount", 0);
  Prop.Editable = false;

  lCat = Prop.InsertCategory  (lStore, "Прочее", "Стартовые номера");
  Prop.bCash    = true;
  Prop.Editable = true;
  Prop.InsertProperty_Int     (lCat, "Арфы №",             "Арфы №",             "nArfaStart",        0);
  Prop.InsertProperty_Int     (lCat, "А-пир. СП  № пачки", "А-пир. СП  № пачки", "nPackStartAPyrGP",  0);
  Prop.InsertProperty_Int     (lCat, "А-пир. Нар № пачки", "А-пир. Нар № пачки", "nPackStartAPyrNar", 0);
  Prop.InsertProperty_ComboBox(lCat, "Стол раскроя",  "Стол раскроя", "idCuttingTable", 
                               "select NULL as ID, '-' as Name union select ID, Name from CuttingTable order by Name", 0);
  Prop.Editable = false;
}

//////////////////////////////////////////////////////////////////////////
// Показать свойства планирования.

function Prog::PlanPropShow()
{
  Prop.Clear();

  var
    lStore = Prop.InsertStore ("План"),
    lCat   = Prop.InsertCategory (lStore, "План", "Реквизиты плана");

  Prop.bCash = true;
  Prop.InsertProperty_Date    (lCat, "Производство", "Дата начала производства", "DateGiveManufact", 0);
  Prop.InsertProperty_Date    (lCat, "Отгрузка",     "Дата отгрузки",            "DateShiping",      0);  // Дата отгрузки задания в производство или наряд заказа.
  Prop.InsertProperty_ComboBox(lCat, "Бригада", "Бригада", "idTeam", "select ID, Name from Team where IsNull(bHide, 0) = 0 and IsNull(nType,0) = 0 union " +
                                                                     "select 0 as ID, '-' as Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Смена",   "Смена",   "nSmena", "select 1 as ID, '1' as Name union " +
                                                                     "select 2 as ID, '2' as Name union " +
                                                                     "select 3 as ID, '3' as Name union " +
                                                                     "select 0 as ID, '-' as Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Цех",     "Цех", "idWorkShop", "select ID, Name from WorkShop union " +
                                                                     "select 0 as ID, '-' as Name order by Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Линия сборки", "Линия сборки", "idAssemblyLine", "select ID, Name from AssemblyLine union " +
                                                                     "select 0 as ID, '-' as Name order by Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Завод", 
                                     "Производственное подразделение", "idDepotSubDivision", "select ID, Name from DepotSubDivision order by Name", 0);
  Prop.bCash = false;
}

//////////////////////////////////////////////////////////////////////////
// Редактировать свойства планирования.

function Prog::PlanPropEdit()
{
  Prop.Clear();

  var
    lStore = Prop.InsertStore ("План"),
    lCat   = Prop.InsertCategory (lStore, "План", "Реквизиты плана");

  Prop.bCash = true;
  Prop.InsertProperty_Date    (lCat, "Производство", "Дата начала производства", "DateGiveManufact", 0);
  Prop.InsertProperty_Date    (lCat, "Отгрузка",     "Дата отгрузки",            "DateShiping",      0);  // 121121 [SB] Дата отгрузки задания в производство или наряд заказа.
  Prop.InsertProperty_ComboBox(lCat, "Бригада", "Бригада", "idTeam", "select ID, Name from Team where IsNull(bHide, 0) = 0 and IsNull(nType,0) = 0 union " +
                                                                     "select 0 as ID, '-' as Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Смена",   "Смена",   "nSmena", "select 1 as ID, '1' as Name union " +
                                                                     "select 2 as ID, '2' as Name union " +
                                                                     "select 3 as ID, '3' as Name union " +
                                                                     "select 0 as ID, '-' as Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Цех",     "Цех", "idWorkShop", "select ID, Name from WorkShop union " +
                                                                     "select 0 as ID, '-' as Name order by Name", 0);
  Prop.InsertProperty_ComboBox(lCat, "Линия сборки", "Линия сборки", "idAssemblyLine", "select ID, Name from AssemblyLine union " +
                                                                     "select 0 as ID, '-' as Name order by Name", 0);
  Prop.bCash = false;                                                                     
}

function Prog::TaskManufPropShow()
{
  Prop.Clear();

  var
    lStore = Prop.InsertStore ("Заказы в пр-во"),
    lCat   = Prop.InsertCategory (lStore, "Заказы в пр-во", "Заказы в производство");

  Prop.Editable = false;
  Prop.InsertProperty_String  (lCat, "Номер задания", "Номер задания",     "ManufName",        0);
  Prop.Editable = true;
  Prop.bCash    = true;
  Prop.InsertProperty_Int     (lCat, "Приоритет задания", "Приоритет задания", "Priority",     0);
  Prop.InsertProperty_Date    (lCat, "Производство",      "Дата производства", "DateGiveManufact", 0);
  Prop.InsertProperty_Date    (lCat, "Отгрузка",          "Дата отгрузки",     "DateShiping",      0);
  Prop.InsertProperty_ComboBox(lCat, "Подразделение",     "Производственная площадка", "idDepotSubDivision",
                                     "select ID, Name from DepotSubDivision union " +
                                     "select 0 as ID, '-' as Name order by Name", 0);
  Prop.bCash = false;                                     
}

function Prog::CuttingPropShow()
{
	/**/
  Prop.Clear();
  Prop.Editable = false;

  var
    lStore = Prop.InsertStore ("Раскрой"),
    lCat   = Prop.InsertCategory (lStore, "Деталь", "Выбранная деталь");

  Prop.InsertComp_Int    (lCat, "Ширина",  1600,  "Ширина",  0);
  Prop.InsertComp_Int    (lCat, "Высота",  1800,  "Высота",  0);
	/**/
}

function CalcAngles(X1, Y1, X2, Y2, X0, Y0, nAngle)
{
  var  a1, a2;

  if ( X1 - X0 == 0 )
    a1 = Math.PI / 2.;
  else
    a1 = Math.abs(Math.atan((Y1 - Y0) / (X1 - X0)));
  if ( X1 - X0 < 0  &&  Y1 - Y0 >= 0 )
    a1 = Math.PI - a1;
  if ( X1 - X0 < 0  &&  Y1 - Y0 < 0 )
    a1 = Math.PI + a1;                       // проверяем возможное положение угла во II - III -четверти
  if ( X1 - X0 >= 0  &&  Y1 - Y0 < 0 )
    a1 = 2 * Math.PI - a1;                   // Начальный угол дуги к оси ОХ (a1>0)
  if ( X2 - X0 == 0 )
    a2 = Math.PI / 2.;
  else
    a2 = Math.abs(Math.atan((Y2 - Y0) / (X2 - X0)));
  if ( X2 - X0 < 0  &&  Y2 - Y0 >=0 )
    a2 = Math.PI - a2;
  if ( X2 - X0 < 0  &&  Y2 - Y0 < 0 )
    a2 = Math.PI + a2;                       // проверяем возможное положение угла во II - III -четверти
  if ( X2 - X0 >= 0  &&  Y2 - Y0 < 0 )
    a2 = 2 * Math.PI - a2;                   // Конечный угол дуги к оси OX (a2>0)

  if ( a2 > a1 )
    a2 = a2 - 2 * Math.PI;
  else
    a2 = a2 + 2 * Math.PI;

  if ( a2 > Math.PI * 2 )
  {
    a2 = a2 - 2 * Math.PI;
    a1 = a1 - 2 * Math.PI;
  }
  if ( nAngle == 1 )
    return a1;
  else
    return a2;
}
//////////////////////////////////////////////////////////////////////////
// Отобразить свойства текущего объекта ------------
// Prop.js

function Prog::PropShow()
{
  //Prog.SaveError("Prog: :PropShow nClass = " + CurObj.nClass, false);
  try
  {
    var  CurObj            = Prog.CurObj,
         CurSeg            = Prog.CurSeg,
         CurVector         = Prog.CurVector,
         PropShowMode      = Prog.PropShowMode,
         bGlassAddBToSizes = Prog.bGlassAddBToSizes;

    Prop.Clear();
    Prop.Editable = true;
    
    //[OK] А кто вообще сказал, что CurObj есть?    
    if ( !CurObj )
      return;

    switch ( CurObj.nClass )
    {
      case nClass_Glass:

        var  lStore = Prop.InsertStore ("Стеклопакет"),
             lCat   = Prop.InsertCategory (lStore, "Размеры стеклопакета", "Габаритный размер стеклопакета"),
             lComp  = Prop.InsertCompound (lCat,   "Размер стеклопакета",  "Габаритный размер стеклопакета"),
             sP = "Нет",
             sSQL;

        if ( PropShowMode == 1  &&  CurVector )
        {
          lCat  = Prop.InsertCategory (lStore, "Расположение сегмента", "Расположение сегмента стеклопакета");
          lComp = Prop.InsertCompound (lCat, "Координаты", "Расположение сегмента стеклопакета");

          //Prop.InsertComp_Float(lComp, "X", CurVector.X, "X", 3);
          //Prop.InsertComp_FloatlComp, "Y", CurVector.Y, "Y", 4);
          
          Prop.InsertComp_FloatFormat(lCat, "X", CurVector.X, "X", "%.2f", 3);
          Prop.InsertComp_FloatFormat(lCat, "Y", CurVector.Y, "Y", "%.2f", 4);

          lCat  = Prop.InsertCategory (lStore, "Формулы", "Формулы координат");
          Prop.InsertComp_String  (lCat, "Формула X",  CurVector.AnalExpr_X,    "Формула X",      0);
          Prop.InsertComp_String  (lCat, "Формула Y",  CurVector.AnalExpr_Y,    "Формула Y",      0);

          lCat  = Prop.InsertCategory (lStore, "Обработки стекла", "Обработки стекла");
          Prop.InsertComp_String  (lCat, "Обработка",  CurVector.Processing,    "Обработка",      0);

          lCat  = Prop.InsertCategory (lStore, "Скругление угла", "Скругление угла");
          Prop.InsertComp_String  (lCat, "Радиус",  CurVector.CornerRadius,    "Радиус",      0);

          break;
        }
        else
        if ( PropShowMode == 2  &&  CurSeg )
        {
          lCat  = Prop.InsertCategory (lStore, "Выступ стекла(зуб)", "Выступ стекла(зуб)");
          Prop.InsertComp_Float (lCat, "Выступ стекла", CurSeg.OuterMargin, "Выступ стекла", 0);
          lCat  = Prop.InsertCategory (lStore, "Шлифование стороны", "Шлифование стороны");
          Prop.InsertComp_Float (lCat, "Глубина шлифования", CurSeg.DephGrind, "Глубина шлифования", 0);
          
          Prop.Editable = false;

          lCat  = Prop.InsertCategory (lStore, "Припуски на обработку стекла", "Припуски на обработку стекла");

          Prop.InsertComp_Float  (lCat, "Припуск стекла 1",  CurSeg.ProcessMarginGlass1,    "Припуск стекла 1",      0);
          Prop.InsertComp_Float  (lCat, "Припуск стекла 2",  CurSeg.ProcessMarginGlass2,    "Припуск стекла 2",      0);
          Prop.InsertComp_Float  (lCat, "Припуск стекла 3",  CurSeg.ProcessMarginGlass3,    "Припуск стекла 3",      0);

          Prop.Editable = true;

          lCat  = Prop.InsertCategory (lStore, "Обработки стекла", "Обработки стекла");
          Prop.InsertComp_String  (lCat, "Обработка",  CurSeg.Processing,    "Обработка",      0);

          if ( !CurSeg.IsArc )
          {
            lCat  = Prop.InsertCategory (lStore, "Углы", "Обработки стекла");
            
            Prop.InsertComp_FloatFormat(lCat, "Угол начальный", CurSeg.AngleLef_Dim, "Угол начальный - при рассмотреннии сегмента против часовой стрелки", "%.2f", 7)
            Prop.InsertComp_FloatFormat(lCat, "Угол конечный",  CurSeg.AngleRig_Dim, "Угол конечный - при рассмотреннии сегмента против часовой стрелки",  "%.2f", 7);

            
            lCat  = Prop.InsertCategory(lStore, "Текст", "Показать текст");
            Prop.InsertCat_CheckBox    (lCat,   "Показать длину", CurSeg.bShowLength, "Показать длину");
          }
          
          if ( CurSeg.IsArc )
          {
            lCat  = Prop.InsertCategory (lStore, "Арочный сегмент", "Арочный сегмент");
            lComp = Prop.InsertCompound (lCat, "Высота хорды арки", "Высота хорды арки");
            
            var  t        = Math.sqrt((CurSeg.V.X - CurSeg.VNext.X) * (CurSeg.V.X - CurSeg.VNext.X) + (CurSeg.V.Y - CurSeg.VNext.Y) * (CurSeg.V.Y - CurSeg.VNext.Y)) / 2,
                 fAngle1  = CalcAngles(CurSeg.V.X, CurSeg.V.Y, CurSeg.VNext.X, CurSeg.VNext.Y, CurSeg.VCenter.X, CurSeg.VCenter.Y, 1),
                 fAngle2  = CalcAngles(CurSeg.V.X, CurSeg.V.Y, CurSeg.VNext.X, CurSeg.VNext.Y, CurSeg.VCenter.X, CurSeg.VCenter.Y, 2),
                 fAngle   = fAngle2 - fAngle1,
                 Chord;
            
            if ( fAngle > Math.PI )
              Chord = CurSeg.R + Math.sqrt((CurSeg.R * CurSeg.R) - t * t);
            else
              Chord = CurSeg.R - Math.sqrt((CurSeg.R * CurSeg.R) - t * t);

            Prop.InsertComp_Int  (lComp, "Высота хорды", Chord,        "Высота хорды", 0);
            Prop.InsertComp_Float(lComp, "Радиус",       CurSeg.R,     "Радиус",       0);
          }
          break;
        }

        CalcFigureParam(CurObj);

        // не даем менять эти свойства если непрямоуголник, потому что все остальное нужно хитро обрабатывать
        if ( !(GP.SegCount == 4 && GP.RightAngleCount == 4 && !GP.ArcSegCount) ) 
          Prop.Editable = false;
        Prop.InsertComp_Int(lComp, "Ширина", CurObj.Int("Glass_Width" ), "Ширина ", 3);
        Prop.InsertComp_Int(lComp, "Высота", CurObj.Int("Glass_Height"), "Высота ", 4);
        Prop.Editable = true;
        
        // позволяем менять высоту прямоугольной части если не прямоугольник
        if ( (GP.SegCount == 4 && GP.RightAngleCount == 4 && !GP.ArcSegCount) ) 
          Prop.Editable = false;
        Prop.InsertComp_Int(lComp, "Высота прямоугольной части", CurObj.Int("Glass_Height"), "Высота прямоугольной части ", 4);
        Prop.Editable = true;
        
        //Prop.InsertCat_ComboBox(lCat,  "Ширина Шпрос",    CurObj.StringID("ID_Ras_Width"),  "Ширина Шпрос",    0, "select ID, Name from WidthType");
        
        Prop.InsertCat_CheckBox(lComp, "Прибавлять B",   (bGlassAddBToSizes)?1:0,           "Прибавлять B к размерам при раскрое");
        Prop.InsertComp_Int    (lComp, "Геом. тип сп",    CurObj.Int  ("GeomType"),         "Геом. тип сп",    0);

        lCat  = Prop.InsertCategory (lStore, "Выступ стекла(зуб)", "Выступ стекла(зуб)");
        // заполнение выпадающего списка для выбора номера стекла с выступом
        // перебераем все стекла из рекордсета ProjectItem
        var SQL = Prog.GetSQL_ListNumGlass();
        Prop.InsertComp_Float  (lCat, "Выступ стекла", CurObj.Float("OuterMargin" ), "Выступ стекла",       0);
        Prop.InsertCat_ComboBox(lCat, "№ стекла",      CurObj.Int("nGlassMargin" ),  "№ стекла с выступом", 0, SQL);

        var nCamCount = GP.GetShort("CamCount");
        lCat  = Prop.InsertCategory (lStore, "Шлифование", "Шлифование");
        Prop.InsertComp_Float  (lCat, "Глубина шлифования",  CurObj.Float("DephGrind" ), "Глубина шлифования", 0);
        // запретим менять шлифовку стекла на чертеже, шлифовка стекла изменяется в справочнике видов стекла
        Prop.Editable = false;
        Prop.InsertCat_CheckBox(lCat, "Шлифование стекла 1", CurObj.Int("bGrindGlass1"), "Шлифование стекла 1");
        if ( nCamCount > 0 )
          Prop.InsertCat_CheckBox(lCat, "Шлифование стекла 2", CurObj.Int("bGrindGlass2"), "Шлифование стекла 2");
        if ( nCamCount > 1 )
          Prop.InsertCat_CheckBox(lCat, "Шлифование стекла 3", CurObj.Int("bGrindGlass3"), "Шлифование стекла 3");

        Prop.InsertCat_ComboBox(lCat, "Тип построения",   Prog.ModeGrind, "Вид постороения зон шлифования", 0, 
                                "select 0 as ID, 'Областями (под 45%)' as Name union " +
                                "select 1 as ID, 'Треками + Областями (под 45%) - по умолчанию' as Name union " +
                                "select 2 as ID, 'Областями (под 90%) вариант А' as Name union " +
                                "select 3 as ID, 'Областями (под 90%) вариант B' as Name");
				
				Prop.Editable = true;

        lCat  = Prop.InsertCategory (lStore, "Припуски на обработку стекла", "Припуски на обработку стекла");
        Prop.InsertComp_Float  (lCat, "Припуск стекла 1",  CurObj.Float("ProcessMarginGlass1" ), "Припуск стекла 1", 0);
        if ( nCamCount > 0 )
          Prop.InsertComp_Float(lCat, "Припуск стекла 2",  CurObj.Float("ProcessMarginGlass2" ), "Припуск стекла 2", 0);
        if ( nCamCount > 1 )
          Prop.InsertComp_Float(lCat, "Припуск стекла 3",  CurObj.Float("ProcessMarginGlass3" ), "Припуск стекла 3", 0);

        lCat  = Prop.InsertCategory (lStore, "Стоимость шпрос", "Цены и стоимость шпрос");
        
        if ( Prog.CalcPriceMethod == 1 )
        {
          Prop.InsertComp_Int  (lCat, "Кол.секц.шпрос",  CurObj.Int  ("nCountSection"  ),  "Кол.секц.шпрос",  0);
          Prop.InsertComp_Float(lCat, "Цена за секцию",  CurObj.Float("RasPriceSection"),  "Цена за секцию",  0);
        }
        else
          Prop.InsertComp_Float(lCat, "Цена за пог. м",  CurObj.Float("RasPriceM"),        "Цена за пог. м",  0);

        Prop.InsertComp_Float  (lCat, "Цена креста",     CurObj.Float("CrossPrice"),       "Цена креста",     0);
        Prop.InsertComp_Float  (lCat, "Цена пробки",     CurObj.Float("CapPrice"),         "Цена пробки",     0);

        if ( !Prog.bRecalcRasAfterPlotSave )
        {
          Prop.InsertComp_Float  (lCat, "Стоимость шпрос", CurObj.Float("RasPrice"),         "Стоимость шпрос", 0);

          Prop.InsertComp_Int    (lCat, "Кол-во крестов",   CurObj.Int("nRasIntersect"),     "Кол-во крестов",  0);
          Prop.InsertCat_CheckBox(lCat, "Блок.счёт.крестов",CurObj.Int("BlockCalcRasCross"), "Автоматический пересчёт крестов");
        }

        lCat  = Prop.InsertCategory (lStore, "Настройка шпрос", "Параметры шпрос");
        Prop.InsertCat_ComboBox(lCat, "Ширина Шпрос",       CurObj.StringID("ID_Ras_Width"      ), "Ширина Шпрос",    0, "select ID, Name from WidthType");
        Prop.InsertCat_ComboBox(lCat, "Произв.Шпрос",       CurObj.StringID("ID_Ras_Manuf"      ), "Произв.Шпрос",    0, "select ID, Name from Manufacter");

        var sSQL_Ras = "select Color.ID, Color.Name " + 
                       " from Color left join Manufacter on  IsNull(Manufacter.bLam,0) = IsNull(Color.bLam,0) " + 
                       "                                 or (IsNull(Manufacter.bLam,0) = 1 and IsNull(Color.bDefault,0) = 1) " + // тут исключаем все цвета основы кроме Белого
                       " where Manufacter.ID = " + CurObj.StringID("ID_Ras_Manuf") + " " + 
                       " order by IsNull(Color.bLam,0), Color.Name";

        Prop.InsertCat_ComboBox(lCat, "Цвет Шпрос Наружу",  CurObj.StringID("ID_Ras_Color"      ), "Цвет Шпрос Наружу с Улицы",   0, sSQL_Ras);
        Prop.InsertCat_ComboBox(lCat, "Цвет Шпрос Внутри",  CurObj.StringID("ID_Ras_Color_Ins"  ), "Цвет Шпрос Внутри Помещения", 0, sSQL_Ras);
        Prop.InsertComp_Int    (lCat, "№ Камеры для Шпрос", CurObj.Int     ("nCameraShpros"     ), "№ Камеры для установки шпрос", 0);
        Prop.InsertComp_Int    (lCat, "Кол.компл.шпрос",    CurObj.Int     ("RasComplectCount"  ), "Кол.компл.шпрос",  0);

        sSQL_Ras = 
          "select vRST.ID, vRST.Name " +
          "from v_RasConnectType vRST left join Manufacter M on  IsNull(M.bNotch,0) = IsNull(vRST.bNotch,0) " +
          "where M.ID = " + CurObj.StringID("ID_Ras_Manuf");

        Prop.InsertCat_ComboBox(lCat, "Соединение",         CurObj.StringID("ID_Ras_ConnectType"), "Тип соединения шпрос", 0, sSQL_Ras);
        // так как шпросы одного типа могут быть и врезные и крестовые, то позволим пользователю выбирать Тип соединения шпрос
        //Prop.InsertCat_ComboBox(lCat, "Соединение",         CurObj.StringID("ID_Ras_ConnectType"), "Тип соединения шпрос", 0, "select ID, Name from v_RasConnectType");

        lCat  = Prop.InsertCategory (lStore, "Расстановка шпрос верт.",  "Авторасстановка шпрос по ширине");
        Prop.FillRasXDistList(lCat, CurObj);
        Prop.InsertComp_FloatFormat (lCat,  "След. отступ Х", 0., "Отступ по ширине следующей шпросы", "%.1f", 0);
        Prop.InsertComp_FloatFormat (lCat,  "След. коорд. Х", 0., "Координата Х новой шпросы",         "%.1f", 0);
     
        lCat  = Prop.InsertCategory (lStore, "Расстановка шпрос гориз.", "Авторасстановка шпрос по высоте");
        Prop.FillRasYDistList(lCat, CurObj);
        Prop.InsertComp_FloatFormat (lCat,  "След. отступ Y", 0., "Отступ по высоте следующей шпросы", "%.1f", 0);
        Prop.InsertComp_FloatFormat (lCat,  "След. коорд. Y", 0., "Координата Y новой шпросы",         "%.1f", 0);
        
        if ( Prog.Select_Int("select distinct d_iNum from Config where Name = 'bOffCutManual' ", "d_iNum", true) )
        {
          lCat  = Prop.InsertCategory (lStore, "Кромки", "Наличие кромок вокруг фигуры при раскрое");
          Prop.InsertCat_CheckBox(lCat, "Лево",  CurObj.Int("bOffCut_Left"),   "Кромка слева");
          Prop.InsertCat_CheckBox(lCat, "Право", CurObj.Int("bOffCut_Right"),  "Кромка справа");
          Prop.InsertCat_CheckBox(lCat, "Верх",  CurObj.Int("bOffCut_Top"),    "Кромка сверху");
          Prop.InsertCat_CheckBox(lCat, "Низ",   CurObj.Int("bOffCut_Bottom"), "Кромка снизу");
        }
        
        lCat  = Prop.InsertCategory (lStore, "Шрифт",  "Параметры шрифта");
        Prop.InsertComp_Int         (lCat,   "Шрифт", CurObj.FontHeight, "Размер шрифта", 0);
        
        lCat  = Prop.InsertCategory (lStore, "Параметры",  "Параметрические параметры");
        Prop.InsertComp_String      (lCat,   "Добавить",  "",  "Добавить или удалить параметрический параметр", 0);
    
        Prop.FillParamList(lCat, CurObj);
      
        break;

      case nClass_Ras_Vert:
        if ( PropShowMode == 1  &&  CurVector )
        {
          lStore = Prop.InsertStore("Шпрос");

          lCat   = Prop.InsertCategory(lStore, "Координаты", "Координаты конца шпросы");
          Prop.InsertComp_FloatFormat(lCat, "X", CurVector.X, "X","%.2f", 3);
          Prop.InsertComp_FloatFormat(lCat, "Y", CurVector.Y, "Y","%.2f", 4);

          lCat  = Prop.InsertCategory (lStore, "Формулы", "Формулы координат");
          Prop.InsertComp_String  (lCat, "Формула X",  CurVector.AnalExpr_X,    "Формула X",      0);
          Prop.InsertComp_String  (lCat, "Формула Y",  CurVector.AnalExpr_Y,    "Формула Y",      0);

          lCat   = Prop.InsertCategory (lStore, "Расположение", "Расположение сегмента шпросы");
          Prop.InsertComp_FloatFormat(lCat, "Угол", CurObj.Float("Angle"), "Угол", "%.2f", 7);
          // Сделать и это
          //Prop.InsertComp_FloatFormat(lComp, "Гориз. отступ", CurObj.Float("Width"), "Гориз. отступ", "%.1f", 3);

          break;
        }
        else
        if ( /*PropShowMode == 2  &&*/  CurSeg )
        {
          lStore = Prop.InsertStore ("Расстекловка");
          lCat   = Prop.InsertCategory (lStore, "Размеры ", "Габаритные размеры");
          lComp  = Prop.InsertCompound (lCat,   "Размер ",  "Габаритный размер ");

          Prop.InsertComp_FloatFormat(lComp, "Гориз. отступ", CurObj.Float("Width"),  "Гориз. отступ", "%.2f", 3);
          Prop.InsertComp_FloatFormat(lCat, "Угол", CurObj.Float("Angle"), "Угол", "%.2f", 7);

          if ( CurSeg.IsArc )
            Prop.InsertComp_FloatFormat(lComp, "Радиус",      CurSeg.R, "Радиус", "%.2f", 7);

          lCat   = Prop.InsertCategory (lStore, "Параметры ", "Настройка параметров шпрос");
          lComp  = Prop.InsertCompound (lCat,   "Параметр ",  "Параметр шпрос ");
          
          Prop.InsertCat_ComboBox(lCat, "Разрез?", CurObj.StringID("ID_Ras_TypeSection"), "Тип разреза шпрос", 0, "select ID, Name from v_RasTypeSection ");
        }

        break;

      case nClass_Ras_Horiz:
        if ( PropShowMode == 1  &&  CurVector )
        {
          lStore = Prop.InsertStore ("Шпрос");

          lCat   = Prop.InsertCategory(lStore, "Координаты", "Координаты конца шпросы");
          Prop.InsertComp_FloatFormat(lCat, "X",    CurVector.X, "X", "%.2f", 3);
          Prop.InsertComp_FloatFormat(lCat, "Y",    CurVector.Y, "Y", "%.2f", 4);

          lCat   = Prop.InsertCategory (lStore, "Расположение", "Расположение сегмента шпросы");
          Prop.InsertComp_FloatFormat(lCat, "Угол", CurObj.Float("Angle"), "Угол", "%.2f", 7);

          lCat  = Prop.InsertCategory (lStore, "Формулы", "Формулы координат");
          Prop.InsertComp_String  (lCat, "Формула X",  CurVector.AnalExpr_X,    "Формула X",      0);
          Prop.InsertComp_String  (lCat, "Формула Y",  CurVector.AnalExpr_Y,    "Формула Y",      0);

          // Сделать потом
          //Prop.InsertComp_FloatFormat(lComp, "Верт. отступ",  CurObj.Float("Height"), "Верт. отступ", "%.1f", 4);
          break;
        }
        else
        if ( /*PropShowMode == 2  &&*/  CurSeg )
        {
          lStore = Prop.InsertStore ("Расстекловка");
          lCat   = Prop.InsertCategory (lStore, "Размеры ", "Габаритные размеры");
          lComp  = Prop.InsertCompound (lCat,   "Размер ",  "Габаритный размер ");

          Prop.InsertComp_FloatFormat(lComp, "Верт. отступ",  CurObj.Float("Height"), "Верт. отступ", "%.2f",  4);
          Prop.InsertComp_FloatFormat(lCat, "Угол", CurObj.Float("Angle"), "Угол", "%.2f", 7);
          
             if ( CurSeg.IsArc )
               Prop.InsertComp_FloatFormat(lComp, "Радиус",      CurSeg.R, "Радиус", "%.2f", 7);

          lCat   = Prop.InsertCategory (lStore, "Параметры ", "Настройка параметров шпрос");
          lComp  = Prop.InsertCompound (lCat,   "Параметр ",  "Параметр шпрос ");
          
          Prop.InsertCat_ComboBox(lCat, "Разрез?", CurObj.StringID("ID_Ras_TypeSection"), "Тип разреза шпрос", 0, "select ID, Name from v_RasTypeSection ");
        }
        
        break;

      case nClass_Drill:     
        lStore = Prop.InsertStore ("Сверление");

        if ( PropShowMode == 1  &&  CurVector )
        {
          lCat  = Prop.InsertCategory (lStore, "Расположение сегмента", "Расположение сегмента сверления");
          lComp = Prop.InsertCompound (lCat, "Координаты", "Расположение сегмента сверления");

          Prop.InsertComp_Int (lComp, "X", CurVector.X, "X", 3);
          Prop.InsertComp_Int (lComp, "Y", CurVector.Y, "Y", 4);

          break;
        }
        else
        if ( PropShowMode == 2  &&  CurSeg )
        {
          Prop.Editable = true;

          if ( CurSeg.IsArc )
          {
            lCat  = Prop.InsertCategory (lStore, "Арочный сегмент", "Арочный сегмент");
            lComp = Prop.InsertCompound (lCat, "Высота хорды арки", "Высота хорды арки");
            
            var  t        = Math.sqrt((CurSeg.V.X - CurSeg.VNext.X) * (CurSeg.V.X - CurSeg.VNext.X) + (CurSeg.V.Y - CurSeg.VNext.Y) * (CurSeg.V.Y - CurSeg.VNext.Y)) / 2,
                 fAngle1  = CalcAngles(CurSeg.V.X, CurSeg.V.Y, CurSeg.VNext.X, CurSeg.VNext.Y, CurSeg.VCenter.X, CurSeg.VCenter.Y, 1),
                 fAngle2  = CalcAngles(CurSeg.V.X, CurSeg.V.Y, CurSeg.VNext.X, CurSeg.VNext.Y, CurSeg.VCenter.X, CurSeg.VCenter.Y, 2),
                 fAngle   = fAngle2 - fAngle1,
                 Chord;
            
            if ( fAngle > Math.PI )
              Chord = CurSeg.R + Math.sqrt((CurSeg.R * CurSeg.R) - t * t);
            else
              Chord = CurSeg.R - Math.sqrt((CurSeg.R * CurSeg.R) - t * t);

            Prop.InsertComp_Int (lComp, "Высота хорды", Chord,        "Высота хорды", 0);
            Prop.InsertComp_Int (lComp, "Радиус",       CurSeg.R,     "Радиус",       0);
          }
          break;
        }
        
        // Если работаем в координатах рамки (обычные координаты)
        if ( Prog.GetTypeCalcGabarit() == 0 )
        {
          lCat   = Prop.InsertCategory (lStore, "Координаты ", "Координаты");
          lComp  = Prop.InsertCompound (lCat,   "К-ты",  "К-ты");

          Prop.InsertComp_Int    (lComp, "X", CurObj.Int("X_Drill"), "X", 3);
          Prop.InsertComp_Int    (lComp, "Y", CurObj.Int("Y_Drill"), "Y", 4);                
        }
        else
        // Если работаем в координатах габарита зуба - покажем отступы        
        if ( Prog.GetTypeCalcGabarit() == 1 )
        {
           lCat   = Prop.InsertCategory (lStore, "Отступ ", "Отступ");
           lComp  = Prop.InsertCompound (lCat,   "Отступ",  "Отступ");
        
           Prop.InsertComp_Int    (lComp, "Отступ X", CurObj.Int("X_Drill") - Prog.GetGlassLeftGabarit  (), "Отступ X", 3);
           Prop.InsertComp_Int    (lComp, "Отступ Y", CurObj.Int("Y_Drill") - Prog.GetGlassBottomGabarit(), "Отступ Y", 4);        
        }
        
        lCat   = Prop.InsertCategory (lStore, "Параметры ", "Параметры");
        lComp  = Prop.InsertCompound (lCat,   "Параметры",  "Параметры");

        Prop.InsertCat_ComboBox(lCat, "Форма", CurObj.StringID ("nTypeForm"), "Форма сверления", 0, 
        "select ID, Name from v_DrillListTypeForm order by ID");

        Prop.InsertCat_ComboBox(lCat, "Диаметр", CurObj.StringID ("ID_DiameterDrill"), "Диаметр сверления", 0, "select ID, Name from DrillDiameter order by Diameter, Name");

        sP = CurObj.String("Processing");
        lCat  = Prop.InsertCategory (lStore, "Обработки стекла", "Обработки стекла");
        Prop.InsertComp_String  (lCat, "Обработка",  sP ,    "Обработка",      0);

        break;
        
      case nClass_Grind:
        var  
          lStore = Prop.InsertStore ("Шлифовка"),
          lCat   = Prop.InsertCategory (lStore, "Размер", "Размер");
          lComp  = Prop.InsertCompound (lCat,   "Размер",  "Размер");
// пока только через сторону 
//        Prop.InsertComp_Int(lComp, "Глубина", CurObj.Int  ("Grind_Depth" ),  "Глубина", 3);
      break;
    }
  }
  catch(e)
  {
    Prog.SaveError("PlotPropShow " + e.message, false);
    return 0;
  }  
}

//////////////////////////////////////////////////////////////////////////
// Изменено свойство текущего объекта ------------

function Prog::PropChange()
{
  try
  {
    //Prog.MessageBox ("------------------------!");

    var  PropName     = Prop.CurItemName,
         PropShowMode = Prog.PropShowMode,
         CurObj       = Prog.CurObj,
         CurSeg       = Prog.CurSeg,
         CurVector    = Prog.CurVector,
         ObjMas       = Prog.ObjMas;

    Prog.SaveError ("PropChange PropName = " + PropName,           false);
    Prog.SaveError ("PropChange PropShowMode = " + PropShowMode,   false);
    Prog.SaveError ("PropChange CurObj.nClass = " + CurObj.nClass, false);

    if ( PropShowMode == 1  &&  CurVector )
    {
      if ( PropName == "X"         || PropName == "Y"         || PropName == "Обработка" || 
           PropName == "Формула X" || PropName == "Формула Y" || PropName == "Радиус")
      {
        if ( PropName == "X" )
        {
          CurVector.X = Prop.CurItemFloat;
        }
        else
        if ( PropName == "Y" )
        {
          CurVector.Y = Prop.CurItemFloat;
        }
        else if ( PropName == "Обработка" )
        {
          var  sP = Prop.CurItemString;
          CurVector.Processing = sP;
          Prog.CreateAllDim();
          Prop.Refresh();
        }
        else if ( PropName == "Радиус" )
        {
          var  CornerRadius = Prop.CurItemFloat;
          CurVector.CornerRadius = CornerRadius;
          Prog.CreateAllDim();
          Prop.Refresh();
        }
        else 
        if ( PropName == "Формула X" )
        {
          var  sX = Prop.CurItemString;
          CurVector.AnalExpr_X  = sX;
        }
        else 
        if ( PropName == "Формула Y" )
        {
          var  sY = Prop.CurItemString;
          CurVector.AnalExpr_Y  = sY;
        }

        Prog.OnPlotChanged();

        Prop.Refresh();
      }

      Prog.CreateAllDim();
    }
    else
    if ( PropShowMode == 2  &&  CurSeg )
    {
      switch ( PropName )
      {
        case "Высота хорды":
          var  Chord = Prop.CurItemInt,
               Coef  = Math.sqrt((CurSeg.V.X - CurSeg.VNext.X) * (CurSeg.V.X - CurSeg.VNext.X) + (CurSeg.V.Y - CurSeg.VNext.Y) * (CurSeg.V.Y - CurSeg.VNext.Y)) / Chord,
               dX    = Math.abs ((CurSeg.V.Y - CurSeg.VNext.Y)) / Coef,
               dY    = Math.abs ((CurSeg.V.X - CurSeg.VNext.X)) / Coef,
               directX = 0,
               directY = 0;

          if ( Chord == 0 )
            return;

          if ( CurSeg.V.Y < CurSeg.VNext.Y )
            directX =  1;
          else
            directX = -1;
          if ( CurSeg.V.X < CurSeg.VNext.X )
            directY = -1;
          else
            directY =  1;

          if ( !CurSeg.IsArcRight )  //Если нужна арка вогнутая
          {
            directX = -directX;
            directY = -directY;
          }

          CurSeg.VArc.X = (CurSeg.V.X + CurSeg.VNext.X) / 2 + dX * directX;
          CurSeg.VArc.Y = (CurSeg.V.Y + CurSeg.VNext.Y) / 2 + dY * directY;
          // CurSeg.UpdateGeometry();// [AF] Такой интерфейсной функции у сегмента нет, и не надо. Всё должно пересчитываться автоматически.
          ObjMas.UpdateDraw(true); // [AF] Без этого неправильно отображает изменившиеся свойства арки, ЧТО СТРАННО.
          Prog.CreateAllDim();
          Prop.Refresh();
          break;

        case "Радиус":
          if (  CurSeg.R != Prop.CurItemFloat )
          {
            if ( CurObj.nClass != nClass_Ras_Vert && CurObj.nClass != nClass_Ras_Horiz )
              CurSeg.R = Prop.CurItemFloat;

            Prog.CreateAllDim();
            Prop.Refresh();
          }

          break;

        case "Обработка":
          var  sP = Prop.CurItemString;
          CurSeg.Processing = sP;
          Prog.CreateAllDim();
          Prop.Refresh();
          break;      
      }
    }
    
    //else
    switch ( CurObj.nClass )
    {
      case nClass_Glass:
        if ( PropName == "Соединение")
          ChangeRasTypeSection(CurObj);
        else
        if ( PropName == "Ширина"  ||  PropName == "Высота" || PropName == "Высота прямоугольной части" )
        {
          if ( PropName == "Ширина" && CurObj.Int("Glass_Width") != Prop.CurItemInt )
          {
            CurObj.Int ("Glass_Width") = Prop.CurItemInt;
            var  XPos = Math.round(CurObj.Line("Border").Seg(0).V.X + Prop.CurItemInt);
            if ( CurObj.Line("Border").SegCount == 2 )
            {
              if ( CurObj.Line("Border").Seg(0).IsArc  &&  CurObj.Line("Border").Seg(1).IsArc )
              {
                CurObj.Line("Border").Seg(0).V.Y    = 0;
                CurObj.Line("Border").Seg(1).V.Y    = 0;
                CurObj.Line("Border").Seg(0).V.X    = -Prop.CurItemInt / 2;
                CurObj.Line("Border").Seg(1).V.X    = CurObj.Line("Border").Seg(0).V.X + Prop.CurItemInt;
                CurObj.Line("Border").Seg(0).VArc.Y = -Prop.CurItemInt / 2;
                CurObj.Line("Border").Seg(1).VArc.Y = CurObj.Line("Border").Seg(0).VArc.Y + Prop.CurItemInt;
                CurObj.Line("Border").Seg(0).VArc.X = 0;
                CurObj.Line("Border").Seg(1).VArc.X = 0;
                CurObj.Int ("Glass_Height") = Prop.CurItemInt;
                Prop.Refresh();
              }
              else
              if ( CurObj.Line("Border").Seg(0).IsArc || CurObj.Line("Border").Seg(1).IsArc)
              {
                CurObj.Line("Border").Seg(0).V.Y    = 0;
                CurObj.Line("Border").Seg(1).V.Y    = 0;
                CurObj.Line("Border").Seg(1).V.X    = Prop.CurItemInt;
                CurObj.Line("Border").Seg(1).VArc.X = 0.5 * Prop.CurItemInt;
              }
            }
            else
            {
              CurObj.Line("Border").Seg(1).V.X = XPos;
              if ( CurObj.Line("Border").SegCount > 2 )
                CurObj.Line("Border").Seg(2).V.X = XPos;
            }
          }
          else
          if ( PropName == "Высота" && CurObj.Int("Glass_Height") != Prop.CurItemInt)
          {
            if ( CurObj.Father )
            {
              if ( CurObj.Line("Border").SegCount > 2 )
              {
                var  YPos = Math.round(CurObj.Line("Border").Seg(2).V.Y - Prop.CurItemInt);
                CurObj.Line("Border").Seg(0).V.Y = YPos;
                CurObj.Line("Border").Seg(1).V.Y = YPos;
              }
            }
            else
            {
              if ( CurObj.Line("Border").SegCount == 2 )
              {
                if ( CurObj.Line("Border").Seg(0).IsArc  &&  CurObj.Line("Border").Seg(1).IsArc )
                {
                  CurObj.Line("Border").Seg(0).V.Y = 0;
                  CurObj.Line("Border").Seg(1).V.Y = 0;
                  CurObj.Line("Border").Seg(0).V.X = -Prop.CurItemInt / 2;
                  CurObj.Line("Border").Seg(1).V.X = CurObj.Line("Border").Seg(0).V.X + Prop.CurItemInt;
                  CurObj.Line("Border").Seg(0).VArc.Y = -Prop.CurItemInt / 2;
                  CurObj.Line("Border").Seg(1).VArc.Y = CurObj.Line("Border").Seg(0).VArc.Y + Prop.CurItemInt;
                  CurObj.Line("Border").Seg(0).VArc.X = 0;
                  CurObj.Line("Border").Seg(1).VArc.X = 0;
                  CurObj.Int ("Glass_Width") = Prop.CurItemInt;
                  Prop.Refresh();
                }
                else
                if ( CurObj.Line("Border").Seg(0).IsArc )
                {
                  CurObj.Line("Border").Seg(0).V.Y = 0;
                  CurObj.Line("Border").Seg(1).V.Y = 0;
                  CurObj.Line("Border").Seg(0).VArc.Y = -Prop.CurItemInt;
                }
                else
                if ( CurObj.Line("Border").Seg(1).IsArc )
                {
                  CurObj.Line("Border").Seg(0).V.Y = 0;
                  CurObj.Line("Border").Seg(1).V.Y = 0;
                  CurObj.Line("Border").Seg(1).VArc.Y = Prop.CurItemInt;
                }
              }
              else
              {
                var  YPos = Math.round(CurObj.Line("Border").Seg(0).V.Y + Prop.CurItemInt);
                CurObj.Line("Border").Seg(2).V.Y = YPos;
                
                if ( CurObj.Line("Border").SegCount > 3 )
                  CurObj.Line("Border").Seg(3).V.Y = YPos;
              }
            }
          }
          else
          if ( PropName == "Высота прямоугольной части" && CurObj.Int("Glass_Height") != Prop.CurItemInt)
          {
            CurObj.Int ("Glass_Height") = Prop.CurItemInt;
            if ( CurObj.Father )
            {
              if ( CurObj.Line("Border").SegCount > 2 )
              {
                var  YPos = Math.round(CurObj.Line("Border").Seg(2).V.Y - Prop.CurItemInt);
                CurObj.Line("Border").Seg(0).V.Y = YPos;
                CurObj.Line("Border").Seg(1).V.Y = YPos;
              }
            }
            else
            {
              if ( CurObj.Line("Border").SegCount > 2 )
              {
                var  YPos    = Math.round(CurObj.Line("Border").Seg(0).V.Y + Prop.CurItemInt);
                var  YArcPos = Math.round(Prop.CurItemInt - CurObj.Line("Border").Seg(2).V.Y);

                CurObj.Line("Border").Seg(2).V.Y     = YPos;
                CurObj.Line("Border").Seg(2).VArc.Y += YArcPos;
                
                if ( CurObj.Line("Border").SegCount >= 3 )
                {                
                  if (CurObj.Line("Border").Seg(3).V.Y)
                    CurObj.Line("Border").Seg(3).V.Y     = YPos;

                  if (CurObj.Line("Border").Seg(3).VArc)
                    CurObj.Line("Border").Seg(3).VArc.Y += YArcPos;
                }
              }
            }
          }
          Prog.OnPlotChanged();
          Prog.CreateAllDim ();
          
          SetRasTypeSection(CurObj); // после смены размера выставим тип соедиения
          Prop.Refresh();
        }
        else
        {
          switch ( PropName )
          {
            case  "Выступ стекла": 
            case  "№ стекла":
            {
              Prop.Refresh();
              return;
            }
          
            case "Ширина Шпрос":
            {
              CurObj.StringID("ID_Ras_Width") = Prop.CurItemInt;
              
              Prog.UpdateRasPriceParam(CurObj);
              RecalcRasPrice(CurObj);
              Prop.Refresh();

              return;
            }
            case "Произв.Шпрос":
            {
              CurObj.StringID("ID_Ras_Manuf") = Prop.CurItemInt;
              SetRasTypeSection(CurObj); // выставим тип соедиения
              SetRasComplectCount(CurObj); // выставим кол-во комплектов

              Prog.UpdateRasPriceParam(CurObj);
              RecalcRasPrice(CurObj);
              Prop.Refresh();

              return;
            }
            case "Цвет Шпрос Наружу":
            {
              CurObj.StringID("ID_Ras_Color") = Prop.CurItemInt;

              Prog.UpdateRasPriceParam(CurObj);
              RecalcRasPrice(CurObj);
              Prop.Refresh();

              return;
            }
            case "Цвет Шпрос Внутри":
            {
              CurObj.StringID("ID_Ras_Color_Ins") = Prop.CurItemInt;
              Prog.UpdateRasPriceParam(CurObj);
              RecalcRasPrice(CurObj);
              Prop.Refresh();
              return;
            }
            case "№ Камеры для Шпрос":
            {
              nCamera = Prop.CurItemInt;
              
              if ( nCamera < 1 )  
                nCamera = 1;
                
              if ( nCamera > 2 )   
                nCamera = 2;
            
              CurObj.Int("nCameraShpros") = nCamera;
              return;
            }
            case "Прибавлять B":
              bGlassAddBToSizes = (Prop.CurItemCheck)? 1 : 0;
              return;
            case "Кол.секц.шпрос":
              CurObj.Int ("nCountSection"   ) = Prop.CurItemInt;
              return;
            case "Цена за скцию":
              CurObj.StringID ("RasPriceSection" ) = Prop.CurItemFloat;
              return;
            case "Кол.компл.шпрос":
              CurObj.StringID ("RasComplectCount") = Prop.CurItemInt;
              return;

            case "Цена за пог. м":
              CurObj.Float("RasPriceM") = Prop.CurItemFloat;
              return;

            case "Цена за секцию":
              CurObj.Float("RasPriceSection") = Prop.CurItemFloat;
              return;

            case "Цена креста":
              CurObj.Float("CrossPrice") = Prop.CurItemFloat;
              return;
              
            case "Цена пробки":
              CurObj.Float("CapPrice") = Prop.CurItemFloat;
              return;

            case "Кол-во крестов":
              CurObj.Int("nRasIntersect"    ) = Prop.CurItemInt;
              CurObj.Int("BlockCalcRasCross") = 1;
              Prop.Refresh();
              return;

            case "Блок.счёт.крестов":
              CurObj.Int("BlockCalcRasCross") = (Prop.CurItemCheck)? 1 : 0;
              return;

            case "Шлифование стекла 1":
              CurObj.Int("bGrindGlass1") = (Prop.CurItemCheck)? 1 : 0;
              return;

            case "Шлифование стекла 2":
              CurObj.Int("bGrindGlass2") = (Prop.CurItemCheck)? 1 : 0;
              return;

            case "Шлифование стекла 3":
              CurObj.Int("bGrindGlass3") = (Prop.CurItemCheck)? 1 : 0;
              return;
              
            case "Тип построения":
              Prog.ModeGrind = Prop.CurItemInt;
              return;

            case "Лево":
              CurObj.Int("bOffCut_Left")   = (Prop.CurItemCheck)? 1 : 0;
              return;
            case "Право":
              CurObj.Int("bOffCut_Right")  = (Prop.CurItemCheck)? 1 : 0;
              return;
            case "Низ":
              CurObj.Int("bOffCut_Bottom") = (Prop.CurItemCheck)? 1 : 0;
              return;
            case "Вверх":
              CurObj.Int("bOffCut_Top")    = (Prop.CurItemCheck)? 1 : 0;
              return;
              
            case "Шрифт":
              //Prog.MessageBox ("Update Шрифт");
              return;
          }
        }
        break;
      case nClass_Ras_Vert:
        switch ( PropName )
        {
          /* [YK] перенесено в c++ с изменнием алгоритма
          case "Гориз. отступ":
            var  Y0 = CurObj.Line("Body").Seg(0).V.Y,
                 Y1 = CurObj.Line("Body").Seg(1).V.Y,
                 X  = gGlassObj.Line("Border").Seg(0).V.X + Prop.CurItemFloat;

            InputVector.X = X;
            InputVector.Y = Math.abs((Y1 + Y0)/2);
            CurObj.InputFromXY(InputVector.X, InputVector.Y, false);
            Prog.CreateAllDim();

            RecalcRasPrice(gGlassObj);
            break;
          */
          case "Угол":
            if ( CurObj.Float("Angle") != Prop.CurItemFloat )
            {
              CurObj.Float("Angle") = Prop.CurItemFloat;
              CurObj.Update_OnChange_SnapIntersect (CurObj.Line("Body").Seg(0).V.X, CurObj.Line("Body").Seg(0).V.Y, true);
              Prog.CreateAllDim();

              RecalcRasPrice(gGlassObj);
            }
            break;

          case "Разрез?":
            CurObj.StringID ("ID_Ras_TypeSection" ) = Prop.CurItemInt;

            RecalcRasPrice(gGlassObj);
            break;
        }
        break;

      case nClass_Ras_Horiz:
        switch ( PropName )
        {
          /* [YK] перенесено в c++ с изменнием алгоритма
          case "Верт. отступ":
            var  X0 = CurObj.Line("Body").Seg(0).V.X,
                 X1 = CurObj.Line("Body").Seg(1).V.X,
                 Y  = gGlassObj.Line("Border").Seg(0).V.Y + Prop.CurItemFloat;

            InputVector.X = Math.abs((X1 + X0)/ 2);
            InputVector.Y = Y;
            CurObj.InputFromXY (InputVector.X, InputVector.Y, false);
            Prog.CreateAllDim();

            RecalcRasPrice(gGlassObj);
            break;
          */
          case "Угол":
            if ( CurObj.Float("Angle") != Prop.CurItemFloat )
            {
              CurObj.Float("Angle") = Prop.CurItemFloat;
              CurObj.Update_OnChange_SnapIntersect (CurObj.Line("Body").Seg(0).V.X, CurObj.Line("Body").Seg(0).V.Y, true);
              Prog.CreateAllDim();

              RecalcRasPrice(gGlassObj);
            }
            break;

          case "Разрез?":
            CurObj.StringID ("ID_Ras_TypeSection" ) = Prop.CurItemInt;

            RecalcRasPrice(gGlassObj);
            break;
        }

        break;

      case nClass_Drill:
        switch ( PropName )
        {
          case  "X":
            if ( CurObj.Int("X_Drill") != Prop.CurItemInt )
              CurObj.Int("X_Drill") = Prop.CurItemInt;
            break;
          case  "Y":
            if ( CurObj.Int("Y_Drill") != Prop.CurItemInt )
              CurObj.Int("Y_Drill") = Prop.CurItemInt;
            break;
          case  "Диаметр":
            if ( CurObj.StringID("ID_DiameterDrill") != Prop.CurItemInt )
              CurObj.StringID("ID_DiameterDrill") = Prop.CurItemInt;
          break;
          case  "Форма":
            if ( CurObj.StringID("nTypeForm") != Prop.CurItemInt )
              CurObj.StringID("nTypeForm") = Prop.CurItemInt;
          break;
          case  "Обработка":
            var sP = ""; 
            sP = Prop.CurItemString;
            if ( CurObj.String("Processing") != sP )
              CurObj.String("Processing") = sP;
          break;
        }
        CurObj.InputFromXY(CurObj.Int("X_Drill"), CurObj.Int("Y_Drill"), false);      
        break;
    }

    //CurObj.UpdateGeometrySnap();
    ObjMas.UpdateGeometrySnap();
    //CurObj.UpdateDraw (true);

    ObjMas.UpdateDraw (true);
    ObjMas.ZoomAll();
  }
  catch (e)
  {
    //SaveError ("PropChange " + e.message, true);
    Prog.SaveError ("PropChange " + e.message, true);
  }
}

// Св-ва шпрос позиции. Для ввода шпрос без чертежа.
function Prog::ProjectRasPropShow()
{
  try
  {
    Prop.Clear();

    var
      lStore = Prop.InsertStore   ("Раскладка"),
      lCat   = Prop.InsertCategory(lStore, "Раскладка",           "Параметры раскладки"),
      lComp  = Prop.InsertCompound(lCat,   "Параметры раскладки", "Параметры раскладки");

    if ( Prog.CalcPriceMethod == 1 ) // По кол-ву секций.
    {
      Prop.InsertComp_Int        (lComp, "Кол.секц.шпрос",  Prog.RP_nCountSection,   "Кол.секц.шпрос",         0);
      // Prop.InsertComp_Float(lComp, "Цена за секцию",   Prog.RP_RasPriceSection,  "Цена за секцию",   0);
      Prop.InsertComp_FloatFormat(lComp, "Цена за секцию",  Prog.RP_RasPriceSection, "Цена за секцию", "%.2f", 0);
    }
    else                            // По погонным метрам.
    {
      Prop.InsertComp_Int        (lComp, "Общий метраж, мм", Prog.RP_RasLength, "Общий метраж, мм",     0);
      //  Prop.InsertComp_Float(lComp, "Цена за метр",     Prog.RP_RasPriceM,        "Цена за метр",    0);
      Prop.InsertComp_FloatFormat(lComp, "Цена за метр",     Prog.RP_RasPriceM, "Цена за метр", "%.2f", 0);

    }
    Prop.InsertCat_ComboBox    (lCat,  "Ширина Шпрос",      Prog.RP_ID_Ras_Width,     "Ширина Шпрос",      0, "select ID, Name from WidthType" );
    Prop.InsertCat_ComboBox    (lCat,  "Произв.Шпрос",      Prog.RP_ID_Ras_Manuf,     "Произв.Шпрос",      0, "select ID, Name from Manufacter");
    Prop.InsertCat_ComboBox    (lCat,  "Цвет Шпрос Наружу", Prog.RP_ID_Ras_Color,     "Цвет Шпрос Наружу", 0, "select 0 as ID, '-Без цвета-' as Name, 0 as nOrder union select ID, Name, 1 as nOrder from Color order by nOrder, Name");
    Prop.InsertCat_ComboBox    (lCat,  "Цвет Шпрос Внутри", Prog.RP_ID_Ras_Color_Ins, "Цвет Шпрос Внутри", 0, "select 0 as ID, '-Без цвета-' as Name, 0 as nOrder union select ID, Name, 1 as nOrder from Color order by nOrder, Name");
    Prop.InsertComp_Int        (lComp, "Кол.компл.шпрос",   Prog.RP_RasComplectCount, "Кол.компл.шпрос",         0);
    Prop.InsertComp_Int        (lComp, "Кол. крестов",      Prog.RP_CrossCount,       "Кол. крестов",            0);
    // Prop.InsertComp_Float   (lComp, "Цена креста",       Prog.RP_CrossPrice,       "Цена креста",             0);
    Prop.InsertComp_FloatFormat(lComp, "Цена креста",       Prog.RP_CrossPrice,       "Цена креста",     "%.2f", 0);
    Prop.InsertComp_Int        (lComp, "Кол. пробок",       Prog.RP_CapCount,         "Кол. пробок",             0);
    // Prop.InsertComp_Float   (lComp, "Цена пробки",       Prog.RP_CapPrice,         "Цена пробки",             0);
    Prop.InsertComp_FloatFormat(lComp, "Цена пробки",       Prog.RP_CapPrice,         "Цена пробки",     "%.2f", 0);

    // Prop.InsertComp_Float  (lComp, "Стоимость шпрос",   Prog.RP_RasPrice,         "Стоимость шпрос",          0);
    Prop.InsertComp_FloatFormat(lComp, "Стоимость шпрос",   Prog.RP_RasPrice,         "Стоимость шпрос", "%.2f", 0);
    Prop.InsertCat_CheckBox    (lCat,  "Фикс.цена шпрос",   Prog.RP_bFixedRasPrice,   "Фикс.цена шпрос"           );
  }
  catch (e)
  {
    Prog.SaveError ("ProjectRasPropShow " + e.message, true);
  }
}

// Изменение св-в параметров шпрос в окне ProjectView.
function Prog::ProjectRasPropChange()
{
  try
  {
    var  PropName = Prop.CurItemName;
    switch ( PropName )
    {
      case "Кол.секц.шпрос":
        Prog.RP_nCountSection    = Prop.CurItemInt;
        break;
      case "Цена за секцию":
        Prog.RP_RasPriceSection  = Prop.CurItemFloat;
        break;
      case "Цена за метр":
        Prog.RP_RasPriceM        = Prop.CurItemFloat;
        break;
      case "Общий метраж, мм":
        Prog.RP_RasLength        = Prop.CurItemInt;
        break;
      case "Ширина Шпрос":
        Prog.RP_ID_Ras_Width     = Prop.CurItemInt;
        break;
      case "Произв.Шпрос":
        Prog.RP_ID_Ras_Manuf     = Prop.CurItemInt;
        break;
      case "Цвет Шпрос Наружу":
        Prog.RP_ID_Ras_Color     = Prop.CurItemInt;
        break;
      case "Цвет Шпрос Внутри":
        Prog.RP_ID_Ras_Color_Ins = Prop.CurItemInt;
        break;
      case "Кол.компл.шпрос":
        Prog.RP_RasComplectCount = Prop.CurItemInt;
        break;
      case "Кол. крестов":
        Prog.RP_CrossCount       = Prop.CurItemInt;
        break;
      case "Цена креста":
        Prog.RP_CrossPrice       = Prop.CurItemFloat;
        break;
      case "Кол. пробок":
        Prog.RP_CapCount         = Prop.CurItemInt;
        break;
      case "Цена пробки":
        Prog.RP_CapPrice         = Prop.CurItemFloat;
        break;
      case "Стоимость шпрос":
        Prog.RP_RasPrice         = Prop.CurItemFloat;
        break;
      case "Фикс.цена шпрос":
        Prog.RP_bFixedRasPrice   = Prop.CurItemCheck;
        break;
    }
  }
  catch(e)
  {
    Prog.SaveError("ProjectRasPropChange " + e.message, true);
  }
}

// Св-ва транспортных накладных.
function Prog::TransportTaskPropShow()
{
  try
  {
    Prop.Clear();

    var
      lStore = Prop.InsertStore   ("Транспортная накладная"),
      lCat   = Prop.InsertCategory(lStore, "Транспортная накладная", "Параметры транспортной накладной");
    Prop.bCash = true;
    Prop.InsertProperty_String  (lCat, "№ Накладной", "№ Транспортной накладной", "Num", 0);
    Prop.InsertProperty_ComboBox(lCat, "Диспетчер",   "Диспетчер", "idUsers", "select ID, IsNull(Post, '') + ': ' + IsNull(ManagerName, '') as Name from Users where IsNull(ManagerName, '') != '' order by IsNull(Post, ''), IsNull(ManagerName, '')", 0);
    Prop.InsertProperty_String  (lCat, "Паспорта, сертификаты (листов)", "Паспорта, сертификаты (листов)", "Certificate", 0);
    Prop.bCash = false;
  }
  catch(e)
  {
    Prog.SaveError("TransportTaskPropShow " + e.message, true);
  }
}

// Св-ва отгрузки.
function Prog::TransportShipPropShow()
{
  try
  {
    Prop.Clear();

    var
      lStore = Prop.InsertStore("Отгрузка"),
      lCat   = Prop.InsertCategory(lStore, "Отгрузка", "Параметры отгрузки");
    Prop.bCash = true;
    Prop.InsertProperty_ComboBox(lCat, "Перевозчик", "Имя перевозчика", "idCarrier",
      "select 0 as ID, '(Не выбран)' as Name, 0 as nOrder " +
      "union " +
      "select ID, Name, 1 as nOrder from Client where Type in (1, 2) order by nOrder, Name", 0);

    Prop.InsertProperty_ComboBox(lCat, "Водитель", "Имя водителя", "idDriver",
      "select 0 as ID, '(Не выбран)' as Name, 0 as nOrder " +
      "union " +
      "select P.ID, P.Name, 1 as nOrder from Personnel P inner join PersonnelPost PP on P.idPersonnelPost = PP.ID where PP.nType = 2 order by nOrder, Name", 0);

    Prop.InsertProperty_String(lCat, "Водитель (стор.)", "Имя водителя со стороны заказчика", "ClientDriverName", 0);

    Prop.InsertProperty_ComboBox(lCat, "Машина", "Транспортное средство", "idTripTransport",
      "select 0 as ID, '(Не выбран)' as Name, 0 as nOrder, '' as GosNumber " +
      "union " +
      "select TripTransport.ID, Name + ' ' + IsNull(GosNumber, '') as Name, 1 as nOrder, GosNumber from TripTransport order by nOrder, Name, GosNumber", 0);

    Prop.InsertProperty_String(lCat, "Машина (стор.)", "Транспортное средство со стороны заказчика", "ClientTransportGosNumber", 0);

    Prop.InsertProperty_ComboBox(lCat, "Ответственный", "Имя ответственного за отгрузку", "idPersonnel",
      "select 0 as ID, '(Не выбран)' as Name, 0 as nOrder union " +
      "select P.ID, P.Name, 1 as nOrder from Personnel P left join PersonnelPost PP on P.idPersonnelPost = PP.ID where IsNull(PP.nType, 0) = 0 order by nOrder, Name", 0);

    Prop.bCash = false;
  }
  catch(e)
  {
    Prog.SaveError("TransportShipPropShow " + e.message, true);
  }
}

function CheckTaskInReplic()
{
  try
  {
    var rcTask       = Prog.rcTask,
        nReplicState = 0,
        nState       = 0;

    // Проверим открыт ли рекордсет
    if ( rcTask && rcTask.State == 1 &&
        !rcTask.BOF && !rcTask.EOF)
    {
      nReplicState = rcTask("nReplicState").Value;
      nState       = rcTask("nState"      ).Value;

      if ( (nState & 2) == 2 )    // Состояние Производить?
        return 1;                 // Нельзя менять подразделение!
    }

    return nReplicState;
  }
  catch(e)
  {
    Prog.SaveError("CheckTaskInReplic " + e.message, true);
    return 0;
  }
}

function CheckTaskInSaw()         // Заказ в раскрое?
{
  try
  {
    var  rcTask = Prog.rcTask,
         nState = 0;

    // Проверим открыт ли рекордсет
    if ( rcTask && rcTask.State == 1 &&
        !rcTask.BOF && !rcTask.EOF )
    {
      nState = rcTask("nState").Value;
    
      if ( (nState & 4) == 4 )    // Состояние Раскроен?
        return true;              // Нельзя менять дату отгрузки!
    }
  }
  catch(e)
  {
    Prog.SaveError("CheckTaskInReplic " + e.message, true);
  }
  return false;                   // Не раскроен. Менять можно.
}

function ChangeRasTypeSection(CurObj)
{
  try
  {
    var  idTypeConnect = CurObj.StringID("ID_Ras_ConnectType"),
         SonCount      = CurObj.SunMas.ObjCount,
         Obj;
         
    for (var  n = 0; n < SonCount; n++)
    {
      Obj = CurObj.SunMas.GetObjNum(n);

      if ( Obj.nClass == nClass_Ras_Vert || Obj.nClass == nClass_Ras_Horiz)
      {
        // по умолчанию всегда разрез
        Obj.StringID("ID_Ras_TypeSection") = 0;

        if ( idTypeConnect == 2 && Obj.nClass == nClass_Ras_Vert  ||
             idTypeConnect == 3 && Obj.nClass == nClass_Ras_Horiz || 
             Obj.Line("Body").Seg(0).IsArc
           )
          Obj.StringID("ID_Ras_TypeSection") = 1;
      }
    }
  }
  catch(e)
  {
    Prog.SaveError("ChangeRasTypeSection " + e.message, true);
  }
}

function SetRasTypeSection(CurObj)
{
  try
  {
    var sSQL = 
      "select distinct vRST.ID from v_RasConnectType vRST left join Manufacter M on  IsNull(M.bNotch,0) = IsNull(vRST.bNotch,0) " +
      "where M.ID = " + CurObj.StringID("ID_Ras_Manuf") + 
      "  and vRST.nOrient = " +
      "      case when vRST.bNotch = 1 then case when " + CurObj.Int("Glass_Width" ) + " <= " + CurObj.Int("Glass_Height") + " then  1 else 2 end else 0 end";

    var ID_Ras_ConnectType = Prog.Select_Int(sSQL, "ID", true);

    CurObj.StringID("ID_Ras_ConnectType") = ID_Ras_ConnectType;

    ChangeRasTypeSection(CurObj);
  }
  catch(e)
  {
    Prog.SaveError("SetRasTypeSection " + e.message, true);
  }
}

function SetRasComplectCount(CurObj)
{
  try
  {
    var nCamCount = GP.GetShort("CamCount");

    if ( nCamCount < 1 )
      nCamCount = 1;
    else
    if ( nCamCount > 2 )
      nCamCount = 2;

    var sSQL =
      "select case bDuplex when 1 then " + nCamCount + " else 1 end as RasComplectCount from Manufacter M " +
      "where M.ID = " + CurObj.StringID("ID_Ras_Manuf");

    var nRasComplectCount = Prog.Select_Int(sSQL, "RasComplectCount", true);

    CurObj.Int("RasComplectCount") = nRasComplectCount;

  }
  catch(e)
  {
    Prog.SaveError("SetRasComplectCount " + e.message, true);
  }
}

function Prog::onGridInit()
{
  // Событие при инициализации грида.
  // Можно добавить удалить колонки в гриде.
  //Prog.MessageBox("Prog::onGridInit() " + Prog.CurGrid.Name);
}

function Prog::onGridSQL()
{
  // Событие при инициализации грида.
  // Можно добавить удалить колонки в гриде.
  //Prog.MessageBox("Prog::onGridInit() " + Prog.CurGrid.Name);
}
