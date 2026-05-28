document.addEventListener("DOMContentLoaded", function () {

  OperatorList.init(
    "ddListPerson",
    "ddListBrigadier"
  );

});

const OperatorList = (function () {

  let ddOperator = null;
  let ddBrigadier = null;

  async function init(operatorSelectId, brigadierSelectId) {

    ddOperator = document.getElementById(operatorSelectId);
    ddBrigadier = document.getElementById(brigadierSelectId);

    ddBrigadier.addEventListener("change", onBrigadierChange);

    // если уже выбран
    if (ddBrigadier.value) {
      await onBrigadierChange();
    }
  }

  async function onBrigadierChange() {

    const brigadierId = parseInt(ddBrigadier.value);

    // ничего не выбрано
    if (!brigadierId) {
      return;
    }

    try {
      const res = await fetch(
        "WorkPlace.aspx/GetOperatorGroup",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            brigadierId: brigadierId
          })
        });

      if (!res.ok) {
        throw new Error("Request failed");
      }

      const json = await res.json();

      renderOperators(json.d);
    }
    catch (e) {
      console.error(e);
    }
  }

  function renderOperators(list) {

    const selectedValue = ddOperator.value;

    ddOperator.innerHTML = "";

    for (const item of list) {

      const opt = document.createElement("option");

      opt.value = item.ID;
      opt.text = item.Name;

      opt.setAttribute(
        "idsheduleoperator",
        item.idSheduleOperator || 0
      );

      opt.setAttribute(
        "data-coef",
        item.coef || 0
      );

      ddOperator.appendChild(opt);
    }

    // восстановить выбор
    if (selectedValue) {

      const exists = [...ddOperator.options].some(x => x.value === selectedValue);

      if (exists) {
        ddOperator.value = selectedValue;
      }
    }
  }

  return {
    init
  };

})();
