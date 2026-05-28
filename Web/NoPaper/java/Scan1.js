// Функция для повторной отправки запросов из failedRequests
const retryFailedRequests = async () =>
{
  // Получаем массив неудачных запросов из localStorage
  let failedRequests = JSON.parse(localStorage.getItem('failedRequests')) || [];

  // Если есть запросы в массиве, отправляем первый
  while (failedRequests.length > 0)
  {
    const { barcode, idOperator, idPyramidCompleted } = failedRequests[0];

    try
    {
      const response = await fetch('scan1.aspx/PostBarCode', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          barcode: barcode,
          idOperator: idOperator,
          idPyramidCompleted: idPyramidCompleted
        })
      });

      // Проверяем успешность запроса
      if (!response.ok) 
        throw new Error(`Error: ${response.status} ${response.statusText}`);

      // Удаляем успешно отправленный элемент из массива
      failedRequests.shift();

      UpdateDefectBarcodeCounter(failedRequests.length);
      // Обновляем localStorage
      localStorage.setItem('failedRequests', JSON.stringify(failedRequests));

      // Вызываем fetchScanLogs, если нужно обновить таблицу
      fetchScanLogs();
    }
    catch (error)
    {
      console.error('Erorr connecting', error);
      // Прерываем повторную отправку, чтобы не долбить сервер
      break;
    }
  }
}

// Устанавливаем таймер для проверки и повторной отправки каждые 10 секунд
setInterval(retryFailedRequests, 10000);

const BarcodeInput = async (event) => {
  if (event)
    event.preventDefault(); // Останавливаем стандартное поведение формы

  // Получаем значение из текстового поля BarCode
  const barCodeElement = document.getElementById('BarCode');
  const barCodeText = barCodeElement?.value || '';

  // Получаем выбранное значение из выпадающего списка Operator
  const operatorDropdown = document.getElementById('Operator');
  const selectedOperator = operatorDropdown
    ? parseInt(operatorDropdown.options[operatorDropdown.selectedIndex].value, 10) || 0
    : 0;

  // Получаем idPyramidCompleted из LocalStorage
  let idPyramidCompleted = parseInt(localStorage.getItem('idPyramidCompleted'), 10) || 0;

  if (!barCodeText) return;

  // Получаем массив failedRequests
  let failedRequests = JSON.parse(localStorage.getItem('failedRequests')) || [];

  if ( failedRequests.length > 0 ) {
    failedRequests.push({
      barcode: barCodeText,
      idOperator: selectedOperator,
      idPyramidCompleted: idPyramidCompleted
    });

    UpdateDefectBarcodeCounter(failedRequests.length);

    localStorage.setItem('failedRequests', JSON.stringify(failedRequests));
    return;
  } 
  
  try {
    const response = await fetch('scan1.aspx/PostBarCode', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        barcode: barCodeText,
        idOperator: selectedOperator,
        idPyramidCompleted: idPyramidCompleted
      })
    });

    if (!response.ok) 
      throw new Error(`Error: ${response.status} ${response.statusText}`);

    const data = await response.json();
    const jsonStr = data.d;

    const textInfoElement = document.getElementById('TextInfo');
    if (textInfoElement) textInfoElement.innerText = jsonStr.message;

    // Устанавливаем оператора, если он изменился
    if (selectedOperator !== jsonStr.idOperator && jsonStr.idOperator !== 0) {
      operatorDropdown.value = jsonStr.idOperator;
    }

    localStorage.setItem('idPyramidCompleted', jsonStr.idPyramidCompleted);

    // Вывод в таблицу отскарованных штрихкодов, всего что успешно обработано
    if (jsonStr.typeBarCode !== 0)
    {
      const row =
      {
        TimeScan: new Date().toISOString(),
        ScanText: barCodeText
      };

      renderScanTable(row);
    }

    await fetchScanLogs(); // Отрисуем таблицу

    // отсканирована транспотрная пирамида
    if (jsonStr.typeBarCode === 2)
    {
      const ScanTextValue = document.getElementById('pyramid-complete-barcode-now');
      if (ScanTextValue) ScanTextValue.innerText = barCodeText;
    }

    if (jsonStr.currentMassIsBigger && textInfoElement)
      if (jsonStr.m_dPyramidMaxWeight > 0)
        textInfoElement.innerText += `\r\n Текущая масса ${jsonStr.m_dCurrentWeight} превышает допустимую массу пирамиды ${jsonStr.m_dPyramidMaxWeight}`;

    barCodeElement.value = '';
    barCodeElement.focus();

  } catch (error) {
    console.error('Error for post barcode:', error);

    let failedRequests = JSON.parse(localStorage.getItem('failedRequests')) || [];
    failedRequests.push({
      barcode: barCodeText,
      idOperator: selectedOperator,
      idPyramidCompleted: idPyramidCompleted
    });

    barCodeElement.value = '';
    barCodeElement.focus();
    UpdateDefectBarcodeCounter(failedRequests.length);

    // Записываем обновленный массив в LocalStorage
    localStorage.setItem('failedRequests', JSON.stringify(failedRequests));
  }
};


const PyramidToShip = async (event) => {
  if (event)
    event.preventDefault(); // Останавливаем стандартное поведение формы

  const barCodeElement = document.getElementById('BarCode');

  // Получаем idPyramidCompleted из LocalStorage
  const idPyramidCompleted = parseInt(localStorage.getItem('idPyramidCompleted'), 10) || 0;

  try
  {
    const response = await fetch('scan1.aspx/PostPyramidCompleteToShip', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        idPyramidComplete: idPyramidCompleted
      })
    });

    if (!response.ok)
      throw new Error(`Ошибка при отправке PostPyramidCompleteToShip`);


    const data = await response.json();
    const jsonStr = data.d;

    const textInfoElement = document.getElementById('TextInfo');
    if (textInfoElement) textInfoElement.innerText = jsonStr.message;

    // Сбрасываем idPyramidComplete
    localStorage.setItem('idPyramidCompleted', jsonStr.idPyramidCompleted);

    clearScanLogsTable();

    barCodeElement.value = '';
    barCodeElement.focus();

  } catch (error) {
    console.error('Error for post barcode:', error);

    barCodeElement.value = '';
    barCodeElement.focus();
  }
};

document.getElementById('ButBegin')?.addEventListener('click', BarcodeInput);
document.getElementById('PyramidToShip')?.addEventListener('click', PyramidToShip);

// Событие нажатия на кнопку Enter
document.addEventListener("DOMContentLoaded", () => {
  const barcodeInput = document.getElementById("BarCode");
  const submitButton = document.getElementById("ButBegin");

  const rules = window.appConfig.rules;

  function matchHardcode(value)
  {
    if (rules.length > 0) {
      const v = value.trim().toUpperCase();
      return rules.some(r => v.startsWith(r.prefix) && v.length === r.length);
    }
  }

  // Нажатие Enter в поле ввода вызывает BarcodeInput
  barcodeInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
      event.preventDefault(); // Останавливаем стандартное поведение
      BarcodeInput(event);
    }
  });

  // Автовызов по хардкоду
  barcodeInput.addEventListener("input", () => {
    if (matchHardcode(barcodeInput.value)) {
      BarcodeInput();
    }
  });

  let failedRequests = JSON.parse(localStorage.getItem('failedRequests')) || [];
  UpdateDefectBarcodeCounter(failedRequests.length);

  // Клик по кнопке вызывает BarcodeInput
  submitButton.addEventListener("click", BarcodeInput);
});

const fetchScanLogs = async () => {
  try
  {
    const response = await fetch('scan1.aspx/GetScanLogs', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    });

    const data  = await response.json();
    let jsonStr = JSON.parse(data.d); // предполагаем, что данные вложены в свойство d

    // Обновление таблицы на HTML
    const table = document.querySelector('.gridview');
    const tbody = table.querySelector('tbody');
    tbody.innerHTML = ''; // Очистка существующих строк

    const textInfo = document.getElementById('ScanTextValue');
    if (textInfo) textInfo.innerText = jsonStr.length;

    jsonStr.forEach(row => {
      const tr = document.createElement('tr');
      tr.classList.add("grid-row");

      // Создание и заполнение ячеек
      const timeScanCell = document.createElement('td');
      const dateObj = new Date(row.TimeScan);
      const formattedDate = `${dateObj.toLocaleDateString()} ${dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;

      timeScanCell.textContent = formattedDate;
      tr.appendChild(timeScanCell);

      const scanTextCell = document.createElement('td');
      scanTextCell.textContent = row.ScanText;
      tr.appendChild(scanTextCell);

      const accountNumCell = document.createElement('td');
      accountNumCell.textContent = row.AccountNum;
      tr.appendChild(accountNumCell);

      tbody.appendChild(tr);
    });

  } catch (error)
  {
    console.error('Error fetching scan logs:', error);
  }
};

const clearScanLogsTable = () => {
  const table = document.querySelector('.gridview');
  const tbody = table.querySelector('tbody');

  tbody.innerHTML = '';
};

// Отрисовка таблицы
const renderScanTable = (row) => {
  let table = document.getElementById('scannedBarcodesTable');

  // Если таблицы нет — создаём
  if (!table) {
    table                      = document.createElement('table');
    table.id                   = 'scannedBarcodesTable';
    table.className            = 'temp-gridview';

    // Первая строка — заголовок
    const headerRow = document.createElement('tr');
    headerRow.classList.add('grid-header');

    const thTime = document.createElement('th');
    thTime.textContent = 'Время сканирования';
    headerRow.appendChild(thTime);

    const thCode = document.createElement('th');
    thCode.textContent = 'Штрих-код';
    headerRow.appendChild(thCode);

    table.appendChild(headerRow);

    document.body.appendChild(table);
  }

  // Добавляем строку с данными
  const tr = document.createElement('tr');
  tr.classList.add('.grid-row');

  const timeScanCell = document.createElement('td');
  const dateObj = new Date(row.TimeScan);
  const formattedDate = `${dateObj.toLocaleDateString()} ${dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
  timeScanCell.textContent = formattedDate;
  tr.appendChild(timeScanCell);

  const scanTextCell = document.createElement('td');
  scanTextCell.textContent = row.ScanText;
  tr.appendChild(scanTextCell);

  table.appendChild(tr);
};

const UpdateDefectBarcodeCounter = (count) => {
  const counter = document.querySelector('.count-failed-barcode');

  if (count === 0) {
    counter.classList.add('hide');
    return;
  }

  if (counter.classList.contains('hide'))
    counter.classList.remove('hide');

  if (counter) 
    counter.innerText = `Штрихкодов в очереди: ${count}`;
};

