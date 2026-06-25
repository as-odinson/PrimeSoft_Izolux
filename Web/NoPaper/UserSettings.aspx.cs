using NoPaper.Models;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Web.Services;
using Utils;

public partial class UserSettings : System.Web.UI.Page
{
  private const string OWNER_USER  = "user";
  private const string OWNER_GROUP = "group";
  private class ReportAccessStorage
  {
    public string TableName;
    public string OwnerField;
    public string ReportField;
    public bool HasGrantColumn;
  }

  private class ColumnAccessStorage
  {
    public string TableName;
    public string OwnerField;
    public string ColumnField;
  }

  private static readonly Dictionary<int, string> ReportGroups = new Dictionary<int, string>
  {
    { 1,  "Список Заказов" },
    { 2,  "Отгрузка" },
    { 3,  "План" },
    { 4,  "Заказ" },
    { 5,  "Упаковка" },
    { 6,  "Задание в Производство" },
    { 8,  "Раскрой" },
    { 9,  "Разбор формул" },
    { 10, "Склад" },
    { 11, "Контекстное меню" },
    { 12, "Коммерческое Предложение" }
  };

  private class CatalogueAccessStorage
  {
    public string TableName;
    public string OwnerField;
  }


  private static readonly PermissionDef[] PermissionList =
  {
    new PermissionDef { Name = "TypeOrder0", Title = "Показ заказов с статусом (Б)", Group = "Видимость" },
    new PermissionDef { Name = "TypeOrder1", Title = "Показ заказов с статусом (Ч)", Group = "Видимость" },
    new PermissionDef { Name = "TypeOrder2", Title = "Показ заказов с статусом (ОБ)", Group = "Видимость" },

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

  // INIT
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

  // Пользователи и группы
  [WebMethod]
  public static DetailDto GetUser(int id)
  {
    return LoadDetail(BuildUserDetailSql(), id);
  }

  [WebMethod]
  public static DetailDto GetGroup(int id)
  {
    return LoadDetail(BuildGroupDetailSql(), id);
  }

  [WebMethod]
  public static void SaveUser(DetailDto dto)
  {
    ValidateUser(dto);

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    {
      conn.Open();

      using (SqlTransaction tr = conn.BeginTransaction())
      {
        try
        {
          SaveUserBase(conn, tr, dto);

          if (dto.idUserGroup.HasValue)
            ApplyGroupTemplatesToUser(conn, tr, dto.ID, dto.idUserGroup.Value);
          else
            UpdatePermissions(conn, tr, "Users", "ID", dto.ID, dto.Permissions);

          tr.Commit();
        }
        catch
        {
          tr.Rollback();
          throw;
        }
      }
    }
  }

  [WebMethod]
  public static void SaveGroup(DetailDto dto)
  {
    ValidateGroup(dto);

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    {
      conn.Open();

      using (SqlTransaction tr = conn.BeginTransaction())
      {
        try
        {
          SaveGroupBase(conn, tr, dto);
          EnsureGroupPermissionRow(conn, tr, dto.ID);
          UpdatePermissions(conn, tr, "UserGroupPermission", "idUserGroup", dto.ID, dto.Permissions);
          ApplyGroupPermissionsToUsers(conn, tr, dto.ID);

          tr.Commit();
        }
        catch
        {
          tr.Rollback();
          throw;
        }
      }
    }
  }

  [WebMethod]
  public static int CreateGroup(string name, string commentary)
  {
    if (string.IsNullOrWhiteSpace(name))
      throw new Exception("Введите название группы.");

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    {
      conn.Open();

      using (SqlTransaction tr = conn.BeginTransaction())
      {
        try
        {
          int idGroup;

          using (SqlCommand cmd = new SqlCommand(@"
            insert into UserGroups(Name, Commentary)
            values(@Name, @Commentary)

            select cast(scope_identity() as int)", conn, tr))
          {
            cmd.Parameters.AddWithValue("@Name", name.Trim());
            cmd.Parameters.AddWithValue("@Commentary", NullIfEmpty(commentary));

            idGroup = Convert.ToInt32(cmd.ExecuteScalar());
          }

          EnsureGroupPermissionRow(conn, tr, idGroup);

          tr.Commit();
          return idGroup;
        }
        catch
        {
          tr.Rollback();
          throw;
        }
      }
    }
  }

  [WebMethod]
  public static void DeleteGroup(int id)
  {
    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    {
      conn.Open();

      using (SqlTransaction tr = conn.BeginTransaction())
      {
        try
        {
          EnsureGroupCanBeDeleted(conn, tr, id);

          DeleteGroupReportAccess(conn, tr, id);
          DeleteGroupPermissions(conn, tr, id);
          DeleteGroupRow(conn, tr, id);
          DeleteGroupCatalogueAccess(conn, tr, id);

          tr.Commit();
        }
        catch
        {
          tr.Rollback();
          throw;
        }
      }
    }
  }

  // -------------------------------------------------------
  // ОТЧЕТЫ
  [WebMethod]
  public static ReportAccessDto GetReports(string ownerType, int idOwner)
  {
    if (idOwner <= 0)
      throw new Exception("Не выбран пользователь или группа.");

    ReportAccessStorage storage = GetReportAccessStorage(ownerType);
    return LoadReports(storage, idOwner);
  }

  [WebMethod]
  public static void SaveReports(string ownerType, int idOwner, List<SaveReportAccessItemDto> reports)
  {
    if (idOwner <= 0)
      throw new Exception("Не выбран пользователь или группа.");

    ReportAccessStorage storage = GetReportAccessStorage(ownerType);

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    {
      conn.Open();

      using (SqlTransaction tr = conn.BeginTransaction())
      {
        try
        {
          SaveReportsInternal(conn, tr, storage, idOwner, reports);

          if (ownerType == OWNER_GROUP)
            ApplyGroupReportsToUsers(conn, tr, idOwner);

          tr.Commit();
        }
        catch
        {
          tr.Rollback();
          throw;
        }
      }
    }
  }

  // --------------------------------------------------------
  // КОЛОНКИ
  [WebMethod]
  public static List<ColumnGroupDto> GetColumnGroups()
  {
    List<ColumnGroupDto> result = new List<ColumnGroupDto>();

    string sql = @"
    select
      idRestrictGrid,
      GridDescript,
      count(1) as CountColumns
    from v_RestrictColumn
    where isnull(idColumn, 0) = 0
    group by
      idRestrictGrid,
      GridDescript
    order by
      GridDescript,
      idRestrictGrid";

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(sql, conn))
    {
      conn.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
        {
          result.Add(new ColumnGroupDto
          {
            idRestrictGrid = SafeConvert.ToInt(reader["idRestrictGrid"]),
            GridDescript = SafeConvert.ToString(reader["GridDescript"]),
            CountColumns = SafeConvert.ToInt(reader["CountColumns"])
          });
        }
      }
    }

    return result;
  }

  [WebMethod]
  public static ColumnAccessDto GetColumns(string ownerType, int idOwner, int idRestrictGrid)
  {
    if (idOwner <= 0)
      throw new Exception("Не выбран пользователь или группа.");

    if (idRestrictGrid <= 0)
      throw new Exception("Не выбрана таблица.");

    ColumnAccessStorage storage = GetColumnAccessStorage(ownerType);

    ColumnAccessDto result = new ColumnAccessDto
    {
      Groups = new List<string>(),
      Columns = new List<ColumnAccessItemDto>()
    };

    string sql = string.Format(@"
    select
      C.idColumn,
      C.Caption,
      isnull(A.CaptionUser, C.CaptionUser) as CaptionUser,
      isnull(A.Num, C.Num) as Num,
      cast(isnull(A.bVisible, C.bVisible) as bit) as bVisible,
      cast(isnull(A.bEdit, C.bEdit) as bit) as bEdit,
      cast(isnull(A.bEdit_ToManufakt, 0) as bit) as bEdit_ToManufakt
    from v_RestrictColumn C
    left join {0} A on A.{1} = C.idColumn
                    and A.{2} = @idOwner
    where
      C.idRestrictGrid = @idRestrictGrid
      and isnull(C.idColumn, 0) <> 0
      and isnull(C.Caption, '') <> ''
    order by
      C.TreeLevel,
      C.Num,
      C.idColumn",
    storage.TableName,
    storage.ColumnField,
    storage.OwnerField);

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(sql, conn))
    {
      cmd.Parameters.AddWithValue("@idOwner", idOwner);
      cmd.Parameters.AddWithValue("@idRestrictGrid", idRestrictGrid);
      conn.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
        {
          result.Columns.Add(new ColumnAccessItemDto
          {
            idColumn = SafeConvert.ToInt(reader["idColumn"]),
            Caption = SafeConvert.ToString(reader["Caption"]),
            CaptionUser = SafeConvert.ToString(reader["CaptionUser"]),
            GridDescript = "",
            Num = SafeConvert.ToInt(reader["Num"]),
            bVisible = SafeConvert.ToBool(reader["bVisible"]),
            bEdit = SafeConvert.ToBool(reader["bEdit"]),
            bEdit_ToManufakt = SafeConvert.ToBool(reader["bEdit_ToManufakt"])
          });
        }
      }
    }

    return result;
  }

  [WebMethod]
  public static void SaveColumns(string ownerType, int idOwner, int idRestrictGrid, List<SaveColumnAccessItemDto> columns)
  {
    if (idRestrictGrid <= 0)
      throw new Exception("Не выбрана таблица колонок.");

    if (idOwner <= 0)
      throw new Exception("Не выбран пользователь или группа.");

    ColumnAccessStorage storage = GetColumnAccessStorage(ownerType);

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    {
      conn.Open();

      using (SqlTransaction tr = conn.BeginTransaction())
      {
        try
        {
          SaveColumnsInternal(conn, tr, storage, idOwner, idRestrictGrid, columns);

          if (ownerType == "group")
            ApplyGroupColumnsToUsers(conn, tr, idOwner);

          tr.Commit();
        }
        catch
        {
          tr.Rollback();
          throw;
        }
      }
    }
  }

  // --------------------------------------------------------
  // СПРАВОЧНИКИ
  [WebMethod]
  public static List<string> GetCatalogueGroups()
  {
    List<string> result = new List<string>();

    string sql = @"
    select distinct
      case
        when C.CatGroup = 0 then '-Без группы-'
        when C.CatGroup = 1 then 'Ценообразование'
        when C.CatGroup = 2 then 'Материалы'
        when C.CatGroup = 3 then 'Отчеты'
        when C.CatGroup = 4 then 'Брак'
        when C.CatGroup = 5 then 'Персонал'
        when C.CatGroup = 6 then 'Склад'
        else 'Группа не определена'
      end as CatalogueGroup,
      C.CatGroup
    from Catalogue C
    left join Config VS on VS.Name = 'VersionStone'
    where
      C.CatName <> ''
      and C.CatName <> '-'
      and (
        isnull(VS.d_iNum, 0) = 0 and C.IDDResource != 'ID_REF_DECOR'
        or isnull(VS.d_iNum, 0) = 1
      )
    order by
      C.CatGroup";

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(sql, conn))
    {
      conn.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
          result.Add(SafeConvert.ToString(reader["CatalogueGroup"]));
      }
    }

    return result;
  }

  [WebMethod]
  public static CatalogueAccessDto GetCatalogues(string ownerType, int idOwner, string catalogueGroup)
  {
    if (string.IsNullOrWhiteSpace(catalogueGroup))
      throw new Exception("Не выбрана группа справочников.");

    if (idOwner <= 0)
      throw new Exception("Не выбран пользователь или группа.");

    CatalogueAccessStorage storage = GetCatalogueAccessStorage(ownerType);

    CatalogueAccessDto result = new CatalogueAccessDto
    {
      Groups = new List<string>(),
      Items = new List<CatalogueAccessItemDto>()
    };

    string sql = string.Format(@"
    select
      C.ID as idCatalogue,
      C.CatName as CatalogueName,
      C.IDDResource,
      C.CatGroup,
      case
        when C.CatGroup = 0 then '-Без группы-'
        when C.CatGroup = 1 then 'Ценообразование'
        when C.CatGroup = 2 then 'Материалы'
        when C.CatGroup = 3 then 'Отчеты'
        when C.CatGroup = 4 then 'Брак'
        when C.CatGroup = 5 then 'Персонал'
        when C.CatGroup = 6 then 'Склад'
        else 'Группа не определена'
      end as CatalogueGroup,
      cast(isnull(A.bDenyShow, 0) as bit) as bDenyShow,
      cast(isnull(A.bDenyEdit, 0) as bit) as bDenyEdit
    from Catalogue C
    left join {0} A on A.idCatalogue = C.ID
                    and A.{1} = @idOwner
    left join Config VS on VS.Name = 'VersionStone'
    where
      C.CatName <> ''
      and C.CatName <> '-'
      and (
        isnull(VS.d_iNum, 0) = 0 and C.IDDResource != 'ID_REF_DECOR'
        or isnull(VS.d_iNum, 0) = 1
      )
      and
        case
          when C.CatGroup = 0 then '-Без группы-'
          when C.CatGroup = 1 then 'Ценообразование'
          when C.CatGroup = 2 then 'Материалы'
          when C.CatGroup = 3 then 'Отчеты'
          when C.CatGroup = 4 then 'Брак'
          when C.CatGroup = 5 then 'Персонал'
          when C.CatGroup = 6 then 'Склад'
          else 'Группа не определена'
        end = @catalogueGroup
    order by
      C.CatGroup,
      C.ID",
    storage.TableName,
    storage.OwnerField);

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(sql, conn))
    {
      cmd.Parameters.AddWithValue("@idOwner", idOwner);
      cmd.Parameters.AddWithValue("@catalogueGroup", catalogueGroup);
      conn.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
        {
          string groupName = SafeConvert.ToString(reader["CatalogueGroup"]);

          result.Items.Add(new CatalogueAccessItemDto
          {
            idCatalogue = SafeConvert.ToInt(reader["idCatalogue"]),
            CatalogueName = SafeConvert.ToString(reader["CatalogueName"]),
            IDDResource = SafeConvert.ToString(reader["IDDResource"]),
            CatalogueGroup = groupName,
            bDenyShow = SafeConvert.ToBool(reader["bDenyShow"]),
            bDenyEdit = SafeConvert.ToBool(reader["bDenyEdit"])
          });

          AddDistinctGroup(result.Groups, groupName);
        }
      }
    }

    return result;
  }

  [WebMethod]
  public static void SaveCatalogues(string ownerType, int idOwner, string catalogueGroup, List<SaveCatalogueAccessItemDto> items)
  {
    if (idOwner <= 0)
      throw new Exception("Не выбран пользователь или группа.");

    CatalogueAccessStorage storage = GetCatalogueAccessStorage(ownerType);

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    {
      conn.Open();

      using (SqlTransaction tr = conn.BeginTransaction())
      {
        try
        {
          SaveCataloguesInternal(conn, tr, storage, idOwner, catalogueGroup, items);

          if (ownerType == "group")
            ApplyGroupCataloguesToUsers(conn, tr, idOwner);

          tr.Commit();
        }
        catch
        {
          tr.Rollback();
          throw;
        }
      }
    }
  }

  /// -------------------------------------------------------
  // ОТЧЕТЫ И ГРУППЫ

  private static void ValidateUser(DetailDto dto)
  {
    if (dto == null)
      throw new Exception("Нет данных для сохранения.");

    if (string.IsNullOrWhiteSpace(dto.Name))
      throw new Exception("Введите имя пользователя.");
  }

  private static void ValidateGroup(DetailDto dto)
  {
    if (dto == null)
      throw new Exception("Нет данных для сохранения.");

    if (string.IsNullOrWhiteSpace(dto.Name))
      throw new Exception("Введите название группы.");
  }

  private static void SaveUserBase(SqlConnection conn, SqlTransaction tr, DetailDto dto)
  {
    using (SqlCommand cmd = new SqlCommand(@"
      update Users
      set
        Name = @Name,
        ManagerName = @ManagerName,
        Post = @Post,
        Tel = @Tel,
        idUserGroup = @idUserGroup,
        bUseGroupPermission = @bUseGroupPermission
      where ID = @ID", conn, tr))
    {
      bool useGroup = dto.idUserGroup.HasValue;

      cmd.Parameters.AddWithValue("@ID", dto.ID);
      cmd.Parameters.AddWithValue("@Name", dto.Name.Trim());
      cmd.Parameters.AddWithValue("@ManagerName", NullIfEmpty(dto.ManagerName));
      cmd.Parameters.AddWithValue("@Post", NullIfEmpty(dto.Post));
      cmd.Parameters.AddWithValue("@Tel", NullIfEmpty(dto.Tel));
      cmd.Parameters.AddWithValue("@idUserGroup", dto.idUserGroup.HasValue ? (object)dto.idUserGroup.Value : DBNull.Value);
      cmd.Parameters.AddWithValue("@bUseGroupPermission", useGroup);

      if (cmd.ExecuteNonQuery() == 0)
        throw new Exception("Пользователь не найден.");
    }
  }

  private static void SaveGroupBase(SqlConnection conn, SqlTransaction tr, DetailDto dto)
  {
    using (SqlCommand cmd = new SqlCommand(@"
      update UserGroups
      set
        Name = @Name,
        Commentary = @Commentary
      where ID = @ID", conn, tr))
    {
      cmd.Parameters.AddWithValue("@ID", dto.ID);
      cmd.Parameters.AddWithValue("@Name", dto.Name.Trim());
      cmd.Parameters.AddWithValue("@Commentary", NullIfEmpty(dto.Commentary));

      if (cmd.ExecuteNonQuery() == 0)
        throw new Exception("Группа не найдена.");
    }
  }

  private static List<ItemDto> GetUsers()
  {
    List<ItemDto> result = new List<ItemDto>();

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
      select
        U.ID,
        U.Name,
        U.ManagerName,
        U.Post,
        U.idUserGroup,
        U.bUseGroupPermission,
        G.Name as GroupName
      from Users U
      left join UserGroups G on G.ID = U.idUserGroup
      order by U.Name", conn))
    {
      conn.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
        {
          string managerName = SafeConvert.ToString(reader["ManagerName"]);
          string groupName = SafeConvert.ToString(reader["GroupName"]);

          result.Add(new ItemDto
          {
            ID = SafeConvert.ToInt(reader["ID"]),
            Name = SafeConvert.ToString(reader["Name"]),
            SubText = BuildUserSubText(managerName, groupName),
            idUserGroup = GetNullableInt(reader["idUserGroup"]),
            bUseGroupPermission = SafeConvert.ToBool(reader["bUseGroupPermission"])
          });
        }
      }
    }

    return result;
  }

  private static List<ItemDto> GetGroups()
  {
    List<ItemDto> result = new List<ItemDto>();

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(@"
      select
        G.ID,
        G.Name,
        G.Commentary,
        (
          select count(1)
          from Users U
          where U.idUserGroup = G.ID
        ) as UserCount
      from UserGroups G
      order by G.Name", conn))
    {
      conn.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
        {
          int countUsers = SafeConvert.ToInt(reader["UserCount"]);
          string commentary = SafeConvert.ToString(reader["Commentary"]);

          result.Add(new ItemDto
          {
            ID = SafeConvert.ToInt(reader["ID"]),
            Name = SafeConvert.ToString(reader["Name"]),
            SubText = BuildGroupSubText(countUsers, commentary)
          });
        }
      }
    }

    return result;
  }

  private static DetailDto LoadDetail(string sql, int id)
  {
    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(sql, conn))
    {
      cmd.Parameters.AddWithValue("@id", id);
      conn.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        if (!reader.Read())
          return null;

        DetailDto dto = new DetailDto
        {
          ID = SafeConvert.ToInt(reader["ID"]),
          Name = SafeConvert.ToString(reader["Name"]),
          ManagerName = SafeConvert.ToString(reader["ManagerName"]),
          Post = SafeConvert.ToString(reader["Post"]),
          Tel = SafeConvert.ToString(reader["Tel"]),
          Commentary = SafeConvert.ToString(reader["Commentary"]),
          idUserGroup = GetNullableInt(reader["idUserGroup"]),
          bUseGroupPermission = SafeConvert.ToBool(reader["bUseGroupPermission"]),
          Permissions = new Dictionary<string, bool>()
        };

        foreach (PermissionDef p in PermissionList)
          dto.Permissions[p.Name] = SafeConvert.ToBool(reader[p.Name]);

        return dto;
      }
    }
  }

  private static string BuildUserDetailSql()
  {
    return string.Format(@"
      select
        U.ID,
        U.Name,
        U.ManagerName,
        U.Post,
        U.Tel,
        U.Commentary,
        U.idUserGroup,
        U.bUseGroupPermission,
        {0}
      from Users U
      where U.ID = @id", BuildPermissionSelect("U"));
  }

  private static string BuildGroupDetailSql()
  {
    return string.Format(@"
      select
        G.ID,
        G.Name,
        cast(null as varchar(256)) as ManagerName,
        cast(null as varchar(256)) as Post,
        cast(null as varchar(64)) as Tel,
        G.Commentary,
        cast(null as int) as idUserGroup,
        cast(0 as bit) as bUseGroupPermission,
        {0}
      from UserGroups G
      left join UserGroupPermission P on P.idUserGroup = G.ID
      where G.ID = @id", BuildPermissionSelect("P"));
  }

  private static string BuildPermissionSelect(string alias)
  {
    List<string> parts = new List<string>();

    foreach (PermissionDef p in PermissionList)
      parts.Add(string.Format("cast(isnull({0}.{1}, 0) as bit) as {1}", alias, p.Name));

    return string.Join(",\r\n        ", parts.ToArray());
  }

  private static void EnsureGroupPermissionRow(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    using (SqlCommand cmd = new SqlCommand(@"
      if not exists(
        select 1
        from UserGroupPermission
        where idUserGroup = @idGroup
      )
      begin
        insert into UserGroupPermission(idUserGroup)
        values(@idGroup)
      end", conn, tr))
    {
      cmd.Parameters.AddWithValue("@idGroup", idGroup);
      cmd.ExecuteNonQuery();
    }
  }

  private static void UpdatePermissions(SqlConnection conn, SqlTransaction tr, string tableName, string keyField, int id, Dictionary<string, bool> permissions)
  {
    if (permissions == null)
      permissions = new Dictionary<string, bool>();

    foreach (PermissionDef p in PermissionList)
    {
      string sql = string.Format(@"
        update {0}
        set {1} = @{1}
        where {2} = @ID", tableName, p.Name, keyField);

      using (SqlCommand cmd = new SqlCommand(sql, conn, tr))
      {
        bool value = permissions.ContainsKey(p.Name) && permissions[p.Name];

        cmd.Parameters.AddWithValue("@ID", id);
        cmd.Parameters.AddWithValue("@" + p.Name, value);
        cmd.ExecuteNonQuery();
      }
    }
  }

  private static void ApplyGroupTemplatesToUser(SqlConnection conn, SqlTransaction tr, int idUser, int idGroup)
  {
    ApplyGroupPermissionsToUser(conn, tr, idUser, idGroup);
    ApplyGroupReportsToUser(conn, tr, idUser, idGroup);
    ApplyGroupColumnsToUser(conn, tr, idUser, idGroup);
    ApplyGroupCataloguesToUser(conn, tr, idUser, idGroup);
  }

  private static void ApplyGroupPermissionsToUser(SqlConnection conn, SqlTransaction tr, int idUser, int idGroup)
  {
    EnsureGroupPermissionRow(conn, tr, idGroup);

    string sql = BuildApplyGroupPermissionsSql(@"
      update U
      set {0}
      from Users U
      join UserGroupPermission G on G.idUserGroup = @idGroup
      where U.ID = @idUser");

    using (SqlCommand cmd = new SqlCommand(sql, conn, tr))
    {
      cmd.Parameters.AddWithValue("@idUser", idUser);
      cmd.Parameters.AddWithValue("@idGroup", idGroup);
      cmd.ExecuteNonQuery();
    }
  }

  private static void ApplyGroupPermissionsToUsers(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    EnsureGroupPermissionRow(conn, tr, idGroup);

    string sql = BuildApplyGroupPermissionsSql(@"
      update U
      set {0}
      from Users U
      join UserGroupPermission G on G.idUserGroup = @idGroup
      where U.idUserGroup = @idGroup");

    using (SqlCommand cmd = new SqlCommand(sql, conn, tr))
    {
      cmd.Parameters.AddWithValue("@idGroup", idGroup);
      cmd.ExecuteNonQuery();
    }
  }

  private static string BuildApplyGroupPermissionsSql(string template)
  {
    List<string> parts = new List<string>();

    foreach (PermissionDef p in PermissionList)
      parts.Add(string.Format("U.{0} = isnull(G.{0}, 0)", p.Name));

    return string.Format(template, string.Join(",\r\n          ", parts.ToArray()));
  }

  private static void DeleteGroupRow(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    using (SqlCommand cmd = new SqlCommand(@"
      delete from UserGroups
      where ID = @idGroup", conn, tr))
    {
      cmd.Parameters.AddWithValue("@idGroup", idGroup);

      if (cmd.ExecuteNonQuery() == 0)
        throw new Exception("Группа не найдена.");
    }
  }

  private static void AddDistinctGroup(List<string> groups, string groupName)
  {
    if (string.IsNullOrWhiteSpace(groupName))
      return;

    if (!groups.Contains(groupName))
      groups.Add(groupName);
  }

  private static List<int> GetUsersByGroup(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    List<int> result = new List<int>();

    using (SqlCommand cmd = new SqlCommand(@"
      select ID
      from Users
      where idUserGroup = @idGroup", conn, tr))
    {
      cmd.Parameters.AddWithValue("@idGroup", idGroup);

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
          result.Add(SafeConvert.ToInt(reader["ID"]));
      }
    }

    return result;
  }

  private static void EnsureGroupCanBeDeleted(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    using (SqlCommand cmd = new SqlCommand(@"
      select count(1)
      from Users
      where idUserGroup = @idGroup", conn, tr))
    {
      cmd.Parameters.AddWithValue("@idGroup", idGroup);

      int countUsers = Convert.ToInt32(cmd.ExecuteScalar());

      if (countUsers > 0)
        throw new Exception("Нельзя удалить группу: к ней привязаны пользователи.");
    }
  }

  private static void DeleteGroupReportAccess(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    using (SqlCommand cmd = new SqlCommand(@"
      delete from UserGroupReportList
      where idUserGroup = @idGroup", conn, tr))
    {
      cmd.Parameters.AddWithValue("@idGroup", idGroup);
      cmd.ExecuteNonQuery();
    }
  }

  private static void DeleteGroupPermissions(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    using (SqlCommand cmd = new SqlCommand(@"
      delete from UserGroupPermission
      where idUserGroup = @idGroup", conn, tr))
    {
      cmd.Parameters.AddWithValue("@idGroup", idGroup);
      cmd.ExecuteNonQuery();
    }
  }

  private static string BuildUserSubText(string managerName, string groupName)
  {
    if (string.IsNullOrWhiteSpace(groupName))
      return managerName;

    if (string.IsNullOrWhiteSpace(managerName))
      return "Группа: " + groupName;

    return managerName + " · Группа: " + groupName;
  }

  private static string BuildGroupSubText(int countUsers, string commentary)
  {
    string text = "Пользователей: " + countUsers;

    if (!string.IsNullOrWhiteSpace(commentary))
      text += " · " + commentary;

    return text;
  }

  // -------------------------------------------------------
  // Отчеты приватные методы
  private static ReportAccessDto LoadReports(ReportAccessStorage storage, int idOwner)
  {
    ReportAccessDto result = new ReportAccessDto
    {
      Groups = new List<string>(),
      Reports = new List<ReportAccessItemDto>()
    };

    string sql = string.Format(@"
      select
        R.ID,
        R.RepName,
        R.RepTitle,
        R.RepGroup,
        cast(isnull(A.ReportStatusDeny, 0) as bit) as bDenied
      from ReportList R
      left join {0} A on A.{1} = R.ID
                      and A.{2} = @idOwner
      where isnull(R.bShowInMenu, 0) = 1
      order by
        R.RepGroup,
        case when R.ID = 0 then 0 else 1 end,
        R.RepOrder,
        R.nLevel,
        R.RepTitle",
      storage.TableName,
      storage.ReportField,
      storage.OwnerField);

    using (SqlConnection conn = new SqlConnection(DbConfig.ConnectionString))
    using (SqlCommand cmd = new SqlCommand(sql, conn))
    {
      cmd.Parameters.AddWithValue("@idOwner", idOwner);
      conn.Open();

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
        {
          string repGroup = GetGroupName(SafeConvert.ToInt(reader["RepGroup"]));

          result.Reports.Add(new ReportAccessItemDto
          {
            idReport = SafeConvert.ToInt(reader["ID"]),
            Name = SafeConvert.ToString(reader["RepTitle"]),
            RepName = SafeConvert.ToString(reader["RepName"]),
            RepGroup = repGroup,
            bDenied = SafeConvert.ToBool(reader["bDenied"])
          });

          AddDistinctGroup(result.Groups, repGroup);
        }
      }
    }

    return result;
  }
  private static string GetGroupName(int repGroup)
  {
    string name;
    return ReportGroups.TryGetValue(repGroup, out name)
        ? name
        : "Группа не определена";
  }

  private static void SaveReportsInternal(SqlConnection conn, SqlTransaction tr, ReportAccessStorage storage, int idOwner, List<SaveReportAccessItemDto> reports)
  {
    if (reports == null)
      reports = new List<SaveReportAccessItemDto>();

    ClearReportAccess(conn, tr, storage, idOwner);

    foreach (SaveReportAccessItemDto report in reports)
    {
      if (report == null || report.idReport <= 0 || !report.bDenied)
        continue;

      UpsertDeniedReport(conn, tr, storage, idOwner, report.idReport);
    }

    DeleteEmptyReportRows(conn, tr, storage, idOwner);
  }

  private static void ClearReportAccess(SqlConnection conn, SqlTransaction tr, ReportAccessStorage storage, int idOwner)
  {
    string setSql = "ReportStatusDeny = 0";

    if (storage.HasGrantColumn)
      setSql += ", ReportStatusGrant = 0";

    string sql = string.Format(@"
      update {0}
      set {1}
      where {2} = @idOwner",
      storage.TableName,
      setSql,
      storage.OwnerField);

    using (SqlCommand cmd = new SqlCommand(sql, conn, tr))
    {
      cmd.Parameters.AddWithValue("@idOwner", idOwner);
      cmd.ExecuteNonQuery();
    }
  }

  private static void UpsertDeniedReport(SqlConnection conn, SqlTransaction tr, ReportAccessStorage storage, int idOwner, int idReport)
  {
    string grantUpdateSql = storage.HasGrantColumn ? ", ReportStatusGrant = 0" : "";
    string grantInsertFieldSql = storage.HasGrantColumn ? ", ReportStatusGrant" : "";
    string grantInsertValueSql = storage.HasGrantColumn ? ", 0" : "";

    string sql = string.Format(@"
      if exists(
        select 1
        from {0}
        where {1} = @idOwner
          and {2} = @idReport
      )
      begin
        update {0}
        set
          ReportStatusDeny = 1
          {3}
        where {1} = @idOwner
          and {2} = @idReport
      end
      else
      begin
        insert into {0} (
          {1},
          {2},
          ReportStatusDeny
          {4}
        )
        values
        (
          @idOwner,
          @idReport,
          1
          {5}
        )
      end",
      storage.TableName,
      storage.OwnerField,
      storage.ReportField,
      grantUpdateSql,
      grantInsertFieldSql,
      grantInsertValueSql);

    using (SqlCommand cmd = new SqlCommand(sql, conn, tr))
    {
      cmd.Parameters.AddWithValue("@idOwner", idOwner);
      cmd.Parameters.AddWithValue("@idReport", idReport);
      cmd.ExecuteNonQuery();
    }
  }

  private static void DeleteEmptyReportRows(SqlConnection conn, SqlTransaction tr, ReportAccessStorage storage, int idOwner)
  {
    string grantCondition = storage.HasGrantColumn
      ? "and isnull(ReportStatusGrant, 0) = 0"
      : "";

    string sql = string.Format(@"
      delete from {0}
      where {1} = @idOwner
        and isnull(ReportStatusDeny, 0) = 0
        {2}",
      storage.TableName,
      storage.OwnerField,
      grantCondition);

    using (SqlCommand cmd = new SqlCommand(sql, conn, tr))
    {
      cmd.Parameters.AddWithValue("@idOwner", idOwner);
      cmd.ExecuteNonQuery();
    }
  }

  private static void ApplyGroupReportsToUsers(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    // Применить к текущему пользователю
    List<int> users = GetUsersByGroup(conn, tr, idGroup);

    foreach (int idUser in users)
      ApplyGroupReportsToUser(conn, tr, idUser, idGroup);
  }

  private static void ApplyGroupReportsToUser(SqlConnection conn, SqlTransaction tr, int idUser, int idGroup)
  {
    // Применить к группе пользователей
    ReportAccessStorage groupStorage = GetReportAccessStorage(OWNER_GROUP);
    ReportAccessStorage userStorage = GetReportAccessStorage(OWNER_USER);

    List<SaveReportAccessItemDto> groupReports = GetDeniedReportsInternal(conn, tr, groupStorage, idGroup);
    SaveReportsInternal(conn, tr, userStorage, idUser, groupReports);
  }

  private static List<SaveReportAccessItemDto> GetDeniedReportsInternal(SqlConnection conn, SqlTransaction tr, ReportAccessStorage storage, int idOwner)
  {
    List<SaveReportAccessItemDto> result = new List<SaveReportAccessItemDto>();

    string sql = string.Format(@"
      select {0} as idReport
      from {1}
      where {2} = @idOwner
        and isnull(ReportStatusDeny, 0) <> 0",
      storage.ReportField,
      storage.TableName,
      storage.OwnerField);

    using (SqlCommand cmd = new SqlCommand(sql, conn, tr))
    {
      cmd.Parameters.AddWithValue("@idOwner", idOwner);

      using (SqlDataReader reader = cmd.ExecuteReader())
      {
        while (reader.Read())
        {
          result.Add(new SaveReportAccessItemDto
          {
            idReport = SafeConvert.ToInt(reader["idReport"]),
            bDenied = true
          });
        }
      }
    }

    return result;
  }


  private static ReportAccessStorage GetReportAccessStorage(string ownerType)
  {
    if (ownerType == OWNER_USER)
    {
      return new ReportAccessStorage
      {
        TableName = "ReportListUser",
        OwnerField = "idUser",
        ReportField = "idReportUser",
        HasGrantColumn = true
      };
    }

    if (ownerType == OWNER_GROUP)
    {
      return new ReportAccessStorage
      {
        TableName = "UserGroupReportList",
        OwnerField = "idUserGroup",
        ReportField = "idReport",
        HasGrantColumn = false
      };
    }

    throw new Exception("Неизвестный тип владельца отчётов.");
  }


  // -------------------------------------------------------
  // Колонки

  private static void SaveColumnsInternal(SqlConnection conn, SqlTransaction tr, ColumnAccessStorage storage, int idOwner, int idRestrictGrid, List<SaveColumnAccessItemDto> columns)
  {
    if (columns == null)
      columns = new List<SaveColumnAccessItemDto>();

    ClearColumns(conn, tr, storage, idOwner, idRestrictGrid);

    foreach (SaveColumnAccessItemDto column in columns)
    {
      if (column == null || column.idColumn <= 0)
        continue;

      UpsertColumnAccess(conn, tr, storage, idOwner, column);
    }
  }

  private static void ClearColumns(SqlConnection conn, SqlTransaction tr, ColumnAccessStorage storage, int idOwner, int idRestrictGrid)
  {
    string sql = string.Format(@"
    delete A
    from {0} A
    join v_RestrictColumn C on C.idColumn = A.{1}
    where A.{2} = @idOwner
      and C.idRestrictGrid = @idRestrictGrid",
    storage.TableName,
    storage.ColumnField,
    storage.OwnerField);

    using (SqlCommand cmd = new SqlCommand(sql, conn, tr))
    {
      cmd.Parameters.AddWithValue("@idOwner", idOwner);
      cmd.Parameters.AddWithValue("@idRestrictGrid", idRestrictGrid);
      cmd.ExecuteNonQuery();
    }
  }

  private static void UpsertColumnAccess(SqlConnection conn, SqlTransaction tr, ColumnAccessStorage storage, int idOwner, SaveColumnAccessItemDto column)
  {
    string sql = string.Format(@"
    insert into {0}
    (
      {1},
      {2},
      CaptionUser,
      Num,
      bVisible,
      bEdit,
      bEdit_ToManufakt
    )
    values
    (
      @idOwner,
      @idColumn,
      @CaptionUser,
      @Num,
      @bVisible,
      @bEdit,
      @bEdit_ToManufakt
    )",
    storage.TableName,
    storage.OwnerField,
    storage.ColumnField);

    using (SqlCommand cmd = new SqlCommand(sql, conn, tr))
    {
      cmd.Parameters.AddWithValue("@idOwner", idOwner);
      cmd.Parameters.AddWithValue("@idColumn", column.idColumn);
      cmd.Parameters.AddWithValue("@CaptionUser", string.IsNullOrWhiteSpace(column.CaptionUser) ? (object)DBNull.Value : column.CaptionUser.Trim());
      cmd.Parameters.AddWithValue("@Num", column.Num.HasValue ? (object)column.Num.Value : DBNull.Value);
      cmd.Parameters.AddWithValue("@bVisible", column.bVisible);
      cmd.Parameters.AddWithValue("@bEdit", column.bEdit);
      cmd.Parameters.AddWithValue("@bEdit_ToManufakt", column.bEdit_ToManufakt);
      cmd.ExecuteNonQuery();
    }
  }

  private static void ApplyGroupColumnsToUsers(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    List<int> users = GetUsersByGroup(conn, tr, idGroup);

    foreach (int idUser in users)
      ApplyGroupColumnsToUser(conn, tr, idUser, idGroup);
  }

  private static void ApplyGroupColumnsToUser(SqlConnection conn, SqlTransaction tr, int idUser, int idGroup)
  {
    using (SqlCommand cmd = new SqlCommand(@"
    delete from RestrictColumnUser
    where idUser = @idUser;

    insert into RestrictColumnUser
    (
      idUser,
      idColumn,
      bVisible,
      bEdit,
      bEdit_ToManufakt,
      CaptionUser,
      Num
    )
    select
      @idUser,
      idColumn,
      bVisible,
      bEdit,
      bEdit_ToManufakt,
      CaptionUser,
      Num
    from UserGroupRestrictColumn
    where idUserGroup = @idGroup", conn, tr))
    {
      cmd.Parameters.AddWithValue("@idUser", idUser);
      cmd.Parameters.AddWithValue("@idGroup", idGroup);
      cmd.ExecuteNonQuery();
    }
  }

  private static ColumnAccessStorage GetColumnAccessStorage(string ownerType)
  {
    if (ownerType == "user")
    {
      return new ColumnAccessStorage
      {
        TableName = "RestrictColumnUser",
        OwnerField = "idUser",
        ColumnField = "idColumn"
      };
    }

    if (ownerType == "group")
    {
      return new ColumnAccessStorage
      {
        TableName = "UserGroupRestrictColumn",
        OwnerField = "idUserGroup",
        ColumnField = "idColumn"
      };
    }

    throw new Exception("Неизвестный тип владельца колонок.");
  }

  // -------------------------------------------------------
  // Справочники
  private static void SaveCataloguesInternal(SqlConnection conn, SqlTransaction tr, CatalogueAccessStorage storage, int idOwner, string catalogueGroup, List<SaveCatalogueAccessItemDto> items)
  {
    if (items == null)
      items = new List<SaveCatalogueAccessItemDto>();

    foreach (SaveCatalogueAccessItemDto item in items)
    {
      if (item == null || item.idCatalogue <= 0)
        continue;

      using (SqlCommand cmd = new SqlCommand(string.Format(@"
      update {0}
      set
        bDenyShow = @bDenyShow,
        bDenyEdit = @bDenyEdit
      where
        {1} = @idOwner
        and idCatalogue = @idCatalogue

      if @@rowcount = 0
      begin
        insert into {0}
        (
          {1},
          idCatalogue,
          bDenyShow,
          bDenyEdit
        )
        values
        (
          @idOwner,
          @idCatalogue,
          @bDenyShow,
          @bDenyEdit
        )
      end",
        storage.TableName,
        storage.OwnerField), conn, tr))
      {
        cmd.Parameters.AddWithValue("@idOwner", idOwner);
        cmd.Parameters.AddWithValue("@idCatalogue", item.idCatalogue);
        cmd.Parameters.AddWithValue("@bDenyShow", item.bDenyShow);
        cmd.Parameters.AddWithValue("@bDenyEdit", item.bDenyEdit);

        cmd.ExecuteNonQuery();
      }
    }
  }

  private static void ApplyGroupCataloguesToUsers(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    List<int> users = GetUsersByGroup(conn, tr, idGroup);

    foreach (int idUser in users)
      ApplyGroupCataloguesToUser(conn, tr, idUser, idGroup);
  }

  private static void ApplyGroupCataloguesToUser(SqlConnection conn, SqlTransaction tr, int idUser, int idGroup)
  {
    using (SqlCommand cmd = new SqlCommand(@"
    delete from CatalogueUser
    where idUser = @idUser;

    insert into CatalogueUser
    (
      idUser,
      idCatalogue,
      bDenyShow,
      bDenyEdit
    )
    select
      @idUser,
      idCatalogue,
      bDenyShow,
      bDenyEdit
    from UserGroupCatalogueRight
    where idUserGroup = @idGroup", conn, tr))
    {
      cmd.Parameters.AddWithValue("@idUser", idUser);
      cmd.Parameters.AddWithValue("@idGroup", idGroup);
      cmd.ExecuteNonQuery();
    }
  }

  private static void DeleteGroupCatalogueAccess(SqlConnection conn, SqlTransaction tr, int idGroup)
  {
    using (SqlCommand cmd = new SqlCommand(@"
    delete from UserGroupCatalogueRight
    where idUserGroup = @idGroup", conn, tr))
    {
      cmd.Parameters.AddWithValue("@idGroup", idGroup);
      cmd.ExecuteNonQuery();
    }
  }

  private static CatalogueAccessStorage GetCatalogueAccessStorage(string ownerType)
  {
    if (ownerType == "user")
    {
      return new CatalogueAccessStorage
      {
        TableName = "CatalogueUser",
        OwnerField = "idUser"
      };
    }

    if (ownerType == "group")
    {
      return new CatalogueAccessStorage
      {
        TableName = "UserGroupCatalogueRight",
        OwnerField = "idUserGroup"
      };
    }

    throw new Exception("Неизвестный тип владельца справочников.");
  }

  // -------------------------------------------------------
  // Общие
  private static object NullIfEmpty(string value)
  {
    return string.IsNullOrWhiteSpace(value)
      ? (object)DBNull.Value
      : value.Trim();
  }

  private static int? GetNullableInt(object value)
  {
    if (value == null || value == DBNull.Value)
      return null;

    return Convert.ToInt32(value);
  }

}
