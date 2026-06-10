let selectedGroupId = null;

// init

document.addEventListener("DOMContentLoaded", function () {
  loadGroups();
  loadBrigadiers();
});

// группы

function loadBrigadiers() {

  PageMethods.GetBrigadiers(function (res) {

    const sel = document.getElementById("brigadierCreate");
    sel.innerHTML = "";

    // пустое значение (чтобы не было автоселекта мусора)
    const empty = document.createElement("option");
    empty.value = "";
    empty.text = "-- выбрать бригадира --";
    sel.appendChild(empty);

    res.forEach(b => {

      const opt = document.createElement("option");
      opt.value = b.ID;
      opt.text = b.Name;

      sel.appendChild(opt);
    });
  });
}

function loadGroups() {
  PageMethods.GetGroups(function (res) {

    const container = document.getElementById("groups");
    container.innerHTML = "";

    res.forEach(g => {

      const div = document.createElement("div");
      div.className = "group-item";

      div.innerHTML =
        g.Name + " | " + (g.BrigadierName || "—");

      div.onclick = function () {
        selectGroup(g.ID, g.Name);
      };

      container.appendChild(div);
    });
  });
}

function selectGroup(id, name) {

  selectedGroupId = id;

  document.getElementById("selectedGroupInfo").innerText =
    "Группа: " + name;

  document.querySelectorAll(".group-item").forEach(x => {
    x.classList.remove("active");
  });

  event.target.classList.add("active");

  loadGroupDetails(id);
}

function loadGroupDetails(groupId) {

  PageMethods.GetGroupDetails(groupId, function (res) {

    renderMembers(res.members);
    renderAvailable(res.available);
  });
}

// рендер
function renderMembers(members) {

  const container = document.getElementById("groupMembers");
  container.innerHTML = "";

  members.forEach(m => {

    const row = document.createElement("div");
    row.className = "member" + (m.IsBrigadier ? " brigadier" : "");

    row.innerHTML =
      "<span>" +
      m.Name +
      (m.IsBrigadier ? " <span class='star'>★ бригадир</span>" : "") +
      "</span>" +
      "<div class='member-actions'>" +
      "<button class='btn-small' onclick='removeOperator(" + m.ID + ")'>Удалить</button>" +
      "<button class='btn-small' onclick='setBrigadier(" + m.ID + ")'>Сделать бригадиром</button>" +
      "</div>";

    container.appendChild(row);
  });
}

function renderAvailable(list) {

  const sel = document.getElementById("availableOperators");
  sel.innerHTML = "";

  list.forEach(o => {

    const opt = document.createElement("option");
    opt.value = o.ID;
    opt.text = o.Name;

    sel.appendChild(opt);
  });
}

// функционал

function createGroup() {

  const name = document.getElementById("groupName").value;
  const brigadierId = document.getElementById("brigadierCreate").value;

  if (!name || !brigadierId) return;

  PageMethods.CreateGroup(name, parseInt(brigadierId), function () {
    loadGroups();
  });
}

function addOperators() {

  if (!selectedGroupId) return;

  const coef = parseFloat(document.getElementById("coef").value || "1");

  const ops = getSelected("availableOperators");

  if (ops.length === 0) return;

  PageMethods.AddOperators(selectedGroupId, ops, coef, function () {
    loadGroupDetails(selectedGroupId);
  });
}

function removeOperator(id) {

  if (!selectedGroupId) return;

  PageMethods.DeleteOperators(selectedGroupId, [id], function () {
    loadGroupDetails(selectedGroupId);
  });
}

function setBrigadier(id) {

  if (!selectedGroupId) return;

  PageMethods.SetBrigadier(selectedGroupId, id, function () {
    loadGroupDetails(selectedGroupId);
  });
}

// Хелперы

function getSelected(selectId) {

  const sel = document.getElementById(selectId);

  var arr = [];

  for (var i = 0; i < sel.options.length; i++) {
    if (sel.options[i].selected) {
      arr.push(parseInt(sel.options[i].value));
    }
  }

  return arr;
}
