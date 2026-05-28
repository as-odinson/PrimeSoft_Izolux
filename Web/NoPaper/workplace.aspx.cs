using log4net;
using log4net.Config;
using Newtonsoft.Json;
using NoPaper.Controllers;
using NoPaper.Helpers;
using NoPaper.Models;
using NoPaper.Queries;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics.Eventing.Reader;
using System.Drawing;
using System.EnterpriseServices;
using System.IO;
using System.Linq;
using System.Runtime.Remoting.Messaging;
using System.Security.Policy;
using System.Web;
using System.Web.Configuration;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;
using Utils;
using static System.Net.Mime.MediaTypeNames;

namespace NoPaper
{
  public partial class workplace : PageModel
  {
    private HashSet<string>  displayedPyramidButtons = new HashSet<string>();  // Для отслеживания отображенных кнопок пирамиды
    private List<SawLimit>   _sawLimitsList;

    private static int?      IdFirstGlassProcessingPyramid;                    // id первой пирамиде
    private static int       currentScanIdPyramidBarCode = 0;                  // id текущей отсканированной пирамиды

    private static DBConfig  m_config;

    private Dictionary<string, List<string>> pyramidCollectionArgs;            // Колекция аргументов для кнопки готово на пирамиду

    private static readonly ILog log = LogManager.GetLogger(typeof(workplace));

    private void ChangeSortDirection(string columnSortExpression)
    {
      string  sortDirection         = "ASC",
              currentSortExpression = Session["SortExpression"] as string;

      if (currentSortExpression != null && currentSortExpression == columnSortExpression)
      {
        string currentSortDirection = Session["SortDirection"] as string;
        if (currentSortDirection != null && currentSortDirection == "ASC")
          sortDirection = "DESC";
      }

      // Сохранение нового направления сортировки
      Session["SortExpression"] = columnSortExpression;
      Session["SortDirection"]  = sortDirection;
    }

    private string GetSortExpresion(int nTypeSector)
    {
      string              sortExpression      = Session["SortExpression"] as string,
                          sortDirection       = Session["SortDirection"] as string;

      if (sortExpression != null && sortDirection != null)
        return $"{sortExpression} {sortDirection}";

      // Если сборка то нужно отсортировать сортируем по вычисляему полю assemblyOrder, которое получаем min (PiramidOrder) over (partition by idBarCode)
      if (nTypeSector == 2)
        return "NameSawTask, assemblyOrder, GlassNum, PiramidOrder, nGlassInPack, nOrderOper, PiramidNum, PiramidSide, nPack, PiramidCell";

      return "NameSawTask, PiramidNum, idGlassProcessingPyramid, PiramidSide, nPack, nGlassInPackTake desc, nGlassInPack, PiramidCell";
      // Сортируем по номеру оптимизации, а потом по ID оптимизации
      // на случай если 2 оптимизации будут с одинковым номером
    }

    private Dictionary<string, List<string>> CreatePyramidButtonCommandArgsCollection(DataTable table)
    {
      Dictionary<string, List<string>> pyramidButtonArgsCollection = new Dictionary<string, List<string>>();

      foreach (DataRow row in table.Rows)
      {
        string sIdPiramid                = row["idPiramid"].ToString(),
               sIdGlassProcessingPyramid = row["idGlassProcessingPyramid"].ToString();

        // Если ключ уже существует, добавляем в существующий список
        if (pyramidButtonArgsCollection.ContainsKey(sIdPiramid))
        {
          // Добавляем только уникальные значения
          if (!pyramidButtonArgsCollection[sIdPiramid].Contains(sIdGlassProcessingPyramid))
            pyramidButtonArgsCollection[sIdPiramid].Add(sIdGlassProcessingPyramid);
        }
        else
          pyramidButtonArgsCollection[sIdPiramid] = new List<string> { sIdGlassProcessingPyramid };
      }

      return pyramidButtonArgsCollection;
    }

    private void BindData_GridOper(SectorManufactInfo sector, Equipment equipment, GlassProcessingController glassProcessingController)
    {
      /*
       * Нет смысла, требуется вывести только те стекла у которых следующий участок будет сборка
      string sWhereBlock = sector.nType == 2 
                           ? string.Join  (",", _sectorManufactList
                                 .Where (s => s.nType == 2 || s.nType == 16)
                                 .Select(s => s.ID))
                           : "";
      */

      /* 
       [AO]: Тестировал на базе G_SHTANDART на раскрое 7142, ID = 7685 на участке сборке выходит одно стекло
       При условии temp.idSectorManufactNext = {sector.ID}
       Выходит так после группировки нескольких idGlassProcessingPyramid
       При замене на условие temp.idSectorManufact != {sector.ID} вызодит правильно, 
       тесты проводил на раскроях 7142, 7143, 7147, 7541, 10220
      */
      string sWhereAdd = "";
      if ( sector.nType == 2 )
        sWhereAdd = $@" and 
                    (
                      IsNull(temp.idSectorManufactNext, 0) = {sector.ID} 
                      or temp.idSectorManufactNext is null
                    )
                    and IsNull(temp.idSectorManufactPrev, 0) != {sector.ID}
                    and IsNull(temp.idSectorManufact,     0) != {sector.ID}" ;
      else
      // Объединение участка, если на текущем участке стоит галка bChangeOrder
      if ( sector.bChangeOrder )
      {
        int idSectorManufact = _sectorManufactList.FirstOrDefault((s) => s.nType == 1)?.ID ?? 0; // Если предыдщий этап резка, то будем в любом случае выводить пирамиду готовую к перемещению
        sWhereAdd = $" or (bChangeOrderPrev != 1 and temp.idSectorManufactPrev != {idSectorManufact})";
      }

      DataTable table       = glassProcessingController.GetTableOper(sector, sWhereAdd, equipment, GetSortExpresion(sector.nType));
      pyramidCollectionArgs = CreatePyramidButtonCommandArgsCollection(table);

      GridOper.DataSource = table;
      GridOper.DataBind();

      IdFirstGlassProcessingPyramid = null;
      foreach (DataRow row in table.Rows)
      {
        if (int.TryParse(row["idGlassProcessingPyramid"].ToString(), out int curIdGlassProcessing))
        {
          IdFirstGlassProcessingPyramid = curIdGlassProcessing;
          break;
        }
      }
    }

    private void BindData_GridOperReady(SectorManufactInfo sector, Equipment equipment, GlassProcessingController glassProcessingController)
    {
      string sWhereAdd = "";
      int    idSectorManufact = _sectorManufactList.FirstOrDefault((s) => s.nType == 1)?.ID ?? 0; 

      if (sector.bChangeOrder)
        sWhereAdd        = $" and (IsNull(t.bChangeOrder, 0 )   = 1 or t.idSectorManufact = {idSectorManufact}) \r\n"; // Если предыдщий этап резка, то будем в любом случае выводить пирамиду готовую к перемещению

      if (idSectorManufact != 0 && sector.ID != idSectorManufact)
        sWhereAdd += $" and (t.idSectorManufactNext = {sector.ID} or ( t.idSectorManufact = {idSectorManufact} and t.ProcessingRoute = '{idSectorManufact},{sector.ID}'))";
      else
        sWhereAdd += $" and t.idSectorManufactNext = {sector.ID}";

      GridOperReady.DataSource = glassProcessingController.GetTableOperReady(equipment, sWhereAdd);
      GridOperReady.DataBind();
    }

    private void LoadSawLimit()
    {
      try
      {
        log.Info("Загрузка ограничений оборудования");
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();

          bool bAssembly = false;

          if (_curentSectorManufact != null)
          {
            bAssembly = _curentSectorManufact.nType == 2;
            log.Info($"Выбрано оборудование для {_curentSectorManufact.Name}");
          }

          // сохраняем текущее выбранное значение
          string selectedValue = ddListEquipment.SelectedValue;

          // Инициализируем контролер для получения списка оборудования на текущем idSectorManufact
          SawLimitController sawLimitController = new SawLimitController(conn, bAssembly);
          List<SawLimit>     sawLimitsList      = new List<SawLimit>(sawLimitController.GetListSawLimit)
                                                                  .Where(sl => sl.idSectorManufact == _curentSectorManufact.ID)
                                                                  .ToList();
          ddListEquipment.DataSource = sawLimitsList;
          ddListEquipment.DataTextField = "EquipmentName";
          ddListEquipment.DataValueField = "EquipmentID";
          ddListEquipment.DataBind();

          ViewState["SawLimitsList"] = sawLimitController.GetListSawLimit;

          ddListEquipment.Items.Insert(0, new ListItem("-", "0"));

          // пытаемся восстановить выбор
          if (!string.IsNullOrEmpty(selectedValue))
          {
            ListItem item = ddListEquipment.Items.FindByValue(selectedValue);
            if (item != null)
            {
              ddListEquipment.ClearSelection();
              item.Selected = true;
            }
            // если не нашли — просто забиваем, как ты и хотел
          }
        }
        log.Info("Конец загрузки ограничений");
      }
      catch (Exception ex)
      {
        ShowMessage("Ошибка при загрузке ограничений", false);
        log.Error($"Ошибка при загрузке ограничений, {ex.Message}");
      }
    }

    private void LoadSawLimitByList()
    {
      bool bAssembly = false;

      if (_curentSectorManufact != null)
      {
        bAssembly = _curentSectorManufact.nType == 2;
        log.Info($"Выбрано оборудование для {_curentSectorManufact.Name}");
      }

      List<SawLimit> sawLimitsList = new List<SawLimit>(_sawLimitsList)
                                                        .Where(sl => sl.idSectorManufact == _curentSectorManufact.ID)
                                                        .ToList();

      ddListEquipment.DataSource = sawLimitsList;
      ddListEquipment.DataTextField = "EquipmentName";
      ddListEquipment.DataValueField = "EquipmentID";
      ddListEquipment.DataBind();

      ddListEquipment.Items.Insert(0, new ListItem("-", "0"));
    }

    private void LoadDataGrid()
    {
      try
      {
        log.Info("Начало загрузки данных");

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();

          Equipment equipment = new Equipment(_ID  : int.Parse(ddListEquipment.SelectedValue),
                                              _Name: ddListEquipment.SelectedItem.Text,
                                              type : _curentSectorManufact.nType == 2 ? TypeEquipment.e_assembly : TypeEquipment.e_default);

          GlassProcessingController glassProcessingController = new GlassProcessingController(conn, SawTaskTxtInput.Text, _curentSectorManufact);

          log.Info($"Создание временной таблицы с выбранным участком {_curentSectorManufact.Name}, ID = {_curentSectorManufact.ID} ");
          glassProcessingController.MakeTempTable(_curentSectorManufact);

          log.Info("Привязка данных к основной таблице");
          BindData_GridOper(_curentSectorManufact, equipment, glassProcessingController);

          log.Info("Привязка данных к таблице готовых к перемещению пирамид");
          BindData_GridOperReady(_curentSectorManufact, equipment, glassProcessingController);

          // SetCurrentSawTask(glassProcessingController.GetSawTask());
        }
      }
      catch (InvalidOperationException ex)
      {
        ShowMessage(ex.Message);
        log.Error($"На сборке остуствуют записи или ссылки на idSawTask_Assembly :\n {ex.Message}");
      }
      catch (Exception ex)
      {
        log.Error($"Ошибка при загрузке данных :\n {ex.Message}");
      }
    }

    private void LoadDataGrid(SawTaskInfo sawTask)
    {
      try
      {
        log.Info($"Начало загрузки данных раскроя ID {sawTask.ID}");

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();

          Equipment equipment = new Equipment(_ID: int.Parse(ddListEquipment.SelectedValue),
                                              _Name: ddListEquipment.SelectedItem.Text,
                                              type : _curentSectorManufact.nType == 2 ? TypeEquipment.e_assembly : TypeEquipment.e_default);


          GlassProcessingController glassProcessingController = new GlassProcessingController(conn, sawTask);

          log.Info($"Создание временной таблицы с выбранным участком {_curentSectorManufact.Name}, ID = {_curentSectorManufact.ID} ");
          glassProcessingController.MakeTempTable(_curentSectorManufact);

          log.Error("Привязка данных к основной таблице");
          BindData_GridOper(_curentSectorManufact, equipment, glassProcessingController);

          log.Info("Привязка данных к таблице готовых к перемещению пирамид");
          BindData_GridOperReady(_curentSectorManufact, equipment, glassProcessingController);

          //SetCurrentSawTask(glassProcessingController.GetSawTask());
        }
      }
      catch (InvalidOperationException ex)
      {
        ShowMessage(ex.Message);
        log.Error($"На сборке остуствуют записи или ссылки на idSawTask_Assembly :\n {ex.Message}");
      }
      catch (Exception ex)
      {
        log.Error($"Ошибка при загрузке данных :\n {ex.Message}");
      }
    }

    private void ShowAdditionalColumns()
    {
      // Если сборка тогда выводим только значение № в Пачке взять
      if (_curentSectorManufact.nType == 2)
      {
        operationSelect.SelectedValue = "in";

        // делаем невозможным выбор остальных элементов
        foreach (ListItem item in operationSelect.Items)
          if (item.Value != "in")
            item.Attributes.Add("style", "display:none"); // Скрываем элемент с помощью CSS
      }
      else // иначе нужно вернуть все как было
      {
        foreach (ListItem item in operationSelect.Items)
          item.Attributes.Remove("style"); // Удаляем атрибут style, чтобы элемент снова стал видимым
      }

      string selectedValue = operationSelect.SelectedValue;

      // Имя столбца "№ в пачке взять"
      string controlIdIn = "nGlassInPackTake";
      // Имя столбца "№ в пачке поставить"
      string controlIdOut = "nGlassInPack";

      switch (selectedValue)
      {
        case "in":
          ShowOrHideColumn(controlIdIn, true);
          ShowOrHideColumn(controlIdOut, false);
          break;
        case "out":
          ShowOrHideColumn(controlIdIn, false);
          ShowOrHideColumn(controlIdOut, true);
          break;
        case "in-out":
          ShowOrHideColumn(controlIdIn, true);
          ShowOrHideColumn(controlIdOut, true);
          break;
      }
    }

    private void ShowOrHideColumn(string controlId, bool isVisible)
    {
      int cellIndex = -1;
      GridViewRow firstRow = GridOper.Rows.Cast<GridViewRow>().FirstOrDefault();
      if (firstRow != null)
      {
        // Находим контрол в шаблоне по его ID в первой строке GridView
        Label labelControl = firstRow.FindControl(controlId) as Label;
        if (labelControl != null)
          cellIndex = firstRow.Cells.Cast<DataControlFieldCell>().ToList().FindIndex(cell => cell.Controls.Contains(labelControl));
      }

      // Если удалось найти индекс ячейки с контролом, находим соответствующий столбец и устанавливаем его видимость
      if (cellIndex != -1)
      {
        DataControlField column = GridOper.Columns[cellIndex];
        if (column != null)
          column.Visible = isVisible;
      }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
      log.Info("Начало Page_Load");

      bool   isSectorChange  = false;
      string parameter       = Request["__EVENTARGUMENT"];
      int    idSavedOperator = 0;

      BarCodeTxtInput.Attributes["autocomplete"] = "off";

      // Перезагружать список операторо при каждом Postback включая первой инициализации
      LoadOperatorList(ddListPerson, "ID", "Name", "1=1", true); // Список операторов с ключем 

      if (!IsPostBack)
      {
        BindOperatorBrigadirList();

        int idSector = 0;
        string sectorParam = Request.QueryString["sector"];

        if (!string.IsNullOrEmpty(sectorParam) && int.TryParse(sectorParam, out int result))
        {
          idSector = result;
          ddListSector.Enabled = false; // Если параметр есть, отключаем DropDownList
        }
        else
          ddListSector.Enabled = true; // Если параметра нет, разрешаем изменение

        if (Request.QueryString["param"] != null)
        {
          string paramsValue = Request.QueryString["param"];
          string[] paramArguments = paramsValue.Split('_');
          Int32.TryParse(paramArguments[2], out idSector);
        }

        LoadSectorManufact(ddListSector, idSector);
        m_config = LoadDBSettings();  // Инициализация переменных из Config

        // если есть параметр с оператором
        if (Request.QueryString["oper"] != null)
        {
          string paramValue = Request.QueryString["oper"];
          idSavedOperator = SafeConvert.ToInt(paramValue);

          log.Info($"Передан параметр оператора: {idSavedOperator}");

          var item = ddListPerson.Items.OfType<ListItem>().FirstOrDefault(x => x.Value == idSavedOperator.ToString());

          ddListPerson.SelectedValue = item?.Value ?? ddListPerson.Items[0].Value;
        }
      }
      else
      {
        if (ViewState["SawLimitsList"] != null) // Иначе если есть то берем значения из State
          _sawLimitsList = new List<SawLimit>((List<SawLimit>)ViewState["SawLimitsList"]);

        if (ViewState["SectorManufactList"] != null)
        {
          _sectorManufactList = new List<SectorManufactInfo>((List<SectorManufactInfo>)ViewState["SectorManufactList"]);
          // Так надежнее
          _curentSectorManufact = _sectorManufactList.FirstOrDefault(sector => sector.ID == Convert.ToInt32(ddListSector.SelectedValue));
        }
      }

      // Выберем объект оператора по значению из ComboBox
      _currentOperatorInfo = _operatorInfoList.FirstOrDefault(oper => oper.ID == Convert.ToInt32(ddListPerson.SelectedValue));
      FilterSectorManufact(ddListSector, _currentOperatorInfo.idSectorManufact);  // Фильтруем участки для текущего оператора

      // Если у оператора есть участок на котором он должен работать
      if (_currentOperatorInfo.idSectorManufact != null)
      {
        // Выберем тот участок к которому принадлежит данный оператор
        SectorManufactInfo curSector = _sectorManufactList.FirstOrDefault(sector => sector.ID == _currentOperatorInfo.idSectorManufact);

        // Если при смене оператора изменился участок выстовим флаг, для перезагрузки грида
        if (curSector.ID != _curentSectorManufact.ID)
          isSectorChange = true;

        _curentSectorManufact = curSector;
      }

      log.Info($"Текущий участок: {_curentSectorManufact.Name}, ID: {_curentSectorManufact.ID}");

      // Загружаем оборудование и линии сборки
      LoadSawLimit();

      log.Info($"Оборудование загружено");

      //// Если мы просто изменили значение участка то нет необходимости перезагружать страницу
      //if (Request.Form[ddListSector.UniqueID] != null && Request.Form["__EVENTTARGET"] == ddListSector.UniqueID)
      //  return;

      if (parameter == null)
      {
        if (!IsPostBack)
          if (Request.QueryString["param"] != null)
          {
            string     paramsValue    = Request.QueryString["param"];
            string[]   paramArguments = paramsValue.Split('_');

            SawTaskInfo sawTask = new SawTaskInfo
            {
              ID          = Convert.ToInt32(paramArguments[0]),
              NameSawTask = paramArguments[1]
            };

            LoadDataGrid(sawTask);
          }
          else
            LoadDataGrid();
        return;
      }

      if ( isSectorChange )
        LoadDataGrid();          // Загрузка данных в таблицы
    }

    private void BindOperatorBrigadirList()
    {
      List<OperatorInfo> brigadiers = new List<OperatorInfo>();

      // 1. "Не назначен"
      brigadiers.Add(new OperatorInfo(0, "Не назначен"));
      brigadiers.AddRange(_operatorInfoList.Where(o => o.bTeam));

      ddListBrigadier.DataSource = brigadiers;
      ddListBrigadier.DataTextField = "Name";
      ddListBrigadier.DataValueField = "ID";
      ddListBrigadier.DataBind();
    }

    /// <summary>
    ///   Записать внутрицеховой штрихкод пирамиды
    /// </summary>
    /// <param name="idBarCode">ID штрихкода</param>
    /// <param name="idPyramid">ID пирамиды на которой находиться штрихкод</param>
    /// <param name="idSectorManufact">ID участка</param>
    /// <param name="pyramidBarCode">Сканируемый штрихкод внутрицеховой пирамиды</param>
    /// <param name="sIdGlassProcessingPyramid">Внутрицеховая пирамида, значение должно быть одинаковым для каждой записи с одним idPiramid, idSectorManufact</param>
    /// <param name="isCheck">Флаг была ли осуществеленна проверка, по умолчанию false
    ///                       true - проверка была выполненна на предыдущем эатпе
    ///                       false - проверка не была выполненна на предыдущем этапе</param>
    /// <returns></returns>
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object WritePyramidBarCodeByTextBox(int idBarCode, int idPyramid, int idSectorManufact, string pyramidBarCode, string sIdGlassProcessingPyramid, bool isCheck = false)
    {
      try
      {
        log.Info("Сканирован внутрицеховой штрихкод пирамиды");

        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();

          GlassProcessingController glassProcessingController = new GlassProcessingController(conn);
          
          // Проверяем существование баркода
          string     query   = $@"select top 1
                                    1 as hasBarCode
                                  from PyramidBarCode
                                  where BarCode = @PyramidBarCode";

          SqlCommand command = new SqlCommand(query, conn);
          command.Parameters.AddWithValue("@PyramidBarCode", pyramidBarCode);

          object     result  = command.ExecuteScalar();

          if ( result == null)
          {
            // Если штрихкод начинается с нужного префикса — добавим запись
            if (!string.IsNullOrEmpty(m_config.sBarCodePrefixGlassProcessingPyramid) && 
                pyramidBarCode.ToLower().StartsWith(m_config.sBarCodePrefixGlassProcessingPyramid))
            {
              query = @"insert into PyramidBarCode (BarCode)
                        values                     (@BarCode)";

              using (SqlCommand insertCommand = new SqlCommand(query, conn))
              {
                insertCommand.Parameters.AddWithValue("@BarCode", pyramidBarCode);
                insertCommand.ExecuteNonQuery();
              }
            }
            else
            {
              return new
              {
                message   = "Не известный штрихкод, проверьте правильность",
                isSuccess = false
              };
            }
          }

          // 1. Узнаем на каком раскрое находится
          int idSawTask    = SawTaskMainController.GetIDSawTaskByBarCode(new BarCodeInfo(idBarCode, ""), new BarCodeGlassInfo(), conn);

          // 2. Выясняем имеются ли дубли
          bool check = glassProcessingController.CheckGlassProcessingPyramidOnPyramid(idSawTask, idPyramid, idSectorManufact);

          // 3. Если аттрибут sIdGlassProcessing будет пустой или существуют разные idGlassProcessingPyramid,
          if (string.IsNullOrEmpty(sIdGlassProcessingPyramid) || !check)
          {
            // Дубли все равно беруться, так что обработаем
            glassProcessingController.WritePyramidBarCode(sIdGlassProcessingPyramid, pyramidBarCode);

            // 3.1 Формируем фильтр для переприсвоения idGlassProcessingPyramid для текущей пирамиды
            string sAddFilter = $"and GD.idPiramid = {idPyramid} and GP.idSectorManufact = {idSectorManufact}";


            // 3.2 выполним переприсвоение только для текущей пирамиды
            glassProcessingController.PiramidParking(idSawTask, sAddFilter);

            // 3.3 Вытаскиваем idGlassProcessingPyramid полученный при новой расстановке
            command.CommandText = $@"select IsNull(idGlassProcessingPyramid, '') as idGlassProcessingPyramid
                                     from GlassProcessing    GP
                                     inner join GlassDetails GD on GD.ID = GP.idGlassDetails
                                     where GP.idSawTaskMain = {idSawTask} and idPiramid = {idPyramid} and idSectorManufact = {idSectorManufact} and idBarCode = {idBarCode} and
                                           isnull(bFinished, 0) = 0
                                     order by nOrderGlobal, ProcessingOrder";

            // 3.4 Если все еще остались дубли, и перестановка не помогла, тогда пройдемся по всем имеющимся idGlassProcessing. А если помогла тогда произведем присвоение
            using (SqlDataReader reader = command.ExecuteReader())
            {
              while (reader.Read())
              {
                sIdGlassProcessingPyramid = SafeConvert.ToString(reader["idGlassProcessingPyramid"]);
                glassProcessingController.WritePyramidBarCode(sIdGlassProcessingPyramid, pyramidBarCode);
              }
            }
          }  

          // если все данные имеются, и проверка успешная
          if ( check )
            glassProcessingController.WritePyramidBarCode(sIdGlassProcessingPyramid, pyramidBarCode);

          return new
          {
            message    = "Штрих-код отсканирован успешно",
            isSuccess  = true
          };
        }
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
        return new
        {
          message   = ex.Message,
          isSuccess = false
        };
      }
    }


    [WebMethod(EnableSession = true)]
    public static List<object> GetOperatorGroup(int brigadierId)
    {
      List<object> result = new List<object>();
      
      if (brigadierId == 0)
      {
        HttpContext.Current.Session.Remove("CurrentOperatorGroup");
        HttpContext.Current.Session.Remove("CurrentBrigadier");

        return result;
      }
      using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
      {
        conn.Open();

        string sql = @"
          select
              O.ID,
              O.Name,
              O.idSectorManufact,
              isnull(SO.ID, 0) as idSheduleOperator,
              isnull(O.idUser, 0) as idUser,
              isnull(O.idDepName, 0) as idDepName,
              isnull(O.bTeam, 0) as bTeam,
              isnull(O.idPersonnel, 0) as idPersonnel,
              GI.Coef
          from OperatorGroup G
          join OperatorGroupItem GI on GI.idOperatorGroup = G.ID
          join Operator O on O.ID = GI.idOperator
          outer apply
          (
              select top 1 ID
              from SheduleOperator SO
              where SO.idOperator = O.ID
                and SO.dtBegin <= getdate()
                and SO.dtEnd >= getdate()
          ) SO
          where G.idOperatorBrigadier = @idBrigadier
          order by O.Name
         ";

        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
          cmd.Parameters.AddWithValue("@idBrigadier", brigadierId);

          using (SqlDataReader reader = cmd.ExecuteReader())
          {
            while (reader.Read())
            {
              result.Add(new
              {
                ID = SafeConvert.ToInt(reader["ID"]),
                Name = SafeConvert.ToString(reader["Name"]),
                idSheduleOperator = SafeConvert.ToInt(reader["idSheduleOperator"]),
                idPersonnel = SafeConvert.ToInt(reader["idPersonnel"]),
                bTeam = SafeConvert.ToBool(reader["bTeam"]),
                coef = Convert.ToDouble(reader["Coef"])
              });
            }
          }
        }
      }

      HttpContext.Current.Session["CurrentOperatorGroup"] = result;
      HttpContext.Current.Session["CurrentBrigadier"] = brigadierId;

      return result;
    }

    /// <summary>
    ///   Сканирование штрихкода оператора
    /// </summary>
    /// <param name="barcode">штрихкод</param>
    /// <returns>
    /// Возвращает ответ с параметрами оператора если по введеному штрихкоду существуют данные
    /// Если данных нет, вернет ответ неизвестного штрихкода
    /// </returns>
    public static ScanResponse<IScanResult> PostOperator(string barcode)
    {
      try
      {
        log.Info($"Сканирование оператора: {barcode}");
        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();

          string query = $"select ID, Name from Operator where BarCode = '{barcode}'";
          SqlCommand command = new SqlCommand(query, conn);

          using (SqlDataReader reader = command.ExecuteReader())
          {
            // Если есть по заданному штрихкоду данные возвращаем
            if (reader.Read())
            {

              int id      = Convert.ToInt32(reader["ID"]);
              string name = SafeConvert.ToString(reader["Name"]);

              OperatorInfo info     = _operatorInfoList.FirstOrDefault(x => x.ID == id);
              int ID               = info?.ID ?? 0,
                  idSectorManufact = info?.idSectorManufact ?? 0;

              _currentOperatorInfo   = _operatorInfoList.FirstOrDefault(oper => oper.ID == id);

              return ScanResponse<IScanResult>.Ok(new OperatorScanResult(ID, idSectorManufact, name), $"Оператор {name} отсканирован");
            }
            return ScanResponse<IScanResult>.Fail(new UnknowResult(), "Оператор не найден");
          }
        }
      }
      catch (Exception ex)
      {
        // Обработка ошибки подключения или запроса
        log.Error(ex.Message);
        return ScanResponse<IScanResult>.Fail(new UnknowResult(), "Ошибка: " + ex.Message);
      }
    }

    public static ScanResponse<IScanResult> PostPyramidBarcode(string barcode)
    {
      try
      {
        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();

          string query = $"select ID from PyramidBarCode where BarCode = '{barcode}'";
          SqlCommand sqlCommand = new SqlCommand(query, conn);

          object result = sqlCommand.ExecuteScalar();

          if (result != null)
          {
            int id = Convert.ToInt32(result);
            currentScanIdPyramidBarCode = id;

            log.Info($"Отсканирован штрих-код: {barcode}");
            return ScanResponse<IScanResult>.Ok(new GlassProcessingPyramidResult(id, barcode), "Штрих код отсканирован");
          }
          else
          {
            log.Warn($"Отсканирпованный штрих-код пирамиды не обнаружен: {barcode}");
            return ScanResponse<IScanResult>.Fail(new UnknowResult(), "Штрих код пирамиды не обнаружен");
          }
        }
      }
      catch (Exception ex)
      {
        log.Error($"Ошибка при сканированиии {barcode}");
        return ScanResponse<IScanResult>.Fail(new UnknowResult(), "Ошибка: " + ex.Message);
      }
    }

    public static ScanResponse<IScanResult> PostBarcode(string barcode, OperatorInfo operatorInfo)
    {
      try
      {
        log.Info($"Сканирование штрихкода {barcode}");
        // Вытянем все данные о текущем учатске
        _curentSectorManufact = _sectorManufactList.FirstOrDefault(sector => sector.ID == operatorInfo.idSectorManufact);
        _currentOperatorInfo   = _operatorInfoList.FirstOrDefault(oper => oper.ID == operatorInfo.ID );

        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();
          OperatorInfo.CreateShedulePersonnel(conn);

          if (_currentOperatorInfo.idSheduleOperator == 0)
          {
            _currentOperatorInfo.idSheduleOperator = OperatorInfo.CreateSheduleOperator(conn, _currentOperatorInfo.ID);
            log.Info($"новый idSheduleOperator: {_currentOperatorInfo.idSheduleOperator}");
          }
        }

         return BarCodeController.PostBarCodeGlass(barcode, _curentSectorManufact, _currentOperatorInfo, currentScanIdPyramidBarCode);
      }
      catch (Exception ex)
      {
        return ScanResponse<IScanResult>.Fail($"Ошибка при сканировании штрихкода: {ex.Message}");
      }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static ScanResponse<IScanResult> WriteBarCode(string barcode, int idSectorManufact, int idOperator, int idSheduleOperator)
    {
      try
      {
        log.Info($"сканирован штрих-код {barcode}");
        string operBarCodePrefix            = barcode.Substring(0, m_config.sBarCodePrefixOperator.Length).ToLower(),
               glassProcessingPyramidPrefix = barcode.Substring(0, m_config.sBarCodePrefixGlassProcessingPyramid.Length).ToLower();

        // Префикс штрихкода является оператором?
        if (operBarCodePrefix == m_config.sBarCodePrefixOperator && barcode.Length > 0)
        {
          log.Info("Штрих-код оператора");
          return PostOperator(barcode);
        }
        // Префикс штрихкода является штрихкодом внутрицеховой пирамиды
        else if (glassProcessingPyramidPrefix == m_config.sBarCodePrefixGlassProcessingPyramid && barcode.Length > 0)
        {
          log.Info("Штрих-код внутрицехвой пирамиды");
          return PostPyramidBarcode(barcode);
        }
        // Штрихкод является штрихкодм стекла или СП
        else if (barcode.Length > 0)
        {
          log.Info("Штрихкод СП или стекла"); ;

          OperatorInfo operatorInfo = new OperatorInfo(idOperator, idSheduleOperator, 0, idSectorManufact, 0, "");

          return PostBarcode(barcode, operatorInfo);
        }

        log.Warn("Неизвестный штрих-код");
        return ScanResponse<IScanResult>.Fail("По данному штрихкоду не найдено записей");
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
        return ScanResponse<IScanResult>.Fail(ex.Message);
      }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string GetData(string argument)
    {
      string[] parts = argument.Split('_');
      string barCodeGlass = parts[0],
             sIdBarCode   = parts[1];

      RemakeModel remakeModel;

      using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
      {
        BarCodeController barCodeController = new BarCodeController(conn);
        remakeModel = barCodeController.GetInfoByBarCodeReject(sIdBarCode);
      }

      string json = JsonConvert.SerializeObject(remakeModel);

      return json;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string GetDrawDetails(int idSector)
    {
      List<GlassDetail> glassDetailsList = new List<GlassDetail>();

      if (IdFirstGlassProcessingPyramid == null)
        return "";

      using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
      {
        conn.Open();
        
        SqlCommand command = new SqlCommand($@"select
                                                 GD.ID,
                                                 GD.Width,
                                                 GD.Height,
                                                 SM.nType,
                                                 IsNull(GD.PiramidSide,        0) as PiramidSide,
                                                 IsNull(GP.nGlassInPack,       0) as nGlassInPack,
                                                 IsNull(prevProc.nGlassInPack, 0) as nGlassInPackTake,
                                                 IsNull(GD.PiramidCell,        0) as PiramidCell,
                                                 --IsNull(GD.nGlassPyramidASidePack, 0) as nGlassPyramidASidePack,
                                                 IsNull(GP.nPack,              0)       as nPack,
                                                 P.Thickness,
                                                 IsNull(GP.bFinished, 0) as bFinished
                                               from GlassProcessingPyramid GPP
                                               inner join GlassProcessing GP on GP.idGlassProcessingPyramid = GPP.ID
                                               inner join GlassDetails    GD on GP.idGlassDetails           = GD.ID
                                               inner join Project         P  on GD.idProject                = P.ID
                                               inner join SectorManufact  SM on GP.idSectorManufact         = SM.ID
                                               outer apply (
                                                 select top 1
                                                   GP1.idSectorManufact,
                                                   GP1.nGlassInPack
                                                 from GlassProcessing GP1
                                                 where GP1.idGlassDetails    = GD.ID
                                                   and GP1.idSectorManufact != {idSector}
                                                   and GP1.nOrderOper        = GP.nOrderOper - 1
                                               ) as prevProc
                                               where GPP.ID = {IdFirstGlassProcessingPyramid} and GP.idSectorManufact = {idSector}
                                               order by PiramidSide, nPack, nGlassInPack, PiramidCell",
                                               conn);

        using (SqlDataReader reader = command.ExecuteReader())
        {
          while (reader.Read())
          {
            int id               = SafeConvert.ToInt(reader["ID"              ]),
                width            = SafeConvert.ToInt(reader["width"           ]),
                height           = SafeConvert.ToInt(reader["height"          ]),
                nType            = SafeConvert.ToInt(reader["nType"           ]),
                thickness        = SafeConvert.ToInt(reader["Thickness"       ]),
                piramidSide      = SafeConvert.ToInt(reader["PiramidSide"     ]),
                nGlassInPack     = SafeConvert.ToInt(reader["nGlassInPack"    ]),
                nGlassInPackTake = SafeConvert.ToInt(reader["nGlassInPackTake"]),
                piramidCell      = SafeConvert.ToInt(reader["PiramidCell"     ]),
                nPack            = SafeConvert.ToInt(reader["nPack"           ]);

            bool bFinished = SafeConvert.ToBool(reader["bFinished"]);

            glassDetailsList.Add(new GlassDetail(id, width, height, nType, thickness, piramidSide, nGlassInPack, nGlassInPackTake, nPack, piramidCell, bFinished));
          }
        }
      }

      string json = JsonConvert.SerializeObject(glassDetailsList);

      return json;
    }

    // Проход по строкам
    protected void GridOper_RowDataBound(object sender, GridViewRowEventArgs e)
    {
      if (e.Row.RowType == DataControlRowType.DataRow)
      {
        // Для кнопки сделанно на пирамиде
        string sIdGlassProcessingPyramid = DataBinder.Eval(e.Row.DataItem, "idGlassProcessingPyramid").ToString(),
               sIdPiramid                = DataBinder.Eval(e.Row.DataItem, "idPiramid"               ).ToString(),
               sIdGlassDetails           = DataBinder.Eval(e.Row.DataItem, "idGlassDetails"          ).ToString(),
               sIdBarCode                = DataBinder.Eval(e.Row.DataItem, "idBarCode"               ).ToString(),
               barCode                   = DataBinder.Eval(e.Row.DataItem, "barcode"                 ).ToString(),
               barCodeGlass              = DataBinder.Eval(e.Row.DataItem, "BarCode_Glass"           ).ToString(),
               currentPyramidBarCodeText = DataBinder.Eval(e.Row.DataItem, "CurrentPyramidBarCode"   ).ToString(),
               previousPyramidBarCodeText = DataBinder.Eval(e.Row.DataItem, "CurrentPyramidBarCode"   ).ToString(),
               uniqueComboForMakePyramid = $"{sIdGlassProcessingPyramid}_{sIdPiramid}"; // Создаем уникальное слово для словаря с idGlassProecssingPyramid и idPyramid

        TextBox currentPyramidBarCode   = (TextBox)e.Row.FindControl("CurrentPyramidBarCode");

        int  idProject                  = SafeConvert.ToInt (SafeConvert.SafeEval(e.Row.DataItem, "idProject"));
        bool bPlot                      = SafeConvert.ToBool(SafeConvert.SafeEval(e.Row.DataItem, "bPlot")),
             bShpros                    = SafeConvert.ToBool(SafeConvert.SafeEval(e.Row.DataItem, "bShpros")),
             bFinishedPrev              = SafeConvert.ToBool(SafeConvert.SafeEval(e.Row.DataItem, "bFinishedPrev"));

        // Кнопка чертежа
        HyperLink linkToPlot = (HyperLink)e.Row.FindControl("OpenPlot");
        if (linkToPlot != null)
        {
          linkToPlot.Visible = bPlot;                            // показываем кнопку если надо
          linkToPlot.NavigateUrl = $"~/Plot.aspx?idProject={idProject}&bShpros={bShpros}";
        }

        // Выключаем подсказки
        if (currentPyramidBarCode != null)
          currentPyramidBarCode.Attributes["autocomplete"] = "off";

        // Если пачка с значение 0, тогда не выводим информацию о ней в таблицу
        if (e.Row.FindControl("nPack") is Label l_nPack && l_nPack.Text == "0")
          l_nPack.Text = string.Empty;

        // Добавление атрибута к строке с idGlassDetails
        e.Row.Attributes["data-id"] = sIdGlassDetails;

        // Бракована ли деталь
        bool isDefect      = (int)DataBinder.Eval(e.Row.DataItem, "isDefect")      == 1, // По таблице BarCode
             isDefectGlass = (int)DataBinder.Eval(e.Row.DataItem, "isDefectGlass") == 1; // По таблице BarCode_Glass

        int nType = _curentSectorManufact.nType;

        if (!displayedPyramidButtons.Contains(uniqueComboForMakePyramid))
        {
          // Добавляем в коллекцию и делаем и надпись видимой колонки Пирамида
          displayedPyramidButtons.Add(uniqueComboForMakePyramid);
          Label pyramidLabel   = (Label)e.Row.FindControl("PiramidNumLabel");
          pyramidLabel.Visible = true;

          if (nType != 2)
          {
            // Делаем кнопку "Готово" для пирамиды видимой только если не в сборке
            Button pyramidButton  = (Button)e.Row.FindControl("MakePyramidButton");
            pyramidButton.Visible = true;
            pyramidButton.CommandArgument = uniqueComboForMakePyramid;

            // Делаем видимым TextBox для ввода BarCode и кнопку для редактирования
            TextBox pyramidBarCodeTextBox = (TextBox)e.Row.FindControl("CurrentPyramidBarCode");
            Button pyramidBarCodeButton   = (Button)e.Row.FindControl("WritePyramidBarCodeButton");
            pyramidBarCodeTextBox.Visible = true;
            pyramidBarCodeButton.Visible = true;

            // Выделяем строку пирамиды
            e.Row.CssClass = "row-pyramid";
          }

          // Делаем видимым Label баркода предыдущей пирамиды
          Label pyramidBarCodePrevLabel   = (Label)e.Row.FindControl("PreviousPyramidBarCode");
          pyramidBarCodePrevLabel.Visible = true;
        }

        //// --ПРЕДУПРЕЖДЕНИЕ И ПОДСКАЗКА--
        Label pyramidBarCodeTextBox_Prev = (Label)e.Row.FindControl("PreviousPyramidBarCode");
        // На предыдущем участке деталь не готова? Выводим знак предупреждения и подсказку, сборку пропускаем
        if (!bFinishedPrev && nType != 2)
        {
          if (!displayedPyramidButtons.Contains(uniqueComboForMakePyramid))
            pyramidBarCodeTextBox_Prev.Text = $"⚠  {pyramidBarCodeTextBox_Prev.Text}"; // Выведим знак предупредения
          else
            pyramidBarCodeTextBox_Prev.Text = $"⚠"; // Выведим только знак предупредения

          pyramidBarCodeTextBox_Prev.Attributes["title"] = "На предыдущем участке данная деталь не помечена как готовая";
          pyramidBarCodeTextBox_Prev.Visible = true;
        }
        //----

        Button glassReadyButton = (Button)e.Row.FindControl("MakeOperButton"),
               infoRemakeButton = (Button)e.Row.FindControl("InfoRemakeButton"),
               makeRemakeButton = (Button)e.Row.FindControl("MakeDefectButton");

        glassReadyButton.CommandArgument = $"{sIdGlassDetails}_{sIdGlassProcessingPyramid}_{sIdBarCode}";
        makeRemakeButton.Attributes["data-argument"] = $"{barCodeGlass}";
        infoRemakeButton.Attributes["data-argument"] = $"{barCodeGlass}_{sIdBarCode}";

        makeRemakeButton.Visible = true;

        // Если брак тогда отображаем кнопку информации о переделке
        if (isDefect || isDefectGlass)
        {
          e.Row.CssClass += " row-defect";

          infoRemakeButton.Visible = true;
          glassReadyButton.Visible = false;
        }
        else
        {
          infoRemakeButton.Visible = false;
          glassReadyButton.Visible = true;
        }

        // Выведим PiramidNum и штрих предыдущий штрих код если сборка
        if (nType == 2)
        {
          Label piramidNumLabel             = (Label)e.Row.FindControl("PiramidNumLabel");
          Label previousPyramidBarCodeLabel = (Label)e.Row.FindControl("PreviousPyramidBarCode");

          piramidNumLabel.Visible = true;
          previousPyramidBarCodeLabel.Visible = true;

          // Кнопку выводим только на строке с формулой
          if (currentPyramidBarCodeText == "assembly")
          {
            glassReadyButton.Enabled = true;
            glassReadyButton.Text = "Собрано";
            e.Row.CssClass = "row-assembly";

            // для кнопки брака первоя строка будет браковать весь СП
            makeRemakeButton.Attributes["data-argument"] = $"{barCode}";

            // Номера столбцов которые нужно скрыть на данной строке
            string[] hiddenCols = new string[] {
                                           "AccountNum",         // Заказ
                                           "NameEquipment",      // Оборудование
                                           "ProjectNum",         // Позиция Заказа   
                                           "PiramidSide",        // Сторона
                                           "nPack",              // Пачка
                                           "PiramidCell",        // Ячейка
                                           "nGlassInPack",       // № в Пачке поставить
                                           "nGlassInPackTake"    // № в Пачке взять
                                          };

            foreach (string hidden in hiddenCols)
            {
              Label label   = (Label)e.Row.FindControl(hidden);
              label.Visible = false;
            }
          }
          else
          {
            Label label   = (Label)e.Row.FindControl("SawOrder");
            label.Visible = false;
            glassReadyButton.Visible = false;
          }
        }

        ShowAdditionalColumns(); // Вывод соответстующего столбца в зависимости от выбора значения ComboBox Переход
      }
    }

    protected void GridOper_RowCommand(object sender, GridViewCommandEventArgs e)
    {
      using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
      {
        conn.Open();
        GlassProcessingController glassProcessingController = new GlassProcessingController(conn);

        switch (e.CommandName)
        {
          case "OnMakeOper":
            {
              string[] commandArgs         = e.CommandArgument.ToString().Split('_');

              string sIdGlassProcessingPyramid = commandArgs[1];
              int? idGlassDetails              = SecureConvert.ToNullableInt(commandArgs[0]),
                   idBarCode                   = SecureConvert.ToNullableInt(commandArgs[2]);
              int  idOperator                  = Convert.ToInt32(ddListPerson.SelectedValue);

              if (!CheckGlassProcessingPyramid(idGlassDetails, 0, sIdGlassProcessingPyramid, conn))
                return;

              OperatorInfo operatorInfo = _operatorInfoList.FirstOrDefault(o => o.ID == idOperator);

              GlassDetailsOper glassOper = new GlassDetailsOper(operatorInfo, _curentSectorManufact, idGlassDetails, sIdGlassProcessingPyramid, idBarCode, ShowMessage);

              if (_curentSectorManufact.nType == 2)
                glassProcessingController.MakeOperSP(glassOper, false, currentScanIdPyramidBarCode);
              else
                glassProcessingController.MakeOper(glassOper, currentScanIdPyramidBarCode);

              _currentOperatorInfo = glassOper.operatorInfo;
              break;
            }

          case "OnMakePyramid":
          {
            string[] commandArgs           = e.CommandArgument.ToString().Split('_');

            string sIdGlassProcessingPyramid = commandArgs[0];
            int    idPiramid                 = SafeConvert.ToInt(commandArgs[1]);
            int    idOperator                = SafeConvert.ToInt(ddListPerson.SelectedValue);
            OperatorInfo operatorInfo        = _operatorInfoList.FirstOrDefault(o => o.ID == idOperator);

            if (sIdGlassProcessingPyramid.Length == 0)
            {
              ShowMessage("Операция не возможна, не назначены пирамиды на операции", false);
              return;
            }

            // Проверяем запросы выполнются 
            bool isSuccess = glassProcessingController.MakePyramid(operatorInfo, sIdGlassProcessingPyramid, idPiramid, currentScanIdPyramidBarCode, _curentSectorManufact);
            _currentOperatorInfo = operatorInfo;

            if (!isSuccess)
              ShowMessage("Операция не возможна, не введен Штрих-код", false);

            break;
          }

          case "OnWritePyramidBarCode":
          {
            GridViewRow gridViewRow = (GridViewRow)(((Button)e.CommandSource).NamingContainer);
            string[] commandArgs    = e.CommandArgument.ToString().Split('_');
            string pyramidBarCode   = ((TextBox)gridViewRow.FindControl("CurrentPyramidBarCode")).Text;

              //10954442
            string sIdGlassProcessingPyramid = commandArgs[0];
            int    idBarCode                 = SafeConvert.ToInt(commandArgs[1]),
                   idPyramid                 = SafeConvert.ToInt(commandArgs[2]),
                   idSectorManufact          = SafeConvert.ToInt(commandArgs[3]);

            dynamic result = WritePyramidBarCodeByTextBox(idBarCode, idPyramid, idSectorManufact, pyramidBarCode, sIdGlassProcessingPyramid);

            if (result != null)
              ShowMessage(result.message, result.isSuccess);

            break;
          }

          case "OnOpenItemPlot":
            Response.Redirect("~/Plot.aspx?ID=" + e.CommandArgument);
            break;

          case "OnGetRemakeInfo": // Вызов модального окна
            return;
          default:
            return;
        }
        LoadDataGrid();
      }
    }

    protected void GridOperReady_RowDataBound(object sender, GridViewCommandEventArgs e)
    {
      using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
      {
        conn.Open();
        GlassProcessingController glassProcessingController = new GlassProcessingController(conn);
        switch (e.CommandName)
        {
          case "OnTookPyramid":
            {
              int idGlassProcessingPyramid = SafeConvert.ToInt(GridOperReady.DataKeys[int.Parse((string)e.CommandArgument)].Values["idGlassProcessingPyramid"]);

              if (idGlassProcessingPyramid == 0)
              {
                int idSawTask = SafeConvert.ToInt(GridOperReady.DataKeys[int.Parse((string)e.CommandArgument)].Values["idSawTaskMain"]);

                glassProcessingController.TryFillGlassProcessingOnPyramid(idSawTask, "");
                glassProcessingController.PiramidParking(idSawTask, "");

                ShowMessage("идентификатор пирамиды пустой, попытка назначения", false);
                return;
              }

              glassProcessingController.TookPiramid(idGlassProcessingPyramid);
              break;
            }
          default:
            return;
        }

        LoadDataGrid();
      }
    }

    protected void ButBegin_Click(object sender, EventArgs e)
    {
      LoadDataGrid();          // Загрузка данных в таблицы
    }

    protected void GridOper_Sorting(object sender, GridViewSortEventArgs e)
    {
      string sortExpression = e.SortExpression;
      switch (sortExpression)
      {
        case "NameSawTask":
          // Сортировка по пирамиде / ячейке также для Арфа-пирамид
          sortExpression = "NameSawTask, idGlassProcessingPyramid, PiramidNum, PiramidSide, nGlassInPack, PiramidCell";
          break;
        case "ItemName":
          sortExpression = "NameSawTask, idGlassProcessingPyramid, NameGlassProduct, PiramidNum, PiramidSide, nGlassInPack";
          break;
        case "TimeBeginProcessing":
          sortExpression = "NameSawTask, idGlassProcessingPyramid, TimeBeginProcessing, PiramidNum, PiramidSide, nGlassInPack";
          break;
        case "PiramidNum":
          sortExpression = "NameSawTask, idGlassProcessingPyramid, PiramidNum, PiramidSide, nGlassInPack";
          break;
        case "nGlassInPack":
          sortExpression = "NameSawTask, idGlassProcessingPyramid, PiramidNum, PiramidSide, nPack, nGlassInPack";
          break;
      }

      ChangeSortDirection(sortExpression);
      LoadDataGrid();
    }

    public void ddListSector_SelectedIndexChanged(object sender, EventArgs e) // Событие при смене элемента sectorManufact
    {
      _curentSectorManufact = _sectorManufactList[ddListSector.SelectedIndex];
      //LoadSawLimitByList();
    }

    public void ddListPerson_SelectedIndexChanged(object sender, EventArgs e) // Событие при смене элемента sectorManufact
    {
      int? idSector = _operatorInfoList[ddListPerson.SelectedIndex].idSectorManufact;
      FilterSectorManufact(ddListSector, idSector);
    }
    
    public void SetCurrentSawTask(SawTaskInfo sawTask)
    {
      if (sawTask.ID != 0 && sawTask.NameSawTask != "")
      {
        Session["idSawTask"] = sawTask.ID;
        Session["nameSawTask"] = sawTask.NameSawTask;
        SawTaskTxtInput.Text = sawTask.NameSawTask;
      }
    }

    public bool CheckGlassProcessingPyramid(int? idGlassDetails, int? idBarCode, string sIdListGlassProcessingPyramid, SqlConnection conn)
    {
      if (!string.IsNullOrEmpty(sIdListGlassProcessingPyramid))
        return true;
      else
      {
        ShowMessage("Выполняется расчет внутрецеховой логистики, повторите попытку ", false);
        int idSawTask = 0;

        if (idGlassDetails != 0)
          idSawTask = SawTaskMainController.GetIDSawTaskByIdGlassDetails(idGlassDetails, conn);
        else
          idSawTask = SawTaskMainController.GetIDSawTaskByBarCode(new BarCodeInfo(Convert.ToInt32(idBarCode), ""), new BarCodeGlassInfo(), conn);

        GlassProcessingController glassProcessingController = new GlassProcessingController(conn);
        glassProcessingController.PiramidParking(idSawTask);
        return false;
      }
    }
  }
}
