<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ScanHistory.aspx.cs" Inherits="NoPaper.ScanHistory" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
  <title>История сканирования</title>
  <link href="css/Pages/ScanHistory.css" rel="stylesheet" />
  <script src="Java/Pages/ScanHistory.js"></script>
</head>
<body>
  <form id="form1" runat="server">

    <div class="page">

      <div class="header">
        <div>
          <h1>История сканирования</h1>
        </div>
      </div>

      <div class="filters">
        <div class="filter-group">
          <label>Дата с</label>
          <input type="date" id="dateFrom" />
        </div>

        <div class="filter-group">
          <label>Дата по</label>
          <input type="date" id="dateTo" />
        </div>

        <div class="filter-group">
          <label>Тип</label>
          <select id="typeFilter">
            <option value="-1">Все</option>
            <option value="0">Неизвестный</option>
            <option value="1">Оператор</option>
            <option value="2">Пирамида</option>
            <option value="4">Отгрузка</option>
          </select>
        </div>

        <button type="button" id="btnSearch">
          Обновить
        </button>
      </div>

      <div class="table-wrapper">
        <table class="history-table">
          <thead>
            <tr>
              <th>Время</th>
              <th>Оператор</th>
              <th>Штрихкод</th>
              <th>Тип</th>
              <th>Сообщение</th>
            </tr>
          </thead>
          <tbody id="historyBody">
          </tbody>
        </table>
      </div>

    </div>

  </form>
</body>
</html>
