document.addEventListener("DOMContentLoaded", function () {
  loadHistory();

  document.getElementById("btnSearch")
    .addEventListener("click", loadHistory);
});

async function loadHistory() {
  try {
    const request =
    {
      dateFrom: document.getElementById("dateFrom").value,
      dateTo: document.getElementById("dateTo").value,
      type: parseInt(document.getElementById("typeFilter").value)
    };

    const response = await fetch("ScanHistory.aspx/GetHistory",
      {
        method: "POST",
        headers:
        {
          "Content-Type": "application/json; charset=utf-8"
        },
        body: JSON.stringify(request)
      });

    const data = await response.json();

    renderHistory(data.d);
  }
  catch (e) {
    console.error(e);
    alert("Ошибка загрузки истории");
  }
}

function renderHistory(items) {
  const tbody = document.getElementById("historyBody");

  let html = "";

  for (let i = 0; i < items.length; i++) {
    const item = items[i];

    html += `
      <tr>
        <td>${item.DateScan}</td>
        <td>${item.IDOperator}</td>
        <td class="barcode">${item.BarCode}</td>
        <td>
          <span class="type-badge type-${item.TypeBarCode}">
            ${item.TypeName}
          </span>
        </td>
        <td>${item.Message ?? ""}</td>
      </tr>
    `;
  }

  tbody.innerHTML = html;
}
