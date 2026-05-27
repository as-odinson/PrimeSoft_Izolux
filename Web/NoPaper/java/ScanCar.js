const BarcodeInput = async (event) => {
  try
  {
    if (event)
      event.preventDefault(); // Останавливаем стандартное поведение формы

    // Получаем значение из текстового поля BarCode
    const barCodeElement = document.getElementById('BarCode');
    const barCodeText = barCodeElement?.value || '';

    // Если штрихкод пуст
    if (!barCodeText) return;

    // Получаем выбранное значение из выпадающего списка Operator
    const operatorDropdown = document.getElementById('Operator');
    const selectedOperator = operatorDropdown
                           ? parseInt(operatorDropdown.options[operatorDropdown.selectedIndex].value, 10) || 0
                           : 0;

    const response = await fetch('ScanCar.aspx/PostBarCode', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        barcode: barCodeText,
        idOperator: selectedOperator
      })
    });

    // Ошибка выполнения запроса
    if (!response.ok)
    {
      ShowMessage("Ошибка обработки штрихкода", true);
      throw new Error(`Error: ${response.status} ${response.statusText}`);
    }

    const data    = await response.json();
    const jsonStr = data.d;

    const textInfoElement = document.getElementById('TextInfo');
    if (textInfoElement) // Краткий вывод информации
      textInfoElement.innerText = jsonStr.message;

    // Устанавливаем оператора, если он изменился
    if (selectedOperator !== jsonStr.idOperator && jsonStr.idOperator !== 0)
      operatorDropdown.value = jsonStr.idOperator;


    if (
          (jsonStr.Type === 4 || jsonStr.Type === 2)
          && !jsonStr.bHasError
       )
    {
      saveScan({
        barcode: barCodeText,
        operatorId: jsonStr.idOperator,
        time: new Date().toISOString()
      });
    }

    await fetchScanLogs(); // Отрисуем таблицу

    barCodeElement.value = '';
  }
  catch (error)
  {
    const barCodeElement = document.getElementById('BarCode');
    barCodeElement.value = '';
    console.error('Error for post barcode:', error);
  }
};

// Добавим прослушивание события на нажатие кнопки
document.getElementById('ButBegin')?.addEventListener('click', BarcodeInput);

// Событие нажатия на кнопку Enter
document.addEventListener("DOMContentLoaded", () => {
  const barcodeInput = document.getElementById("BarCode");
  const submitButton = document.getElementById("ButBegin");

  // Нажатие Enter в поле ввода вызывает BarcodeInput
  barcodeInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      event.preventDefault(); // Останавливаем стандартное поведение
      BarcodeInput(event);
    }
  });

  // Клик по кнопке вызывает BarcodeInput
  submitButton.addEventListener("click", BarcodeInput);
  fetchScanLogs();
});


const MAX_ITEMS = 30; // Полную историю ввести нет смысла, запоминаем просто последние 20 значений отгрузки
function saveScan(newItem) {
  let list = JSON.parse(localStorage.getItem("shipScans")) || [];

  list.unshift(newItem);

  if (list.length > MAX_ITEMS) 
    list = list.slice(0, MAX_ITEMS);

  localStorage.setItem("shipScans", JSON.stringify(list));
}

const fetchScanLogs = () => {
  try
  {
    // берём из localStorage
    let jsonStr = JSON.parse(localStorage.getItem("shipScans")) || [];

    // Обновление таблицы на HTML
    const table = document.querySelector('.gridview');
    const tbody = table.querySelector('tbody');
    tbody.innerHTML = '';

    const textInfo = document.getElementById('ScanTextValue');
    if (textInfo) textInfo.innerText = jsonStr.length;

    // получаем dropdown операторов
    const operatorDropdown = document.getElementById('Operator');

    jsonStr.forEach(row => {
      const tr = document.createElement('tr');
      tr.classList.add("grid-row");

      // --- ВРЕМЯ ---
      const timeScanCell = document.createElement('td');
      const dateObj = new Date(row.time);

      const formattedDate = `${dateObj.toLocaleDateString()} ${dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
      timeScanCell.textContent = formattedDate;

      tr.appendChild(timeScanCell);

      // --- ШТРИХКОД ---
      const scanTextCell = document.createElement('td');
      scanTextCell.textContent = row.barcode;

      tr.appendChild(scanTextCell);

      // --- ОПЕРАТОР (текст из select) ---
      const operatorCell = document.createElement('td');

      let operatorText = row.operatorId;

      if (operatorDropdown) {
        const option = Array.from(operatorDropdown.options)
          .find(opt => parseInt(opt.value, 10) === row.operatorId);

        if (option)
          operatorText = option.text;
      }

      operatorCell.textContent = operatorText;

      tr.appendChild(operatorCell);

      tbody.appendChild(tr);
    });

  }
  catch (error) {
    console.error('Error loading scan logs:', error);
  }
};
