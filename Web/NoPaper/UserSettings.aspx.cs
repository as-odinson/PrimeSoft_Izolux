using NoPaper.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using Utils;

public partial class UserSettings : System.Web.UI.Page
{
  public class PermissionDef
  {
    public string Name;
    public string Title;
    public string Group;
  }

  public class ItemDto
  {
    public int ID;
    public string Name;
    public string SubText;
    public int? idUserGroup;
    public bool bUseGroupPermission;
  }

  public class InitDto
  {
    public List<ItemDto> Users;
    public List<ItemDto> Groups;
    public List<PermissionDef> Permissions;
  }

  public class DetailDto
  {
    public int ID;
    public string Name;
    public string ManagerName;
    public string Post;
    public string Tel;
    public string Commentary;
    public int? idUserGroup;
    public bool bUseGroupPermission;
    public Dictionary<string, bool> Permissions;
  }

  private static readonly PermissionDef[] PermissionList =
  {
    new PermissionDef { Name = "TypeOrder0", Title = "Показ заказов типа 0", Group = "Видимость" },
    new PermissionDef { Name = "TypeOrder1", Title = "Показ заказов типа 1", Group = "Видимость" },
    new PermissionDef { Name = "TypeOrder2", Title = "Показ заказов типа 2", Group = "Видимость" },

    new PermissionDef { Name = "bTaskAdd", Title = "Добавление заказов", Group = "Заказы" },
    new PermissionDef { Name = "bTaskDelete", Title = "Удаление заказов", Group = "Заказы" },
    new PermissionDef { Name = "bTaskProcessedDelete", Title = "Удаление обработанных заказов", Group = "Заказы" },
    new PermissionDef { Name = "bTaskReopen", Title = "Открытие заказа, открытого другим пользователем", Group = "Заказы" },
    new PermissionDef { Name = "bPositionEdit", Title = "Редактирование позиций", Group = "Заказы" },
    new PermissionDef { Name = "bTaskPlan", Title = "Планирование заказов", Group = "Заказы" },
    new PermissionDef { Name = "bDateManufactEdit", Title = "Перенос на другую дату", Group = "Заказы" },
    new PermissionDef { Name = "bTaskReady", Title = "Отметка об изготовлении", Group = "Заказы" },

    new PermissionDef { Name = "bToSaw", Title = "Добавление в раскрой", Group = "Раскрой" },
    new PermissionDef { Name = "bExportGPS", Title = "Экспорт GPS.opt", Group = "Раскрой" },
    new PermissionDef { Name = "bRecalcTimeGlassProcSaw", Title = "Пересчёт времени обработки в раскроях", Group = "Раскрой" },

    new PermissionDef { Name = "bUserEdit", Title = "Управление пользователями", Group = "Администрирование" },
    new PermissionDef { Name = "bOptionsEdit", Title = "Настройки программы", Group = "Администрирование" },
    new PermissionDef { Name = "bSecurity", Title = "Опции безопасности", Group = "Администрирование" },

    new PermissionDef { Name = "bLockedTaskEdit", Title = "Редактирование заблокированных заказов", Group = "Ограничения" },
    new PermissionDef { Name = "bShippedTaskEdit", Title = "Редактирование отгруженных заказов", Group = "Ограничения" },
    new PermissionDef { Name = "bAllowEditPaidTaskProperty", Title = "Изменение свойств оплаченного заказа", Group = "Ограничения" },

    new PermissionDef { Name = "bShipLock", Title = "Блокировка отгрузки", Group = "Отгрузка" },
    new PermissionDef { Name = "bShipUnlock", Title = "Разблокировка отгрузки", Group = "Отгрузка" },

    new PermissionDef { Name = "bWagesEdit", Title = "Редактирование настроек ЗП", Group = "Производство" },
    new PermissionDef { Name = "bSetProcessComplete", Title = "Заполнение готовности этапов", Group = "Производство" },
    new PermissionDef { Name = "bClearProcessComplete", Title = "Удаление готовности этапов", Group = "Производство" },
    new PermissionDef { Name = "bSetFactReject", Title = "Установка фактического брака", Group = "Производство" },

    new PermissionDef { Name = "bViewAnotherTask", Title = "Просмотр чужих заказов", Group = "Доступ" },
    new PermissionDef { Name = "bShowAnotherTask", Title = "Отображать чужие заказы", Group = "Доступ" },
    new PermissionDef { Name = "bCanSavePlot", Title = "Сохранять чертёж", Group = "Доступ" }
  };

  [WebMethod]
  public static InitDto GetInitialData()
  {
    return new InitDto
    {
      Users = GetUsers(),
      Groups = GetGroups(),
      Permissions = new List<PermissionDef>(PermissionList)
    };
  }

  [WebMethod]
  public static DetailDto GetUser(int id)
  {
    string sql = @"
      select *
      from Users
      where ID = @id";

    return LoadDetail(sql, id, false);
  }

  [WebMethod]
  public static DetailDto GetGroup(int id)
  {
    string sql = @"
      select
        G.ID,
        G.Name,
        null as ManagerName,
        null as Post,
        null as Tel,
        G.Commentary,
        null as idUserGroup,
        cast(0 as bit) as bUseGroupPermission,
        P.*
      from UserGroups G
      left join UserGroupPermission P on P.idUserGroup = G.ID
      where G.ID = @id";

    return LoadDetail(sql, id, true);
  }

  private static List<ItemDto> GetUsers()
  {
    var res = new List<ItemDto>();

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
      select ID, Name, ManagerName, Post, idUserGroup, bUseGroupPermission
      from Users
      order by Name", conn))
    {
      conn.Open();

      using (var reader = cmd.ExecuteReader())
      {
        while (reader.Read())
        {
          res.Add(new ItemDto
          {
            ID = SafeConvert.ToInt(reader["ID"]),
            Name = SafeConvert.ToString(reader["Name"]),
            SubText = SafeConvert.ToString(reader["ManagerName"]),
            idUserGroup = SafeConvert.ToInt(reader["idUserGroup"]),
            bUseGroupPermission = SafeConvert.ToBool(reader["bUseGroupPermission"])
          });
        }
      }
    }

    return res;
  }

  private static List<ItemDto> GetGroups()
  {
    List<ItemDto> res = new List<ItemDto>();

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
      select ID, Name, Commentary
      from UserGroups
      order by Name", conn))
    {
      conn.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
        {
          res.Add(new ItemDto
          {
            ID = SafeConvert.ToInt(reader["ID"]),
            Name = SafeConvert.ToString(reader["Name"]),
            SubText = SafeConvert.ToString(reader["Commentary"])
          });
        }
      }
    }

    return res;
  }

  private static DetailDto LoadDetail(string sql, int id, bool isGroup)
  {
    using (var conn = new SqlConnection(DbConfig.ConnectionString))
    using (var cmd = new SqlCommand(sql, conn))
    {
      cmd.Parameters.AddWithValue("@id", id);
      conn.Open();

      using (var reader = cmd.ExecuteReader())
      {
        if (!reader.Read())
          return null;

        var dto = new DetailDto
        {
          ID = SafeConvert.ToInt(reader["ID"]),
          Name = SafeConvert.ToString(reader["Name"]),
          ManagerName = SafeConvert.ToString(reader["ManagerName"]),
          Post = SafeConvert.ToString(reader["Post"]),
          Tel = SafeConvert.ToString(reader["Tel"]),
          Commentary = SafeConvert.ToString(reader["Commentary"]),
          idUserGroup = SafeConvert.ToInt(reader["idUserGroup"]) ,
          bUseGroupPermission = SafeConvert.ToBool(reader["bUseGroupPermission"]),
          Permissions = new Dictionary<string, bool>()
        };

        foreach (var p in PermissionList)
          dto.Permissions[p.Name] = SafeConvert.ToBool(reader[p.Name]);

        return dto;
      }
    }
  }
}