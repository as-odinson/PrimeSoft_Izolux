using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using NoPaper.Models;
using NoPaper.Helpers;
using NoPaper.Queries;
using System.Threading.Tasks;
using System.Linq;
using System.Configuration;
using System.Xml.Linq;
using AjaxControlToolkit;
using Utils;
using log4net;
using System.Collections;

namespace NoPaper.Controllers
{
  internal class GlassProcessingController : SPIDInfo
  {
    private SqlConnection      _conn;
    private List<SawTaskInfo>  _sawTasks;

    private static readonly ILog log = LogManager.GetLogger(typeof(GlassProcessingController));

    public GlassProcessingController(SqlConnection conn)
    {
      _conn = conn;
      _sawTasks = new List<SawTaskInfo>();
      InitializeSPID(_conn);
    }

    public GlassProcessingController(SqlConnection conn, string nameSawTask, SectorManufactInfo sector) : this(conn)
    {
      InitializeSawTaskInfo(nameSawTask, sector);
    }

    public GlassProcessingController(SqlConnection conn, SawTaskInfo sawTask) : this(conn)
    {
      _sawTasks.Add(sawTask);
    }

    public string GetSListIdSawTask()
    {
      // [ao]: Для ускорения работы в Авангард где много раскроев на которых есть не забранные пирамиды, выберем 5 элементов
      var  idValues = _sawTasks.Select(sawTask => sawTask.ID.ToString());

      return string.Join(",", idValues);
    }

    private void InitializeSawTaskInfo(string nameSawTask, SectorManufactInfo sector)
    {
      string      commandText = nameSawTask != ""
                              ? SawTaskMainData.GetDataByNameSawTask(nameSawTask)
                              : SawTaskMainData.GetAllReadyToTransportData(sector);
      SqlCommand  command     = new SqlCommand(commandText, _conn);
      int         nSawTask    = 0;

      using (SqlDataReader reader = command.ExecuteReader())
      {
        while(reader.Read())
        {
          _sawTasks.Add(new SawTaskInfo()
          {
            ID          = Convert.ToInt32(reader["ID"].ToString()),
            NameSawTask = reader["Name"].ToString()
          });

          // Гигансткие списки не создаём. Хватит и 50 последних раскроев.
          if ( nSawTask > 50 )
            break;
          nSawTask++;
        }

        // Проверим заполнился ли наш лист
        if (_sawTasks.Count == 0)
        {
          // Если был пустой создадим пока нулевой SawTask во избежании ошибки
          _sawTasks.Add(new SawTaskInfo()
          {
            ID          = 0,
            NameSawTask = ""
          });
        }
      }
    }
    private void UpdateIdGlassProcessingPyramid(int idSawTask, string sAddFilter = "")
    {
      string commandText = $@"update GP set                                                                         
                                GP.idGlassProcessingPyramid = GPP.ID                                                
                              from GlassDetails                     as GD                                           
                                   left join GlassProcessing        as GP  on GD.ID             = GP.idGlassDetails 
                                   left join GlassProcessingPyramid as GPP on GPP.idSawTaskMain = GD.idSawTaskMain  
                              where                                                                                 
                                GD.idSawTaskMain          = {idSawTask}              and                            
                                IsNull(GPP.idSawLimit, 0) = IsNull(GP.idSawLimit, 0) and                            
                                GPP.idPyramidA            = GD.idPiramid             and                            
                                GPP.ProcessingRoute       = GD.ProcessingRoute
                                {sAddFilter}";

      using (SqlCommand command = new SqlCommand(commandText, _conn))
        command.ExecuteNonQuery();
    }

    private void UpdateIdGlassProcessingPyramidPrev(int idSawTask, string sAddFilter = "")
    {
      string commandText = $@"select                                                          
                                idGlassDetails,                                               
                                ProcessingRoute,                                              
                                idSawTaskMain,                                                
                                idSectorManufact,                                             
                                idPiramid,                                                    
                                nOrderOper,                                                   
                                idGlassProcessingPyramid,                                     
                                idGlassProcessingPyramid_Prev                                 
                                from (                                                        
                                  select                                                      
                                    GP.idGlassDetails,                                        
                                    GD.ProcessingRoute,                                       
                                    GD.idSawTaskMain,                                         
                                    GD.idPiramid,                                             
                                    GP.idSectorManufact,                                      
                                    GP.nOrderOper,                                            
                                    GP.idGlassProcessingPyramid,                              
                                    GP.idGlassProcessingPyramid_Prev                          
                                  from GlassProcessing GP                                     
                                       inner join GlassDetails GD on GD.ID = GP.idGlassDetails
                                       where 1 = 1 {sAddFilter}
                                ) as innerQuery                                               
                              where idSawTaskMain = {idSawTask}                                     
                              order by                                                        
                                idPiramid,                                                    
                                idGlassDetails,                                               
                                nOrderOper";

      List <GlassProcessingInfo> dataList = new List<GlassProcessingInfo>();

      using (SqlCommand command = new SqlCommand(commandText, _conn))
      {
        using (SqlDataReader reader = command.ExecuteReader())
        {
          while (reader.Read())
          {
            GlassProcessingInfo glassProcessing = new GlassProcessingInfo
            (
              _idGlassDetails           : SafeConvert.ToInt(reader["idGlassDetails"]),
              _idGlassProcessingPyramid : SafeConvert.ToInt(reader["idGlassProcessingPyramid"]),
              _idSectorManufact         : SafeConvert.ToInt(reader["idSectorManufact"])
            );

            dataList.Add(glassProcessing);
          }
        }
      }

      // Обрабатываем данные и обновляем записи
      long idGlassDetailsPrev           = 0,
           idGlassProcessingPyramidPrev = 0,
           idGlassProccessingPrev       = 0,
           idSectorManufactFirst        = 0,
           idSectorManufactPrev         = 0;

      foreach (GlassProcessingInfo data in dataList)
      {
        if (data.IdGlassDetails != idGlassDetailsPrev)
        {
          idGlassDetailsPrev = data.IdGlassDetails;
          idGlassProcessingPyramidPrev = 0;
          idSectorManufactFirst = data.IdSectorManufact;
        }

        if (idSectorManufactPrev != data.IdSectorManufact)
          idGlassProcessingPyramidPrev = idGlassProccessingPrev != 0
                                       ? idGlassProccessingPrev
                                       : data.IdGlassProcessingPyramid;

        if (idSectorManufactFirst != data.IdSectorManufact)
        {
          string updateText = $@"update GlassProcessing
                                 set idGlassProcessingPyramid_Prev = {idGlassProcessingPyramidPrev}
                                 where idGlassProcessingPyramid    = {data.IdGlassProcessingPyramid}";

          using (SqlCommand updateCommand = new SqlCommand(updateText, _conn))
            updateCommand.ExecuteNonQuery();
        }

        idGlassProccessingPrev = data.IdGlassProcessingPyramid;
        idSectorManufactPrev = data.IdSectorManufact;
      }
    }

    private void PiramidParkingUpdateFields(DataRow newRow, DataRow sourceRow, long nParking, DateTime dateBegin)
    {
      int idEquipment = SafeConvert.ToInt(sourceRow["idEquipment"]),
          idSawLimit  = SafeConvert.ToInt(sourceRow["idSawLimit"]);


      if (idEquipment != 0 && idSawLimit == 0)
        throw new Exception($"Не создана запись в SawLimit для оборудования {idEquipment}");

      // Присовение значений полям
      newRow["idSawTaskMain"]   = SafeConvert.ToLong(sourceRow["idSawTaskMain"]);
      newRow["idPyramidA"]      = SafeConvert.ToLong(sourceRow["idPyramid"]);
      newRow["nPyramid"]        = SafeConvert.ToLong(sourceRow["nTypeOper"]);
      newRow["idSawLimit"]      = idSawLimit;
      newRow["idEquipment"]     = idEquipment;
      newRow["nPark"]           = nParking;
      newRow["TimeBegin"]       = dateBegin;

      newRow["ProcessingRoute"] = sourceRow["ProcessingRoute"].ToString();
    }

    public void PiramidParking(int idSawTask, string sAddFilter = "")
    {
      try
      {
        int    nParking           = 0;
        DateTime dateBeginPrev    = new DateTime(),
                 dateBeginCurrent = new DateTime();

        string commandText = $@"select 
                                 ProcessingRoute, 
                                 idSawTaskMain, 
                                 idSectorManuf, 
                                 idPyramid, 
                                 nTypeOper, 
                                 idSawLimit, 
                                 MIN(InnerQuery.DateBegin) over (partition by InnerQuery.ProcessingRoute, InnerQuery.Name) as DateBegin, 
                                 idEquipment, 
                                 TimeProcessing, 
                                 ParkCountBefore, 
                                 ParkCountAfter
                             from (
                                 select 
                                     GD.ProcessingRoute,
                                     GD.idSawTaskMain,
                                     Piramid.ID as idPyramid,
                                     SM.ID as idSectorManuf,
                                     SM.Name,
                                     MIN(GP.TimeBeginProcessing) as DateBegin,
                                     Piramid.nTypeOper,
                                     GP.idSawLimit,
                                     SL.idEquipment,
                                     SUM(GP.TimeProcessing) as TimeProcessing,
                                     E.ParkCountBefore,
                                     E.ParkCountAfter
                                 from GlassProcessing GP
                                 inner join GlassDetails GD on GD.ID = GP.idGlassDetails
                                 inner join SectorManufact SM on SM.ID = GP.idSectorManufact
                                 left join Piramid on GD.idPiramid = Piramid.ID
                                 left join SawLimit SL on SL.ID = GP.idSawLimit
                                 left join Equipment E on E.ID = SL.idEquipment
                                 where GD.idSawTaskMain = {idSawTask} {sAddFilter}
                                 group by GD.ProcessingRoute, SM.ID, SM.Name, GD.idSawTaskMain, Piramid.nTypeOper, Piramid.ID, GP.idSawLimit, SL.idEquipment, E.ParkCountBefore, E.ParkCountAfter
                             ) as InnerQuery
                             order by InnerQuery.ProcessingRoute, InnerQuery.idSectorManuf, idPyramid
      ";
        using (SqlCommand command = new SqlCommand(commandText, _conn))
        {
          using (SqlDataReader reader = command.ExecuteReader())
          {
            DataTable glassProcessingPyramidData = new DataTable();
            glassProcessingPyramidData.Load(reader);

            reader.Close();

            command.CommandText = $"select * from GlassProcessingPyramid where idSawTaskMain = {idSawTask}";

            using (SqlDataAdapter adapter = new SqlDataAdapter(command))
            {

              var parameters = new Dictionary<string, SqlParameter>
            {
                { "@idSawTaskMain",   CommandConfigurator.CreateParameter("@idSawTaskMain",   SqlDbType.Int,     "idSawTaskMain"  )},
                { "@idPyramidA",      CommandConfigurator.CreateParameter("@idPyramidA",      SqlDbType.Int,     "idPyramidA"     )},
                { "@nPyramid",        CommandConfigurator.CreateParameter("@nPyramid",        SqlDbType.Int,     "nPyramid"       )},
                { "@idSawLimit",      CommandConfigurator.CreateParameter("@idSawLimit",      SqlDbType.Int,     "idSawLimit"     )},
                { "@idEquipment",     CommandConfigurator.CreateParameter("@idEquipment",     SqlDbType.Int,     "idEquipment"    )},
                { "@nPark",           CommandConfigurator.CreateParameter("@nPark",           SqlDbType.Int,     "nPark"          )},
                { "@TimeBegin",       CommandConfigurator.CreateParameter("@TimeBegin",       SqlDbType.DateTime,"TimeBegin"      )},
                { "@ProcessingRoute", CommandConfigurator.CreateParameter("@ProcessingRoute", SqlDbType.VarChar, "ProcessingRoute")}
            };

              commandText = $@"insert into GlassProcessingPyramid
                                    (idSawTaskMain,   idPyramidA,  nPyramid,  idSawLimit,  idEquipment,  nPark,  TimeBegin, ProcessingRoute) 
                             values (@idSawTaskMain, @idPyramidA, @nPyramid, @idSawLimit, @idEquipment, @nPark, @TimeBegin, @ProcessingRoute)";

              // Присваиваем команду вставки адаптеру
              CommandConfigurator.ConfigureInsertCommand(adapter, commandText, parameters, _conn);

              using (DataSet dataSet = new DataSet())
              {
                adapter.Fill(dataSet);

                foreach (DataRow row in glassProcessingPyramidData.Rows)
                {
                  dateBeginCurrent = row["DateBegin"] != DBNull.Value
                                   ? Convert.ToDateTime(row["DateBegin"])
                                   : DateTime.Now;
                  if (dateBeginCurrent != dateBeginPrev)
                  {
                    dateBeginPrev = dateBeginCurrent;
                    nParking = 1;
                  }

                  DataRow newRow = dataSet.Tables[0].NewRow();
                  PiramidParkingUpdateFields(newRow, row, nParking++, dateBeginCurrent);
                  dataSet.Tables[0].Rows.Add(newRow);
                }

                adapter.Update(dataSet);
              }
            }
          }
        }
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
      }
      finally // Пробуем обновить idGlassProcessingPyramid несмотря на возможные проблемы парковки
      {
        UpdateIdGlassProcessingPyramid(idSawTask, sAddFilter);
        UpdateIdGlassProcessingPyramidPrev(idSawTask, sAddFilter);
      }
    }

    public void TryFillGlassProcessing(int idSawTask, Action<string, bool> showMessage)
    {
      try
      {
        if (ExecuteTransactionFillGlassProcessing(idSawTask)) // Вызов транзакции произошел успешно sp_FillGlassProcessing
          PiramidParking(idSawTask);
        else
          throw new Exception("Не удалось привязать штрихкод");
      }
      catch (Exception ex)
      {
        showMessage(ex.Message, false); // Выводим сообщение о том что бар кода нет
      }
    }

    public void TryFillGlassProcessingOnPyramid(int idSawTask, string sFilter)
    {
      try
      {
        log.Info("Попытка заполнить idGlassProcessingPyramid");

        if (ExecuteTransactionFillGlassProcessing(idSawTask)) // Вызов транзакции произошел успешно sp_FillGlassProcessing
          PiramidParking(idSawTask, sFilter);
        
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
      }
    }

    /*
     * Очистка / удаление GlassProcessing если нет правильной связки ProjectItemProcessing inner join GlassProcessing
     * Если есть, обновлениеы данных:
     * Заполнение таблицы GlassProcessing или переприсвоение правильных idGlassDetails, nOrderOper, nOrderGlobal если записи уже есть
     * Присвоение GlassDetails.ProcessingRoute:
    */
    private bool ExecuteTransactionFillGlassProcessing(int idSawTask)
    {
      SqlTransaction transaction = null;

      try
      {
        log.Info($"Запуск sp_FillGlassProcessing {idSawTask}, 0");

        transaction = _conn.BeginTransaction();

        string commandText = $"exec sp_FillGlassProcessing {idSawTask}, 0";
                                                                            // @bAddNew - обязательное удаление GlassProcessing
                                                                            // в данном случае не удаляем, обновляем

        using (SqlCommand command = new SqlCommand(commandText, _conn, transaction))
          command.ExecuteNonQuery();

        // Проверка на дубли
        commandText = @"
            with cte as (
                select 1 as duble
                from GlassProcessing
                where idSawTaskMain = @idSawTask
                group by idGlassDetails, idSectorManufact, idSawLimit, TimeProcessing
                having count(*) > 1
            )
            select top 1 duble from cte";

        using (SqlCommand checkCommand = new SqlCommand(commandText, _conn, transaction))
        {
          checkCommand.Parameters.AddWithValue("@idSawTask", idSawTask);
          object result = checkCommand.ExecuteScalar();

          if (result != null)
          {
            transaction.Rollback();
            return false;
          }

          transaction.Commit();
        }

        return true;
      }
      catch (Exception ex)
      {
        try
        {
          log.Error(ex.Message);
          transaction?.Rollback();
          return false;
        }
        catch (Exception exc)
        {
          log.Error($"Ошибка при откате транзакции, {exc.Message}");
          return false;
        }
      }
    }

    public bool MakeOper(GlassDetailsOper glassOper, int idScanPyramid)
    {
      SqlCommand command = new SqlCommand();
      try
      {
        log.Info($"Пометить деталь как готовую");

        if (glassOper.sIdGlassProcessingPyramidList == null)
        {
          // Вывод сообщения если операция вызвана со стороны сервера
          glassOper.showMessage?.Invoke("Не удалось выполнить операцию", false);
          return false;
        }

        int  glassCount       = 0,
             finishedCount    = 1;
        int? idPyramidBarCode = null;

        command = new SqlCommand($@"select 
                                                 count(*) as glassCount,
                                                 sum
                                                 (
                                                   case when bFinished = 1
                                                        then 1
                                                        else 0
                                                   end
                                                 ) as FinishedCount,
                                                 idPyramidBarCode
                                               from GlassProcessing GP
                                                 inner join GlassProcessingPyramid GPP on GP.idGlassProcessingPyramid = GPP.ID
                                                 inner join GlassDetails           GD  on GD.ID = GP.idGlassDetails
                                               where idGlassProcessingPyramid = {glassOper.sIdGlassProcessingPyramidList}
                                                     and GP.idSectorManufact     = {glassOper.sectorManufact.ID} 
                                               group by idPyramidBarCode",
                                            _conn);

        using (SqlDataReader reader = command.ExecuteReader())
        {
          if (reader.Read())
          {
            glassCount = Convert.ToInt32(reader["glassCount"].ToString());
            finishedCount += Convert.ToInt32(reader["FinishedCount"].ToString());
            idPyramidBarCode = SecureConvert.ToNullableInt(reader["idPyramidBarCode"].ToString());
          }
        }

        // Если последняя нужно проверить чтобы был штрих - код пирамады
        if (finishedCount == glassCount && idPyramidBarCode == null)
        {
          if (idScanPyramid == 0)
          {
            // Вывод сообщения если операция вызвана со стороны сервера
            log.Info("Штрих-код не помечен как готов, так как не назначена внутрицеховая пирамида");
            glassOper.showMessage?.Invoke("операция невозможна, отсутствует штрих код внутрицеховой пирамиды", false);
            return false;
          }
          command.CommandText = $"update GlassProcessingPyramid set idPyramidBarCode = {idScanPyramid} where ID = {glassOper.sIdGlassProcessingPyramidList}";
          command.ExecuteNonQuery();
        }

        // Сделать запись о бригадире и составе бриагд
        OperatorInfo.CreateShedulePersonnel(_conn);

        // Создадим SheduleOperator если значение отсутствует
        if (glassOper.operatorInfo.idSheduleOperator == 0)
        {
          log.Warn("Отсутвует idSheduleOperator, попытка создать");
          glassOper.operatorInfo.idSheduleOperator = OperatorInfo.CreateSheduleOperator(_conn, glassOper.operatorInfo.ID);
        }


        log.Info("Перед пометкой о готовности");
        command.CommandText = $@"update GlassProcessing set 
                                  TimeProcessingComplete = GetDate(),
                                  TimeMarkManufact       = GetDate(),
                                  bFinished              = 1,
                                  idSheduleOperator      = {glassOper.operatorInfo.idSheduleOperator}
                                where idGlassDetails = {glassOper.idGlassDetails} 
                                and idSectorManufact = {glassOper.sectorManufact.ID}";

        command.ExecuteNonQuery();


        log.Info("штризх-код помечен как готовый");
        // Если количество готовых изделий равно общему количеству изделий пирамиды, выполняем обновление
        if (finishedCount == glassCount)
        {
          log.Info("Все штрихкоды на пирамиде готовы, попытка установки для пирамиды времени готовности");
          command = new SqlCommand($@"update GlassProcessingPyramid set                                           
                                        ReadyDateTime = GetDate()                                                 
                                      where ID = {glassOper.sIdGlassProcessingPyramidList}",
                                   _conn);
          command.ExecuteNonQuery();

          log.Info("Успех");
        }
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
      }

      command.Dispose();
      return true;
    }

    // Помечаем в внутрецеховой логистике СП как готовый
    public void MakeOperSP(GlassDetailsOper glassOper, bool isBindToSector = false, int idScanPyramid = 0)
    {
      SqlCommand command = new SqlCommand();
      try
      {
        log.Info("Пометка штрихкода СП как готового");

        if (glassOper.sIdGlassProcessingPyramidList == null)
        {
          log.Error($"для idGlassDetails: {glassOper.idGlassDetails}, idBarCode: {glassOper.idBarCode} отсутствует значение idGlassProcessingPyramid");
          // Вывод сообщения если операция вызвана со стороны сервера
          glassOper.showMessage?.Invoke("Не удалось выполнить операцию", false);
          return;
        }

        // Сделать запись о бригадире и составе бриагд
        OperatorInfo.CreateShedulePersonnel(_conn);

        // Создадим если требуется
        if (glassOper.operatorInfo.idSheduleOperator == 0)
        {
          log.Warn("Отсутвует idSheduleOperator, попытка создать");
          glassOper.operatorInfo.idSheduleOperator = OperatorInfo.CreateSheduleOperator(_conn, glassOper.operatorInfo.ID);
        }

        log.Info("Перед пометкой о готовности");
        string commandText = $@"update GlassProcessing set 
                               TimeProcessingComplete = GetDate(),
                               TimeMarkManufact       = GetDate(),
                               bFinished              = 1,
                               idSheduleOperator      = {glassOper.operatorInfo.idSheduleOperator}
                             from GlassProcessing                                                         
                               inner join GlassDetails on GlassProcessing.idGlassDetails = GlassDetails.ID  
                             where idBarCode in ({glassOper.idBarCode})";

        log.Info("штризх-код помечен как готовый");

        commandText += isBindToSector ? $"and idSectorManufact = {glassOper.sectorManufact.ID}" : "";

        command = new SqlCommand(commandText, _conn);
        command.ExecuteNonQuery();

        // Если провели сканирование на этапе сборки, тогда выставим внутрицеховую пирамиду
        if (idScanPyramid != 0)
        {
          command.CommandText = $"update GlassProcessingPyramid set idPyramidBarCode = {idScanPyramid} where ID = {glassOper.sIdGlassProcessingPyramidList}";
          command.ExecuteNonQuery();
        }
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
      }
      finally
      {
        command.Dispose();
      }
    }

    /// <summary>
    /// Проверяем чтобы idGlassProcessingPyramid на пирамиде idPiramid и участке idSectorManufact были одинаковыми
    /// </summary>
    /// <param name="idPyramid">ID пирамиды на которой располагаются детали</param>
    /// <param name="idSectorManufact">Участок на котором нужно проверить пирамиду</param>
    /// <returns>
    /// true:  успех, idGlassProcessingPyramid одинаковый для каждой записи
    /// false: провал, idGlassProcessingPyramid отличается хотябы у одной записи
    /// </returns>
    public bool CheckGlassProcessingPyramidOnPyramid(int idSawTaskMain, int idPyramid, int idSectorManufact)
    {
      try
      {
        string query = $@"select distinct
                            idGlassProcessingPyramid, 
                            idGlassProcessingPyramid_Prev
                          from GlassProcessing GP
                          inner join GlassDetails GD on GD.ID = GP.idGlassDetails
                          where IsNull(GP.idSawTaskMain, GD.idSawTaskMain) = {idSawTaskMain} and idPiramid = {idPyramid} and idSectorManufact = {idSectorManufact}";
        using (SqlCommand command = new SqlCommand(query, _conn))
        {
          int rowCount = 0; // Количество уникальных записей
          using(SqlDataReader reader = command.ExecuteReader())
            while (reader.Read())
              rowCount++;

          if (rowCount > 1)
            return false;
        }
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
        return false;
      }

      return true;
    }

    private void RebuildGlassProcessingPyramidOnPyramid()
    {

    }

    public bool MakePyramid(OperatorInfo operatorInfo, string sIdGlassProcessingPyramidList, int idPyramid, int scanIDPyramid, SectorManufactInfo sector)
    {
      SqlCommand command = new SqlCommand();
      try
      {
        log.Info($"Помечаем готовность пирамиды");

        // Проверяем, передана ли строка с idGlassProcessingPyramid
        if (string.IsNullOrEmpty(sIdGlassProcessingPyramidList))
        {
          log.Error($"Отсутствует idGlassProcessingPyramid для пирамиды {idPyramid}");
          return false;
        }

        // 1. Проверим чтобы idGlassProcessingPyramid у всех позиций текущей пирамиды был одинаковым
        //if (!CheckGlassProcessingPyramidOnPyramid(idPyramid, sector.ID))
        //  RebuildGlassProcessingPyramidOnPyramid();

        // Проверяем введен ли штрих код у данной пирамиды
        command = new SqlCommand($"select ID, idPyramidBarCode from GlassProcessingPyramid where ID in ({sIdGlassProcessingPyramidList})", _conn);

        List<int>    idGlassProcessingPyramidList = new List<int>();
        List<object> results                      = new List<object>();

        using (SqlDataReader reader = command.ExecuteReader())
        {
          while (reader.Read())
          {
            int    idGlassProcessingPyramid = (int)reader["ID"];
            object result                   = reader["idPyramidBarCode"];

            idGlassProcessingPyramidList.Add(idGlassProcessingPyramid);
            results.Add(result);
          }
        }

        // Сделать запись о бригадире и составе бриагд
        OperatorInfo.CreateShedulePersonnel(_conn);

        for (int i = 0; i < idGlassProcessingPyramidList.Count; i++)
        {
          int    idGlassProcessingPyramid = idGlassProcessingPyramidList[i];
          object result                   = results[i];

          // Если и результат запроса (idPyramidBarCode) и отсканированный штрих-код пирамиды равны 0, то ничего не делаем
          if ((result == null || result == DBNull.Value) && scanIDPyramid == 0)
            return false;

          // Если отсканирован штрих-код пирамиды, и в базе пусто или 0, то обновляем idPyramidBarCode
          if ((result == null || result == DBNull.Value) && scanIDPyramid != 0)
          {
            command.CommandText = $"update GlassProcessingPyramid set idPyramidBarCode = {scanIDPyramid} where ID = {idGlassProcessingPyramid}";
            command.ExecuteNonQuery();
          }

          if (operatorInfo.idSheduleOperator == 0)
          {
            log.Warn("Отсутвует idSheduleOperator, попытка создать");
            operatorInfo.idSheduleOperator = OperatorInfo.CreateSheduleOperator(_conn, operatorInfo.ID);
          }


          log.Info($"Выставляем готовность пирамиды idGlassProcessingPyramid: {idGlassProcessingPyramid}, idPyramid: {idPyramid}, участок {sector.Name}");
          command.CommandText = $@"update GlassProcessing set 
                                   TimeProcessingComplete = GetDate(),
                                   TimeMarkManufact       = GetDate(),
                                   bFinished              = 1, 
                                   idSheduleOperator      = {operatorInfo.idSheduleOperator}                             
                                 from GlassProcessing                                                         
                                      inner join GlassDetails on GlassProcessing.idGlassDetails = GlassDetails.ID  
                                 where GlassProcessing.idGlassProcessingPyramid = {idGlassProcessingPyramid} 
                                       and GlassDetails.idPiramid   = {idPyramid}
                                       and GlassProcessing.idSectorManufact = {sector.ID}";
          command.ExecuteNonQuery();


          log.Info("Устанавливаем время готовности");
          // Установка времени готовности
          command.CommandText = $@"update GlassProcessingPyramid set                                           
                                   ReadyDateTime = GetDate()                                                 
                                 where ID = {idGlassProcessingPyramid}";
          command.ExecuteNonQuery();
        }

        return true;
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
        return false;
      }
      finally
      {
        command.Dispose();
      }
    }

    public void WritePyramidBarCode(int? idGlassProcessingPyramid, string pyramidBarCode)
    {
      SqlCommand  command = new SqlCommand($@"update GlassProcessingPyramid set
                                                idPyramidBarCode = (select ID from PyramidBarCode where BarCode = '{pyramidBarCode}') 
                                              where ID = {idGlassProcessingPyramid}", 
                                           _conn);
      try
      {
        command.ExecuteNonQuery();
      }
      finally
      {
        command.Dispose();
      }
    }
     
    public void WritePyramidBarCode(string sIdGlassProcessingPyramidList, string pyramidBarCode)
    {
      if (String.IsNullOrEmpty(sIdGlassProcessingPyramidList))
        return;

      SqlCommand  command = new SqlCommand($@"update GlassProcessingPyramid set
                                                idPyramidBarCode = (select ID from PyramidBarCode where BarCode = @PyramidBarCode) 
                                              where ID in ({sIdGlassProcessingPyramidList})", 
                                            _conn);

      command.Parameters.AddWithValue("@PyramidBarCode", pyramidBarCode);

      try
      {
        command.ExecuteNonQuery();
      }
      catch
      {

      }
      finally
      {
        command.Dispose();
      }
    }

    public void TookPiramid(int idGlassProcessingPyramid)
    {
      SqlCommand command = new SqlCommand($@"update GlassProcessingPyramid set 
                                               ReceiveDateTime = GetDate()
                                             from GlassProcessingPyramid 
                                             where ID = {idGlassProcessingPyramid}", 
                                          _conn);
      command.ExecuteNonQuery();
      command.Dispose();
    }

    public bool CheckBarCode(string pyramidBarCode, Action<string, bool> showMessage, Action focusNextTextBox, Action<string> focusGlassTextBox, GlassDetailsOper glassDetailsOper)
    {
      if (pyramidBarCode == "")
        return false;

      bool       hasRecord  = false;
      SqlCommand sqlCommand = new SqlCommand($@"select top 1
                                                  1 as hasBarCode
                                                from PyramidBarCode
                                                where BarCode = '{pyramidBarCode}'", 
                                             _conn);

      using (SqlDataReader reader = sqlCommand.ExecuteReader())
        hasRecord = reader.Read() ? true : false;  // Проверяем что это бар код пирамиды

      // Если нет записей то возможно это бар код Детали
      if (!hasRecord)                              
      {
        sqlCommand = new SqlCommand($@"select
                                         idGlassDetails,
                                         BarCode
                                       from v_SawTaskGlassProcessing
                                       where BarCode_Glass    = '{pyramidBarCode}'
                                             and   idSectorManufact =  {glassDetailsOper.sectorManufact.ID} ", 
                                    _conn);

        using (SqlDataReader reader = sqlCommand.ExecuteReader())
        {
          if (!reader.Read())
          {
            showMessage("Операция не возможна, не известный штрих код", false); // Выводим сообщение о том что бар кода нет
            return false;
          }
          glassDetailsOper.idGlassDetails = Convert.ToInt32(reader["idGlassDetails"].ToString());
        }

        if (glassDetailsOper.sectorManufact.nType == 2)
          MakeOperSP(glassDetailsOper);
        else
          MakeOper(glassDetailsOper, 0);

        focusGlassTextBox(pyramidBarCode); // Иначе делаем фокус и вставляем текст в значение TextBox изделия который находится в шапке
        return false;
      }
      else                   
        focusNextTextBox();  // Если бар код найден переходим на следующий TextBox пирамиды

      return true;
    }

    public void MakeTempTable(SectorManufactInfo sector)
    {
      string filter      = sector.nType != 2
                         ? $"idSawTaskMain in ({GetSListIdSawTask()})"
                         : $"idSawTaskMain_Assembly in ({GetSListIdSawTask()})",
             commandText = GlobalTempData.MakeData(_SPID, filter);
      
      log.Debug($"Создание временой таблицы: \r\n {commandText}");

      using (SqlCommand command = new SqlCommand(commandText, _conn))
        command.ExecuteNonQuery();

      if (sector.nType == 2)
      {
        string checkSQL = $"select top 1 1 from ##TempGlassProcessing{_SPID} where {filter}";
        using (SqlCommand command = new SqlCommand(checkSQL, _conn))
        {
          var res = command.ExecuteScalar();

          if (res == null)
            throw new InvalidOperationException("Сборка не назначена, дайте команду \"Переместить сборку в этот раскрой\"");
        }
      }
    }

    public SawTaskInfo GetSawTask()
    {
      return _sawTasks[0];
    }

    /// <summary>
    /// Получает таблицу операций на основе заданных параметров.
    /// </summary>
    /// <param name="sector">Информация об участке.</param>
    /// <param name="sWhereAdd">Доп условие. Для сборочного участка используется для получения стекл. Или для вывода пирамиды которую забрали на предыдущем участке
    /// которые будут использованны на сборке. Если null тогда это не сборка.
    /// </param>
    /// <param name="idEquipment">Идентификатор оборудования.</param>
    /// <param name="sortExpression">Выражение для сортировки данных в таблице.</param>
    /// <returns>Возвращает таблицу данных, содержащую операции.</returns>
    public DataTable GetTableOper(SectorManufactInfo sector, string sWhereAdd, Equipment equipment, string sortExpression)
    {
      // Загрузка всех деталей у которых bFinished != 1
      string     query           = "",
                 sListIdSawTask  = GetSListIdSawTask(),
                 sEquipmentWhere = "";

      if (equipment.typeEquipment == TypeEquipment.e_assembly)
        sEquipmentWhere = equipment.ID != 0 ? $"and temp.idAssemblyLine = {equipment.ID}" : "";
      else
        sEquipmentWhere = equipment.ID != 0 ? $"and E.ID = {equipment.ID}" : "";

      query = sector.nType == 2 
            ? AssemblyData. GetData(sListIdSawTask, sector.ID, _SPID, sWhereAdd, sEquipmentWhere, sortExpression)
            : TableOperData.GetData(sListIdSawTask, sector,    _SPID, sWhereAdd, sEquipmentWhere, sortExpression);

      log.Debug($"Создание таблицы: \r\n {query}");

      using (SqlCommand command = new SqlCommand(query, _conn))
      {
        command.CommandText = query;
        using (SqlDataAdapter adapter = new SqlDataAdapter(command))
        {
          DataSet dataSet = new DataSet();
          adapter.Fill(dataSet);
          return dataSet.Tables[0];
        }
      }
    }

    public DataTable GetTableOperReady(Equipment equipment, string sWhereAdd = "")
    {
      //string sEquipmentWhere = idEquipment != 0 ? $"and E.ID = {idEquipment}" : "";

      // Загрузка только пирамид готовых к перемещению
      using (SqlCommand command = new SqlCommand(TableOperReadyData.GetData(GetSListIdSawTask(), _SPID, sWhereAdd), _conn))
      {

        log.Debug($"Создание готовности пирамид: \r\n {command.CommandText}");
        using (SqlDataAdapter adapter = new SqlDataAdapter(command))
        {
          DataSet dataSet = new DataSet();
          adapter.Fill(dataSet);
          return dataSet.Tables[0];
        }
      }

    }
  }
}
