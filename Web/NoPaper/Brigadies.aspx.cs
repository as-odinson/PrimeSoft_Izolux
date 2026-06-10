using NoPaper.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Services;
using Utils;

namespace NoPaper
{
  public partial class Brigadies : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    // ==================
    // CONNECTION
    private static SqlConnection GetConn()
    {
      var conn = new SqlConnection(DbConfig.ConnectionString);
      conn.Open();
      return conn;
    }

    // =====================
    // ГРУППЫ (LEFT PANEL)

    [WebMethod]
    public static List<object> GetBrigadiers()
    {
      using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
      {
        conn.Open();

        DataTable dt = SQLHelper.GetDataTable(@"select ID, Name
                                                from Operator
                                                where bTeam = 1
                                                order by Name", conn);

        return dt.AsEnumerable()
            .Select(r => new
            {
              ID = SafeConvert.ToInt(r["ID"]),
              Name = r["Name"].ToString()
            }).ToList<object>();
      }
    }

    [WebMethod]
    public static List<object> GetGroups()
    {
      using (var conn = GetConn())
      {
        var dt = SQLHelper.GetDataTable(@"select 
                                            og.ID,
                                            og.Name,
                                            o.Name as BrigadierName
                                          from OperatorGroup og
                                          left join Operator o on o.ID = og.idOperatorBrigadier
                                          order by og.ID desc
                                        ", conn);

        return dt.AsEnumerable()
            .Select(r => new
            {
              ID = SafeConvert.ToInt(r["ID"]),
              Name = r["Name"].ToString(),
              BrigadierName = r["BrigadierName"] == DBNull.Value ? null : r["BrigadierName"].ToString()
            })
            .ToList<object>();
      }
    }

    [WebMethod]
    public static bool CreateGroup(string name, int brigadierId)
    {
      using (var conn = GetConn())
      {
        SQLHelper.ExecuteCommand(@"insert into OperatorGroup (Name, idOperatorBrigadier)
                                   values (@name, @brigadier)",
                                   conn,
                                   null,
                                   new SqlParameter("@name", name),
                                   new SqlParameter("@brigadier", brigadierId));
        return true;
      }
    }

    // =========================================
    // ДЕТАЛИ ГРУППЫ (RIGHT PANEL)
    [WebMethod]
    public static object GetGroupDetails(int groupId)
    {
      using (var conn = GetConn())
      {
        // MEMBERS
        var membersDt = SQLHelper.GetDataTable(@"select 
                                                   o.ID,
                                                   o.Name,
                                                   case when og.idOperatorBrigadier = o.ID then 1 else 0 end as IsBrigadier
                                                 from OperatorGroupItem gi
                                                 join Operator o on o.ID = gi.idOperator
                                                 join OperatorGroup og on og.ID = gi.idOperatorGroup
                                                 where gi.idOperatorGroup = @g
                                                 order by o.Name",
                                                 conn,
                                                 null,
                                                 new SqlParameter("@g", groupId));

        // AVAILABLE (NOT IN GROUP)
        var availableDt = SQLHelper.GetDataTable(@"select ID, Name
                                                     from Operator
                                                   where ID not in (
                                                       select idOperator
                                                       from OperatorGroupItem
                                                       where idOperatorGroup = @g
                                                   )
                                                   order by Name",
                                                   conn,
                                                   null,
                                                   new SqlParameter("@g", groupId));

        var members = membersDt.AsEnumerable()
                    .Select(r => new
                    {
                      ID = SafeConvert.ToInt(r["ID"]),
                      Name = r["Name"].ToString(),
                      IsBrigadier = SafeConvert.ToInt(r["IsBrigadier"]) == 1
                    })
                    .ToList();

        var available = availableDt.AsEnumerable()
                    .Select(r => new
                    {
                      ID = SafeConvert.ToInt(r["ID"]),
                      Name = r["Name"].ToString()
                    })
                    .ToList();

        return new
        {
          members,
          available
        };
      }
    }

    // ===============================================
    // Добавление операторов в группу

    [WebMethod]
    public static bool AddOperators(int groupId, int[] operators, float coef)
    {
      using (var conn = GetConn())
      {
        using (var tx = conn.BeginTransaction())
        {
          try
          {
            foreach (var op in operators)
            {
              SQLHelper.ExecuteCommand(@"insert into OperatorGroupItem
                                        (idOperatorGroup, idOperator, Coef)
                                        values (@g, @o, @c)",
                                        conn,
                                        tx,
                                        new SqlParameter("@g", groupId),
                                        new SqlParameter("@o", op),
                                        new SqlParameter("@c", coef));
            }

            tx.Commit();
            return true;
          }
          catch
          {
            tx.Rollback();
            throw;
          }
        }
      }
    }

    // ===========
    // удаление операторов из группы

    [WebMethod]
    public static bool DeleteOperators(int groupId, int[] operators)
    {
      using (var conn = GetConn())
      {
        using (var tx = conn.BeginTransaction())
        {
          try
          {
            foreach (var op in operators)
            {
              SQLHelper.ExecuteCommand(@"delete from OperatorGroupItem
                                         where idOperatorGroup = @g and idOperator = @o",
                                         conn,
                                         tx,
                                         new SqlParameter("@g", groupId),
                                         new SqlParameter("@o", op));
            }

            tx.Commit();
            return true;
          }
          catch
          {
            tx.Rollback();
            throw;
          }
        }
      }
    }

    // =================
    // Изменение
    [WebMethod]
    public static bool SetBrigadier(int groupId, int operatorId)
    {
      using (var conn = GetConn())
      {
        SQLHelper.ExecuteCommand(@"update OperatorGroup
                                   set idOperatorBrigadier = @o
                                   where ID = @g",
                                   conn,
                                   null,
                                   new SqlParameter("@o", operatorId),
                                   new SqlParameter("@g", groupId));

        return true;
      }
    }

    // ========================
    // Проверка оператор уже есть в группе

    [WebMethod]
    public static bool IsOperatorInGroup(int groupId, int operatorId)
    {
      using (var conn = GetConn())
      {
        int count = SQLHelper.GetIntFromSQL(@"select count(*)
                                              from OperatorGroupItem
                                              where idOperatorGroup = @g and idOperator = @o",
                                              conn,
                                              null,
                                              new SqlParameter("@g", groupId),
                                              new SqlParameter("@o", operatorId));

        return count > 0;
      }
    }
  }
}
