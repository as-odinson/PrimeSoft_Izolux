using NoPaper.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Utils;

namespace NoPaper
{
  public partial class ScanHistory : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    public class ScanHistoryItem
    {
      public string DateScan { get; set; }
      public string OperatorName{ get; set; }
      public string BarCode { get; set; }
      public int TypeBarCode { get; set; }
      public string TypeName { get; set; }
      public string Message { get; set; }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object GetHistory(string dateFrom, string dateTo, int type)
    {
      List<ScanHistoryItem> items = new List<ScanHistoryItem>();

      using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
      {
        conn.Open();

        string sql =
        @"select top 500
            DateScan,
            Operator.Name as OperatorName,
            ScanHistory.BarCode,
            Type,
            Message
          from ScanHistory
          left join Operator on ScanHistory.idOperator = Operator.ID
          where
            (@dateFrom = '' or cast(DateScan as date) >= cast(@dateFrom as date))
            and
            (@dateTo = '' or cast(DateScan as date) <= cast(@dateTo as date))
            and
            (@type = -1 or Type = @type)
          order by ScanHistory.ID desc";

        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
          cmd.Parameters.AddWithValue("@dateFrom", dateFrom ?? "");
          cmd.Parameters.AddWithValue("@dateTo", dateTo ?? "");
          cmd.Parameters.AddWithValue("@type", type);

          using (SqlDataReader reader = cmd.ExecuteReader())
          {
            while (reader.Read())
            {
              int typeBarCode = Convert.ToInt32(reader["Type"]);

              items.Add(
                new ScanHistoryItem()
                {
                  DateScan = SafeConvert.ToDateTime(reader["DateScan"], DateTime.Now).ToString("dd.MM.yyyy HH:mm:ss"),
                  OperatorName = reader["OperatorName"].ToString(),
                  BarCode = reader["BarCode"].ToString(),
                  TypeBarCode = typeBarCode,
                  TypeName = GetTypeName(typeBarCode),
                  Message = reader["Message"].ToString()
                }
              );
            }
          }
        }
      }

      return items;
    }

    private static string GetTypeName(int type)
    {
      switch (type)
      {
        case 1:
        return "Оператор";

        case 2:
        return "Пирамида";

        case 3:
        return "СП";

        case 4:
        return "Отгрузка";

        default:
        return "Неизвестно";
      }
    }
  }
}
