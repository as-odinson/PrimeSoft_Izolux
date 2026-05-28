<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ScanCar.aspx.cs" Inherits="NoPaper.ScanCar" Async="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>Сканирование</title>
  <link rel="stylesheet" type="text/css" href="~/css/scan1.css?v=3" />
  <link rel="stylesheet" type="text/css" href="~/css/message.css?v=5" />
</head>
<body>
  <div>
    <header>
      <div class="select-operator">
        <form id="form1" runat="server">
          <asp:ScriptManager runat="server" EnablePageMethods="true" />
          <p>Оператор</p>
          <asp:DropDownList
            runat="server"
            ID="Operator"
            CssClass="operator-dropdown" />
          <p>Штрихкод</p>
        </form>
      </div>
      <div class="info">
        <label id="ScanTextInfo" class="info-label">Отскан ШК: <span id="ScanTextValue" /></label>
        <label id="TextInfo" class="info-label" />
      </div>
      <div class="barcode-input">
        <input id="BarCode" class="barcode-textbox" maxlength="12" autofocus />
      </div>

      <button id="ButBegin" class="submit-button">Ввод</button>
    </header>

    <table id="OperationTable" class="gridview">
      <thead>
        <tr class="grid-header">
          <th>Время</th>
          <th>Отгрузка</th>
          <th>Оператор</th>
        </tr>
      </thead>
      <tbody class="grid-pager">
        <!-- Динамические данные будут добавляться сюда -->
      </tbody>
    </table>
  </div>
  <div class="message"></div>
  <script src="/ConfigHandler.ashx"></script>
  <script src="./Java/ScanCar.js?v=4"></script>
  <script src="./Java/Messages.js?v=3"></script>
</body>
</html>
