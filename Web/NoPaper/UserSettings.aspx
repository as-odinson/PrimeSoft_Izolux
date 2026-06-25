<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserSettings.aspx.cs" Inherits="UserSettings" %>

<!DOCTYPE html>
<html>
<head runat="server">
  <title>Настройки пользователей</title>
  <link rel="stylesheet" href="css/Pages/UserSettings.css" />
</head>
<body>
<form id="form1" runat="server">
  <asp:ScriptManager runat="server" EnablePageMethods="true" />

  <div class="page">
    <div class="sidebar">
      <div class="panel">
        <div class="panel-header">
          <span>Пользователи</span>
          <button type="button" id="btnAddUser">+</button>
        </div>
        <div id="usersList" class="list"></div>
      </div>

      <div class="panel">
        <div class="panel-header">
          <span>Группы</span>
          <button type="button" id="btnAddGroup">+</button>
        </div>
        <div id="groupsList" class="list"></div>
      </div>
    </div>

    <div class="content">
      <div class="toolbar">
        <h2 id="editorTitle">Выберите пользователя или группу</h2>
        <button type="button" id="btnSave" disabled>Сохранить</button>
        <button type="button" id="btnDelete" disabled>Удалить</button>
      </div>

      <div id="editor" class="editor empty">
        Ничего не выбрано
      </div>
    </div>
  </div>

  <script src="Java/Pages/UserSettings.js"></script>
</form>
</body>
</html>