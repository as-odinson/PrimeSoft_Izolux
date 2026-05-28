using NoPaper.Controllers;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Linq.Expressions;
using System.Web.Services.Description;
using System.Web.UI.WebControls;
using log4net;
using log4net.Config;
using Utils;

namespace NoPaper.Models
{
  public class MessageModel
  {
    public bool isSuccess;
    public bool isShow;
    public string message;


    public MessageModel(bool isSuccess,  string message, bool isShow = true)
    {
      this.isSuccess = isSuccess;
      this.message = message;
      this.isShow = isShow;
    }
  }

  public static class DbConfig
  {
    public static readonly string ConnectionString = ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString;
  }

  public class PageModel : System.Web.UI.Page
  {
    public enum ETypeBarCode
    {
      e_type_unknow  = 0, // неизвестный
      e_type_oper    = 1, // оператор
      e_type_pyramid = 2, // пирамида
      e_type_barcode = 3, // СП
      e_type_ship    = 4 // отгрузка
    }

    public class ResonseString
    {
      bool         isSuccess;
      string       message;
      ETypeBarCode code;
    }


    /// <summary>
    /// Текущий участок
    /// </summary>
    protected static SectorManufactInfo _curentSectorManufact;
    /// <summary>
    /// Список участков
    /// </summary>
    protected static List<SectorManufactInfo> _sectorManufactList;
    /// <summary>
    /// Текущий оператор
    /// </summary>
    protected static OperatorInfo       _currentOperatorInfo;
    /// <summary>
    /// Список операторов
    /// </summary>
    protected static List<OperatorInfo> _operatorInfoList;

    private static readonly ILog log = LogManager.GetLogger(typeof(PageModel));

    public PageModel()
    {
      // Инициализация log4net из web.config
      XmlConfigurator.Configure();
    }


    /// <summary>
    /// Загрузка в DropDownList списка участков
    /// </summary>
    /// <param name="ddListSector">Комбобокс для привязки списка</param>
    /// <param name="idSector">Значение для привязки текущего участка</param>
    public void LoadSectorManufact(DropDownList ddListSector, int idSector = 0)
    {
      try
      {
        log.Info($"Загрузка участков");
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();
          SectorManufactController sectorManufactController = new SectorManufactController(conn);
          List<SectorManufactInfo> sectorManufactsList = new List<SectorManufactInfo>(sectorManufactController.GetSectorManufactInfo);

          ddListSector.DataSource = sectorManufactsList;
          ddListSector.DataTextField = "Name";
          ddListSector.DataValueField = "ID";
          ddListSector.DataBind();

          ViewState["SectorManufactList"] = sectorManufactsList;
          _sectorManufactList = new List<SectorManufactInfo>(sectorManufactsList);

          if (idSector != 0)
          {
            log.Info($"Текущий участок {idSector}");
            ListItem selectedItem = ddListSector.Items.FindByValue(idSector.ToString());
            if (selectedItem != null)
            {
              selectedItem.Selected = true;
              _curentSectorManufact = sectorManufactsList.FirstOrDefault(sector => sector.ID == idSector); // Инициализируем если передали id участка
              return;
            }
          }

          _curentSectorManufact = sectorManufactsList[0]; // Инициализируем первым значением в массиве
        }

        log.Info($"Конец загрузки участков");
      }
      catch (Exception ex)
      {
        ShowMessage("Ошибка при загрузке участков", false);
        log.Info($"Ошибка при загрузке участков, {ex.Message}");
      }
    }


    public void FilterSectorManufact(DropDownList ddListSector, int? idSector)
    {
      foreach (ListItem item in ddListSector.Items)
      {
        if (idSector.HasValue)
        {
          if (item.Value != idSector.Value.ToString())
            item.Attributes["style"] = "display:none"; // скрываем
          else
          {
            item.Attributes.Remove("style");           // показываем выбранный
            ddListSector.SelectedValue = item.Value;   // сразу делаем его выбранным
          }
        }
        else
          item.Attributes.Remove("style");
      }
    }

    /// <summary>
    ///    Возвращает список операторов в DropDownList
    /// </summary>
    /// <param name="ddListOperator">Комбобокс для привязки списка</param>
    /// <param name="dataValueField">Ключ комбобокса</param>
    /// <param name="dataTextField">Значение комбобокса</param>
    /// <param name="sFilter">Дополнительная фильтрация операторов</param>
    public void LoadOperatorList(DropDownList ddListOperator, string dataValueField = "ID", string dataTextField = "Name", string sFilter = "1 = 1", bool isPostBack = false)
    {
      try
      {
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          log.Info("Начало загрузки списка операторов");

          conn.Open();

          int selectedId = 0;

          if (!string.IsNullOrEmpty(ddListOperator.SelectedValue) && isPostBack)
          {
            selectedId = Convert.ToInt32(ddListOperator.SelectedValue);
            _currentOperatorInfo = _operatorInfoList.FirstOrDefault(o => o.ID == selectedId);
          }

          List<OperatorInfo> operatorInfoList = new List<OperatorInfo>();
          string commandText = $@"select 
                                 O.ID, 
                                 O.Name,
                                 O.idSectorManufact,
                                 IsNull(SO.ID,    0) as idSheduleOperator,
                                 IsNull(O.idUser, 0) as idUser,
                                 IsNull(O.idDepName, 0) as idDepName,
                                 isnull(O.bTeam, 0) as bTeam,
                                 isnull(idPersonnel, 0 ) as idPersonnel
                               from Operator O
                               outer apply  
                               (
                                select top 1 ID
                                from SheduleOperator SO
                                where SO.idOperator = O.ID    and 
                                      SO.dtBegin <= getdate() and
                                      SO.dtEnd   >= getdate()
                               ) SO
                               where {sFilter}
                               order by Name";

          using (SqlCommand command = new SqlCommand(commandText, conn))
          using (SqlDataReader reader = command.ExecuteReader())
          {
            while (reader.Read())
            {
              OperatorInfo opearator = new OperatorInfo(
                _ID:               SafeConvert.ToInt(reader["ID"]),
               _idSheduleOperator: SafeConvert.ToInt(reader["idSheduleOperator"]),
               _idUser:            SafeConvert.ToInt(reader["idUser"]),
               _idSectorManufact:  SafeConvert.ToNullableInt(reader["idSectorManufact"]),
               _idDepName:         SafeConvert.ToInt(reader["idDepName"]),
               _Name:              SafeConvert.ToString(reader["Name"]),
               bTeam:              SafeConvert.ToBool(reader["bTeam"]),
               idPersonnel:        SafeConvert.ToInt(reader["idPersonnel"])
              );

              operatorInfoList.Add(opearator);
            }
          }

          ddListOperator.DataSource     = operatorInfoList;
          ddListOperator.DataTextField  = dataTextField;
          ddListOperator.DataValueField = dataValueField;
          ddListOperator.DataBind();

          // добавляем атрибут idSheduleOperator каждому элементу комбобокса, нужно для JS
          for (int i = 0; i < ddListOperator.Items.Count; i++)
            ddListOperator.Items[i].Attributes["idSheduleOperator"] = operatorInfoList[i].idSheduleOperator.ToString();

          _operatorInfoList = new List<OperatorInfo>(operatorInfoList);

          if ( _currentOperatorInfo != null && isPostBack) // Выберем оператора если вызов PostBack
          {
            _currentOperatorInfo = operatorInfoList.FirstOrDefault(o => o.ID == _currentOperatorInfo.ID);
            if ( _currentOperatorInfo != null )
              ddListOperator.SelectedValue = _currentOperatorInfo.ID.ToString();
          }
          else
          {
            if ( operatorInfoList.Count != 0 )
            {
              _currentOperatorInfo = _operatorInfoList.FirstOrDefault(o => o.ID == selectedId);

              if ( _currentOperatorInfo == null )  // если все еще не нашли берем первого
                   _currentOperatorInfo = operatorInfoList[0];

              ddListOperator.SelectedValue = _currentOperatorInfo.ID.ToString();
            }
            else
              _currentOperatorInfo = new OperatorInfo(); // Оператор не найден
          }
        }
      }
      catch (Exception ex)
      {
        log.Error($"Ошибка при заргрузке операторов, {ex.Message}");
        ShowMessage("Ошибка при загрузке списка операторов", false);
      }
    }

    public void LoadOperatorList(DropDownList ddListOperator, string sFilter)
    {
      LoadOperatorList(ddListOperator, "ID", "Name", sFilter);
    }

    public void SelectOperatorInList(DropDownList ddListOperator, OperatorInfo operatorInfo)
    {
      if (operatorInfo == null)
        return;

      if (operatorInfo.idSheduleOperator != _currentOperatorInfo.idSheduleOperator)
      {
        ListItem item = ddListOperator.Items.FindByValue(operatorInfo.ID.ToString());

        if (item != null)
        {
          ddListOperator.ClearSelection();
          item.Selected        = true;
          _currentOperatorInfo = operatorInfo;
        }
      }
    }

    public static DBConfig LoadDBSettings()
    {
      SqlCommand command = new SqlCommand();
      try
      {
        log.Info("Загрузка опций базы данных");
        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();

          command = new SqlCommand("", conn);

          // Префикс штрихкода транспортной пирамиды
          command.CommandText = "select d_string from Config where Name = 'BarCodePrefixPyramid'";
          string sBarCodePrefixPyramid = SafeConvert.ToString(command.ExecuteScalar()).ToLower();

          // Префикс внутрицеховой пирамиды
          command.CommandText = "select d_string from Config where Name = 'BarCodePrefixGlassProcessingPyramid'";
          string sBarCodePrefixGlassProcessingPyramid = SafeConvert.ToString(command.ExecuteScalar()).ToLower();

          // Префикс оператора сканирования
          command.CommandText = "select d_string from Config where Name = 'BarCodePrefixOperator'";
          string sBarCodePrefixOperator = SafeConvert.ToString(command.ExecuteScalar(), "OPER").ToLower();

          // Префикс отгрузки
          command.CommandText = "select d_string from Config where Name = 'BarCodePrefixShip'";
          string sBarCodePrefixShip = SafeConvert.ToString(command.ExecuteScalar(), "SH").ToLower();

          // Длина штрих-кода отгрузки
          command.CommandText = "select d_string from Config where Name = 'BarCodeSHLeng'";
          int nBarCodeSHLeng = SafeConvert.ToInt(command.ExecuteScalar(), 10);

          // Использовать документ _T("Задание в производство")
          command.CommandText = "select d_iNum from Config where Name = 'bUseTaskToManuf'";
          bool bUseTaskToManuf = SafeConvert.ToBool(command.ExecuteScalar());

          // Выставлять статус отгружен при сканировании ШК
          command.CommandText = "select d_iNum from Config where Name = 'bSetDelivBarCodeAndTask'";
          bool bSetDelivStatus = SafeConvert.ToBool(command.ExecuteScalar());

          log.Info($@"Префикс штрихкода транспортной пирамиды: {sBarCodePrefixPyramid}
                      Префикс внутрицеховой пирамиды         : {sBarCodePrefixGlassProcessingPyramid} 
                      Префикс оператора сканирования         : {sBarCodePrefixOperator}");

          return new DBConfig(sBarCodePrefixPyramid, sBarCodePrefixGlassProcessingPyramid, sBarCodePrefixOperator, sBarCodePrefixShip, nBarCodeSHLeng, bUseTaskToManuf, bSetDelivStatus);
        }        
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
        return new DBConfig();
      }
      finally
      {
        command.Dispose();
      }
    }

    // Всплывающее информационное окно блокирующее интерфейс
    public void Alert(string message)
    {
      string script = $"alert('{message}');";
      ClientScript.RegisterStartupScript(this.GetType(), "Alert", script, true);
    }

    public void FocusNextTextBox()
    {
      string script = "document.addEventListener('DOMContentLoaded', function() { focusNextTextBox(); });";
      ClientScript.RegisterStartupScript(this.GetType(), "CallFocusNextTextBoxFunction", script, true);
    }

    public void FocusGlassTextBox(string pyramidBarCode)
    {
      string script = $"document.addEventListener('DOMContentLoaded', function() {{ focusGlassTextBox('{pyramidBarCode}'); }});";
      ClientScript.RegisterStartupScript(this.GetType(), "CallFocusGlassTextBox", script, true);
    }

    // Всплывающее окно не блокирующее интерфейс
    public void ShowMessage(string message, bool isSuccess = false)
    {
      string script = $@"
        document.addEventListener('DOMContentLoaded', function() {{
            ShowMessage('{message}', {isSuccess.ToString().ToLower()});
        }});
    ";
      ClientScript.RegisterStartupScript(GetType(), "CallShowMessage", script, true);
    }

    public void ShowRemakeModal()
    {
      ClientScript.RegisterStartupScript(GetType(), "ShowRemakeModal", "ShowRemakeModal()", true);
    }

  }
}