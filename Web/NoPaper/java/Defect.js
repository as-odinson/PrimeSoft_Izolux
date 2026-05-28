window.addEventListener('DOMContentLoaded', function () {
  // Проверяем параметр в URL
  const params = new URLSearchParams(window.location.search);
  if (params.get("mode") === "modal") {
    // Скрываем nav
    const nav = document.querySelector('nav');
    if (nav) nav.style.display = 'none';
  }
});