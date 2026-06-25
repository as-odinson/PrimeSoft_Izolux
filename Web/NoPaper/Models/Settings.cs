using System.Collections.Generic;

namespace NoPaper.Models
{
  // Права пользователей и групп
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

  // Права на отчеты пользователей, групп пользователей
  public class ReportAccessDto
  {
    public List<string> Groups;
    public List<ReportAccessItemDto> Reports;
  }

  public class ReportAccessItemDto
  {
    public int idReport;
    public string Name;
    public string RepName;
    public string RepGroup;
    public bool bDenied;
  }

  public class SaveReportAccessItemDto
  {
    public int idReport;
    public bool bDenied;
  }

  // Права пользователей и групп на колонки справочников
  public class ColumnGroupDto
  {
    public int idRestrictGrid;
    public string GridDescript;
    public int CountColumns;
  }

  public class ColumnAccessDto
  {
    public List<string> Groups;
    public List<ColumnAccessItemDto> Columns;
  }

  public class ColumnAccessItemDto
  {
    public int idColumn;
    public string Caption;
    public string CaptionUser;
    public string GridDescript;
    public int? Num;
    public bool bVisible;
    public bool bEdit;
    public bool bEdit_ToManufakt;
  }

  public class SaveColumnAccessItemDto
  {
    public int idColumn;
    public string CaptionUser;
    public int? Num;
    public bool bVisible;
    public bool bEdit;
    public bool bEdit_ToManufakt;
  }

  // Команды
  public class CatalogueAccessDto
  {
    public List<string> Groups;
    public List<CatalogueAccessItemDto> Items;
  }

  public class CatalogueAccessItemDto
  {
    public int idCatalogue;
    public string CatalogueName;
    public string CatalogueGroup;
    public string IDDResource;
    public bool bDenyShow;
    public bool bDenyEdit;
  }

  public class SaveCatalogueAccessItemDto
  {
    public int idCatalogue;
    public bool bDenyShow;
    public bool bDenyEdit;
  }

}