using System;
using System.Linq;
using System.Web;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Services;
using System.Data;
using System.Web.Script.Services;
using Newtonsoft.Json;
using NoPaper.Controllers;
using NoPaper.Models;
using Utils;
using log4net;
using System.Web.Services.Description;

// Сканирование стеклопакетов

namespace NoPaper
{
  public partial class Scan1 : PageModel
  {
    private static SqlConnection _conn;

    private static readonly ILog log = LogManager.GetLogger(typeof(workplace));

    public static int m_idOperator         = 0,
                      m_idPyramidCompleted = 0,
                      m_PackNum            = 0,
                      m_PackPosNum         = 0,
                      SPID;

    public static int? g_lDepotSubDivisionToSaw = null;

    public static double m_dPyramidMaxWeight = 0.0,
                         m_dCurrentWeight    = 0.0;

    public static SectorManufactInfo m_sector;

    public static string m_sBarCodePrefixPyramid  = ""; // Префикс штрихкода транспортной пирамиды
    public static string m_sBarCodePrefixOperator = ""; // Префикс штрихкода оператора
    public static bool   m_bUseTaskToManuf,   // Использовать документ _T("Задание в производство")
                                              // Взято из Гласс где данное поле читается из реестра
                                              // true: необходимо вызывать sp_UpdateManufTaskState
                                              // false: необходимо вызывать sp_UpdateTaskState
                         m_bSetDelivStatus,
                         m_bWriteBarCodeDepot;// Создавать расход ГП

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object PostBarCode(string barcode, int idOperator, int idPyramidCompleted)
    {
      try
      {
        m_idOperator         = idOperator;
        m_idPyramidCompleted = idPyramidCompleted;
        
        Tuple<bool, string, int> result = CheckDefaultStateBarCode(barcode);
        if (!result.Item1) // Если не штрихкод не корректен
          return new
          {
            message            = result.Item2,
            idPyramidCompleted = m_idPyramidCompleted
          };

        // Проверим, если у нас префиксы пустые подгрузим их еще раз
        if (String.IsNullOrEmpty(m_sBarCodePrefixOperator) || String.IsNullOrEmpty(m_sBarCodePrefixPyramid))
          LoadDB();

        string operBarCodePrefix = barcode.Substring(0, m_sBarCodePrefixOperator.Length).ToLower(),
               barCodePrefix     = barcode.Substring(0, m_sBarCodePrefixPyramid.Length).ToLower();
        
        if (operBarCodePrefix == m_sBarCodePrefixOperator && barcode.Length > 0)
        {
          log.Info($"Префикс оператора введенный: {operBarCodePrefix}, Префикс оператора в базе: {m_sBarCodePrefixOperator}");
          result = SetOperator(barcode);                            // Сканирован оператор
        }  
        else if ( barCodePrefix == m_sBarCodePrefixPyramid && barcode.Length > 0)
        {
          log.Info($"Префикс пирамиды введенный: {barCodePrefix}, Префикс пирамиды в базе: {m_sBarCodePrefixPyramid}");
          result = WriteTransportPyramid(barcode);                  // Сканирована транспортная пирамида
        }
        else if ( barcode.Length > 0 && m_idPyramidCompleted != 0 )
          result = WriteBarCode(barcode);                           // Сканирован штрихкод
        else if (barcode.Length > 0 && m_idPyramidCompleted == 0 )
          result = new Tuple<bool, string, int>(false, $"Ошибка не отсканироваана пирамида", (int)ETypeBarCode.e_type_unknow);
        else
          result = new Tuple<bool, string, int>(false, $"Ошибка сканирования неизвестная команда: {barcode}", (int)ETypeBarCode.e_type_unknow);
        
        log.Info(result.Item2); // Логируем результат
        
        return new
        {
          message            = result.Item2,
          idPyramidCompleted = m_idPyramidCompleted,
          idOperator         = m_idOperator,
          typeBarCode        = result.Item3,
          currentMassIsBigger= m_dCurrentWeight > m_dPyramidMaxWeight,
          m_dPyramidMaxWeight,
          m_dCurrentWeight
        };
      }
      catch
      {
        Tuple<bool, string, int> result = new Tuple<bool, string, int>(false, $"Ошибка при сканировании команды: {barcode}", (int)ETypeBarCode.e_type_unknow);
        return new
        {
          message             = result.Item2,
          idPyramidCompleted  = m_idPyramidCompleted,
          idOperator          = m_idOperator,
          typeBarCode         = result.Item3,
          currentMassIsBigger = m_dCurrentWeight > m_dPyramidMaxWeight,
          m_dPyramidMaxWeight,
          m_dCurrentWeight
        };
      }
    }

    // Метод для получения префикса из базы или кеша
    private static string GetBarCodePrefixPyramid()
    {
      // Проверяем, есть ли значение в памяти приложения
      string prefix = HttpContext.Current.Application["BarCodePrefixPyramid"] as string;
      if (string.IsNullOrEmpty(prefix))
      {
        // Если значения нет, запрашиваем из базы и сохраняем в память приложения
        prefix = LoadDBPrefix().ToLower();
        HttpContext.Current.Application["BarCodePrefixPyramid"] = prefix;
      }
      return prefix;
    }

    public static Tuple<bool, string, int> CheckDefaultStateBarCode(string barcode)
    {
      // Не сканируем пустоту
      if (barcode.Length == 0)
        return new Tuple<bool, string, int>(false, "Требуется ввести команду", (int)ETypeBarCode.e_type_unknow);
      
      if (barcode.Length < m_sBarCodePrefixPyramid.Length)
        return new Tuple<bool, string, int>(false, $"Ошибка сканирования неизвестная команда: {barcode}", (int)ETypeBarCode.e_type_unknow);

      // Баркод прошел базовую проверку
      return new Tuple<bool, string, int>(true, "", (int)ETypeBarCode.e_type_unknow);
    }

    [WebMethod]
    public static Tuple<bool, string, int> SetOperator(string barcodeText)
    {
      try
      {
        log.Info($"Сканирование Оператора: {barcodeText}");
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();

          string query = $"select ID from Operator where BarCode = @barcodeText";
          SqlCommand sqlCommand = new SqlCommand(query, conn);
          sqlCommand.Parameters.AddWithValue("@barcodeText", barcodeText);

          object result = sqlCommand.ExecuteScalar();

          if (result != null)
          {
            m_idOperator = Convert.ToInt32(result);
            return new Tuple<bool, string, int>(true, $"Отсканирован оператор: {barcodeText}", (int)ETypeBarCode.e_type_oper);
          }
          else
            return new Tuple<bool, string, int>(false, $"Отсканирован не найден: {barcodeText}", (int)ETypeBarCode.e_type_oper);
        }
      }
      catch
      {
        log.Error($"Отсканирован не найден: {barcodeText}");
        return new Tuple<bool, string, int>(false, $"Отсканирован не найден: {barcodeText}", (int)ETypeBarCode.e_type_oper);
      }
    }


    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]

    public static object PostPyramidCompleteToShip(int idPyramidComplete)
    {
      try
      {
        int idShip = CreateNewShip();

        WritePyramidCompleteToShip(idShip, idPyramidComplete);

        int idPyramidCompletedNew = WriteNewPyramidCompletedByOldID(idPyramidComplete);

        return new
        {
          idPyramidCompleted = idPyramidCompletedNew,
          message            = "Пирамида очищена и добавлена на отгрузку"
        };
      }
      catch
      {
        return new
        {
          idPyramidCompleted = 0,
          message            = "Произошла ошибка при очистки пирамиды"
        };
      }
    }

    [WebMethod]
    public static int CreateNewShip()
    {
      int idShip = 0;
      try
      {
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();

          long  idCarrier = SQLHelper.GetIntFromSQL("select top 1 ID from Client where Type = 1 order by IsNull(bDef, 0) desc", conn);

          string commandText = $@"insert into Ship (Date, idCarrier) values (getdate(), {idCarrier})
                                  select scope_identity()";

          using (SqlCommand command = new SqlCommand(commandText, conn))
          {
            object result = command.ExecuteScalar();
                   idShip = SafeConvert.ToInt(result);
          }

        }

      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
      }

      return idShip;
    }

    // Очистить пирамиду путем добавления на отгрузку
    [WebMethod]
    public static void WritePyramidCompleteToShip(int idShip, int idPyramidComplete)
    {
      using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
      {
        conn.Open();
        string commandText = $"select * from dbo.f_GetPyramidCompletedClientList({idPyramidComplete}) order by Name";

        bool   hasRecord   = false;
        string GUID_Client = "";
        using (SqlCommand command = new SqlCommand(commandText, conn))
          using (SqlDataReader reader = command.ExecuteReader())
            if (reader.Read())
            {
              GUID_Client = SafeConvert.ToString(reader["GUID"]);
              hasRecord = true;
            }

        if (hasRecord)
        {
          // Пирамиду оставим у первого клиента
          commandText = $"update PyramidCompleted set guidClient = '{GUID_Client}' where ID = {idPyramidComplete}";

          using (SqlCommand command = new SqlCommand(commandText, conn))
            command.ExecuteNonQuery();
        }

        string clearCommand = $"delete from IDTempStore where SPID = {SPID} and nType = 5";
        SQLHelper.ExecuteCommand(clearCommand, conn);

        commandText = $@"insert into IDTempStore(ID, nType, SPID)   
                      select                     ID, 5,     {SPID}
                      from PyramidCompleted where ID = {idPyramidComplete}";
        SQLHelper.ExecuteCommand(commandText, conn);


        commandText = $"exec sp_AppendShip {idShip}, {SPID}, 0";
        SQLHelper.ExecuteCommand(commandText, conn);

        SQLHelper.ExecuteCommand(clearCommand, conn);
      }
    }

    [WebMethod]
    public static Tuple<bool, string, int> WriteTransportPyramid(string barcodeText)
    {
      try
      {
        log.Info($"Сканирование транспортной пирамиды: {barcodeText}");
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();
          SqlCommand command = new SqlCommand($@"select
                                                  max(PC.ID) as Value,
                                                  max(PO.MaxWeight) as MaxWeight
                                               from PyramidCompleted PC
                                               inner join PyramidOut PO on PO.ID                = PC.idPyramidOut
                                               left  join BarCode B     on B.idPyramidCompleted = PC.ID
                                               where PO.Barcode = '{barcodeText}' and IsNull(B.idTransport, 0) = 0", conn);
          
          using (SqlDataReader reader = command.ExecuteReader())
          {
            if (reader.Read())
            {
              m_idPyramidCompleted = SafeConvert.ToInt(reader["Value"]);
              m_dPyramidMaxWeight  = SafeConvert.ToDouble(reader["MaxWeight"]);
            }
            else
            {
              m_idPyramidCompleted = 0;
              m_dPyramidMaxWeight  = 0.0;
            }
          }


          if (m_idPyramidCompleted != 0)
          {
            command.CommandText = $"update PyramidCompleted set TimePyramid = GetDate() where ID = {m_idPyramidCompleted}";
            command.ExecuteNonQuery();

            command.CommandText = $@"select
                                       B2.PackNum,
                                       max(B2.PackPosNum) as PackPosNum
                                     from BarCode B1
                                       inner join BarCode B2 on B2.idPyramidCompleted = B1.idPyramidCompleted 
                                     where B1.idPyramidCompleted = {m_idPyramidCompleted}
                                     group by
                                       B2.PackNum
                                     having B2.PackNum = MAX(B1.PackNum)";
            SqlDataReader reader = command.ExecuteReader();
            if (reader.Read())
            {
              m_PackNum = reader.GetInt32(reader.GetOrdinal("PackNum"));
              m_PackPosNum = reader.GetInt32(reader.GetOrdinal("PackPosNum"));
            }
            reader.Close();
          }
          else
          {
            command.CommandText = $"select ID as Value, MaxWeight from PyramidOut where BarCode = '{barcodeText}'";
            int idPyramidOut = 0;
            
            using (SqlDataReader reader = command.ExecuteReader())
            {
              if (reader.Read())
              {
                idPyramidOut        = SafeConvert.ToInt   (reader["Value"]);
                m_dPyramidMaxWeight = SafeConvert.ToDouble(reader["MaxWeight"]);
              }
            }

            // Добавим новую пирамиду если не нашли запись
            if (idPyramidOut == 0)
            {
              string sGUID = Guid.NewGuid().ToString();
              command.CommandText = $@"insert into PyramidOut ( BarCode , GUID,  bReturned  )
                                       output inserted.ID
                                       values                ( @BarCode, @GUID, @bReturned )";

              command.Parameters.AddWithValue("@BarCode", barcodeText);
              command.Parameters.AddWithValue("@GUID", sGUID);
              command.Parameters.AddWithValue("@bReturned", true);

              idPyramidOut = Convert.ToInt32(command.ExecuteScalar());
            }

            command.CommandText = $@"update PyramidOut
                                       set 
                                         bReturned = 1,  
                                         DateReturn = getdate(), 
                                         bHide = 0
                                     where ID = {idPyramidOut}";
            command.ExecuteNonQuery();

            command.CommandText = $@"insert into PyramidCompleted(idPyramidOut, TimePyramid)
                                       output inserted.ID
                                       select ID, GetDate() from PyramidOut where PyramidOut.Barcode = '{barcodeText}'";
            m_idPyramidCompleted = Convert.ToInt32(command.ExecuteScalar());
          }

          return new Tuple<bool, string, int>(true, $"Сканированная пирамида {barcodeText}", (int)ETypeBarCode.e_type_pyramid);
        }
      }
      catch
      {
        log.Error($"Ошибка при санировании пирамиды {barcodeText}");
        return new Tuple<bool, string, int>(false, $"Ошибка при санировании пирамиды {barcodeText}", (int)ETypeBarCode.e_type_pyramid);
      }
    }


    [WebMethod]
    public static int WriteNewPyramidCompletedByOldID(int idPyramidCompleted)
    {
      try
      {
        if (idPyramidCompleted == 0)
        {
          log.Error("Ошибка idPyramidCompleted = 0");
          return 0;
        }

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();

          string commandText = $@"select
                                      max(PO.ID) as Value,
                                      max(PO.MaxWeight) as MaxWeight
                                   from PyramidCompleted PC
                                   inner join PyramidOut PO on PO.ID                = PC.idPyramidOut
                                   left  join BarCode B     on B.idPyramidCompleted = PC.ID
                                   where PC.ID = {idPyramidCompleted}";

          int idPyramidOut = 0;

          using (SqlCommand command = new SqlCommand(commandText, conn)) 
          using (SqlDataReader reader = command.ExecuteReader())
          {
            if (reader.Read())
            {
              idPyramidOut        = SafeConvert.ToInt(reader["Value"]);
              m_dPyramidMaxWeight = SafeConvert.ToDouble(reader["MaxWeight"]);
            }
          }

          if (idPyramidOut == 0)
          {
            log.Error("Ошибка idPyramidOut = 0");
            return 0;
          }


          commandText = $@"update PyramidOut
                             set 
                               bReturned = 1,  
                               DateReturn = getdate(), 
                               bHide = 0
                           where ID = {idPyramidOut}";

          using (SqlCommand command = new SqlCommand(commandText , conn))        
            command.ExecuteNonQuery();


          commandText = $@"insert into PyramidCompleted(idPyramidOut,   TimePyramid)
                           output inserted.ID
                           values                      ({idPyramidOut}, getdate())";

          object res;

          using (SqlCommand command = new SqlCommand(commandText, conn))
          {
            res = command.ExecuteScalar();
            m_idPyramidCompleted = SafeConvert.ToInt(res);
          }

          return SafeConvert.ToInt(res);
        }
      }
      catch
      {
        log.Error($"Ошибка при создании idPyramidComplete");
        return 0;
      }
    }

    /* Тестовая серверная кнопка
    protected void ServerButton_Click(object sender, EventArgs e)
    {
      try
      {
        string result = "Нет данных";

        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();
          string query = "select top 1 ID from Task";

          using (SqlCommand cmd = new SqlCommand(query, conn))
          {
            object id = cmd.ExecuteScalar();
            if (id != null)
              result = $"Результат серверной кнопки: ID оператора: {id}";
          }
        }

        ResultLabel.Text = result;
        ShowMessage(result, true);
      }
      catch
      {
        ShowMessage("Ошибка", false);
      }
    }
    */

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object GetTaskId()
    {
      try
      {
        string result = "Нет данных";
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();
          string query = "select top 1 ID from Task";

          using (SqlCommand cmd = new SqlCommand(query, conn))
          {
            object id = cmd.ExecuteScalar();
            if (id != null)
              result = $"ID оператора: {id}";
          }
        }

        // Возвращаем объект с результатами
        return new { success = true, message = result };
      }
      catch
      {
        return new { success = false, message = "Ошибка метода" };
      }
    }

    [WebMethod]

    // Добавим штрихкод СП в транспортную пирамиду
    public static Tuple<bool, string, int> WriteBarCode(string barcodeText)
    {
      SqlCommand command = new SqlCommand();
      try
      {
        int  idBarCode     = 0,
             idTransport   = 0,
             idPyramidCompleted = 0;
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();
          command = new SqlCommand($@"select   
                                        B.ID,
                                        IsNull(B.idPyramidCompleted, 0) as idPyramidCompleted,
                                        IsNull(B.idTransport, 0)        as idTransport, 
                                        BS.PackNum,
                                        Sum(P.Weight) as Weight
                                      from BarCode B  
                                      left join BarCode_Scan BS on BS.idBarCode = B.ID 
                                      left join GlassDetails GD on GD.idBarCode = B.ID
                                      left join Product      P  on GD.idGlass   = P.ID
                                      where B.BarCode = @barcode
                                      group by
                                        B.ID,
                                        IsNull(B.idPyramidCompleted, 0),
                                        IsNull(B.idTransport, 0),
                                        BS.PackNum", conn);

          command.Parameters.Add("@barcode", SqlDbType.NVarChar).Value = barcodeText;
          SqlDataReader reader = command.ExecuteReader();

          if (reader.Read())
          {
            idBarCode          = SafeConvert.ToInt(reader["ID"]);
            idTransport        = SafeConvert.ToInt(reader["idTransport"]);
            idPyramidCompleted = SafeConvert.ToInt(reader["idPyramidCompleted"]);
            m_dCurrentWeight  += SafeConvert.ToDouble(reader["Weight"]);
          }
          reader.Close();

          if (idBarCode == 0)
            return new Tuple<bool, string, int>(false, $"Неизвестный штрихкод: {barcodeText}", (int)ETypeBarCode.e_type_unknow);

          if (idTransport != 0)
            return new Tuple<bool, string, int>(false, $"Штрихкод отгружен!", (int)ETypeBarCode.e_type_unknow);

          if (m_idPyramidCompleted == 0)
            return new Tuple<bool, string, int>(false, "Транспортная пирамида не введена или не известна", (int)ETypeBarCode.e_type_unknow);

          int iState = 128; // Статус изготовлен

          // устанавливать статус отгружен?
          if (m_bSetDelivStatus)
            iState |= 8;

          command.CommandText = $@"update BarCode 
                                   set   
                                     nState = IsNull(nState, 0) | {iState},
                                     idPyramidCompleted = {m_idPyramidCompleted},
                                     TimeScan   = getdate(),
                                     PackNum    = {m_PackNum},
                                     PackPosNum = {m_PackPosNum},
                                     idOperator = {m_idOperator}
                                   where
                                     ID = {idBarCode} and idTransport is NULL";
          command.ExecuteNonQuery();

          command.CommandText = $@"update BarCode set nState = (nState | 65536 | {iState}) ^ 65536, idPyramidCompleted = {m_idPyramidCompleted}, idOperator = {m_idOperator} where ID = {idBarCode}";
          command.ExecuteNonQuery();


          // Закрыть транспортную пирамиду, на которой установлен этот баркод:
          command.CommandText = $@"exec sp_CloseTripPyramidByIdBarCode {idBarCode}";
          command.ExecuteNonQuery();

          // СП переставили
          if (m_idPyramidCompleted != idPyramidCompleted)
          {
            command.CommandText = $@"delete from ScanLog_BarCode
                                   where idBarCode = {idBarCode} and idPyramidCompleted = {idPyramidCompleted}";
            command.ExecuteNonQuery();
          }

          if (m_idPyramidCompleted != 0)
          {
            // Добавить в таблицу
            command.CommandText = $@"if exists (select 1 from ScanLog_BarCode where idBarCode = {idBarCode} )
                                     begin
                                         update ScanLog_BarCode
                                         set 
                                             idPyramidCompleted = {m_idPyramidCompleted},
                                             idOperator         = {m_idOperator},
                                             TimeScan           = getdate()
                                         where idBarCode = {idBarCode}
                                     end
                                     else
                                     begin
                                         insert into ScanLog_BarCode ( TimeScan,  idBarCode,   idOperator,      idPyramidCompleted    )
                                         values                      ( getdate(), {idBarCode}, {m_idOperator}, {m_idPyramidCompleted} )
                                     end";
            command.ExecuteNonQuery();

            command.CommandText = $"select idTask from v_ScanLog_BarCode where idBarCode = {idBarCode}";
            int idTask =  SafeConvert.ToInt(command.ExecuteScalar());
            
            // установливаем статус заказу
            if (m_bUseTaskToManuf)
              command.CommandText = $"exec sp_UpdateManufTaskState {idTask} ";
            else
              command.CommandText = $"exec sp_UpdateTaskState {idTask}";

            command.ExecuteNonQuery();

            m_sector = null;

            if (m_sector == null)
            {
              log.Error("Участок пустой");

              // Попробуем подгрузить
              SectorManufactController sectorManufactController = new SectorManufactController(conn, 16);
              m_sector = sectorManufactController.GetSectorManufactInfo.Count == 0
                       ? new SectorManufactInfo(0, 0, "")                   // Пустой участок если нет элементов
                       : sectorManufactController.GetSectorManufactInfo[0];
            }

            // Устанавливаем статус готовности
            if (m_sector.ID != 0)
            {
              log.Info($"Участок {m_sector.Name} установка готовности для шк {barcodeText}");
              OperatorInfo operatorInfo = OperatorInfo.CheckOperatorInfoByPlanCalendar(conn, m_idOperator).Item1;

              GlassDetailsOper oper = new GlassDetailsOper(operatorInfo, m_sector, "", idBarCode);

              GlassProcessingController glassProcessingController = new GlassProcessingController(conn);
              glassProcessingController.MakeOperSP(oper, true);
            }

            string sWriteToDepot = WriteToDepotGP(conn, barcodeText);
          }

          return m_idPyramidCompleted != idPyramidCompleted
            ? new Tuple<bool, string, int>(true, $"Команда [Перм.Скан.СП]: {barcodeText}", (int)ETypeBarCode.e_type_barcode)
            : new Tuple<bool, string, int>(true, $"Команда [Скан.СП]: {barcodeText}", (int)ETypeBarCode.e_type_barcode);
        }
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
        return new Tuple<bool, string, int>(false, ex.Message, (int)ETypeBarCode.e_type_unknow);
      }
      finally
      {
        command.Dispose();
      }
    }

    public static string WriteToDepotGP(SqlConnection conn, string barcode)
    {
      try
      {
        if (m_bWriteBarCodeDepot && m_idOperator > 0)
        {
          OperatorInfo operatorInfo = _operatorInfoList.FirstOrDefault(oper => oper.ID == m_idOperator) ?? new OperatorInfo();

          if (operatorInfo.idDepName == 0)
          {
            log.Info($"На оператора не назначен склад!");
            throw new Exception();
          }  

          string query = $"exec sp_DepPrj_Add_Prj_BarCode_IG NULL, @barcode, {operatorInfo.idDepName}";
          
          using (SqlCommand command = new SqlCommand(query, conn))
          {
            command.Parameters.AddWithValue("@barcode", barcode);
            command.ExecuteNonQuery();
          }
          log.Info($"Создан расход ГП, ШК: {barcode}, Склад ID: {operatorInfo.idDepName}");

          return "Создан расход ГП";
        }

        return "";
      }
      catch
      {
        log.Error("WriteToDepotGP: Возникла ошибка при создании расхода ГП");
        return "Не удалось создать расход ГП";
      }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
      log.Info("Начало загрузки страницы");
      if (!IsPostBack)
      {
        log.Info("Загрузка страницы через PostBack!");
        _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString);
        Session["DbConnection"] = _conn;
        _conn.Open();

        LoadDB();

        // Привязки нужно сделать в отдельном подключении, чтобы лишний раз не открывать, закрывать
        using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString))
        {
          conn.Open();
          // Инициализируем операторов с ключем как idSheduleOperator
          LoadOperatorList(Operator, " IsNull(bCanScanShipment, 0) = 1 ");

          // Узнаем id участка упаковка
          SectorManufactController sectorManufactController = new SectorManufactController(conn, 16);
          m_sector = sectorManufactController.GetSectorManufactInfo.Count == 0
                   ? new SectorManufactInfo(0, 0, "")                   // Пустой участок если нет элементов
                   : sectorManufactController.GetSectorManufactInfo[0];
        }

      }

      // Устанавливаем оператора
      if ( m_idOperator != 0 )
      {
        log.Info($"Выбран оператор с idOperator = {m_idOperator}");
        Operator.SelectedValue = m_idOperator.ToString();
      }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static string GetScanLogs()
    {
      if (m_idPyramidCompleted == 0)
        return "[]";

      using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
      {
        conn.Open();

        string commandText = $"select * from v_ScanLog_BarCode where idPyramidCompleted = {m_idPyramidCompleted} order by TimeScan desc";
        using (SqlCommand command = new SqlCommand(commandText, conn))
        {
          DataTable table = new DataTable();
          using (SqlDataReader reader = command.ExecuteReader())
            table.Load(reader);

          m_dCurrentWeight = 0.0; // обнуляем текущую массу

          foreach (DataRow row in table.Rows)
            m_dCurrentWeight += SafeConvert.ToDouble(row["weight"]);

          return JsonConvert.SerializeObject(table);
        }
      }
    }    

    public static void LoadDB()
    {
      DBConfig setting         = LoadDBSettings();
      m_sBarCodePrefixPyramid  = setting.sBarCodePrefixPyramid;
      m_sBarCodePrefixOperator = setting.sBarCodePrefixOperator;
      m_bUseTaskToManuf        = setting.bUseTaskToManuf;
      m_bSetDelivStatus        = setting.bSetDelivStatus;

      using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
      {
        conn.Open();

        using (SqlCommand command = new SqlCommand("", conn))
        {
          command.CommandText  = "select d_iNum from Config where Name = 'CreateComing'";
          m_bWriteBarCodeDepot = SafeConvert.ToBool(command.ExecuteScalar());
        }

        SPIDInfo sPIDInfo = new SPIDInfo();
        sPIDInfo.GetOrInitSPID(out SPID, conn);
      }
      
    }
    
    public static string LoadDBPrefix()
    {
      string prefix = HttpContext.Current.Application["BarCodePrefixPyramid"] as string;
      if (string.IsNullOrEmpty(prefix))
      { 
        SqlCommand command = new SqlCommand("select d_string from Config where Name = 'BarCodePrefixPyramid'", _conn);
        HttpContext.Current.Application["BarCodePrefixPyramid"] = prefix = command.ExecuteScalar().ToString().ToLower();
      }
      return prefix;
    }

    protected void Operator_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    private void ReconectConnection()
    {
      if (_conn != null)
      {
        _conn.Close();
        _conn.Dispose();
      }

      _conn = new SqlConnection(ConfigurationManager.ConnectionStrings["GlassConnectionString"].ConnectionString);
      _conn.Open();
    }

  }
}

