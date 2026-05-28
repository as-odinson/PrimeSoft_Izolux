<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="workplace.aspx.cs" Inherits="NoPaper.workplace" Async="true" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>Рабочее место</title>
  <link rel="stylesheet" type="text/css" href="~/css/styles.css?v=4" />
  <link rel="stylesheet" type="text/css" href="~/css/header.css?v=5" />
  <link rel="stylesheet" type="text/css" href="~/css/navigation.css?v=3" />
  <link rel="stylesheet" type="text/css" href="~/css/workplace.css?v=9" />
  <link rel="stylesheet" type="text/css" href="~/css/grid.css?v=11" />
  <link rel="stylesheet" type="text/css" href="~/css/remakeModal.css?v=6" />
  <link rel="stylesheet" type="text/css" href="~/css/message.css?v=6" />
  <link rel="stylesheet" type="text/css" href="~/css/draw.css?v=9" />
</head>
<body>
  <form class="form" id="form1" runat="server">
    <nav>
      <ul class="links-items">
        <li>
          <asp:HyperLink runat="server" NavigateUrl="~/workplace.aspx" Text="Рабочее место" CssClass="link active" />
        </li>
        <li>
          <asp:HyperLink runat="server" NavigateUrl="~/ScanBarCodes.aspx" Text="Сканирование" CssClass="link" />
        </li>
        <li>
          <asp:HyperLink runat="server" NavigateUrl="~/SawPlan.aspx" Text="План работы" CssClass="link" />
        </li>
        <li>
          <asp:HyperLink runat="server" NavigateUrl="~/TaskSearchInfo.aspx" Text="Поиск по заказам" CssClass="link" />
        </li>
        <li>
          <asp:HyperLink runat="server" NavigateUrl="~/Defect.aspx" Text="Брак" CssClass="link" />
        </li>
      </ul>
    </nav>
    <header>
      <div class="header-item">
        Оптимизация
        <asp:TextBox ID="SawTaskTxtInput" runat="server" Placeholder="номер оптимизации"/>
      </div>
      <div class="header-item">
        Бригадир
        <asp:DropDownList runat="server" ID="ddListBrigadier" ClientIDMode="Static" />
      </div>
      <div class="header-item">
        Оператор
        <asp:DropDownList runat="server" ID="ddListPerson" ClientIDMode="Static" OnSelectedIndexChanged="ddListPerson_SelectedIndexChanged" AutoPostBack="true" onchange="saveCurrentOperator(this)" />
      </div>

      <asp:ScriptManager runat="server" EnablePageMethods="true" />
      <asp:UpdatePanel runat="server" UpdateMode="Conditional">
        <ContentTemplate>
          <div class="header-item update-panel">
            <div class="item">
              Участок
              <asp:DropDownList
                ID="ddListSector"
                runat="server"
                DataTextField="Name"
                DataValueField="ID"
                OnSelectedIndexChanged="ddListSector_SelectedIndexChanged"
                AutoPostBack="true" />
            </div>
            <div class="item">
              Оборудование
              <asp:DropDownList
                ID="ddListEquipment"
                runat="server"
                DataTextField="Name"
                DataValueField="ID"
                CssClass="ddList" />
            </div>
          </div>
        </ContentTemplate>
        <Triggers>
          <asp:AsyncPostBackTrigger ControlID="ddListSector" EventName="SelectedIndexChanged" />
        </Triggers>
      </asp:UpdatePanel>
     
      <div class="header-item">
          <label for="operationSelect">Переход:</label>
          <asp:DropDownList ID="operationSelect" runat="server">
            <asp:ListItem Value="in">вход</asp:ListItem>
            <asp:ListItem Value="out">выход</asp:ListItem>
            <asp:ListItem Value="in-out">вход-выход</asp:ListItem>
          </asp:DropDownList>
      </div>
      <div class="header-item">
        <asp:Label runat="server" AssociatedControlID="BarCodeTxtInput">Штрих код:</asp:Label>
        <asp:TextBox ID="BarCodeTxtInput" runat="server" Placeholder="Штрих код" onkeypress="handleBarCodeInput(event, this)" oninput="handleBarCodeInput(event, this)"/>
      </div>
      <div class="header-item">
        <asp:Button ID="ButBegin" runat="server" OnClick="ButBegin_Click" Text="Начать работу" OnClientClick="clearActiveTextBox();" />
      </div>
    </header>

    <section class="pyramid-draw">
      <div class="pyramid-draw-section">
        <section class="pyramid-take">
          <span class="side-num_text">1</span>
          <div class="pyramid-items">
          </div>
          <span class="side-two side-num_text">2</span>
        </section>

          <section class="pyramid-put">
            <span class="side-num_text">1</span>
            <div class="pyramid-items">      
            </div>
            <span class="side-two side-num_text">2</span>
          </section>
        </div>
    </section>

    <main>
      <div class="flex-center">
        <asp:GridView
          ID="GridOperReady"
          runat="server"
          DataKeyNames="idGlassProcessingPyramid,idSawTaskMain"
          AutoGenerateColumns="False"
          OnRowCommand="GridOperReady_RowDataBound"
          CssClass="grid grid_additional-top">
          <Columns>
            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                  <span title="Оптимизация">Опт.</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" Text='<%# Eval("NameSawTask") %>' />
              </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>Изделия</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" Text='<%# Eval("NameGlassProduct") %>' />
              </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>Пирамида</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" Text='<%# Eval("PiramidNum") %>' />
              </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>Штрих код</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" Text='<%# Eval("CurrentPyramidBarCode") %>' />
              </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>Отправлена</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" Text='<%# Eval("ReadyDateTime") %>' />
              </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>Из участка</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" Text='<%# Eval("NameSectorManufact") %>' />
              </ItemTemplate>
            </asp:TemplateField>
            <asp:ButtonField Text="Забрал" ButtonType="Button" CommandName="OnTookPyramid" HeaderStyle-CssClass="grid-header-item" />
          </Columns>
        </asp:GridView>
      </div>

      <div class="flex-center">
        <asp:GridView
          ID="GridOper"
          runat="server"
          DataKeyNames="idGlassDetails"
          AutoGenerateColumns="False"
          OnRowCommand="GridOper_RowCommand"
          OnRowDataBound="GridOper_RowDataBound"
          AllowSorting="true"
          OnSorting="GridOper_Sorting"
          CssClass="grid grid_additional-top">
          <Columns>
            <asp:TemplateField SortExpression="SawTask" HeaderText="Оптимизация" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <div>
                  <asp:LinkButton runat="server" CommandName="Sort" CommandArgument="NameSawTask" OnClientClick="showHideSortArrow(this)">
                    <span title="Оптимизация" class="span-arrow">№ оптим.</span>
                    <div id="NameSawTask" class="arrow">
                      <span class="arrow-left"></span>
                      <span class="arrow-right"></span>
                    </div>
                  </asp:LinkButton>
                </div>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="NameSawTask" Text='<%# Eval("NameSawTask") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>чертёж</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:HyperLink
                  runat="server"
                  ID="OpenPlot"
                  Text="чертёж"
                  CssClass="item_plot__button"
                  Visible="false" />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>Оборудование</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="NameEquipment" Text='<%# Eval("NameEquipment") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField SortExpression="ItemName" HeaderText="Изделие" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <div>
                  <asp:LinkButton runat="server" CommandName="Sort" CommandArgument="NameGlassProduct" OnClientClick="showHideSortArrow(this)">
                    <span class="span-arrow">Изделие</span>
                      <div id="NameGlassProduct" class="arrow">
                        <span class="arrow-left"></span>
                        <span class="arrow-right"></span>
                      </div>
                  </asp:LinkButton>
                </div>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="NameGlassProduct" Text='<%# Eval("NameGlassProduct") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>Заказ</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="AccountNum" Text='<%# Eval("AccountNum") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span title="Позиция заказа">Поз</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="ProjectNum" Text='<%# Eval("ProjectNum") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span title="Позиция сборки">Сборка N</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="SawOrder" Text='<%# Eval("SawOrder") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Размер" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                  <span>Размер</span>
              </HeaderTemplate>
              <ItemTemplate>
                <div class="flex-center" style="padding: 0 4px;">
                  <asp:Label runat="server" ID="Width" Text='<%# Eval("Width") %>' />
                  <span> x </span>
                  <asp:Label runat="server" ID="Height" Text='<%# Eval("Height") %>' />
                </div>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField SortExpression="TimeBeginProcessing" HeaderText="Время Начала" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <div>
                  <asp:LinkButton runat="server" CommandName="Sort" CommandArgument="TimeBeginProcessing" OnClientClick="showHideSortArrow(this)">
                    <span class="span-arrow">Время Начала</span>
                    <div id="TimeBeginProcessing" class="arrow">
                      <span class="arrow-left"></span>
                      <span class="arrow-right"></span>
                    </div>
                  </asp:LinkButton>
                </div>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="TimeBeginProcessing" Text='<%# Eval("TimeBeginProcessing") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="След. Участок" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span title="следующий участок">След. Участок</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label 
                  runat="server"
                  ID="SectorNext"
                  CssClass="grid-item__sector-manufact"
                  Text='<%# Eval("SectorNext") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span title="Количество" style="display: block; width: max-content;">Кол-во</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="ForCount" Text='<%# Eval("ForCount") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField SortExpression="PiramidNum" HeaderText="Пирамида" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <div>
                  <asp:LinkButton runat="server" CommandName="Sort" CommandArgument="PiramidNum" OnClientClick="showHideSortArrow(this)">
                    <span class="span-arrow">Пирамида</span>
                    <div id="PiramidNum" class="arrow">
                      <span class="arrow-left"></span>
                      <span class="arrow-right"></span>
                    </div>
                  </asp:LinkButton>
                </div>
              </HeaderTemplate>
              <ItemTemplate>
                <div>
                  <asp:Label runat="server" ID="PiramidNumLabel" Text='<%# Eval("PiramidNum") %>' Visible="false" />
                  <asp:Button runat="server" ID="MakePyramidButton" Text="Готова" ButtonType="Button" CommandName="OnMakePyramid" CommandArgument='<%# Eval("idGlassProcessingPyramid") + "_" + Eval("idBarCode") %>' Visible="false" />
                </div>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Штрих код пред. пирамиды" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span title="Штрих код предыдущей пирамиды">Штрих код пред. пирамиды</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="PreviousPyramidBarCode" Text='<%# Eval("PreviousPyramidBarCode") %>' Visible="false" />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Штрих код пирамиды" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>Штрих код пирамиды</span>
              </HeaderTemplate>
              <ItemTemplate>
                <div class="grid-item__pyramid-barcode">
                  <asp:TextBox
                    runat="server"
                    ID="CurrentPyramidBarCode"
                    value='<%# Eval("CurrentPyramidBarCode") %>'
                    CssClass="pyramid-barcode__input"
                    Visible="false"
                    onkeypress="if (event.keyCode === 13) handlePyramidBarCodeFetch(event, this)"
                    data-sidglass= '<%# Eval("IdGlassProcessingPyramid") %>'
                    data-idbarcode='<%# Eval("IdBarCode") %>'
                    data-idPyramid='<%# Eval("idPiramid") %>'
                    data-idSector ='<%# Eval("idSectorManufact") %>'
                    data-rowindex='<%# Container.DataItemIndex %>'/>

                  <asp:Button
                    runat="server"
                    ID="WritePyramidBarCodeButton"
                    Text="изменить"
                    ButtonType="Button"
                    CssClass="pyramid-barcode__button"
                    CommandName="OnWritePyramidBarCode"
                    CommandArgument='<%# Eval("idGlassProcessingPyramid") + "_" + Eval("idBarCode") + "_" + Eval("idPiramid") + "_" + Eval("idSectorManufact") %>'
                    Visible="false" />
                </div>
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Сторона" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                  <span>Сторона</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="PiramidSide" Text='<%# Eval("PiramidSide") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Пачка" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                  <span>Пачка</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="nPack" Text='<%# Eval("nPack") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Ячейка" HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>Ячейка</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="PiramidCell" Text='<%# Eval("PiramidCell") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>№ в пачке взять</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="nGlassInPackTake" Text='<%# Eval("nGlassInPackTake") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <HeaderTemplate>
                <span>№ в пачке поставить</span>
              </HeaderTemplate>
              <ItemTemplate>
                <asp:Label runat="server" ID="nGlassInPack" Text='<%# Eval("nGlassInPack") %>' />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <ItemTemplate>
                <asp:Button runat="server" ID="MakeOperButton" Text="Готова" ButtonType="Button" CommandName="OnMakeOper" HeaderStyle-CssClass="grid-header-item" />
                <asp:Button runat="server" 
                            ID="InfoRemakeButton" 
                            CssClass="info-button"
                            Text="Инфо" 
                            ButtonType="Button" 
                            CommandName="OnGetRemakeInfo" 
                            Visible="false"
                            HeaderStyle-CssClass="grid-header-item" />
              </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderStyle-CssClass="grid-header-item">
              <ItemTemplate>
                <asp:Button runat="server" ID="MakeDefectButton" Visible="false" Text="Брак" ButtonType="Button" CssClass="defect-button" />
              </ItemTemplate>
            </asp:TemplateField>

          </Columns>
        </asp:GridView>
      </div>
    </main>
    <div class="modal" id="remakeInfo" tabindex="-1" role="dialog" aria-labelledby="modalHeading" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <div class="modal-header__items">
              <div class="modal-header__item">
                <h5 class="modal-title" id="modalHeading">Информация о переделке <span class="item-info" id="GPName"></span></h5>
              </div>
              <div class="modal-header__item">
                <h5 class="modal-title">Размер <span class="item-info" id="SWidth"></span>&times<span class="item-info" id="SHeight"></span></h5>
              </div>
              <div class="modal-header__items">
                <h5 class="modal-title">Расположение: <span class="item-info" id="SectorName"></span></h5>
              </div>
            </div>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body" id="modalBodyContent">
            <div class="modal-body__items">
              <div class="modal-body__item">
                Заказ: <span class="item-info" id="AccountName"></span>
              </div>
              <div class="modal-body__item">
                Дата заказа: <span class="item-info" id="TaskDate"></span>
              </div>
            </div>
            <div class="modal-body__items">
              <div class="modal-body__item">
                Оптимизация №: <span class="item-info" id="SawTaskName"></span>
              </div>
              <div class="modal-body__item">
                Дата <span class="item-info" id="SawTaskDate"></span>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <div class="modal-footer__items">
              <div class="modal-footer__item">
                Количество №: <span class="item-info" id="nCount"></span>
              </div>
              <div class="modal-footer__item">
                Площадь <span class="item-info" id="Area"></span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div id="rejectModal">
      <div id="rejectModalContent">
        <button id="closeRejectBtn"
          type="button"
          onclick="closeRejectModal(); return false;">
          ✕
   
        </button>

        <iframe id="rejectFrame"></iframe>
      </div>
    </div>

    <asp:SqlDataSource ID="SqlDSOper" runat="server" ConnectionString="<%$ ConnectionStrings:GLASSConnectionString %>" />
  </form>
  <div class="message"></div>
  <script src="/ConfigHandler.ashx"></script>
  <script src="./Java/ShowArrow.js?v=2" defer="defer"></script>
  <script src="./Java/PyramidBarCode.js?v=28"></script>
  <script src="./Java/RemakeModal.js?v=7"></script>  
  <script src="./Java/Draw.js?v=16"></script>
  <script src="./Java/Messages.js?v=3"></script>
  <script src="./Java/Component/OperatorList.js?v=2"></script>
</body>
</html>
