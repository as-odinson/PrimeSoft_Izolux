<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UserSettings.aspx.cs" Inherits="UserSettings" %>

<!DOCTYPE html>
<html>
<head runat="server">
  <title>Настройки пользователей</title>
  <link rel="stylesheet" href="css/Component/Toast.css" />
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
          <button type="button" id="btnAddUser" class="btn btn-icon" title="Добавить пользователя">+</button>
        </div>
        <div id="usersList" class="list"></div>
      </div>

      <div class="panel">
        <div class="panel-header">
          <span>Группы</span>
          <button type="button" id="btnAddGroup" class="btn btn-icon" title="Добавить группу">+</button>
        </div>
        <div id="groupsList" class="list"></div>
      </div>
    </div>

    <div class="content">
      <div class="toolbar">
        <h2 id="editorTitle">Выберите пользователя или группу</h2>

        <div class="toolbar-actions">
          <button type="button" id="btnDelete" class="btn btn-danger" disabled>Удалить</button>
          <button type="button" id="btnSave" class="btn btn-primary" disabled>Сохранить</button>
        </div>
      </div>

      <div id="editor" class="editor empty">
        Ничего не выбрано
      </div>
    </div>
  </div>

  <div id="toastRoot" class="toast-root"></div>

  <div id="groupModal" class="modal-overlay hidden">
    <div class="modal-window">
      <div class="modal-header">
        <h3>Новая группа</h3>
        <button type="button" id="btnCloseGroupModal" class="modal-close">×</button>
      </div>

      <div class="modal-body">
        <label>
          <span>Название</span>
          <input id="modalGroupName" autocomplete="off" />
        </label>

        <label>
          <span>Комментарий</span>
          <textarea id="modalGroupCommentary"></textarea>
        </label>
      </div>

      <div class="modal-footer">
        <button type="button" id="btnCancelGroupModal" class="btn btn-secondary">Отмена</button>
        <button type="button" id="btnCreateGroupModal" class="btn btn-primary">Создать</button>
      </div>
    </div>
  </div>

  <div id="confirmModal" class="modal-overlay hidden">
    <div class="modal-window modal-window-small">
      <div class="modal-header">
        <h3 id="confirmTitle">Подтверждение</h3>
        <button type="button" id="btnCloseConfirmModal" class="modal-close">×</button>
      </div>

      <div class="modal-body">
        <div id="confirmMessage" class="confirm-message"></div>
      </div>

      <div class="modal-footer">
        <button type="button" id="btnCancelConfirmModal" class="btn btn-secondary">Отмена</button>
        <button type="button" id="btnOkConfirmModal" class="btn btn-danger">Удалить</button>
      </div>
    </div>
  </div>

  <script src="Java/Component/Toast.js"></script>
  <script src="Java/Pages/UserSettings.js"></script>
</form>
</body>
</html>
