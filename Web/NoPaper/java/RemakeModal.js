document.addEventListener('DOMContentLoaded', function () {
  const modal       = document.querySelector('.modal');
  const closeButton = modal   .querySelector('.close');

  // Закрытие формы при нажатии на затемненную область и на кнопку закрыть
  modal.addEventListener('click', (e) =>
  {
    e.stopPropagation();
    HideRemakeModal(modal);
  });
  closeButton.addEventListener('click', () => HideRemakeModal(modal));

  // На дочерних элементах выключаем события
  modal.querySelector('.modal-dialog').addEventListener('click', (e) =>
  {
    e.stopPropagation();
  });

  document.querySelectorAll('.info-button').forEach(button =>
  {
    button.addEventListener('click', function (event)
    {
      event.preventDefault();

      const commandArgument = this.getAttribute('data-argument');
      fetch('workplace.aspx/GetData',
            {
              method: 'POST',
              headers:
              {
                'Content-Type': 'application/json'
              },
              body: JSON.stringify({ argument: commandArgument })
            } 
           )
        .then(response =>
        {
          console.log(response);
          return response.json();
        })
        .then(data =>
        {
          const jsonStr    = data.d;
          const parsedData = JSON.parse(jsonStr); // Десериализуем JSON
          
          modal.querySelector("#GPName")     .textContent = parsedData.GPName;
          modal.querySelector("#AccountName").textContent = parsedData.AccountName;
          modal.querySelector("#TaskDate")   .textContent = formatDate(parsedData.TaskDate);
          modal.querySelector("#SectorName").textContent  = parsedData.SectorName;
          modal.querySelector("#SawTaskName").textContent = parsedData.SawTaskName;
          modal.querySelector("#SawTaskDate").textContent = formatDate(parsedData.SawTaskDate);
          modal.querySelector("#nCount")     .textContent = parsedData.nCount;
          modal.querySelector("#SWidth")     .textContent = parsedData.Width;
          modal.querySelector("#SHeight")    .textContent = parsedData.Height;
          modal.querySelector("#Area")       .textContent = parsedData.Area;

          ShowRemakeModal(modal);
        })
        .catch(error => console.error('Ошибка при выполнении запроса:', error));
    });
  });


});

function formatDate(dateString) {
  if (!dateString) 
    return '';
  
  const date  = new Date(dateString);
  const day   = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0'); // Месяцы начинаются с 0
  const year  = date.getFullYear();
  return `${day}/${month}/${year}`;
}

function ShowRemakeModal(dialog)
{
  dialog.classList.add('_show');
}

function HideRemakeModal(dialog)
{
  dialog.classList.remove('_show');
}

// Вешаем событие брака
document.querySelectorAll('.defect-button').forEach(button => {
  button.addEventListener('click', function (e) {
    e.preventDefault(); // отменяем PostBack
    openRejectModal(this);
  });
});

// клик именно по фону, также закрывает модальное окно брака
document.getElementById("rejectModal").addEventListener("click", function (e) {
  if (e.target === this) {
    closeRejectModal();
  }
});

// Открытие модального окна
function openRejectModal(btn) {
  const barcode = btn.getAttribute('data-argument');

  if (!barcode)
  {
    console.error("barcode не найден");
    return;
  }

  const frame = document.getElementById("rejectFrame");
  frame.src = "Defect.aspx?barcode=" + encodeURIComponent(barcode) + "&mode=modal";

  document.getElementById("rejectModal").style.display = "block";
}

// закрываем модальное окно
function closeRejectModal()
{
  document.getElementById("rejectModal").style.display = "none";
}
