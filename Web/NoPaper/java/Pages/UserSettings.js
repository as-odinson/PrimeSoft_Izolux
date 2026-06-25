let state = {
  users: [],
  groups: [],
  permissions: [],
  selectedType: null,
  selectedId: null,
  detail: null
};

document.addEventListener('DOMContentLoaded', init);

async function init() {
  const data = await post('GetInitialData', {});
  state.users = data.Users || [];
  state.groups = data.Groups || [];
  state.permissions = data.Permissions || [];

  renderLists();

  document.getElementById('btnSave').addEventListener('click', saveCurrent);
  document.getElementById('btnDelete').addEventListener('click', deleteCurrent);
  document.getElementById('btnAddGroup').addEventListener('click', addGroup);
  document.getElementById('btnAddUser').addEventListener('click', addUser);
}

async function post(method, data) {
  const res = await fetch(`UserSettings.aspx/${method}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify(data)
  });

  const json = await res.json();
  return json.d;
}

function renderLists() {
  renderList('usersList', state.users, 'user');
  renderList('groupsList', state.groups, 'group');
}

function renderList(containerId, items, type) {
  const container = document.getElementById(containerId);
  container.innerHTML = '';

  items.forEach(item => {
    const el = document.createElement('button');
    el.type = 'button';
    el.className = 'list-item';

    if (state.selectedType === type && state.selectedId === item.ID)
      el.classList.add('active');

    el.innerHTML = `
      <span class="item-title">${escapeHtml(item.Name || '')}</span>
      <span class="item-sub">${escapeHtml(item.SubText || '')}</span>
    `;

    el.addEventListener('click', () => selectItem(type, item.ID));

    container.appendChild(el);
  });
}

async function selectItem(type, id) {
  state.selectedType = type;
  state.selectedId = id;

  if (type === 'user')
    state.detail = await post('GetUser', { id });
  else
    state.detail = await post('GetGroup', { id });

  renderLists();
  renderEditor();
}

function renderEditor() {
  const editor = document.getElementById('editor');
  const title = document.getElementById('editorTitle');

  document.getElementById('btnSave').disabled = false;
  document.getElementById('btnDelete').disabled = false;

  if (!state.detail) {
    editor.className = 'editor empty';
    editor.innerHTML = 'Ничего не выбрано';
    return;
  }

  const isUser = state.selectedType === 'user';

  title.textContent = isUser
    ? `Пользователь: ${state.detail.Name}`
    : `Группа: ${state.detail.Name}`;

  editor.className = 'editor';

  editor.innerHTML = `
    <div class="section">
      <h3>Основное</h3>

      <label>
        <span>Имя</span>
        <input id="fieldName" value="${escapeAttr(state.detail.Name || '')}" />
      </label>

      ${isUser ? `
        <label>
          <span>Ответственный менеджер</span>
          <input id="fieldManagerName" value="${escapeAttr(state.detail.ManagerName || '')}" />
        </label>

        <label>
          <span>Должность</span>
          <input id="fieldPost" value="${escapeAttr(state.detail.Post || '')}" />
        </label>

        <label>
          <span>Телефон</span>
          <input id="fieldTel" value="${escapeAttr(state.detail.Tel || '')}" />
        </label>

        <label>
          <span>Группа</span>
          <select id="fieldGroup">
            <option value="">Без группы</option>
            ${state.groups.map(g => `
              <option value="${g.ID}" ${state.detail.idUserGroup === g.ID ? 'selected' : ''}>
                ${escapeHtml(g.Name)}
              </option>
            `).join('')}
          </select>
        </label>

        <label class="check-row">
          <input id="fieldUseGroup" type="checkbox" ${state.detail.bUseGroupPermission ? 'checked' : ''} />
          <span>Использовать права группы</span>
        </label>
      ` : `
        <label>
          <span>Комментарий</span>
          <textarea id="fieldCommentary">${escapeHtml(state.detail.Commentary || '')}</textarea>
        </label>
      `}
    </div>

    <div class="section">
      <h3>Права</h3>
      ${renderPermissions()}
    </div>
  `;
}

function renderPermissions() {
  const groups = {};

  state.permissions.forEach(p => {
    if (!groups[p.Group])
      groups[p.Group] = [];

    groups[p.Group].push(p);
  });

  return Object.keys(groups).map(groupName => `
    <div class="perm-group">
      <div class="perm-group-title">${escapeHtml(groupName)}</div>
      <div class="perm-list">
        ${groups[groupName].map(p => `
          <label class="perm">
            <input type="checkbox"
                   data-permission="${escapeAttr(p.Name)}"
                   ${state.detail.Permissions && state.detail.Permissions[p.Name] ? 'checked' : ''}>
            <span>${escapeHtml(p.Title)}</span>
          </label>
        `).join('')}
      </div>
    </div>
  `).join('');
}

function saveCurrent() {
  alert('Сохранение следующим шагом бахнем отдельно.');
}

function deleteCurrent() {
  alert('Удаление следующим шагом бахнем отдельно.');
}

function addGroup() {
  alert('Добавление группы следующим шагом.');
}

function addUser() {
  alert('Добавление пользователя следующим шагом.');
}

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function escapeAttr(value) {
  return escapeHtml(value);
}
