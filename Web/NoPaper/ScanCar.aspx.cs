using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.Services;
using System.Data;
using System.Web.Script.Services;
using Newtonsoft.Json;
using NoPaper.Models;
using System.Configuration;
using System.Web.UI.WebControls;
using Utils;
using log4net;

namespace NoPaper
{
// Сканирование выезда машин
  public partial class ScanCar : PageModel
  {
    private static readonly ILog log = LogManager.GetLogger(typeof(workplace));


    private static int    m_idOperator              = 0,  // ID Оператора
                          m_idTripTransport         = 0,  // ID Машины
                          m_BarCodeShipLength       = 0;  // Длина штрихкода
    private static string m_sBarCodePrefixOperator  = ""; // Префикс штрихкода оператора
    public  static string m_sBarCodePrefixShip      = ""; // Префикс штрихкода отгрузки

    protected void Page_Load(object sender, EventArgs e)
    {
      if (!IsPostBack)
      {
        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();
          // Инициализируем операторов с ключем как idSheduleOperator
          LoadOperatorList(Operator);

          // Префикс оператора сканирования
          if (m_sBarCodePrefixOperator == "")
          {
            SqlCommand command = new SqlCommand("select d_string from Config where Name = 'BarCodePrefixOperator'", conn);
            m_sBarCodePrefixOperator = command.ExecuteScalar().ToString().ToLower();
          }

          LoadConfig();
        }
      }

      // Устанавливаем оператора
      if (m_idOperator != 0)
        Operator.SelectedValue = m_idOperator.ToString();
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object PostBarCode(string barcode, int idOperator)
    {
      // bError, Message, Type
      Tuple<bool, string, int> result = new Tuple< bool, string, int >(false, "", (int)ETypeBarCode.e_type_unknow);

      try
      {
        m_idOperator = idOperator;

        if (barcode.Length == 0)
          result = new Tuple<bool, string, int>(false, "Требуется ввести отгрзку", (int)ETypeBarCode.e_type_unknow);


        if (String.IsNullOrEmpty(m_sBarCodePrefixShip))
          LoadConfig();

        string operBarCodePrefix = barcode.Substring(0, m_sBarCodePrefixOperator.Length).ToLower();
        bool   bScanShip         = barcode.Substring(0, m_sBarCodePrefixShip.Length).ToLower() == m_sBarCodePrefixShip.ToLower(); // Баркод отгрузки

        if (operBarCodePrefix == m_sBarCodePrefixOperator && barcode.Length > 0)
          result = SetOperator(barcode);
        else if (bScanShip)
          result = WriteBarCodeShip(barcode); // Сканирована отгрузка


        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();

          SqlCommand cmd = new SqlCommand(
            @"insert into ScanHistory
            (
              idOperator,
              BarCode,
              Type,
              Message
            )
            values
            (
              @idOperator,
              @barCode,
              @TypeBarcode,
              @message
            )", 
          conn);

          cmd.Parameters.AddWithValue("@idOperator", idOperator);
          cmd.Parameters.AddWithValue("@barCode", barcode);
          cmd.Parameters.AddWithValue("@TypeBarcode", (int)result.Item3);
          cmd.Parameters.AddWithValue("@message", result.Item2);

          cmd.ExecuteNonQuery();
        }
        return new
        {
          message         = result.Item2,
          idOperator      = m_idOperator,
          Type            = result.Item3,
          bHasError       = result.Item1
        };
      }
      catch (Exception ex)
      {
        return new Tuple<bool, string, int>(false, ex.Message, (int)ETypeBarCode.e_type_unknow);
      }
    }

    // Устанавливаем оператора
    [WebMethod]
    private static Tuple<bool, string, int> SetOperator(string barcode)
    {
      try
      {
        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();
          string query = $"select ID from Operator where BarCode = @barcodeText";
          SqlCommand sqlCommand = new SqlCommand(query, conn);
          sqlCommand.Parameters.AddWithValue("@barcodeText", barcode);

          object result = sqlCommand.ExecuteScalar();

          if (result != null)
          {
            m_idOperator = Convert.ToInt32(result);
            return new Tuple<bool, string, int>(false, $"Отсканирован оператор: {barcode}", (int)ETypeBarCode.e_type_oper);
          }
          else
            return new Tuple<bool, string, int>(true, $"Отсканирован не найден: {barcode}", (int)ETypeBarCode.e_type_oper);
        }
      }
      catch (Exception ex)
      {
        return new Tuple<bool, string, int>(true, ex.Message, (int)ETypeBarCode.e_type_oper);
      }
    }

    [WebMethod]
    public static Tuple<bool, string, int> WriteBarCodeShip(string barcodeText)
    {
      try
      {
        log.Info($"Команда [Скан.Отгрузки]: {barcodeText}");

        if (m_BarCodeShipLength > 0 && barcodeText.Length != m_BarCodeShipLength)
        {
          log.Error($"Команда [Скан.Отгрузки] неизвестный штрихкод: {barcodeText}");
          return new Tuple<bool, string, int>(false, $"Команда [Скан.Отгрузки] неизвестный штрихкод: {barcodeText}", (int)ETypeBarCode.e_type_ship);
        }

        Tuple<bool, string, int> response = AddShipment(barcodeText);

        return response;

      }
      catch (Exception ex)
      {
        return new Tuple<bool, string, int>(true, ex.Message, (int)ETypeBarCode.e_type_unknow);
      }
    }

<<<<<<< Updated upstream
=======
    [WebMethod]
    public static Tuple<bool, string, int> WriteTransportPyramid(string barcodeText)
    {
      try
      {
        log.Info($"Сканирование возврата транспортной пирамиды: {barcodeText}");

        int idPyramidOut = 0;

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();
          string commandText = $@"select
                                     max(PO.ID) as idPyramidOut
                                  from PyramidCompleted PC
                                  inner join PyramidOut PO on PO.ID                = PC.idPyramidOut
                                  left  join BarCode B     on B.idPyramidCompleted = PC.ID
                                  where PO.Barcode = @barcode";

          using (SqlCommand command = new SqlCommand(commandText, conn))
          {
            command.Parameters.AddWithValue("@barcode", barcodeText);

            using (SqlDataReader reader = command.ExecuteReader())
            {
              if (reader.Read())
              {
                idPyramidOut = SafeConvert.ToInt(reader["idPyramidOut"]);
              }
            }
          }

          if (idPyramidOut != 0)
          {
            SQLHelper.ExecuteCommand($"update PyramidOut set bReturned = 1, DateReturn = GetDate() where ID = {idPyramidOut}", conn);
          }

          return new Tuple<bool, string, int>(false, $"Возврат пирамиды {barcodeText}", (int)ETypeBarCode.e_type_pyramid);
        }
      }
      catch
      {
        log.Error($"Ошибка при возврате пирамиды {barcodeText}");
        return new Tuple<bool, string, int>(true, $"Ошибка при возврате пирамиды {barcodeText}", (int)ETypeBarCode.e_type_pyramid);
      }
    }

>>>>>>> Stashed changes
    // Сканирование отгрузки.
    public static Tuple<bool, string, int> AddShipment(string barcode)
    {
      try
      {
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();

          string sShipID = barcode.ToLower().Replace(m_sBarCodePrefixShip.ToLower(), "");
          long idShip = SafeConvert.ToInt(sShipID);

          if (idShip <= 0)
            return new Tuple<bool, string, int>(false, $"Неверный номер отгрузки: {barcode}", (int)ETypeBarCode.e_type_ship);


          using (SqlCommand command = new SqlCommand($"select ID, Num, IsNull(bLock, 0) as bLock, DateScan from Ship where ID = {idShip}", conn))
          {
            bool       bLock     = false;
            DateTime ? vDateScan = new DateTime();
            string     sShipNum;


            using (SqlDataReader reader = command.ExecuteReader())
            {
              ListItem listItem = new ListItem();

              if (reader.Read())
              {
                bLock = SafeConvert.ToBool(reader["bLock"]);
                vDateScan = SafeConvert.ToDateTime(reader["DateScan"], DateTime.MinValue);
                sShipNum = SafeConvert.ToString(reader["Num"]);
              }
              else
              {
                log.Error($"Отгрузка с номером '{idShip}' не найдена в базе данных.");
                return new Tuple<bool, string, int>(true, $"Отгрузка с номером '{idShip}' не найдена в базе данных.", (int)ETypeBarCode.e_type_ship);
              }
            }

            if (bLock)
            {
              log.Error($"ОШИБКА: Отгрузка (№{sShipNum}: {idShip}) уже была подтверждена.");
              return new Tuple<bool, string, int>(true, $"ОШИБКА: Отгрузка № ({sShipNum}: {idShip}) уже была подтверждена.", (int)ETypeBarCode.e_type_ship);
            }

            DateTime dNow = DateTime.Now;


            command.CommandText = $"update Ship set DateScan = '{dNow:yyyy-MM-ddTHH:mm:ss}', ShipBarCode = '{barcode}', bLock = 1 where ID = {idShip}";
            command.ExecuteNonQuery();


            command.CommandText = $"exec sp_SetNextNumCalcFactForTransportTaskInShip {idShip}";
            command.ExecuteNonQuery();
          }
        }

        return new Tuple<bool, string, int>(false, $"Комманда скан отгрузки прошла успешно", (int)ETypeBarCode.e_type_ship);
      }
      catch
      {
        return new Tuple<bool, string, int>(true, $"ОШИБКА", (int)ETypeBarCode.e_type_ship);
      }
    }



    public class ShipRule
    {
      public string prefix { get; set; }
      public int length { get; set; }
    }

    public static void LoadConfig()
    {
      string json = ConfigurationManager.AppSettings["ShipRules"];

      if (string.IsNullOrEmpty(json))
        return;

      var rules = JsonConvert.DeserializeObject<List<ShipRule>>(json);

      if (rules != null && rules.Count > 0)
      {
        var rule = rules[0]; 

        m_sBarCodePrefixShip = rule.prefix;
        m_BarCodeShipLength  = rule.length; // если ты реально хочешь length сюда
      }
    }

    private static Tuple<bool, string> WriteBarCode(string barcode)
    {
      try
      {
        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();
          string query = "select ID from TripTransport where barcode = @barcode";
          SqlCommand sqlCommand = new SqlCommand(query, conn);
          sqlCommand.Parameters.AddWithValue("@barcode", barcode);

          object result = sqlCommand.ExecuteScalar();

          if (result == null)
            return new Tuple<bool, string>(false, $"Штрих-код машины не найден: {barcode}");

          m_idTripTransport = Convert.ToInt32(result);
          AddScanTripTransport(m_idTripTransport, conn);

          return new Tuple<bool, string>(true, $"Отсканирован штрих-код машины: {barcode}");
        }
      }
      catch (Exception ex)
      {
        return new Tuple<bool, string>(false, ex.Message);
      }
    }

    /// <summary>
    /// Добавляет в таблицу отсканированных штрихкодов запись о машине
    /// </summary>
    /// <param name="idTripTransport">ID машины</param>
    /// <param name="conn">Открытое подключение</param>
    private static void AddScanTripTransport(int idTripTransport, SqlConnection conn)
    {
      string query = @"insert into ScanLog_TripTransport_BarCode (TimeScan,  idOperator,  idTripTransport)
                       select                                     getDate(), @idOperator, @idTripTransport";
      SqlCommand command = new SqlCommand(query, conn);
      command.Parameters.AddWithValue("@idOperator",      m_idOperator);
      command.Parameters.AddWithValue("@idTripTransport", idTripTransport);

      command.ExecuteNonQuery();
    }

    private static Tuple<bool, string> ScanShip(string barcode)
    {
      try
      {
        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();

          string query = $"select top 1 ID from Ship where TransportNumList like '%{barcode}%'";
          SqlCommand command = new SqlCommand(query, conn);

          object result = command.ExecuteScalar();

          if (result != null)
          {
            int idShip = Convert.ToInt32(result);

            command.CommandText = $"select idTask, idBarCode from v_PyramidForShip where idShip = {idShip} and TreeLevel = -1 and TableLevel != 1";

            List<int> arIdBarCodes = new List<int>();
            HashSet<int> arIdTasks = new HashSet<int>();

            using (SqlDataReader reader = command.ExecuteReader())
            {
              while (reader.Read())
              {
                int idTask    = reader.GetInt32(0);
                int idBarCode = reader.GetInt32(1);

                arIdBarCodes.Add(idBarCode);
                arIdTasks.Add(idTask);
              }
            }

            if (arIdBarCodes.Count == 0)
              return Tuple.Create(false, "Нет штрихкодов для отгрузки");

            string sWhere = $"where ID in ({string.Join(",", arIdBarCodes)})";
            command.CommandText = $"update BarCode set nState = IsNull(nState, 0) | 8 {sWhere}"; // Присвоить статус отгружен штрих-кодам
            command.ExecuteNonQuery();

            foreach (int idTask in arIdTasks)
            {
              command.CommandText = $"exec sp_UpdateTaskState {idTask}";
              command.ExecuteNonQuery();
            }

            return Tuple.Create(true, "Накладная отсканированна");
          }
          else throw new Exception("Ошибка сканирования накладной");
        }
      }
      catch (Exception ex)
      {
        return Tuple.Create(false, ex.Message);
      }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string GetScanLogs()
    {
      try
      {       
        using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
        {
          conn.Open();
          string query = $"select * from v_ScanLog_TripTransport_BarCode order by TimeScan desc";
          SqlCommand command = new SqlCommand(query, conn);
          

          DataTable table = new DataTable();
          using (SqlDataReader reader = command.ExecuteReader())
            table.Load(reader);

          return JsonConvert.SerializeObject(table);
        }
      }
      catch
      {
        return "[]";
      }
    }
  }
}

