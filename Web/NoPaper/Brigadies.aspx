<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Brigadies.aspx.cs" Inherits="NoPaper.Brigadies" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Бригады</title>

  <link rel="stylesheet" href="css/pages/brigadies.css" />
  <script src="Java/pages/brigadies.js"></script>
</head>

<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="sm1" runat="server" EnablePageMethods="true" />

<div class="layout">

    <!-- LEFT -->
    <div class="panel left">

        <h2>Группы</h2>

        <input id="groupName" class="input" placeholder="Название группы" />

        <select id="brigadierCreate" class="input"></select>

        <button type="button" class="btn" onclick="createGroup()">Добавить группу</button>

        <hr />

        <div id="groups"></div>

    </div>

    <!-- RIGHT -->
    <div class="panel right">

        <h2>Состав группы</h2>

        <div id="selectedGroupInfo" class="info">
            Группа не выбрана
        </div>

        <h3>В группе</h3>
        <div id="groupMembers"></div>

        <h3>Добавить операторов</h3>
        <select id="availableOperators" class="listbox" multiple></select>

        <input id="coef" class="input" placeholder="Коэффициент" />

        <button class="btn" type="button" onclick="addOperators()">Добавить</button>

    </div>

</div>

</form>
</body>
</html>