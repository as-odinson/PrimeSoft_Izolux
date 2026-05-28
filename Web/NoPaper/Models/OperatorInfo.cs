using log4net;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using Utils;

namespace NoPaper.Models
{
  [Serializable]
  public class OperatorInfo
  {
    public int    ID    { get; private set; }
    public int?   idSectorManufact { get; private set; }
    public int    idSheduleOperator { get; set; }
    public int    idUser            { get; set; }
    public int    idDepName         { get; private set;}
    public string Name  { get; private set; }

    public bool bTeam { get; set; }
    public int idPersonnel { get; set; }

    private static readonly ILog log = LogManager.GetLogger(typeof(OperatorInfo));

    public OperatorInfo()
    {
      ID                = 0;
      idSectorManufact  = 0;
      idSheduleOperator = 0;
      idUser            = 0;
      idDepName         = 0;
      Name              = "";
      bTeam = false;
      idPersonnel = 0;
    }

    public OperatorInfo(int _ID) : base()
    {
      ID = _ID;
    }

    public OperatorInfo(int ID, string Name) : base()
    {
      this.ID = ID;
      this.Name = Name;
    }

    public OperatorInfo(int _ID, int _idSheduleOperator, int _idUser, int? _idSectorManufact, int _idDepName, string _Name)
    {
      ID                = _ID;
      idSheduleOperator = _idSheduleOperator;
      idSectorManufact  = _idSectorManufact;
      idUser            = _idUser;
      Name              = _Name;
      idDepName         = _idDepName;
    }

    public OperatorInfo(
      int _ID,
      int _idSheduleOperator,
      int _idUser,
      int? _idSectorManufact,
      int _idDepName,
      string _Name,
      bool bTeam,
      int idPersonnel) : this(_ID, _idSheduleOperator, _idUser, _idSectorManufact, _idDepName,  _Name) 
    {
      this.idPersonnel = idPersonnel;
      this.bTeam = bTeam;
    }


    /// <summary>
    /// Используем для создание нового записи в таблице SheduleOperator
    /// </summary>
    /// <param name="idOperator">id оператора</param>
    /// <returns>Возвращает новое значение idSheduleOperator</returns>
    public static int CreateSheduleOperator(SqlConnection conn, int idOperator)
    {
      try
      {
        log.Info($"Создание нового idSheduleOperator для оператора ID: {idOperator}");
        // Проверим может уже есть
        Tuple<OperatorInfo, bool> operatorInf = CheckOperatorInfoByPlanCalendar(conn, idOperator);

        if (operatorInf.Item1.idSheduleOperator != 0)
        {
          log.Info($"idSheuleOperator уже существует, idSheduleOperator: {operatorInf.Item1.idSheduleOperator}");
          return operatorInf.Item1.idSheduleOperator;
        }

        // текущий контекст бригады

        using (SqlCommand command = new SqlCommand("sp_CreateSheduleOperator", conn))
        {
          command.CommandType = CommandType.StoredProcedure;

          // входные параметры
          command.Parameters.AddWithValue("@idOperator", idOperator);
          command.Parameters.AddWithValue("@date", DateTime.Now);

          SqlParameter outParam = new SqlParameter("@idSheduleOperatorNew", SqlDbType.Int);
          outParam.Direction    = ParameterDirection.Output;
          command.Parameters.Add(outParam);

          command.ExecuteNonQuery();

          log.Info($"Создан новый idSheduleOperator: {SafeConvert.ToInt(outParam.Value)}");



          return SafeConvert.ToInt(outParam.Value);
        }
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
        return 0;
      }
    }

    public static void CreateShedulePersonnel(SqlConnection conn)
    {
      try
      {
        int idBrigadier = SafeConvert.ToInt(HttpContext.Current?.Session?["CurrentBrigadier"]);
        var currentGroupObj = HttpContext.Current?.Session?["CurrentOperatorGroup"];
        List<object> currentGroup = currentGroupObj as List<object>;

        if (currentGroup == null || currentGroup.Count == 0)
          return;

        // Проверяем/создаём SheduleOperator бригадира
        Tuple<OperatorInfo, bool> brigadierInfo = CheckOperatorInfoByPlanCalendar(conn, idBrigadier);

        int idSheduleOperator = brigadierInfo.Item1.idSheduleOperator;

        // если нет записи — создаём
        if (idSheduleOperator == 0)
        {
          using (SqlCommand command = new SqlCommand("sp_CreateSheduleOperator", conn))
          {
            command.CommandType = CommandType.StoredProcedure;

            command.Parameters.AddWithValue("@idOperator", idBrigadier);
            command.Parameters.AddWithValue("@date", DateTime.Now);

            SqlParameter outParam = new SqlParameter("@idSheduleOperatorNew", SqlDbType.Int);
            outParam.Direction = ParameterDirection.Output;

            command.Parameters.Add(outParam);
            command.ExecuteNonQuery();

            idSheduleOperator = SafeConvert.ToInt(outParam.Value);
          }
        }

        // защита от дублей
        string checkSql = $@"
             select count(*)
             from ShedulePersonnel
             where idSheduleOperator = {idSheduleOperator}
           ";

        using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
        {
          int count = SafeConvert.ToInt(checkCmd.ExecuteScalar());
          if (count > 1)
            return;
        }


        // заполняем ShedulePersonnel
        foreach (dynamic item in currentGroup)
        {
          int idPersonnel = SafeConvert.ToInt(item.idPersonnel);
          float coef = SafeConvert.ToFloat(item.coef);
          bool bTeam = SafeConvert.ToInt(item.ID) == idBrigadier;

          if (idPersonnel == 0)
            continue;

          string sqlcmd;

          if (bTeam)
          {
            sqlcmd = $@"
                update ShedulePersonnel
                set KTU = @coef
                where idSheduleOperator = @idSheduleOperator
                  and idPersonnel =  @idPersonnel
            ";
          }
          else
          {
            sqlcmd = $@"
            insert into ShedulePersonnel
            (
              idSheduleOperator,
              idPersonnel,
              KTU
            )
            values
            (
              @idSheduleOperator,
              @idPersonnel,
              @coef
            )
          ";
          }

          using (SqlCommand cmd = new SqlCommand(sqlcmd, conn))
          {
            cmd.Parameters.AddWithValue("@idSheduleOperator", idSheduleOperator);
            cmd.Parameters.AddWithValue("@idPersonnel", idPersonnel);
            cmd.Parameters.AddWithValue("@coef", coef);

            cmd.ExecuteNonQuery();
          }
        }
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
      }
    }

    // Посмотрим существует ли введеный оператор в таблице SheduleOperator
    public static Tuple<OperatorInfo, bool> CheckOperatorInfoByPlanCalendar(SqlConnection conn, int idOperator)
    {
      log.Info($"Проверка наличия оператора в текущем календаре планирования, idOperator: {idOperator}");
      try
      {
        string commandText = $@"select 
                                 O.ID, 
                                 O.Name,
                                 O.idSectorManufact,
                                 IsNull(SO.ID,    0) as idSheduleOperator,
                                 IsNull(O.idUser, 0) as idUser,
                                 IsNull(O.idDepName, 0) as idDepName
                               from Operator O
                               outer apply  
                               (
                                select top 1 ID
                                from SheduleOperator SO
                                where SO.idOperator = O.ID    and 
                                      SO.dtBegin <= getdate() and
                                      SO.dtEnd   >= getdate()
                               ) SO
                               where O.ID = {idOperator}
                               order by Name";

        using (SqlCommand command = new SqlCommand(commandText, conn))
          using (SqlDataReader reader = command.ExecuteReader())
            if (reader.Read())
            {
              OperatorInfo operatorInfo = new OperatorInfo
                                        (
                                          _ID:                SafeConvert.ToInt(reader["ID"]),
                                          _idSheduleOperator: SafeConvert.ToInt(reader["idSheduleOperator"]),
                                          _idUser:            SafeConvert.ToInt(reader["idUser"]),
                                          _idSectorManufact:  SafeConvert.ToNullableInt(reader["idSectorManufact"]),
                                          _idDepName:         SafeConvert.ToInt(reader["idDepName"]),
                                          _Name:              reader["Name"].ToString()
                                        );


              log.Info($"оператор найден idOperator: {operatorInfo.ID}, idSheduleOperator: {operatorInfo.idSheduleOperator}");
              return new Tuple<OperatorInfo, bool>(operatorInfo, true);
            }

        log.Warn($"Нет idSheduleOperator");
        return new Tuple<OperatorInfo, bool>(new OperatorInfo(idOperator), false);
      }
      catch (Exception ex)
      {
        log.Error(ex.Message);
        return new Tuple<OperatorInfo, bool>(new OperatorInfo(idOperator), false);
      }
    }
  }
}