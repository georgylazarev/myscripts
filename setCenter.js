function setHeight(arg) {
  // Получаем высоту и ширину окна браузера
  var windowHeight = window.innerHeight;
  var windowWidth =  window.innerWidth;
  // Получаем высоту и ширину указанного элемента
  var blockHeight = document.getElementById(arg).offsetHeight;
  var blockWidth = document.getElementById(arg).offsetWidth;
  // Производим вычисления, для получения желаемых параметров
  var blockTop = (windowHeight - blockHeight) / 2;
  var blockLeft = (windowWidth - blockWidth) / 2;
  // Задаем параметры для элемента
  document.getElementById(arg).style.marginTop = blockTop + 'px';
  document.getElementById(arg).style.marginLeft = blockLeft + 'px';
}
  
